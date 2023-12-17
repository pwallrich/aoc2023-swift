//
//  File.swift
//  
//
//  Created by Philipp Wallrich on 17.12.23.
//

import Foundation

enum Direction: Int, CaseIterable {
    case up, down, left, right

    var offset: Point2D {
        switch self {
        case .up:
            Point2D(x: 0, y: -1)
        case .down:
            Point2D(x: 0, y: 1)
        case .left:
            Point2D(x: -1, y: 0)
        case .right:
            Point2D(x: 1, y: 0)
        }
    }

}
