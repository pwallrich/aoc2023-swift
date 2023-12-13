import Foundation

class Day13: Day {
    var day: Int { 13 }
    let grids: [Set<Point2D>]
    let input: String

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
"""
        } else {
            inputString = try InputGetter.getInput(for: 13, part: .first)
        }
        var grids: [Set<Point2D>] = []

        for gridString in inputString.split(separator: "\n\n") {
            var curr: Set<Point2D> = []
            for (y, row) in gridString.lazy.split(separator: "\n").enumerated() {
//                print(row)
                for (x, char) in row.enumerated() where char == "#" {
                    curr.insert(.init(x: x, y: y))
                }
            }
            grids.append(curr)
        }

        self.grids = grids
        self.input = inputString
    }

    func runPart1() throws {
        let grids = input.split(separator: "\n\n")
        var res = 0
        for (idx, grid) in grids.enumerated() {
            print("at ", idx, "of: ", grids.count)
            let rows = grid.split(separator: "\n").map { Array($0) }
            let found = getValue(for: rows)
            let value = found!.horizontal ? found!.idx * 100 : found!.idx
            res += value
        }
        print(res)
    }

    func getValue(for rows: [[Character]], skipping: (Int, Bool)? = nil) -> (idx: Int, horizontal: Bool)? {
        let skipping = skipping ?? (-1, false)
        for i in 1..<rows.count {
            if skipping.1 && skipping.0 == i { continue }
            let lower = rows.dropFirst(i).prefix(i)
            let upper = rows[..<i].dropFirst(abs(i - lower.count))
            if Array(lower) == upper.reversed() {
                return (i, true)
            }
        }

        let charArray = rows.map { Array($0) }
        // turn
        var flipped: [[Character]] = Array(repeating: Array(repeating: ".", count: charArray.count), count: charArray[0].count)
        for (y, row) in charArray.enumerated() {
            for (x, char) in row.enumerated() {
                let newX = charArray.count - y - 1
                let newY = x
                flipped[newY][newX] = char
            }
        }
//            print(flipped)
        for i in 1..<flipped.count {
            if !skipping.1 && skipping.0 == i { continue }
            let lower = flipped.dropFirst(i).prefix(i)
            let upper = flipped[..<i].dropFirst(abs(i - lower.count))
            if Array(lower) == upper.reversed() {
                return (i, false)
            }
        }
        return nil
    }

    func runPart2() throws {
        let grids = input.split(separator: "\n\n")
        var res = 0
        for (idx, grid) in grids.enumerated() {
            print("at ", idx, "of: ", grids.count)
            let rows = grid.split(separator: "\n").map { Array($0) }

            let oldMirror = getValue(for: rows)!
            var didFind = false
            if rows[0] == Array("#..#..##.#.") && rows[1] == Array("#..#..##.#.") {
                print()
            }
        outer:
            for (y, row) in rows.enumerated() {
                print("at ", idx, "of: ", grids.count, "row:", y)
                for (x, char) in row.enumerated() {
                    var changed = rows
//                    print(changed)
                    changed[y][x] = char == "." ? "#" : "."

                    guard let found = getValue(for: changed, skipping: oldMirror) else {
                        continue
                    }
                    if found == oldMirror { continue }
                    let value = found.horizontal ? (found.idx) * 100 : found.idx
                    res += value
                    didFind = true
                    break outer
                }
            }
            guard !didFind else {
                continue
            }
            for row in rows {
                print(row.reduce("") { $0 + String($1) })
            }
            assert(didFind)
        }
        print(res)
    }
}
