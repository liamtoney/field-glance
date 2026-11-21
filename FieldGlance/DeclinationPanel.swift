//
//  DeclinationPanel.swift
//  FieldGlance
//
//  Declination value and north arrow, WMM status, and fix coordinates.
//  Shared by the iPhone and Watch apps.
//

import SwiftUI

struct DeclinationPanel: View {
    // Owned by the parent so the iPhone can also refresh on scene activation
    @ObservedObject var model: DeclinationModel
    let style: PanelStyle

    var body: some View {
        VStack(alignment: .leading, spacing: style.lineSpacing) {
            if let d = model.declination {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(declinationString(d))
                        .lineLimit(1)
                    DeclinationArrow(degrees: d)
                }
            } else {
                Text(model.status)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Text(WMM.statusLabel(on: Date()))
                .secondaryText(style.subFont)
            if let loc = model.location {
                Text(coordinateString(lat: loc.latitude, lon: loc.longitude))
                    .secondaryText(style.subFont)
            }
        }
        .font(style.declinationFont)
        .foregroundStyle(.green)
        .accessibilityElement(children: .combine)
        .onAppear { model.start() }
        .onTapGesture { model.start() }  // tap to refresh location
    }
}
