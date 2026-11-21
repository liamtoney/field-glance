//
//  ContentView.swift
//  FieldGlance
//

import SwiftUI

// Layout tuning:
//    4    spacing between lines within a panel
//   50    spacing between panels
//   36    horizontal padding
//   48    vertical padding
//    0.6  opacity for secondary text
//    0.7  opacity for the local zone label (slightly stronger for blue)

// Clock date/time and declination value font size
private let bigFontSize: CGFloat = 48

extension PanelStyle {
    static let phone = PanelStyle(
        clockFont: .system(size: bigFontSize, weight: .semibold, design: .monospaced),
        declinationFont: .system(size: bigFontSize, weight: .semibold),
        subFont: .system(size: 18),
        lineSpacing: 4,
        panelSpacing: 50,
        dateBottomPadding: -10,
        localOpacity: 0.7,
        secondaryOpacity: 0.6
    )
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var model = DeclinationModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: PanelStyle.phone.panelSpacing) {
                ClocksView(style: .phone)
                DeclinationPanel(model: model, style: .phone)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { model.start() }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

#Preview {
    ContentView()
}
