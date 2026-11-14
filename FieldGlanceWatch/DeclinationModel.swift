//
//  DeclinationModel.swift
//  FieldGlanceWatch
//
//  Gets one location fix and computes magnetic declination with WMM2025.
//

import Combine
import CoreLocation
import SwiftUI
import WidgetKit

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
        // Share with widget
        UserDefaults(suiteName: sharedGroupID)?.set(d, forKey: declKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "DeclComplication")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        status = "Location error"
    }
}

struct DeclinationPanel: View {
    @StateObject private var model = DeclinationModel()

    var body: some View {
        VStack(alignment: .leading) {
            if let d = model.declination {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(String(format: "%.1f° %@", abs(d), d >= 0 ? "E" : "W"))
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(d))
                }
            } else {
                Text(model.status)
            }
            Text(WMM.isValid(on: Date()) ? "DECLINATION · WMM2025" : "WMM2025 OUT OF DATE")
                .font(.caption2)
                .opacity(0.7)
            if let loc = model.location {
                let lat = String(format: "%@%.4f°", loc.latitude  < 0 ? "−" : "", abs(loc.latitude))
                let lon = String(format: "%@%.4f°", loc.longitude < 0 ? "−" : "", abs(loc.longitude))
                Text("(\(lat), \(lon))")
                    .font(.caption2)
                    .opacity(0.7)
            }
        }
        .font(Font.system(size: 36, weight: .semibold))
        .foregroundStyle(.green)
        .onAppear { model.start() }
    }
}
