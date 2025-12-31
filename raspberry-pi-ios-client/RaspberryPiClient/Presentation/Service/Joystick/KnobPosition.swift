//
//  KnobPosition.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/29.
//

import SwiftUI

struct KnobPosition {
    private var position: CGSize
    private static let screenWidth = UIScreen.main.bounds.width
    private static var maxDistance: CGFloat {
        parentCircleWidth / 2 - knobCircleWidth / 2
    }

    /// Waiting factor
    private let WF: Double = 20.0

    static var chevronWidth: CGFloat {
        screenWidth * 0.875
    }
    static var parentCircleWidth: CGFloat {
        screenWidth * 0.625
    }
    static var shadowCircleWidth: CGFloat {
        screenWidth * 0.375
    }
    static var knobCircleWidth: CGFloat {
        screenWidth * 0.25
    }

    init(width: CGFloat, height: CGFloat) {
        self.position = CGSize(width: width, height: height)
    }

    // MARK: Range -2.0 ~ +2.0 to use ROS2 service

    var x: Float {
        let normalizedValue = (position.width / Self.maxDistance) * WF
        let clampedValue = max(-10.0, min(10.0, normalizedValue))
        return Float(floor(clampedValue * 100) / 100)
    }

    var y: Float {
        let normalizedValue = (position.height / Self.maxDistance) * WF
        let clampedValue = max(-10.0, min(10.0, normalizedValue))
        return Float(floor(clampedValue * 100) / 100)
    }

    // MARK: Range -maxDistance ~ +maxDistance to display Joystic knob

    var xCGFloat: CGFloat {
        position.width
    }

    var yCGFloat: CGFloat {
        position.height
    }

    var theta: Float {
        let radians = atan2(x, y)
        let degrees = radians * 180.0 / .pi
        return degrees >= 0 ? degrees : degrees + 360.0
    }

    var radian: Float {
        -atan2(x, y) * Float(WF / 2.0)
    }

    mutating func changePosition(_ value: DragGesture.Value) {
        // Invert the sign of the Y coordinate to make the upward direction positive.
        // Because the downward direction of the screen is positive in SwiftUI's coordinate system.
        let normalizedY = -value.translation.height
        let distance = hypot(value.translation.width, normalizedY)

        // Knob position
        if distance > Self.maxDistance {
            let scale = Self.maxDistance / distance
            position = CGSize(
                width: value.translation.width * scale,
                height: normalizedY * scale
            )
        } else {
            position = CGSize(
                width: value.translation.width,
                height: normalizedY
            )
        }
    }
}
