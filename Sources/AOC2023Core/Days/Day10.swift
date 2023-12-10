import Foundation

class Day10: Day {
    var day: Int { 10 }
    let input: [Point2D: Pipe]
    let startPosition: Point2D

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........
"""
        } else {
            inputString = try InputGetter.getInput(for: 10, part: .first)
        }

        var grid: [Point2D: Pipe] = [:]
        let rows = inputString.split(separator: "\n")
        var start: Point2D?
        for (y, row) in rows.reversed().enumerated() {

            for (x, char) in row.enumerated() {
                let point = Point2D(x: x, y: y)
                switch char {
//                    | is a vertical pipe connecting north and south.
                case "|":
                    grid[point] = [.up, .down]
//                    - is a horizontal pipe connecting east and west.
                case "-":
                    grid[point] = [.left, .right]
//                    L is a 90-degree bend connecting north and east.
                case "L":
                    grid[point] = [.up, .right]
//                    J is a 90-degree bend connecting north and west.
                case "J":
                    grid[point] = [.up, .left]
//                    7 is a 90-degree bend connecting south and west.
                case "7":
                    grid[point] = [.down, .left]
//                    F is a 90-degree bend connecting south and east.
                case "F":
                    grid[point] = [.down, .right]
                case "S":
                    start = point
                case ".":
                    continue
                default:
                    fatalError()
                }
            }
        }

        let allDirs: Pipe = [.up, .right, .left, .down]
        var startDirs = Pipe(rawValue: 0)
        for adj in allDirs.adjacents {
            let nextPoint = start!.adding(adj)
            guard let otherPipe = grid[nextPoint] else {
                continue
            }
            let otherAdj = otherPipe.adjacents
            // check whether the pipes are connected
            guard otherAdj.map({ Point2D(x: $0.x * -1, y: $0.y * -1) }).contains(adj) else {
                continue
            }
            switch (adj.x, adj.y) {
            case (0, 1): startDirs.insert(.up)
            case (0, -1): startDirs.insert(.down)
            case (1, 0): startDirs.insert(.right)
            case (-1, 0): startDirs.insert(.left)
            default:
                fatalError()
            }
        }
        grid[start!] = startDirs

        self.input = grid
        self.startPosition = start!
    }

    func runPart1() throws {
        let loop = buildLoop()
        print(loop.values.max()!)
    }

    func runPart2() throws {
        let loop = buildLoop()

        let minX = loop.keys.map(\.x).min()!
        let maxX = loop.keys.map(\.x).max()!
        let minY = loop.keys.map(\.y).min()!
        let maxY = loop.keys.map(\.y).max()!

        let loopElements = Set(loop.keys)

        var res = 0
        for y in minY...maxY {
            for x in minX...maxX where !loop.keys.contains(.init(x: x, y: y)){
                let intersections = intersectionsOfRaycast(start: .init(x: x, y: y),
                                                           loop: loopElements,
                                                           xRange: minX...maxX,
                                                           yRange: minY...maxY)
                if intersections % 2 == 1 {
                    res += 1
                }
            }
        }

        print(res)
    }

    func buildLoop() -> [Point2D: Int] {
        var current: [Point2D: Pipe] = [startPosition: input[startPosition]!]
        var loop: [Point2D: Int] = [startPosition: 0]
        var steps = 0
        repeat {
            var next: [Point2D: Pipe] = [:]
            steps += 1
            for (point, pipe)  in current {
                for adj in pipe.adjacents {
                    let nextPoint = point.adding(adj)
                    guard let otherPipe = input[nextPoint] else {
                        continue
                    }
                    let otherAdj = otherPipe.adjacents
                    // check whether the pipes are connected
                    guard otherAdj.map({ Point2D(x: $0.x * -1, y: $0.y * -1) }).contains(adj) else {
                        continue
                    }

                    if loop[nextPoint] != nil {
                        // we've already been there
                        continue
                    }
                    next[nextPoint] = otherPipe
                    loop[nextPoint] = steps
                }
            }
            current = next
        } while !current.isEmpty
        return loop
    }

    func intersectionsOfRaycast(start: Point2D, loop: Set<Point2D>, xRange: ClosedRange<Int>, yRange: ClosedRange<Int>) -> Int {
//        print("at \(current)")
        var count = 0
        var toCheck = start
        while xRange.contains(toCheck.x) && yRange.contains(toCheck.y) {
            if loop.contains(toCheck) && input[toCheck] != [.up, .left] && input[toCheck] != [.down, .right] {
                count += 1
            }
            toCheck = toCheck.adding(.init(x: 1, y: 1))
        }
        return count
    }
}

struct Pipe: OptionSet {
    let rawValue: Int

    static let up = Pipe(rawValue: 1 << 0)
    static let right = Pipe(rawValue: 1 << 1)
    static let down = Pipe(rawValue: 1 << 2)
    static let left = Pipe(rawValue: 1 << 3)

    var adjacents: [Point2D] {
        var result: [Point2D] = []
        if self.contains(.up) {
            result.append(.init(x: 0, y: 1))
        }
        if self.contains(.right) {
            result.append(.init(x: 1, y: 0))
        }
        if self.contains(.down) {
            result.append(.init(x: 0, y: -1))
        }
        if self.contains(.left) {
            result.append(.init(x: -1, y: 0))
        }
        return result
    }
}
