//
//  WMM.swift
//  FieldGlance
//
//  Magnetic declination from the World Magnetic Model 2025 (degree 12, valid 2025.0 to 2030.0).
//  Coefficients are from the NOAA NCEI / British Geological Survey WMM.COF file.
//
//  Check value: declination(latitude: 47.6205, longitude: -122.3493, heightKm: 0, year: 2025.25)
//  returns 15.0656 degrees.
//

import Foundation

enum WMM {

    static let epoch = 2025.0
    static let validUntil = 2030.0

    /// True if the model is valid on the given date.
    static func isValid(on date: Date) -> Bool {
        let year = decimalYear(date)
        return year >= epoch && year < validUntil
    }

    /// Label naming the model, or flagging it as expired on the given date.
    static func statusLabel(on date: Date) -> String {
        isValid(on: date) ? wmmLabel : wmmExpiredLabel
    }

    /// Magnetic declination in degrees, east positive.
    /// Height is in km above the WGS84 ellipsoid.
    static func declination(latitude: Double, longitude: Double, heightKm: Double, date: Date)
        -> Double
    {
        declination(
            latitude: latitude, longitude: longitude, heightKm: heightKm, year: decimalYear(date))
    }

    static func declination(latitude: Double, longitude: Double, heightKm: Double, year: Double)
        -> Double
    {
        let rad = Double.pi / 180
        let a = 6378.137  // WGS84 semi-major axis, km
        let flattening = 1 / 298.257223563
        let e2 = flattening * (2 - flattening)
        let referenceRadius = 6371.2  // WMM geomagnetic reference radius, km
        let maxDegree = 12

        let lat = latitude * rad
        let lon = longitude * rad

        // Geodetic to geocentric spherical coordinates
        let rc = a / sqrt(1 - e2 * sin(lat) * sin(lat))
        let p = (rc + heightKm) * cos(lat)
        let z = (rc * (1 - e2) + heightKm) * sin(lat)
        let r = sqrt(p * p + z * z)
        let latGC = atan2(z, p)
        let sinGC = z / r
        let cosGC = p / r

        // Schmidt semi-normalized Legendre functions P[n][m] and their
        // derivatives dP[n][m] with respect to geocentric latitude
        var P = [[Double]](
            repeating: [Double](repeating: 0, count: maxDegree + 1), count: maxDegree + 1)
        var dP = P
        P[0][0] = 1
        for m in 0...maxDegree {
            if m == 1 {
                P[1][1] = cosGC
                dP[1][1] = -sinGC
            } else if m >= 2 {
                let k = sqrt(Double(2 * m - 1) / Double(2 * m))
                P[m][m] = k * cosGC * P[m - 1][m - 1]
                dP[m][m] = k * (cosGC * dP[m - 1][m - 1] - sinGC * P[m - 1][m - 1])
            }
            if m + 1 <= maxDegree {
                let k = sqrt(Double(2 * m + 1))
                P[m + 1][m] = k * sinGC * P[m][m]
                dP[m + 1][m] = k * (cosGC * P[m][m] + sinGC * dP[m][m])
            }
            if m + 2 <= maxDegree {
                for n in (m + 2)...maxDegree {
                    let nd = Double(n)
                    let md = Double(m)
                    let denominator = sqrt(nd * nd - md * md)
                    let k = sqrt((nd - 1) * (nd - 1) - md * md)
                    P[n][m] = ((2 * nd - 1) * sinGC * P[n - 1][m] - k * P[n - 2][m]) / denominator
                    dP[n][m] =
                        ((2 * nd - 1) * (cosGC * P[n - 1][m] + sinGC * dP[n - 1][m])
                            - k * dP[n - 2][m]) / denominator
                }
            }
        }

        // Spherical harmonic sum with linear secular variation
        let t = year - epoch
        let ratio = referenceRadius / r
        var xp = 0.0
        var yp = 0.0
        var zp = 0.0
        for (n, m, g0, h0, gDot, hDot) in rows {
            let g = g0 + t * gDot
            let h = h0 + t * hDot
            let scale = pow(ratio, Double(n + 2))
            let cm = cos(Double(m) * lon)
            let sm = sin(Double(m) * lon)
            let gh = g * cm + h * sm
            xp -= scale * gh * dP[n][m]
            yp += scale * Double(m) * (g * sm - h * cm) * P[n][m]
            zp -= scale * Double(n + 1) * gh * P[n][m]
        }
        yp /= max(cosGC, 1e-12)

        // Rotate the north component back from geocentric to geodetic
        let psi = latGC - lat
        let x = xp * cos(psi) - zp * sin(psi)
        return atan2(yp, x) / rad
    }

