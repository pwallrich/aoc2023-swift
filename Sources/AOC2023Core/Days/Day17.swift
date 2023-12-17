import Foundation

class Day17: Day {
    var day: Int { 17 }
    let input: String
    let destination: Point2D
    let grid: [[Int]]
    let width: Int
    let height: Int

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""
        } else {
            inputString = try InputGetter.getInput(for: 17, part: .first)
        }
        self.input = inputString

        var grid: [[Int]] = []
        var last: Point2D = Point2D(x: 0, y: 0)
        let rows = input.split(separator: "\n")
        for (y, row) in rows.enumerated() {
            var current: [Int] = []
            for (x, char) in row.enumerated() {
//                let point = Point2D(x: x, y: y)
                current.append(Int(String(char))!)
//                grid[point] = Int(String(char))!
                last = Point2D(x: x, y: y)
            }
            grid.append(current)
        }
        destination = last
        self.grid = grid
        self.width = rows[0].count
        self.height = rows.count
    }

    struct HeapItem: Comparable, Hashable {
        static func < (lhs: Day17.HeapItem, rhs: Day17.HeapItem) -> Bool {
            lhs.heuristic < rhs.heuristic
        }

//        struct MoveDirection: Equatable {
//            let dir: Direction
//            let count: Int
//        }

        let currentPoint: Point2D
        let direction: Direction
        let sum: Int
        let heuristic: Int

        init(currentPoint: Point2D, direction: Direction, sum: Int, destination: Point2D) {
            self.currentPoint = currentPoint
            self.direction = direction
            self.sum = sum
            self.heuristic = sum + currentPoint.manhattan(to: destination) * 10
        }
//        let path: [Point2D: [Direction]]


    }

    func runPart1() throws {
        let startPoint = Point2D(x: 0, y: 0)
        var currentBest: Int = .max
        let heap = MinHeap<HeapItem>()
        heap.insert(.init(currentPoint: startPoint, direction: .up, sum: 0, destination: destination))
        heap.insert(.init(currentPoint: startPoint, direction: .left, sum: 0, destination: destination))
        var steps = 0
        var seen: Set<HeapItem> = []
        while !heap.isEmpty {
            if steps % 1000000 == 0 {
                print(steps, heap.heap.count, currentBest)
            }
            let current = heap.remove()!
            if current.currentPoint == destination {
                currentBest = min(currentBest, current.sum)
                continue
            }
            if current.sum > currentBest {
                continue
            }
            for dir in Direction.allCases {
                switch (dir, current.direction) {
                case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
                    continue
                case (.up, .up), (.down, .down), (.left, .left), (.right, .right):
                    continue
                default:
                    break
                }
                var currPoint = current.currentPoint
                var currSum = current.sum
                for _ in 1...3 {
                    currPoint = currPoint.adding(dir.offset)
                    guard 0..<width ~= currPoint.x, 0..<height ~= currPoint.y else {
                        break
                    }
                    currSum += grid[currPoint.y][currPoint.x]

                    let item = HeapItem(currentPoint: currPoint, direction: dir, sum: currSum, destination: destination)
                    if seen.contains(item) {
                        continue
                    }
                    seen.insert(item)
                    heap.insert(item)
                }
            }
            steps += 1
        }
        print(currentBest)
    }

    func runPart2() throws {
        let startPoint = Point2D(x: 0, y: 0)
        var currentBest: Int = .max
        let heap = MinHeap<HeapItem>()
        heap.insert(.init(currentPoint: startPoint, direction: .up, sum: 0, destination: destination))
        heap.insert(.init(currentPoint: startPoint, direction: .left, sum: 0, destination: destination))
        var steps = 0
        var seen: Set<HeapItem> = []
        while !heap.isEmpty {
            if steps % 1000000 == 0 {
                print(steps, heap.heap.count, seen.count, currentBest)
            }
            let current = heap.remove()!
            if current.currentPoint == destination {
                currentBest = min(currentBest, current.sum)
                continue
            }
            if current.sum > currentBest {
                continue
            }
        outer:
            for dir in Direction.allCases {
                switch (dir, current.direction) {
                case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
                    continue
                case (.up, .up), (.down, .down), (.left, .left), (.right, .right):
                    continue
                default:
                    break
                }
                var currPoint = current.currentPoint
                var currSum = current.sum
                for _ in 0..<3 {
                    currPoint = currPoint.adding(dir.offset)
                    guard 0..<width ~= currPoint.x, 0..<height ~= currPoint.y else {
                        continue outer
                    }
                    currSum += grid[currPoint.y][currPoint.x]
                }
                for _ in 0..<7 {
                    currPoint = currPoint.adding(dir.offset)
                    guard 0..<width ~= currPoint.x, 0..<height ~= currPoint.y else {
                        break
                    }
                    currSum += grid[currPoint.y][currPoint.x]

                    let item = HeapItem(currentPoint: currPoint, direction: dir, sum: currSum, destination: destination)
                    if seen.contains(item) {
                        continue
                    }
                    seen.insert(item)
                    heap.insert(item)
                }
            }
            steps += 1
        }
        print(currentBest)
    }
}

extension Array where Element == [Int] {
    func prettyPrint(path: Set<Point2D>) {
//        let maxX = keys.map(\.x).max()!
//        let maxY = keys.map(\.y).max()!
        for (y, row) in self.enumerated() {
            for (x, value) in row.enumerated() {
                let point = Point2D(x: x, y: y)
                if path.contains(point) {
                    print("*", terminator: "")
                } else {
                    print(value, terminator: "")
                }
            }
            print()
        }
    }
}

extension Dictionary where Key == Point2D, Value == Int {
    func prettyPrint(path: [Point2D]) {
        let maxX = keys.map(\.x).max()!
        let maxY = keys.map(\.y).max()!
        for y in 0...maxY {
            for x in 0...maxX {
                let point = Point2D(x: x, y: y)
                if path.contains(point) {
                    print("*", terminator: "")
                } else {
                    print(self[.init(x: x, y: y)]!, terminator: "")
                }
            }
            print()
        }
    }
}
