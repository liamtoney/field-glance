//
//  ClockView.swift
//  FieldGlanceWatch
//

import SwiftUI

private let clockFont = Font.system(size: 24, weight: .semibold, design: .monospaced)

private struct ZoneLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .opacity(0.7)
            .lineLimit(1)
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
                .lineLimit(1)
                .padding(.bottom, -8)
            Text(zone.timeFormatter.string(from: date))
                .lineLimit(1)
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
