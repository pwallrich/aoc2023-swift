import Foundation
import RegexBuilder

class Day24: Day {
    var day: Int { 24 }
    let input: [(start: DPoint3D, v: DPoint3D)]

    let regex = Regex {
        TryCapture {
            Optionally("-")
            OneOrMore(.digit)
        } transform: { Double($0) }
        ","
        TryCapture {
            Optionally("-")
            OneOrMore(.digit)
        } transform: { Double($0) }
        ","
        TryCapture {
            Optionally("-")
            OneOrMore(.digit)
        } transform: { Double($0) }
    }

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
"""
        } else {
            inputString = try InputGetter.getInput(for: 24, part: .first)
        }
        var values: [(DPoint3D, DPoint3D)] = []
        for row in inputString.split(separator: "\n") {
            let matches = row.filter { !$0.isWhitespace }.matches(of: regex)
            assert(matches.count == 2)
            values.append((
                DPoint3D(x: matches[0].output.1, y: matches[0].output.2, z: matches[0].output.3),
                DPoint3D(x: matches[1].output.1, y: matches[1].output.2, z: matches[1].output.3)))
        }
        self.input = values
    }

    func runPart1() throws {
        //        print(input)
        let lower: Double = 200000000000000
        let upper: Double = 400000000000000
        var res = 0
        for values in input.combinations(ofCount: 2) {
            let first = values[0]
            let second = values[1]

            let inter = linesCross(start1: .init(x: first.start.x , y: first.start.y),
                                   end1: .init(x: first.start.x + first.v.x * upper, y: first.start.y + first.v.y * upper),
                                   start2: .init(x: second.start.x, y: second.start.y),
                                   end2: .init(x: second.start.x + second.v.x * upper, y: second.start.y + second.v.y * upper))
            guard let inter else { continue }
            if lower...upper ~= inter.x && lower...upper ~= inter.y {
                res += 1
            }
        }
        print(res)

    }

    func linesCross(start1: CGPoint, end1: CGPoint, start2: CGPoint, end2: CGPoint) -> (x: Double, y: Double)? {
        // calculate the differences between the start and end X/Y positions for each of our points
        let delta1x = end1.x - start1.x
        let delta1y = end1.y - start1.y
        let delta2x = end2.x - start2.x
        let delta2y = end2.y - start2.y

        // create a 2D matrix from our vectors and calculate the determinant
        let determinant = delta1x * delta2y - delta2x * delta1y

        if abs(determinant) < 0.0001 {
            // if the determinant is effectively zero then the lines are parallel/colinear
            return nil
        }

        // if the coefficients both lie between 0 and 1 then we have an intersection
        let ab = ((start1.y - start2.y) * delta2x - (start1.x - start2.x) * delta2y) / determinant

        if ab > 0 && ab < 1 {
            let cd = ((start1.y - start2.y) * delta1x - (start1.x - start2.x) * delta1y) / determinant

            if cd > 0 && cd < 1 {
                // lines cross – figure out exactly where and return it
                let intersectX = start1.x + ab * delta1x
                let intersectY = start1.y + ab * delta1y
                return (intersectX, intersectY)
            }
        }

        // lines don't cross
        return nil
    }

    func runPart2() throws {
        // TODO
        fatalError("Not solved yet")
    }
}

