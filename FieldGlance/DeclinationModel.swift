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
    @Published var status = "Locating…"

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        // Declination changes very little over kilometers, so a coarse fix is plenty
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func start() {
        switch manager.authorizationStatus {
        case .notDetermined:
            // The authorization callback below requests the location once allowed
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            status = "No location access"
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            status = "No location access"
        default:
            break
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
        // Share with widget (watchOS only!)
        #if os(watchOS)
        UserDefaults(suiteName: sharedGroupID)?.set(d, forKey: declKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "DeclComplication")
        #endif
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        status = "Location error"
    }
}
