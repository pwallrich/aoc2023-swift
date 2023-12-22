import Foundation

class Day21: Day {
    var day: Int { 21 }
    let input: Set<Point2D>
    let steps: Int
    let startPoint: Point2D
    let width: Int
    let height: Int

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            steps = 6
            inputString = """
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
"""
        } else {steps = 64
            inputString = try InputGetter.getInput(for: 21, part: .first)
        }
        let rows = inputString.split(separator: "\n")
        var grid: Set<Point2D> = []
        var startPoint: Point2D?
        for (y, row) in rows.enumerated() {
            for(x, char) in row.enumerated() where char != "." {
                if char == "S" {
                    startPoint = .init(x: x, y: y)
                } else {
                    grid.insert(.init(x: x, y: y))
                }
            }
        }
        self.input = grid
        self.startPoint = startPoint!
        self.width = rows[0].count
        self.height = rows.count
    }

    func runPart1() throws {
        var curr = Set([startPoint])
        for _ in 0..<10 {
            var next: Set<Point2D> = []
            for p in curr {
                let adj = p.adjacent(withDiagonal: false).filter { !input.contains($0) }
                next.formUnion(adj)
            }
            curr = next
        }
        print(curr.count)
    }

    func runPart2() throws {
//        print(26501365 / 131)
//        print((202301 * 202301) - 202301 * input.count )
//        return
//        let steps = 26501365

        //solved manually with wolfram alpha and the help of https://www.reddit.com/r/adventofcode/comments/18nevo3/comment/keaiiq7/?utm_source=share&utm_medium=web2x&context=3
    }

    func prettyPrint(next: Set<Point2D>) {
        let minX = next.map(\.x).min()!
        let maxX = next.map(\.x).max()!
        let minY = next.map(\.y).min()!
        let maxY = next.map(\.y).max()!
        for y in minY...maxY {
            for x in minX...maxX {
                if next.contains(.init(x: x, y: y)) {
                    print("*", terminator: "")
                } else if input.contains(offset(point: .init(x: x, y: y))) {
                    print("#", terminator: "")
                } else {
                    print(".", terminator: "")
                }
            }
            print()
        }
    }

    func offset(point: Point2D) -> Point2D {
        let x = point.x < 0 ? width + (point.x % width) : point.x % width
        let y = point.y < 0 ? width + (point.y % height) : point.y % height

//        let gridOffset = Point2D(x: x < 0 ? -1 : x >= width ? 1 : 0, y: y < 0 ? -1 : y >= height ? 1 : 0)
        return .init(x: x, y: y)
    }
}
