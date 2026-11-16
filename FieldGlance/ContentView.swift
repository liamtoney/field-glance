//
//  ContentView.swift
//  FieldGlance
//

import SwiftUI

// Layout tuning:
//   50    clock date/time and declination value font
//   18    zone label, WMM label, coords font
//    4    spacing between lines within a panel
//   50    spacing between panels
//   36    horizontal padding
//   48    vertical padding
//    0.6  opacity for secondary text

private struct ClockPanel: View {
    let date: Date
    let zone: Zone
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(zone.dateFormatter.string(from: date))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.bottom, -10)
            Text(zone.timeFormatter.string(from: date))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: 18))
                .opacity(0.6)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .font(.system(size: 50, weight: .semibold, design: .monospaced))
        .foregroundStyle(color)
        .accessibilityElement(children: .combine)
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var model = DeclinationModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: 1)) { context in
                VStack(alignment: .leading, spacing: 50) {
                    ClockPanel(
                        date: context.date,
                        zone: localZone,
                        label: localLabel(for: localZone.timeZone, at: context.date),
                        color: .blue
                    )
                    ClockPanel(
                        date: context.date,
                        zone: utcZone,
                        label: "UTC",
                        color: .orange
                    )
                    // Declination panel sits outside TimelineView to avoid recreation every second
                    declinationPanel
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 48)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { model.start() }
        }
    }

    // Extracted so the @StateObject model isn't inside the TimelineView closure
    private var declinationPanel: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let d = model.declination {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(String(format: "%.1f° %@", abs(d), d >= 0 ? "E" : "W"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(d))
                }
            } else {
                Text(model.status)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Text(WMM.isValid(on: Date()) ? "DECLINATION • WMM2025" : "WMM2025 OUT OF DATE")
                .font(.system(size: 18))
                .opacity(0.6)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            if let loc = model.location {
                let lat = String(format: "%@%.4f°", loc.latitude  < 0 ? "−" : "", abs(loc.latitude))
                let lon = String(format: "%@%.4f°", loc.longitude < 0 ? "−" : "", abs(loc.longitude))
                Text("(\(lat), \(lon))")
                    .font(.system(size: 18))
                    .opacity(0.6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .font(.system(size: 50, weight: .semibold))
        .foregroundStyle(.green)
        .accessibilityElement(children: .combine)
        .onAppear { model.start() }
        .onTapGesture { model.start() }  // tap to refresh location, same as watch
    }
}

#Preview {
    ContentView()
}
