//
//  Common.swift
//  FieldGlance
//
//  Constants, helpers, and views shared across the iPhone app, Watch app, and widget extension.
//

import SwiftUI

// MARK: - App Group / Widget

let sharedGroupID = "group.com.liamtoney.fieldglance"
let declKey = "declination"
let declWidgetKind = "DeclComplication"

let utcWidgetURL = URL(string: "fieldglancewatch://page/utc")!
let declWidgetURL = URL(string: "fieldglancewatch://page/decl")!

// MARK: - Colors, fonts, and styling

// Also used in the app icon and website (see icon/README.md)
let localColor = Color.blue
let utcColor = Color.orange
let declColor = Color.green

// Watch app and complication fonts. These live here (unlike the iPhone fonts, which are
// inline in PanelStyle.phone) because the widget extension can't see PanelStyle.watch.
let watchClockFont = Font.system(size: 24, weight: .semibold, design: .monospaced)
let watchSubFont = Font.system(size: 13)

extension View {
    /// Small, dimmed, single-line text used for labels under the big values.
    func secondaryText(_ font: Font) -> some View {
        self.font(font).opacity(0.6).lineLimit(1)
    }
}

/// Sizing that differs between the iPhone and Watch layouts.
struct PanelStyle {
    let clockFont: Font
    let declinationFont: Font
    let subFont: Font
    /// Spacing between lines within a panel (nil for the system default)
    let lineSpacing: CGFloat?
    /// Spacing between panels
    let panelSpacing: CGFloat
    /// Pulls the time up closer to the date
    let dateBottomPadding: CGFloat
}

// MARK: - Clock formatting

struct Zone {
    let timeZone: TimeZone
    let dateFormatter: DateFormatter
    let timeFormatter: DateFormatter

    init(_ timeZone: TimeZone) {
        self.timeZone = timeZone
        dateFormatter = Zone.makeFormatter("yyyy-MM-dd", timeZone)
        timeFormatter = Zone.makeFormatter("HH:mm:ss", timeZone)
    }

    static func makeFormatter(_ format: String, _ timeZone: TimeZone) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = timeZone
        f.dateFormat = format
        return f
    }
}

let utcZone = Zone(TimeZone(secondsFromGMT: 0)!)
let localZone = Zone(.autoupdatingCurrent)

func localLabel(for timeZone: TimeZone, at date: Date) -> String {
    let seconds = timeZone.secondsFromGMT(for: date)
    let sign = seconds < 0 ? "−" : "+"
    let hours = abs(seconds) / 3600
    let minutes = (abs(seconds) % 3600) / 60
    let offset =
        minutes == 0
        ? "UTC\(sign)\(hours)"
        : "UTC\(sign)\(hours):" + String(format: "%02d", minutes)

    guard let abbreviation = zoneAbbreviation(for: timeZone, at: date) else {
        return offset
    }
    return "\(abbreviation) (\(offset))"
}

// ICU only provides an abbreviation (e.g. "CEST") in locales where it's commonly
// used; elsewhere it falls back to "GMT+2". Check a handful of English locales so
// regional names show up regardless of the device's locale. en_US is first so
// North American zones are unaffected.
private let abbreviationLocales = [
    "en_US", "en_GB", "en_IE", "en_AU", "en_IN", "en_ZA", "en_SG", "en_HK", "en_JP",
    "en_CA", "en_NZ", "en_PT", "en_GU", "en_GY",
]
.map(Locale.init(identifier:))

private func zoneAbbreviation(for timeZone: TimeZone, at date: Date) -> String? {
    let style: NSTimeZone.NameStyle =
        timeZone.isDaylightSavingTime(for: date)
        ? .shortDaylightSaving
        : .shortStandard
    for locale in abbreviationLocales {
        if let name = timeZone.localizedName(for: style, locale: locale),
            !name.hasPrefix("GMT")
        {
            return name
        }
    }
    return nil
}

// MARK: - Clock views

private struct ClockPanel: View {
    let date: Date
    let zone: Zone
    let label: String
    let color: Color
    let style: PanelStyle

    var body: some View {
        VStack(alignment: .leading, spacing: style.lineSpacing) {
            Text(zone.dateFormatter.string(from: date))
                .lineLimit(1)
                .padding(.bottom, style.dateBottomPadding)
            Text(zone.timeFormatter.string(from: date))
                .lineLimit(1)
            Text(label)
                .secondaryText(style.subFont)
        }
        .font(style.clockFont)
        .foregroundStyle(color)
        .accessibilityElement(children: .combine)
    }
}

/// Local and UTC clocks, updated every second.
struct ClocksView: View {
    let style: PanelStyle

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(alignment: .leading, spacing: style.panelSpacing) {
                ClockPanel(
                    date: context.date,
                    zone: localZone,
                    label: localLabel(for: localZone.timeZone, at: context.date),
                    color: localColor,
                    style: style
                )
                ClockPanel(
                    date: context.date,
                    zone: utcZone,
                    label: "UTC",
                    color: utcColor,
                    style: style
                )
            }
        }
    }
}

// MARK: - Declination formatting

func declinationMagnitude(_ degrees: Double) -> String {
    String(format: "%.1f°", abs(degrees))
}

func declinationDirection(_ degrees: Double) -> String {
    degrees >= 0 ? "E" : "W"
}

func declinationString(_ degrees: Double) -> String {
    "\(declinationMagnitude(degrees)) \(declinationDirection(degrees))"
}

func coordinateString(lat: Double, lon: Double) -> String {
    let latStr = String(format: "%@%.2f°", lat < 0 ? "−" : "", abs(lat))
    let lonStr = String(format: "%@%.2f°", lon < 0 ? "−" : "", abs(lon))
    return "(\(latStr), \(lonStr))"
}

let wmmLabel = "DECLINATION · WMM2025"
let wmmExpiredLabel = "WMM2025 OUT OF DATE"

// MARK: - Declination views

/// North arrow rotated by the declination. Hidden from VoiceOver since the text already says E/W.
struct DeclinationArrow: View {
    let degrees: Double

    var body: some View {
        Image(systemName: "arrow.up")
            .rotationEffect(.degrees(degrees))
            .accessibilityHidden(true)
    }
}
