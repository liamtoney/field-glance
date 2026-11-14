//
//  DeclWidget.swift
//  FieldGlanceWidget
//
//  Magnetic declination complication.
//  Value is written to the shared App Group by the main app (DeclinationModel).
//

import SwiftUI
import WidgetKit

// MARK: - Entry

struct DeclEntry: TimelineEntry {
    let date: Date
    /// Degrees, east positive. Nil if the app hasn't run yet.
    let declination: Double?
}

// MARK: - Provider

struct DeclProvider: TimelineProvider {
    private func storedDeclination() -> Double? {
        UserDefaults(suiteName: sharedGroupID)?.object(forKey: declKey) as? Double
    }

    func placeholder(in context: Context) -> DeclEntry {
        DeclEntry(date: .now, declination: 7.6)
    }

    func getSnapshot(in context: Context, completion: @escaping (DeclEntry) -> Void) {
        completion(DeclEntry(date: .now, declination: storedDeclination() ?? 7.6))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DeclEntry>) -> Void) {
        let entry = DeclEntry(date: .now, declination: storedDeclination())
        // No automatic refresh needed — the app pushes a reload via WidgetCenter
        completion(Timeline(entries: [entry], policy: .never))
    }
}

// MARK: - Views

private let declFont = Font.system(size: 17, weight: .semibold)

struct DeclView: View {
    let entry: DeclEntry

    var body: some View {
        if let d = entry.declination {
            VStack(spacing: 0) {
                Text(String(format: "%.1f°", abs(d)))
                    .lineLimit(1)
                HStack(spacing: 2) {
                    Text(d >= 0 ? "E" : "W")
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(d))
                }
            }
            .font(declFont)
            .foregroundStyle(.green)
            .widgetURL(declWidgetURL)
        } else {
            Text("–")
                .font(declFont)
                .foregroundStyle(.green)
                .widgetURL(declWidgetURL)
        }
    }
}

// MARK: - Widget

struct DeclComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DeclComplication", provider: DeclProvider()) { entry in
            DeclView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Magnetic Declination")
        .description("Magnetic declination at your location.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

// MARK: - Preview

#Preview(as: .accessoryCircular) {
    DeclComplication()
} timeline: {
    DeclEntry(date: .now, declination: 7.6)
    DeclEntry(date: .now, declination: -3.2)
    DeclEntry(date: .now, declination: nil)
}
