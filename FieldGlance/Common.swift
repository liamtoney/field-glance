//
//  Common.swift
//  FieldGlance
//
//  Constants and helpers shared across the iPhone app, Watch app, and widget extension.
//

import Foundation

// MARK: - App Group / Widget

let sharedGroupID = "group.com.liamtoney.fieldglance"
let declKey = "declination"

let utcWidgetURL = URL(string: "fieldglancewatch://page/utc")!
let declWidgetURL = URL(string: "fieldglancewatch://page/decl")!

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

    private static func makeFormatter(_ format: String, _ timeZone: TimeZone) -> DateFormatter {
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

// MARK: - Declination formatting

func declinationString(_ degrees: Double) -> String {
    String(format: "%.1f° %@", abs(degrees), degrees >= 0 ? "E" : "W")
}

func coordinateString(lat: Double, lon: Double) -> String {
    let latStr = String(format: "%@%.2f°", lat < 0 ? "−" : "", abs(lat))
    let lonStr = String(format: "%@%.2f°", lon < 0 ? "−" : "", abs(lon))
    return "(\(latStr), \(lonStr))"
}

let wmmLabel = "DECLINATION · WMM2025"
let wmmExpiredLabel = "WMM2025 OUT OF DATE"
