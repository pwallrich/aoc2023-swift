import Foundation

class Day16: Day {
    var day: Int { 16 }
    let input: String
    let grid: [Point2D: Character]
    let width: Int
    let height: Int

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = #"""
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
"""#
        } else {
            inputString = try InputGetter.getInput(for: 16, part: .first)
        }
        self.input = inputString
        let rows = input.lazy.split(separator: "\n")
        var grid: [Point2D: Character] = [:]
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() where char != "." {
                grid[.init(x: x, y: y)] = char
            }
        }

        self.grid = grid
        self.height = rows.count
        self.width = rows.first!.count
    }

    struct Current: Hashable {
        let point: Point2D
        let dir: Direction
    }

    func runPart1() throws {
        let res = calculateEnergizedCount(startingAt: .init(point: .init(x: 0, y: 0), dir: .right))
        print(res)
    }

    func runPart2() async throws {
        var startPoints: [Current] = []
        startPoints.append(.init(point: .init(x: 0, y: 0), dir: .right))
        startPoints.append(.init(point: .init(x: width - 1, y: 0), dir: .left))
        startPoints.append(.init(point: .init(x: 0, y: height - 1), dir: .right))
        startPoints.append(.init(point: .init(x: width - 1, y: height - 1), dir: .left))

        for x in 0..<width {
            startPoints.append(.init(point: .init(x: x, y: 0), dir: .down))
            startPoints.append(.init(point: .init(x: x, y: height - 1), dir: .up))
        }
        for y in 1..<(height - 1) {
            startPoints.append(.init(point: .init(x: 0, y: y), dir: .right))
            startPoints.append(.init(point: .init(x: width - 1, y: y), dir: .left))
        }

        let res = await withTaskGroup(of: Int.self) { group in
            for startPoint in startPoints {
                group.addTask {
                    return self.calculateEnergizedCount(startingAt: startPoint)
                }
            }
            return await group.reduce(Int.min, max)
        }
        print(res)
    }

    func calculateEnergizedCount(startingAt startPoint: Current) -> Int {
        var current: [Current] = [startPoint]
        var seen: Set<Current> = []

        var steps = 0
        while !current.isEmpty {
            var next: [Current] = []
            for curr in current {
                guard !seen.contains(curr) else { continue }
                guard 0..<height ~= curr.point.y, 0..<width ~= curr.point.x else {
                    continue
                }

                seen.insert(curr)

                guard let value = grid[curr.point] else {
                    let nextPoint = curr.point.adding(curr.dir.offset)
                    next.append(.init(point: nextPoint, dir: curr.dir))
                    continue
                }

                switch (value, curr.dir) {
                case ("\\", .up):
                    let nextPoint = curr.point.adding(Direction.left.offset)
                    next.append(.init(point: nextPoint, dir: Direction.left))
                case ("\\", .right):
                    let nextPoint = curr.point.adding(Direction.down.offset)
                    next.append(.init(point: nextPoint, dir: Direction.down))
                case ("\\", .down):
                    let nextPoint = curr.point.adding(Direction.right.offset)
                    next.append(.init(point: nextPoint, dir: Direction.right))
                case ("\\", .left):
                    let nextPoint = curr.point.adding(Direction.up.offset)
                    next.append(.init(point: nextPoint, dir: Direction.up))

                case ("/", .up):
                    let nextPoint = curr.point.adding(Direction.right.offset)
                    next.append(.init(point: nextPoint, dir: Direction.right))
                case ("/", .right):
                    let nextPoint = curr.point.adding(Direction.up.offset)
                    next.append(.init(point: nextPoint, dir: Direction.up))
                case ("/", .down):
                    let nextPoint = curr.point.adding(Direction.left.offset)
                    next.append(.init(point: nextPoint, dir: Direction.left))
                case ("/", .left):
                    let nextPoint = curr.point.adding(Direction.down.offset)
                    next.append(.init(point: nextPoint, dir: Direction.down))

                case ("|", .up), ("|", .down),
                    ("-", .right), ("-", .left):
                    let nextPoint = curr.point.adding(curr.dir.offset)
                    next.append(.init(point: nextPoint, dir: curr.dir))

                case ("|", _):
                    let up = curr.point.adding(Direction.up.offset)
                    next.append(.init(point: up, dir: Direction.up))
                    let down = curr.point.adding(Direction.down.offset)
                    next.append(.init(point: down, dir: Direction.down))
                case ("-", _):
                    let left = curr.point.adding(Direction.left.offset)
                    next.append(.init(point: left, dir: Direction.left))
                    let right = curr.point.adding(Direction.right.offset)
                    next.append(.init(point: right, dir: Direction.right))
                default:
                    fatalError()
                }

            }
            current = next
            steps += 1
        }
        let points = Set(seen.map(\.point))
        return points.count
    }
}
