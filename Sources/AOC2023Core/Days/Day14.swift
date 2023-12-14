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
        var hasMoved = false
        var step = 0
        var toMove = self.filter { $0.value == "O" }.sorted { lhs, rhs in
            if lhs.key.y < rhs.key.y {
                return true
            }
            if lhs.key.y > rhs.key.y {
                return false
            }
            return lhs.key.x < rhs.key.x
        }
        repeat {
//            next.prettyPrint(width: width, height: height)
//            if step % 10 == 0 {
//                print("at \(step)")
//            }
//            print()
            hasMoved = false

            for (idx, (point, char)) in toMove.enumerated() {
                let north = point.adding(Point2D(x: 0, y: -1))
                guard north.y >= 0, self[north] == nil else {
                    continue
                }
                self[point] = nil
                self[north] = char
                hasMoved = true
                toMove[idx] = (north, char)
            }
            step += 1

        } while hasMoved
    }

    mutating func moveSouth(width: Int, height: Int) {
        var hasMoved = false

        var step = 0
        var toMove = self.filter { $0.value == "O" }.sorted { lhs, rhs in
            if lhs.key.y > rhs.key.y {
                return true
            }
            if lhs.key.y < rhs.key.y {
                return false
            }
            return lhs.key.x < rhs.key.x
        }
        repeat {
//            next.prettyPrint(width: width, height: height)
//            if step % 10 == 0 {
//                print("at \(step)")
//            }
//            print()
            hasMoved = false

            for (idx, (point, char)) in toMove.enumerated() {
                let south = point.adding(Point2D(x: 0, y: 1))
                guard south.y < height, self[south] == nil else {
                    continue
                }
                self[point] = nil
                self[south] = char
                hasMoved = true
                toMove[idx] = (south, char)
            }
            step += 1

        } while hasMoved
    }

    mutating func moveEast(width: Int, height: Int) {
        var hasMoved = false
        var step = 0
        var toMove = self.filter { $0.value == "O" }.sorted { lhs, rhs in
            if lhs.key.x > rhs.key.x {
                return true
            }
            if lhs.key.x < rhs.key.x {
                return false
            }
            return lhs.key.y < rhs.key.y
        }
        repeat {
//            next.prettyPrint(width: width, height: height)
//            if step % 10 == 0 {
//                print("at \(step)")
//            }
//            print()
            hasMoved = false

            for (idx, (point, char)) in toMove.enumerated() {
                let east = point.adding(Point2D(x: 1, y: 0))
                guard east.x < width, self[east] == nil else {
                    continue
                }
                self[point] = nil
                self[east] = char
                hasMoved = true
                toMove[idx] = (east, char)
            }
            step += 1

        } while hasMoved
    }

    mutating func moveWest(width: Int, height: Int) {
        var hasMoved = false

        var toMove = self.filter { $0.value == "O" }.sorted { lhs, rhs in
            if lhs.key.x < rhs.key.x {
                return true
            }
            if lhs.key.x > rhs.key.x {
                return false
            }
            return lhs.key.y < rhs.key.y
        }
        var step = 0
        repeat {
//            next.prettyPrint(width: width, height: height)
//            if step % 10 == 0 {
//                print("at \(step)")
//            }
//            print()
            hasMoved = false

            for (idx, (point, char)) in toMove.enumerated() {
                let west = point.adding(Point2D(x: -1, y: 0))
                guard west.x >= 0, self[west] == nil else {
                    continue
                }
                self[point] = nil
                self[west] = char
                hasMoved = true
                toMove[idx] = (west, char)
            }
            step += 1

        } while hasMoved
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
