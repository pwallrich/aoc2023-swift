import Foundation
import RegexBuilder

class Day8: Day {
    var day: Int { 8 }
    let input: (directions: Substring, mapping: [Substring: (left: Substring, right: Substring)])

    let regex = Regex {
        Capture {
            OneOrMore(.word)
        }
        " = ("
        Capture {
            OneOrMore(.word)
        }
        ", "
        Capture {
            OneOrMore(.word)
        }
        ")"
    }

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""
        } else {
            inputString = try InputGetter.getInput(for: 8, part: .first)
        }
        let newline = inputString.firstIndex(of: "\n")!
        let directions = inputString[..<newline]

        var mapping: [Substring: (left: Substring, right: Substring)] = [:]
        for match in inputString[newline...].matches(of: regex) {
            mapping[match.output.1] = (match.output.2, match.output.3)
        }
        self.input = (directions, mapping)
    }

    func runPart1() throws {
        let result = calculateStepsToFinish(start: "AAA") { $0 == "ZZZ" }
        print(result)
    }

    func runPart2() async throws {
        let current: [Substring] = input.mapping.keys.filter { $0.last == "A" }
        let stepsNeeded = current.map { 
            calculateStepsToFinish(start: $0) { $0.last == "Z"}
        }

        print(leastCommonMultiple(numbers: stepsNeeded))
    }

    func calculateStepsToFinish(start: Substring, isFinished: (Substring) -> Bool) -> Int {
        print("calculating \(start)")
        var current: Substring = start
        var steps = 0
        var idx = input.directions.startIndex

        while !isFinished(current) {
            let directions = input.directions[idx]
            let nextValues = input.mapping[current]!
            switch directions {
            case "R":
                current = nextValues.right
            case "L":
                current = nextValues.left
            default:
                fatalError()
            }
            steps += 1
            idx = input.directions.index(after: idx)
            if idx == input.directions.endIndex {
                idx = input.directions.startIndex
            }
        }
        print(steps)
        return steps
    }
}
