//  DeclinationPanel.swift
//  FieldGlanceWatch
//

import SwiftUI

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
        .onTapGesture { model.start() }
    }
}
