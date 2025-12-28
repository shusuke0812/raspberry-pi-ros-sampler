//
//  JoystickView.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import SwiftUI

// Ref: https://github.com/TheAppWizard/JoystickSwiftUI/blob/main/JoystickSwiftUI/JoystickSwiftUI/ContentView.swift

struct JoystickView: View {
    let isShowDebugView: Bool

    @State private var knobPosition: CGSize = .zero
    @State private var isShowUpChevron = false
    @State private var isShowDownChevron = false
    @State private var isShowLeftChevron = false
    @State private var isShowRightChevron = false

    private let screenWidth = UIScreen.main.bounds.width

    init(isShowDebugView: Bool = false) {
        self.isShowDebugView = isShowDebugView
    }

    var body: some View {
        let chevronWidth: CGFloat = screenWidth * 0.875
        let parentCircleWidth: CGFloat = screenWidth * 0.625
        let shadowCircleWidth: CGFloat = screenWidth * 0.375
        let knobCircleWidth: CGFloat = screenWidth * 0.25

        ZStack {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: parentCircleWidth, height: parentCircleWidth)
                    .shadow(color: Color.white.opacity(0.1), radius: 10, x: -5, y: -5)
                    .shadow(color: Color.black.opacity(0.5), radius: 10, x: 5, y: 5)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(gradient: Gradient(colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.2),
                                Color.gray.opacity(0.3),
                                Color.black
                            ]), center: .center, startRadius: 0, endRadius: parentCircleWidth * 0.8)
                        )
                        .opacity(0.5)
                        .frame(width: shadowCircleWidth, height: shadowCircleWidth)
                        .offset(x: knobPosition.width * 0.6, y: knobPosition.height * 0.6)

                    Circle()
                        .fill(
                            RadialGradient(gradient: Gradient(colors: [
                                Color.red,
                                Color.red.opacity(0.5),
                                Color.red.opacity(0.7),
                                Color.black
                            ]), center: .center, startRadius: 0, endRadius: parentCircleWidth * 0.8)
                        )
                        .frame(width: knobCircleWidth, height: knobCircleWidth)
                        .offset(knobPosition)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                            let maxDistance: CGFloat = parentCircleWidth / 2 - knobCircleWidth / 2

                            // Knob position
                            if distance > maxDistance {
                                let scale = maxDistance / distance
                                knobPosition = CGSize(
                                    width: value.translation.width * scale,
                                    height: value.translation.height * scale
                                )
                            } else {
                                knobPosition = value.translation
                            }

                            // Chevron showing
                            isShowUpChevron = knobPosition.height < -10
                            isShowDownChevron = knobPosition.height > 10
                            isShowLeftChevron = knobPosition.width < -10
                            isShowRightChevron = knobPosition.width > 10
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut(duration: 0.2)) {
                                knobPosition = .zero

                                isShowUpChevron = false
                                isShowDownChevron = false
                                isShowLeftChevron = false
                                isShowRightChevron = false
                            }
                        }
                )
            }
            .frame(width: parentCircleWidth, height: parentCircleWidth)

            VStack {
                Image(systemName: "chevron.up")
                    .font(.system(size: 35))
                    .foregroundColor(isShowUpChevron ? .black : .black.opacity(0.2))

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 35))
                    .foregroundColor(isShowDownChevron ? .black : .black.opacity(0.2))
            }
            .frame(height: chevronWidth)

            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 35))
                    .foregroundColor(isShowLeftChevron ? .black : .black.opacity(0.2))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 35))
                    .foregroundColor(isShowRightChevron ? .black : .black.opacity(0.2))
            }
            .frame(width: chevronWidth)

            DebugView(showDebugView: isShowDebugView, positionWidth: knobPosition.width, positionHeight: knobPosition.height)
        }
    }
}

private struct DebugView: View {
    let showDebugView: Bool
    let positionWidth: CGFloat
    let positionHeight: CGFloat

    var body: some View {
        if (showDebugView) {
            VStack {
                Spacer()
                Text("X: \(Int(positionWidth)), Y: \(Int(positionHeight))")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    JoystickView(isShowDebugView: true)
}
