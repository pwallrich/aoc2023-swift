import Foundation
import Algorithms

class Day11: Day {
    var day: Int { 11 }
    let input: Set<Point2D>
    let xRange: Range<Int>
    let yRange: Range<Int>

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
"""
        } else {
            inputString = try InputGetter.getInput(for: 11, part: .first)
        }
        let rows = inputString.split(separator: "\n")
        yRange = 0..<rows.count
        xRange = 0..<rows[0].count

        var grid: Set<Point2D> = []
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() where char == "#" {
                grid.insert(.init(x: x, y: y))
            }
        }
        self.input = grid
    }

    func runPart1() throws {
        let grid = offsetGrid(multiplyingBy: 1)

        let combs = grid.combinations(ofCount: 2)

        var res = 0
        for points in combs {
            let first = points[0]
            let second = points[1]

            res += first.manhattan(to: second)
        }
        print(res)

    }

    func runPart2() throws {
        let grid = offsetGrid(multiplyingBy: 1_000_000 - 1)

        let combs = grid.combinations(ofCount: 2)

        var res = 0
        for points in combs {
            let first = points[0]
            let second = points[1]

            res += first.manhattan(to: second)
        }
        print(res)
    }

    func offsetGrid(multiplyingBy age: Int) -> Set<Point2D> {
        let expandedRows = xRange.filter { x in !input.contains(where: { $0.x == x }) }
        let expandedCols = yRange.filter { y in !input.contains(where: { $0.y == y }) }

        var res: Set<Point2D> = []

        for point in input {
            let yOffset = expandedCols.prefix { $0 < point.y }.count * (age)
            let xOffset = expandedRows.prefix { $0 < point.x }.count * (age)
            res.insert(point.adding(.init(x: xOffset, y: yOffset)))
        }
        return res
    }
}

extension Set where Element == Point2D {
    func prettyPrint() {
        let maxX = self.map(\.x).max()!
        let maxY = self.map(\.y).max()!

        for y in 0...maxY {
            for x in 0...maxX {
                let point = Point2D(x: x, y: y)
                print(self.contains(point) ? "#" : ".", terminator: "")
            }
            print()
        }
    }
}
