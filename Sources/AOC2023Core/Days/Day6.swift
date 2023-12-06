import Foundation
import RegexBuilder
class Day6: Day {
    var day: Int { 6 }
    let input: String

    static let regex = Regex {
        TryCapture {
            OneOrMore(.digit)
        } transform: { Int($0) }
    }

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
Time:      7  15   30
Distance:  9  40  200
"""
        } else {
            inputString = try InputGetter.getInput(for: 6, part: .first)
        }
        self.input = inputString
    }

    func runPart1() throws {
        let rows = input.split(separator: "\n")
        let times = rows[0].matches(of: Self.regex).map(\.output.1)
        let distances: [Int] = rows[1].matches(of: Self.regex).map(\.output.1)

        assert(times.count == distances.count)

        let races = zip(times, distances)
        var res = 1
        for (time, distance) in races {
            var winningRounds = 0
            for curr in 1..<time {
                let raceDistance = curr * (time - curr)
                if raceDistance > distance {
                    winningRounds += 1
                }
            }
            res *= winningRounds
        }

        print(res)
    }

    func runPart2() throws {
        let rows = input.split(separator: "\n")
        let times = rows[0]
            .filter { !$0.isWhitespace}
            .matches(of: Self.regex).map(\.output.1)
        let distances: [Int] = rows[1]
            .filter { !$0.isWhitespace }
            .matches(of: Self.regex).map(\.output.1)

        assert(times.count == 1 && distances.count == 1)

        let time = times[0]
        let distance = distances[0]

        let res = (1..<time).reduce(into: 0) { res, curr in
            let raceDistance = curr * (time - curr)
            if raceDistance > distance {
                res += 1
            }
        }

        print(res)

    }
}
