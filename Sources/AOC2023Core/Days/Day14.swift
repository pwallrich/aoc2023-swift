import Foundation

class Day14: Day {
    var day: Int { 14 }
//    let input: String
    let grid: [Point2D: Character]
    let width: Int
    let height: Int

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
"""
        } else {
            inputString = try InputGetter.getInput(for: 14, part: .first)
        }
        var grid: [Point2D: Character] = [:]

        let rows = inputString.split(separator: "\n")
        height = rows.count
        width = rows[0].count
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() where char != "." {
                let point = Point2D(x: x, y: y)
                grid[point] = char
            }
        }

        self.grid = grid
    }

    func runPart1() throws {
        var grid = grid
        grid.moveNorth(width: width, height: height)
        let load = grid.calculateLoad(height: height)
        print(load)
    }

    func runPart2() throws {
        var seen: [String:Int] = [:]
        var grid = grid
        var i = 0
        var foundCycle = false
        while i < 1000000000 {
            if i > 100000000 || i % 20 == 0 {
                print("at iteration: \(i) of 1000000000")
            }

            grid.moveNorth(width: width, height: height)
            grid.moveWest(width: width, height: height)
            grid.moveSouth(width: width, height: height)
            grid.moveEast(width: width, height: height)

            let cacheKey = grid.cacheKey()
            guard !foundCycle else {
                i += 1
                continue
            }
            if let first = seen[cacheKey] {
                foundCycle = true
                let loopLength = i - first
                let finished = (1000000000 - i - 1) % loopLength
                i = 1000000000 - finished
                print(i - seen[cacheKey]!)
            } else {
                seen[cacheKey] = i
                i += 1
            }
        }
        let load = grid.calculateLoad(height: height)
        print(load)

        // 104931
    }

}

extension Dictionary where Key == Point2D, Value == Character {
    func cacheKey() -> String {
        let sorted = self.sorted { lhs, rhs in
            if lhs.key.y < rhs.key.y {
                return true
            }
            if lhs.key.y > rhs.key.y {
                return false
            }
            return lhs.key.x < rhs.key.x
        }
        return sorted.reduce("") { res, curr in
            res + "(\(curr.key.x),\(curr.key.y)):\(curr.value)"
        }
    }
    mutating func moveNorth(width: Int, height: Int) {
        let toMove = self.filter { $0.value == "O" }.sorted { lhs, rhs in
            if lhs.key.y < rhs.key.y {
                return true
            }
            if lhs.key.y > rhs.key.y {
                return false
            }
            return lhs.key.x < rhs.key.x
        }

        for (point, char) in toMove {
            guard point.y > 0 else { continue }

            var north: Point2D = point
            while north.y > 0 {
                let point = north.adding(.init(x: 0, y: -1))
                guard self[point] == nil else {
                    break
                }

                north = point
            }

            self[point] = nil
            self[north] = char
        }
    }

    mutating func moveSouth(width: Int, height: Int) {
        let toMove = self.filter { $0.value == "O" }.sorted { lhs, rhs in
            if lhs.key.y > rhs.key.y {
                return true
            }
            if lhs.key.y < rhs.key.y {
                return false
            }
            return lhs.key.x < rhs.key.x
        }

        for (point, char) in toMove {
            guard point.y < height - 1 else { continue }
            var south: Point2D = point
            while south.y < height - 1 {
                let point = south.adding(.init(x: 0, y: 1))
                guard self[point] == nil else {
                    break
                }
                south = point
            }

            self[point] = nil
            self[south] = char
        }
    }

    mutating func moveEast(width: Int, height: Int) {

        let toMove = self.filter { $0.value == "O" }.sorted { lhs, rhs in
            if lhs.key.x > rhs.key.x {
                return true
            }
            if lhs.key.x < rhs.key.x {
                return false
            }
            return lhs.key.y < rhs.key.y
        }

        for (point, char) in toMove {
            guard point.x < width - 1 else { continue }
            var east: Point2D = point
            while east.x < width - 1 {
                let point = east.adding(.init(x: 1, y: 0))
                guard self[point] == nil else {
                    break
                }
                east = point
            }
            self[point] = nil
            self[east] = char
        }
    }

    mutating func moveWest(width: Int, height: Int) {
        let toMove = self.filter { $0.value == "O" }.sorted { lhs, rhs in
            if lhs.key.x < rhs.key.x {
                return true
            }
            if lhs.key.x > rhs.key.x {
                return false
            }
            return lhs.key.y < rhs.key.y
        }
        for (point, char) in toMove {
            guard point.x > 0 else { continue }
            var west: Point2D = point
            while west.x > 0 {
                let point = west.adding(.init(x: -1, y: 0))
                guard self[point] == nil else {
                    break
                }
                west = point
            }
            self[point] = nil
            self[west] = char
        }
    }

    func calculateLoad(height: Int) -> Int {
        self
            .filter { $0.value == "O" }
            .reduce(0) { res, curr in
                res + (height - curr.key.y)
            }
    }

    func prettyPrint(width: Int, height: Int) {
        for y in 0..<height {
            for x in 0..<width {
                let point = Point2D(x: x, y: y)
                print(self[point] ?? ".", terminator: "")
            }
            print()
        }
    }
}
