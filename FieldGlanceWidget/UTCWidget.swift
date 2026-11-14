//
//  UTCWidget.swift
//  FieldGlanceWidget
//

import WidgetKit
import SwiftUI

private func utcFormatter(_ format: String) -> DateFormatter {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = TimeZone(secondsFromGMT: 0)
    f.dateFormat = format
    return f
}

private let dateFormatter = utcFormatter("yyyy-MM-dd")
private let timeFormatter = utcFormatter("HH:mm")

private let utcFont = Font.system(size: 26, weight: .semibold, design: .monospaced)

private struct UTCLabel: View {
    var body: some View {
        Text("UTC")
            .font(.caption2)
            .opacity(0.7)
    }
}

struct UTCEntry: TimelineEntry {
    let date: Date
}

struct UTCProvider: TimelineProvider {
    func placeholder(in context: Context) -> UTCEntry { UTCEntry(date: .now) }

    func getSnapshot(in context: Context, completion: @escaping (UTCEntry) -> Void) {
        completion(UTCEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UTCEntry>) -> Void) {
        let cal = Calendar.current
        let start = cal.dateInterval(of: .minute, for: .now)!.start
        let entries = (0..<60).map {
            UTCEntry(date: cal.date(byAdding: .minute, value: $0, to: start)!)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct UTCView: View {
    let entry: UTCEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading) {
            Text(dateFormatter.string(from: entry.date))
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(timeFormatter.string(from: entry.date))
                UTCLabel()
            }
        }
        .font(utcFont)
        .foregroundStyle(.orange)
        .padding(.top, 12)
        .widgetURL(utcWidgetURL)
    }
}

struct UTCComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "UTCComplication", provider: UTCProvider()) { entry in
            UTCView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("UTC Date and Time")
        .description("Current date and time in UTC.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}

@main
struct FieldGlanceBundle: WidgetBundle {
    var body: some Widget {
        UTCComplication()
        DeclComplication()
    }
}

#Preview(as: .accessoryRectangular) {
    UTCComplication()
} timeline: {
    UTCEntry(date: .now)
}
