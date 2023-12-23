import Foundation

class Day23: Day {
    var day: Int { 23 }
    let input: String
    let grid: [Point2D: Character]
    
    let startPoint: Point2D
    let endPoint: Point2D

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#
"""
        } else {
            inputString = try InputGetter.getInput(for: 23, part: .first)
        }
        self.input = inputString
        var grid: [Point2D: Character] = [:]
        var startPoint: Point2D?
        var endPoint: Point2D?
        let rows = input.split(separator: "\n")
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() where char != "#" {
                if startPoint == nil {
                    startPoint = Point2D(x: x, y: y)
                }
                grid[.init(x: x, y: y)] = char
                if y == rows.count - 1 {
                    endPoint = Point2D(x: x, y: y)
                }
            }
        }
        self.grid = grid
        self.startPoint = startPoint!
        self.endPoint = endPoint!
    }

    func runPart1() throws {
        print(grid)
        var curr: [(Point2D, [Point2D], Character)] = [(startPoint, [startPoint], ".")]
        var steps = 0
        while !curr.isEmpty {
            print(steps, curr.count)
            var nextSteps: [(Point2D, [Point2D], Character)] = []
            for (next, seen, currChar) in curr {
                let directions: [Direction] = switch currChar {
                case ".": Direction.allCases
                case "^": [Direction.up]
                case ">": [Direction.right]
                case "v": [Direction.down]
                case "<": [Direction.left]
                default: fatalError()
                }
                for direction in directions {
                    let adj = next.adding(direction.offset)
                    guard let char = grid[adj] else { continue }
                    guard !seen.contains(adj) else { continue }
                    nextSteps.append((adj, seen + [adj], char))
                }
            }
            curr = nextSteps
            steps += 1
        }
        print(steps - 1)
    }

    func runPart2() throws {
        let conjunctions: [Point2D] = findConjunctions()
        let paths: [Point2D: [(Point2D, Int)]] = calculatePathsBetween(conjunctions: conjunctions)

        let res = findPath(current: startPoint, seen: [startPoint], paths: paths)
        print(res)
    }

    func findConjunctions() -> [Point2D] {
        var conjunctions: [Point2D] = [startPoint, endPoint]
        for item in grid where item.value == "." {
            let adj = item.key.adjacent(withDiagonal: false).filter {
                guard let value = grid[$0] else { return false }
                guard value != "." else { return false }
                return true
            }
            if adj.count > 1 {
                conjunctions.append(item.key)
            }
        }
        return conjunctions
    }

    func calculatePathsBetween(conjunctions: [Point2D]) -> [Point2D: [(Point2D, Int)]] {
        var paths: [Point2D: [(Point2D, Int)]] = [:]
        for conjuction in conjunctions {
            let adjs = conjuction.adjacent(withDiagonal: false).filter { grid[$0] != nil }
            for start in adjs {
                var curr = start
                var path: [Point2D] = [conjuction, start]
                repeat {
                    path.append(curr)
                    let adj = curr.adjacent(withDiagonal: false).filter { grid[$0] != nil && !path.contains($0) }
                    if adj.isEmpty {
                        print("dead end")
                        continue
                    }
                    if adj.count > 1 {
                        fatalError()
                    }
                    curr = adj[0]
                } while !conjunctions.contains(curr)
                paths[conjuction, default:[]].append((curr, path.count - 1))
            }
        }
        return paths
    }

    func findPath(current: Point2D, seen: [Point2D], paths: [Point2D: [(Point2D, Int)]]) -> Int {
        if current == endPoint {
            return 0
        }
        var best: Int = 0
        for (adj, steps) in paths[current]! where !seen.contains(adj) {
            let bestFromHere = findPath(current: adj, seen: seen + [adj], paths: paths)
            best = max(best, bestFromHere + steps)
        }

        return best
    }
}

extension Dictionary where Key == Point2D, Value == Character {
    func prettyPrint(withPath path: [Point2D]) {
        let minX = self.map(\.key.x).min()!
        let minY = self.map(\.key.y).min()!
        let maxX = self.map(\.key.x).max()!
        let maxY = self.map(\.key.y).max()!

        for y in minY...maxY {
            for x in minX...maxX {
                let point = Point2D(x: x, y: y)
                if path.contains(point) {
                    print("O", terminator: "")
                } else if let char = self[point] {
                    print(char, terminator: "")
                } else {
                    print("#", terminator: "")
                }
            }
            print()
        }
    }
}
