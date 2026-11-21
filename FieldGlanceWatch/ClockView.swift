//
//  ClockView.swift
//  FieldGlanceWatch
//

import SwiftUI

extension PanelStyle {
    static let watch = PanelStyle(
        clockFont: watchClockFont,
        declinationFont: .system(size: 36, weight: .semibold),
        subFont: watchSubFont,
        lineSpacing: nil,
        panelSpacing: 12,
        dateBottomPadding: -8,
        localOpacity: 0.7,
        secondaryOpacity: 0.7
    )
}

private enum Page: Int {
    case clocks = 0
    case declination = 1
}

struct ClockView: View {
    @State private var selectedPage = Page.clocks
    @StateObject private var model = DeclinationModel()

    var body: some View {
        TabView(selection: $selectedPage) {
            // Page 1: Local and UTC clocks
            ClocksView(style: .watch)
                .tag(Page.clocks)

            // Page 2: Declination
            DeclinationPanel(model: model, style: .watch)
                .tag(Page.declination)
        }
        .tabViewStyle(.page)
        .onOpenURL { url in
            switch url {
            case utcWidgetURL: selectedPage = .clocks
            case declWidgetURL: selectedPage = .declination
            default: break
            }
        }
    }
}

#Preview {
    ClockView()
}
