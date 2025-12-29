//
//  KnobPosition.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/29.
//

import SwiftUI

struct KnobPosition {
    private var position: CGSize

    init(width: CGFloat, height: CGFloat) {
        self.position = CGSize(width: width, height: height)
    }

    var x: Float {
        Float(floor(position.width * 100) / 100)
    }

    var y: Float {
        Float(floor(position.height * 100) / 100)
    }

    var xCGFloat: CGFloat {
        position.width
    }

    var yCGFloat: CGFloat {
        position.height
    }

    var theta: Float {
        let radians = atan2(y, x)
        let degrees = radians * 180.0 / .pi
        return degrees >= 0 ? degrees : degrees + 360.0
    }

    mutating func changePosition(_ value: DragGesture.Value, parentCircleWidth: CGFloat, knobCircleWidth: CGFloat) {
        // Invert the sign of the Y coordinate to make the upward direction positive.
        // Because the downward direction of the screen is positive in SwiftUI's coordinate system.
        let normalizedY = -value.translation.height
        let distance = hypot(value.translation.width, normalizedY)
        let maxDistance: CGFloat = parentCircleWidth / 2 - knobCircleWidth / 2

        // Knob position
        if distance > maxDistance {
            let scale = maxDistance / distance
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
