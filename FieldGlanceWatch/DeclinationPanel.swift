//
//  DeclinationPanel.swift
//  FieldGlanceWatch
//

import SwiftUI

struct DeclinationPanel: View {
    @StateObject private var model = DeclinationModel()

    var body: some View {
        VStack(alignment: .leading) {
            if let d = model.declination {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(declinationString(d))
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(d))
                }
            } else {
                Text(model.status)
            }
            Text(WMM.isValid(on: Date()) ? wmmLabel : wmmExpiredLabel)
                .font(.caption2)
                .opacity(0.7)
            if let loc = model.location {
                Text(coordinateString(lat: loc.latitude, lon: loc.longitude))
                    .font(.caption2)
                    .opacity(0.7)
            }
        }
        .font(Font.system(size: 36, weight: .semibold))
        .foregroundStyle(.green)
        .onAppear { model.start() }
        .onTapGesture { model.start() }
    }
}
