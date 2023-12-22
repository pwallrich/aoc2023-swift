import Foundation
import RegexBuilder

class Day22: Day {
    var day: Int { 22 }
    let input: [Bounds]

    let regex = Regex {
        TryCapture {
            Optionally { "-"}
            OneOrMore(.digit)
        } transform: { Int($0) }
        ","
        TryCapture {
            Optionally { "-"}
            OneOrMore(.digit)
        } transform: { Int($0) }
        ","
        TryCapture {
            Optionally { "-"}
            OneOrMore(.digit)
        } transform: { Int($0) }
    }

    typealias Bounds = (start: Point3D, end: Point3D)

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
"""
        } else {
            inputString = try InputGetter.getInput(for: 22, part: .first)
        }

        var numbers: [Bounds] = []
        for row in inputString.split(separator: "\n") {
            let matches = row.matches(of: regex)
            assert(matches.count == 2)
            let first = Point3D(x: matches[0].output.1, y: matches[0].output.2, z: matches[0].output.3)
            let second = Point3D(x: matches[1].output.1, y: matches[1].output.2, z: matches[1].output.3)
            numbers.append((first, second))
        }

        self.input = numbers
    }

    func runPart1() throws {
        var sorted = input.sorted(by: { min($0.0.z, $0.1.z) < min($1.0.z, $1.1.z)} )
        print(sorted)
        print()
        var hasMoved = false
        var fallStep = 0
        repeat {
            hasMoved = false
            for (idx, item) in sorted.enumerated() {
                if min(item.0.z, item.1.z) <= 1 {
                    continue
                }
                guard !sorted.isItemBlocked(at: idx) else {
                    continue
                }
                sorted[idx] = (Point3D(x: item.start.x, y: item.start.y, z: item.start.z - 1), Point3D(x: item.end.x, y: item.end.y, z: item.end.z - 1))
                hasMoved = true
            }
        } while hasMoved

        print(sorted)
        prettyPrint(bounds: sorted)

        var res: Set<Int> = []
        for (idx, item) in sorted.enumerated() {
            var hasMoved = false
            var sorted = sorted.filter { $0 != item }

            for (idx, item) in sorted.enumerated() {
                if min(item.0.z, item.1.z) <= 1 {
                    continue
                }
                guard !sorted.isItemBlocked(at: idx) else {
                    continue
                }
                sorted[idx] = (Point3D(x: item.start.x, y: item.start.y, z: item.start.z - 1), Point3D(x: item.end.x, y: item.end.y, z: item.end.z - 1))
                hasMoved = true
                break
            }
            if !hasMoved {
                res.insert(idx)
            }
        }
        print(res)
        print(res.count)

    }

    func runPart2() throws {
        var sorted = input.sorted(by: { min($0.0.z, $0.1.z) < min($1.0.z, $1.1.z)} )
//        print(sorted)
//        print()
        var hasMoved = false
        repeat {
            hasMoved = false
            for (idx, item) in sorted.enumerated() {
                if min(item.0.z, item.1.z) <= 1 {
                    continue
                }
                guard !sorted.isItemBlocked(at: idx) else {
                    continue
                }
                sorted[idx] = (Point3D(x: item.start.x, y: item.start.y, z: item.start.z - 1), Point3D(x: item.end.x, y: item.end.y, z: item.end.z - 1))
                hasMoved = true
            }
        } while hasMoved

//        prettyPrint(bounds: sorted)

        var res: [Int: Int] = [:]
        for (idx, item) in sorted.enumerated() {
            if idx % 100 == 0 {
                print(idx)
            }
            var sorted = sorted.filter { $0 != item }
            var count = 0
            for (idx, item) in sorted.enumerated() {
                if min(item.0.z, item.1.z) <= 1 {
                    continue
                }
                guard !sorted.isItemBlocked(at: idx) else {
                    continue
                }
                sorted[idx] = (Point3D(x: item.start.x, y: item.start.y, z: item.start.z - 1), Point3D(x: item.end.x, y: item.end.y, z: item.end.z - 1))
                count += 1
            }
            res[idx] = count
        }

        print(res.values.reduce(0, +))
    }

    func prettyPrint(bounds: [Bounds]) {
        let minX = bounds.map { min($0.start.x, $0.end.x) }.min()!
        let minY = bounds.map { min($0.start.y, $0.end.y) }.min()!

        let maxX = bounds.map { max($0.start.x, $0.end.x) }.max()!
        let maxY = bounds.map { max($0.start.y, $0.end.y) }.max()!
        let maxZ = bounds.map { max($0.start.z, $0.end.z) }.max()!

        print("x axis\n")
        for z in (0...maxZ).reversed() {
            print(z, terminator: " ")
            for x in minX...maxX {
                if bounds.contains(where: { ($0.start.z...$0.end.z).contains(z) && ($0.start.x...$0.end.x).contains(x) }) {
                    print("#", terminator: "")
                } else {
                    print(".", terminator: "")
                }
            }
            print()
        }
        print("\ny axis\n")
        for z in (0...maxZ).reversed() {
            print(z, terminator: " ")
            for y in minY...maxY {
                if bounds.contains(where: { ($0.start.z...$0.end.z).contains(z) && ($0.start.y...$0.end.y).contains(y) }) {
                    print("#", terminator: "")
                } else {
                    print(".", terminator: "")
                }
            }
            print()
        }
    }
}

extension Array where Element == Day22.Bounds {
    func isItemBlocked(at idx: Int) -> Bool {
        let item = self[idx]
        let xRange = Swift.min(item.start.x, item.end.x)...Swift.max(item.start.x, item.end.x)
        let yRange = Swift.min(item.start.y, item.end.y)...Swift.max(item.start.y, item.end.y)
        for other in self[..<idx] {
            // too far away. Can't block.
            if Swift.max(other.start.z, other.end.z) != Swift.min(item.start.z, item.end.z) - 1 {
                continue
            }

            let otherXRange = Swift.min(other.start.x, other.end.x)...Swift.max(other.start.x, other.end.x)
            let otherYRange = Swift.min(other.start.y, other.end.y)...Swift.max(other.start.y, other.end.y)
            if otherXRange.overlaps(xRange) && otherYRange.overlaps(yRange) {

                return true
            }
        }
        return false
    }
}
