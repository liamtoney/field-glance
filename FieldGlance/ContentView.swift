//
//  ContentView.swift
//  FieldGlance
//

import SwiftUI

// Layout tuning:
//    4    spacing between lines within a panel
//   50    spacing between panels
//   36    horizontal padding
//   48    vertical padding
//    0.6  opacity for secondary text

// Zone label, WMM label, coords font
private let subFont = Font.system(size: 18)
// Clock date/time and declination value font
private let bigFontSize: CGFloat = 48

private struct ClockPanel: View {
    let date: Date
    let zone: Zone
    let label: String
    let color: Color
    var secondaryOpacity: Double = 0.6

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(zone.dateFormatter.string(from: date))
                .lineLimit(1)
                .padding(.bottom, -10)
            Text(zone.timeFormatter.string(from: date))
                .lineLimit(1)
            Text(label)
                .font(subFont)
                .opacity(secondaryOpacity)
                .lineLimit(1)
        }
        .font(.system(size: bigFontSize, weight: .semibold, design: .monospaced))
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
                        color: .blue,
                        secondaryOpacity: 0.7  // Slightly stronger for blue
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
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    // Extracted so the @StateObject model isn't inside the TimelineView closure
    private var declinationPanel: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let d = model.declination {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(declinationString(d))
                        .lineLimit(1)
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(d))
                        .accessibilityHidden(true)
                }
            } else {
                Text(model.status)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Text(WMM.isValid(on: Date()) ? wmmLabel : wmmExpiredLabel)
                .font(subFont)
                .opacity(0.6)
                .lineLimit(1)
            if let loc = model.location {
                Text(coordinateString(lat: loc.latitude, lon: loc.longitude))
                    .font(subFont)
                    .opacity(0.6)
                    .lineLimit(1)
            }
        }
        .font(.system(size: bigFontSize, weight: .semibold))
        .foregroundStyle(.green)
        .accessibilityElement(children: .combine)
        .onAppear { model.start() }
        .onTapGesture { model.start() }  // tap to refresh location, same as watch
    }
}

#Preview {
    ContentView()
}
