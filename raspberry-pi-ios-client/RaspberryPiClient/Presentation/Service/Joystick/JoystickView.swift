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
    @Binding var knobPosition: KnobPosition

    @State private var isShowUpChevron = false
    @State private var isShowDownChevron = false
    @State private var isShowLeftChevron = false
    @State private var isShowRightChevron = false

    private let screenWidth = UIScreen.main.bounds.width

    init(knobPosition: Binding<KnobPosition>, isShowDebugView: Bool = false) {
        self._knobPosition = knobPosition
        self.isShowDebugView = isShowDebugView
    }

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: KnobPosition.parentCircleWidth, height: KnobPosition.parentCircleWidth)
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
                            ]), center: .center, startRadius: 0, endRadius: KnobPosition.parentCircleWidth * 0.8)
                        )
                        .opacity(0.5)
                        .frame(width: KnobPosition.shadowCircleWidth, height: KnobPosition.shadowCircleWidth)
                        .offset(x: knobPosition.xCGFloat * 0.6, y: -knobPosition.yCGFloat * 0.6)

                    Circle()
                        .fill(
                            RadialGradient(gradient: Gradient(colors: [
                                Color.red,
                                Color.red.opacity(0.5),
                                Color.red.opacity(0.7),
                                Color.black
                            ]), center: .center, startRadius: 0, endRadius: KnobPosition.parentCircleWidth * 0.8)
                        )
                        .frame(width: KnobPosition.knobCircleWidth, height: KnobPosition.knobCircleWidth)
                        .offset(x: knobPosition.xCGFloat, y: -knobPosition.yCGFloat)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            knobPosition.changePosition(value)

                            // Chevron showing
                            isShowUpChevron = knobPosition.yCGFloat > 10
                            isShowDownChevron = knobPosition.yCGFloat < -10
                            isShowLeftChevron = knobPosition.xCGFloat < -10
                            isShowRightChevron = knobPosition.xCGFloat > 10
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut(duration: 0.2)) {
                                knobPosition = KnobPosition(width: 0, height: 0)

                                isShowUpChevron = false
                                isShowDownChevron = false
                                isShowLeftChevron = false
                                isShowRightChevron = false
                            }
                        }
                )
            }
            .frame(width: KnobPosition.parentCircleWidth, height: KnobPosition.parentCircleWidth)

            VStack {
                Image(systemName: "chevron.up")
                    .font(.system(size: 35))
                    .foregroundColor(isShowUpChevron ? .black : .black.opacity(0.2))

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 35))
                    .foregroundColor(isShowDownChevron ? .black : .black.opacity(0.2))
            }
            .frame(height: KnobPosition.chevronWidth)

            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 35))
                    .foregroundColor(isShowLeftChevron ? .black : .black.opacity(0.2))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 35))
                    .foregroundColor(isShowRightChevron ? .black : .black.opacity(0.2))
            }
            .frame(width: KnobPosition.chevronWidth)

            DebugView(
                showDebugView: isShowDebugView,
                positionWidth: knobPosition.x,
                positionHeight: knobPosition.y,
                theta: knobPosition.theta
            )
        }
    }
}

private struct DebugView: View {
    let showDebugView: Bool
    let positionWidth: Float
    let positionHeight: Float
    let theta: Float

    var body: some View {
        if (showDebugView) {
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("X: \(positionWidth), Y: \(positionHeight)")
                    Text("Theta: \(theta)°")
                }
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
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var knobPosition = KnobPosition(width: 0, height: 0)
    
    var body: some View {
        JoystickView(
            knobPosition: $knobPosition,
            isShowDebugView: true
        )
    }
}