    private static func decimalYear(_ date: Date) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utcZone.timeZone
        let year = calendar.component(.year, from: date)
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        return Double(year) + date.timeIntervalSince(start) / end.timeIntervalSince(start)
    }

    // Coefficients: (n, m, g, h, gDot, hDot)
    private static let rows: [(Int, Int, Double, Double, Double, Double)] = [
        (1, 0, -29351.8, 0.0, 12.0, 0.0),
        (1, 1, -1410.8, 4545.4, 9.7, -21.5),
        (2, 0, -2556.6, 0.0, -11.6, 0.0),
        (2, 1, 2951.1, -3133.6, -5.2, -27.7),
        (2, 2, 1649.3, -815.1, -8.0, -12.1),
        (3, 0, 1361.0, 0.0, -1.3, 0.0),
        (3, 1, -2404.1, -56.6, -4.2, 4.0),
        (3, 2, 1243.8, 237.5, 0.4, -0.3),
        (3, 3, 453.6, -549.5, -15.6, -4.1),
        (4, 0, 895.0, 0.0, -1.6, 0.0),
        (4, 1, 799.5, 278.6, -2.4, -1.1),
        (4, 2, 55.7, -133.9, -6.0, 4.1),
        (4, 3, -281.1, 212.0, 5.6, 1.6),
        (4, 4, 12.1, -375.6, -7.0, -4.4),
        (5, 0, -233.2, 0.0, 0.6, 0.0),
        (5, 1, 368.9, 45.4, 1.4, -0.5),
        (5, 2, 187.2, 220.2, 0.0, 2.2),
        (5, 3, -138.7, -122.9, 0.6, 0.4),
        (5, 4, -142.0, 43.0, 2.2, 1.7),
        (5, 5, 20.9, 106.1, 0.9, 1.9),
        (6, 0, 64.4, 0.0, -0.2, 0.0),
        (6, 1, 63.8, -18.4, -0.4, 0.3),
        (6, 2, 76.9, 16.8, 0.9, -1.6),
        (6, 3, -115.7, 48.8, 1.2, -0.4),
        (6, 4, -40.9, -59.8, -0.9, 0.9),
        (6, 5, 14.9, 10.9, 0.3, 0.7),
        (6, 6, -60.7, 72.7, 0.9, 0.9),
        (7, 0, 79.5, 0.0, -0.0, 0.0),
        (7, 1, -77.0, -48.9, -0.1, 0.6),
        (7, 2, -8.8, -14.4, -0.1, 0.5),
        (7, 3, 59.3, -1.0, 0.5, -0.8),
        (7, 4, 15.8, 23.4, -0.1, 0.0),
        (7, 5, 2.5, -7.4, -0.8, -1.0),
        (7, 6, -11.1, -25.1, -0.8, 0.6),
        (7, 7, 14.2, -2.3, 0.8, -0.2),
        (8, 0, 23.2, 0.0, -0.1, 0.0),
        (8, 1, 10.8, 7.1, 0.2, -0.2),
        (8, 2, -17.5, -12.6, 0.0, 0.5),
        (8, 3, 2.0, 11.4, 0.5, -0.4),
        (8, 4, -21.7, -9.7, -0.1, 0.4),
        (8, 5, 16.9, 12.7, 0.3, -0.5),
        (8, 6, 15.0, 0.7, 0.2, -0.6),
        (8, 7, -16.8, -5.2, -0.0, 0.3),
        (8, 8, 0.9, 3.9, 0.2, 0.2),
        (9, 0, 4.6, 0.0, -0.0, 0.0),
        (9, 1, 7.8, -24.8, -0.1, -0.3),
        (9, 2, 3.0, 12.2, 0.1, 0.3),
        (9, 3, -0.2, 8.3, 0.3, -0.3),
        (9, 4, -2.5, -3.3, -0.3, 0.3),
        (9, 5, -13.1, -5.2, 0.0, 0.2),
        (9, 6, 2.4, 7.2, 0.3, -0.1),
        (9, 7, 8.6, -0.6, -0.1, -0.2),
        (9, 8, -8.7, 0.8, 0.1, 0.4),
        (9, 9, -12.9, 10.0, -0.1, 0.1),
        (10, 0, -1.3, 0.0, 0.1, 0.0),
        (10, 1, -6.4, 3.3, 0.0, 0.0),
        (10, 2, 0.2, 0.0, 0.1, -0.0),
        (10, 3, 2.0, 2.4, 0.1, -0.2),
        (10, 4, -1.0, 5.3, -0.0, 0.1),
        (10, 5, -0.6, -9.1, -0.3, -0.1),
        (10, 6, -0.9, 0.4, 0.0, 0.1),
        (10, 7, 1.5, -4.2, -0.1, 0.0),
        (10, 8, 0.9, -3.8, -0.1, -0.1),
        (10, 9, -2.7, 0.9, -0.0, 0.2),
        (10, 10, -3.9, -9.1, -0.0, -0.0),
        (11, 0, 2.9, 0.0, 0.0, 0.0),
        (11, 1, -1.5, 0.0, -0.0, -0.0),
        (11, 2, -2.5, 2.9, 0.0, 0.1),
        (11, 3, 2.4, -0.6, 0.0, -0.0),
        (11, 4, -0.6, 0.2, 0.0, 0.1),
        (11, 5, -0.1, 0.5, -0.1, -0.0),
        (11, 6, -0.6, -0.3, 0.0, -0.0),
        (11, 7, -0.1, -1.2, -0.0, 0.1),
        (11, 8, 1.1, -1.7, -0.1, -0.0),
        (11, 9, -1.0, -2.9, -0.1, 0.0),
        (11, 10, -0.2, -1.8, -0.1, 0.0),
        (11, 11, 2.6, -2.3, -0.1, 0.0),
        (12, 0, -2.0, 0.0, 0.0, 0.0),
        (12, 1, -0.2, -1.3, 0.0, -0.0),
        (12, 2, 0.3, 0.7, -0.0, 0.0),
        (12, 3, 1.2, 1.0, -0.0, -0.1),
        (12, 4, -1.3, -1.4, -0.0, 0.1),
        (12, 5, 0.6, -0.0, -0.0, -0.0),
        (12, 6, 0.6, 0.6, 0.1, -0.0),
        (12, 7, 0.5, -0.1, -0.0, -0.0),
        (12, 8, -0.1, 0.8, 0.0, 0.0),
        (12, 9, -0.4, 0.1, 0.0, -0.0),
        (12, 10, -0.2, -1.0, -0.1, -0.0),
        (12, 11, -1.3, 0.1, -0.0, 0.0),
        (12, 12, -0.7, 0.2, -0.1, -0.1),
    ]
}
