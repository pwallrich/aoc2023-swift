//
//  File.swift
//  
//
//  Created by Philipp Wallrich on 04.12.23.
//

import Foundation

struct Point2D: Hashable {
    let x: Int
    let y: Int

    func adding(_ other: Point2D) -> Point2D {
        return .init(x: x + other.x, y: y + other.y)
    }

    func manhattan(to other: Point2D) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }

    func adjacent(withDiagonal: Bool) -> [Point2D] {
        guard withDiagonal else {
            return [
                adding(Point2D(x: 0, y: 1)),
                adding(Point2D(x: 0, y: -1)),
                adding(Point2D(x: 1, y: 0)),
                adding(Point2D(x: -1, y: 0)),
            ]
        }
        var res: [Point2D] = []
        for yOff in (y-1)...(y+1) {
            for xOff in (x-1)...(x+1) {
                if xOff == 0 && yOff == 0 {
                    continue
                }
                res.append(Point2D(x: x + xOff, y: y + yOff))
            }
        }
        return res
    }
}
