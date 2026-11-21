//
//  DeclinationPanel.swift
//  FieldGlanceWatch
//

import SwiftUI

private let declFont = Font.system(size: 13)

struct DeclinationPanel: View {
    @StateObject private var model = DeclinationModel()

    var body: some View {
        VStack(alignment: .leading) {
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
                .font(declFont)
                .opacity(0.7)
                .lineLimit(1)
            if let loc = model.location {
                Text(coordinateString(lat: loc.latitude, lon: loc.longitude))
                    .font(declFont)
                    .opacity(0.7)
                    .lineLimit(1)
            }
        }
        .font(Font.system(size: 36, weight: .semibold))
        .foregroundStyle(.green)
        .onAppear { model.start() }
        .onTapGesture { model.start() }
    }
}
