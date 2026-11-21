//
//  UTCWidget.swift
//  FieldGlanceWidget
//

import SwiftUI
import WidgetKit

// Complications only update once a minute, so drop the seconds
private let shortTimeFormatter = Zone.makeFormatter("HH:mm", utcZone.timeZone)

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

    var body: some View {
        VStack(alignment: .leading) {
            Text(utcZone.dateFormatter.string(from: entry.date))
                .lineLimit(1)
                .padding(.bottom, -8)
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(shortTimeFormatter.string(from: entry.date))
                    .lineLimit(1)
                Text("UTC")
                    .secondaryText(watchSubFont)
            }
        }
        .font(watchClockFont)
        .foregroundStyle(utcColor)
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
        .supportedFamilies([.accessoryRectangular])
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
