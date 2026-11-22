//
//  ContentView.swift
//  FieldGlance
//

import SwiftUI

// Clock date/time and declination value font size
private let bigFontSize: CGFloat = 48

extension PanelStyle {
    static let phone = PanelStyle(
        clockFont: .system(size: bigFontSize, weight: .semibold, design: .monospaced),
        declinationFont: .system(size: bigFontSize, weight: .semibold),
        subFont: .system(size: 18),
        lineSpacing: 4,
        panelSpacing: 50,
        dateBottomPadding: -10
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
