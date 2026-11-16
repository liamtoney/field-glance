//
//  ClockView.swift
//  FieldGlanceWatch
//

import SwiftUI

private struct Zone {
    let timeZone: TimeZone
    let dateFormatter: DateFormatter
    let timeFormatter: DateFormatter

    init(_ timeZone: TimeZone) {
        self.timeZone = timeZone
        dateFormatter = Zone.makeFormatter("yyyy-MM-dd", timeZone)
        timeFormatter = Zone.makeFormatter("HH:mm:ss", timeZone)
    }

    private static func makeFormatter(_ format: String, _ timeZone: TimeZone) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = timeZone
        f.dateFormat = format
        return f
    }
}

private func localLabel(for timeZone: TimeZone, at date: Date) -> String {
    let seconds = timeZone.secondsFromGMT(for: date)
    let sign = seconds < 0 ? "−" : "+"
    let hours = abs(seconds) / 3600
    let minutes = (abs(seconds) % 3600) / 60
    let offset = minutes == 0
        ? "UTC\(sign)\(hours)"
        : "UTC\(sign)\(hours):" + String(format: "%02d", minutes)

    guard let abbreviation = timeZone.abbreviation(for: date),
          !abbreviation.hasPrefix("GMT") else {
        return offset
    }
    return "\(abbreviation) (\(offset))"
}

private let utcZone = Zone(TimeZone(secondsFromGMT: 0)!)
private let localZone = Zone(.autoupdatingCurrent)

private let clockFont = Font.system(size: 24, weight: .semibold, design: .monospaced)

private struct ZoneLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .opacity(0.7)
    }
}

private struct ClockPanel: View {
    let date: Date
    let zone: Zone
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(zone.dateFormatter.string(from: date))
                .padding(.bottom, -8)
            Text(zone.timeFormatter.string(from: date))
            ZoneLabel(text: label)
        }
        .font(clockFont)
        .foregroundStyle(color)
    }
}

private enum Page: Int {
    case clocks = 0
    case declination = 1
}

struct ClockView: View {
    @State private var selectedPage = Page.clocks

    var body: some View {
        TabView(selection: $selectedPage) {
            // Page 1: UTC clocks
            TimelineView(.periodic(from: .now, by: 1)) { context in
                VStack(alignment: .leading, spacing: 12) {
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
                }
            }
            .tag(Page.clocks)

            // Page 2: Declination
            DeclinationPanel()
                .tag(Page.declination)
        }
        .tabViewStyle(.page)
        .onOpenURL { url in
            switch url {
            case utcWidgetURL:  selectedPage = .clocks
            case declWidgetURL: selectedPage = .declination
            default: break
            }
        }
    }
}

#Preview {
    ClockView()
}
