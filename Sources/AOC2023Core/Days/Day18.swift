import Foundation

class Day18: Day {
    var day: Int { 18 }
    let input: [Substring]

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
"""
        } else {
            inputString = try InputGetter.getInput(for: 18, part: .first)
        }
        self.input = inputString
            .split(separator: "\n")
    }

    func runPart1() throws {
        var current = Point2D(x: 0, y: 0)
        var edges: [Point2D] = [current]

        for row in input {
            let values = row.split(separator: " ")
            let direction = values[0]
            let steps = Int(String(values[1]))!


            let offset = switch direction {
            case "R": Point2D(x: 1, y: 0)
            case "D": Point2D(x: 0, y: 1)
            case "U": Point2D(x: 0, y: -1)
            case "L": Point2D(x: -1, y: 0)
            default:
                fatalError()
            }

            current = current.adding(.init(x: steps * offset.x, y: steps * offset.y))
            edges.append(current)
        }
        let innerArea = shoeLaceFormula(of: edges)
        let outer = perimeter(of: edges)

        // Pick's theorem
        // A = i + b/2 - 1
        // i + b = A + b/2 + 1
        let total = abs(innerArea) + (outer / 2) + 1

        print(total)

    }

    func shoeLaceFormula(of edges: [Point2D]) -> Int {
        edges
            .windows(ofCount: 2)
            .map { values in
                let (a, b) = (values.first!, values.last!)
                return a.x * b.y - a.y * b.x
            }
            .reduce(0, +) / 2
    }

    func perimeter(of edges: [Point2D]) -> Int {
        edges
            .windows(ofCount: 2)
            .map { abs($0.first!.x - $0.last!.x) + abs($0.first!.y - $0.last!.y) }
            .reduce(0, +)
    }

    func runPart2() throws {
        var current = Point2D(x: 0, y: 0)
        var edges: [Point2D] = [current]

        for row in input {
            let endIdx = row.lastIndex(of: " ")!
            var hex = row[endIdx...].dropFirst(3).dropLast()
            let direction = hex.removeLast()
            let steps = Int(String(hex), radix: 16)!

            let offset = switch direction {
            case "0": Point2D(x: 1, y: 0)
            case "1": Point2D(x: 0, y: 1)
            case "2": Point2D(x: -1, y: 0)
            case "3": Point2D(x: 0, y: -1)
            default:
                fatalError()
            }

            current = current.adding(.init(x: steps * offset.x, y: steps * offset.y))
            edges.append(current)
        }

        let innerArea = shoeLaceFormula(of: edges)
        let outer = perimeter(of: edges)

        // Pick's theorem
        // A = i + b/2 - 1
        // i + b = A + b/2 + 1
        let total = abs(innerArea) + (outer / 2) + 1

        print(total)
    }
}
