import Foundation
import RegexBuilder

class Day2: Day {
    var day: Int { 2 }
    let input: String

    let gameRegex = Regex {
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int($0)
        }
        " "
        Capture {
            ChoiceOf {
                "red"
                "green"
                "blue"
            }
        }
    }

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""
        } else {
            inputString = try InputGetter.getInput(for: 2, part: .first)
        }
        self.input = inputString
    }

    func runPart1() throws {
        let valid: [Substring: Int] = [
            "red": 12,
            "green": 13,
            "blue": 14
        ]
        let result = input
            .split(separator: "\n")
            .enumerated()
            .filter { (idx, row) in
                return !row.matches(of: gameRegex)
                    .contains { valid[$0.output.2]! < $0.output.1 }
            }
            .map { $0.offset + 1}
            .reduce(0, +)
        print(result)
    }

    func runPart2() throws {
        let result = input
            .split(separator: "\n")
            .map { row in
                let cubesNeeded = row.matches(of: gameRegex)
                    .reduce(into: [Substring:Int]()) { res, curr in
                        let currentMax = res[curr.output.2, default: 0]
                        res[curr.output.2] = max(currentMax, curr.output.1)
                    }
                return cubesNeeded.values.reduce(1, *)
            }
            .reduce(0, +)
        print(result)
    }
}
