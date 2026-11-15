//  ClockFormat.swift
//  FieldGlance
//

import Foundation

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

func localLabel(for timeZone: TimeZone, at date: Date) -> String {
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

let utcZone  = Zone(TimeZone(secondsFromGMT: 0)!)
let localZone = Zone(.autoupdatingCurrent)
