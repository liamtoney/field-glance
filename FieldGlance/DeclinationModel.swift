//
//  DeclinationModel.swift
//  FieldGlance
//
//  Gets one location fix and computes magnetic declination with WMM2025.
//

import Combine
import CoreLocation

#if os(watchOS)
    import WidgetKit
#endif

final class DeclinationModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var declination: Double?  // degrees, east positive
    @Published var location: CLLocationCoordinate2D?
    @Published var status = "Locating..."

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        // Declination changes very little over kilometers, so a coarse fix is plenty
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func start() {
        handleAuthorization(manager.authorizationStatus, prompt: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization(manager.authorizationStatus, prompt: false)
    }

    /// Requests a fix if allowed. With `prompt`, asks for permission if not yet determined.
    private func handleAuthorization(_ authorization: CLAuthorizationStatus, prompt: Bool) {
        switch authorization {
        case .notDetermined:
            // The authorization callback requests the location once allowed
            if prompt { manager.requestWhenInUseAuthorization() }
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            fail("No location access")
        @unknown default:
            fail("No location access")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let fix = locations.last else { return }
        // WMM wants height above the WGS84 ellipsoid, in km
        let heightKm = fix.verticalAccuracy >= 0 ? fix.ellipsoidalAltitude / 1000 : 0
        let d = WMM.declination(
            latitude: fix.coordinate.latitude,
            longitude: fix.coordinate.longitude,
            heightKm: heightKm,
            date: Date()
        )
        declination = d
        location = fix.coordinate
        publishToWidget(d)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        fail("Location error")
    }

    private func fail(_ message: String) {
        status = message
        location = nil
        declination = nil
        publishToWidget(nil)
    }

    /// Shares the declination with the complication (watchOS only!). Nil clears it.
    private func publishToWidget(_ value: Double?) {
        #if os(watchOS)
            let defaults = UserDefaults(suiteName: sharedGroupID)
            if let value {
                defaults?.set(value, forKey: declKey)
            } else {
                defaults?.removeObject(forKey: declKey)
            }
            WidgetCenter.shared.reloadTimelines(ofKind: declWidgetKind)
        #endif
    }
}
