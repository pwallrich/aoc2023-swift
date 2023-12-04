import Foundation
import RegexBuilder

class Day4: Day {
    var day: Int { 4 }
    let input: [(Set<Int>, [Int])]

    static let regex = Regex {
        TryCapture {
            OneOrMore(.digit)
        } transform: { Int($0) }
    }

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"""
        } else {
            inputString = try InputGetter.getInput(for: 4, part: .first)
        }
        self.input = inputString
            .split(separator: "\n")
            .map { row in
                let colonIdx = row.firstIndex(of: ":")!
                let toUse = row[colonIdx...]
                let split = toUse.split(separator: "|")
                let winning = split[0].matches(of: Self.regex).map(\.output.1)
                let scratched = split[1].matches(of: Self.regex).map(\.output.1)
                return (Set(winning), scratched)
             }
    }

    func runPart1() throws {
        var res = 0
        for (winning, scratched) in input {
            var temp = 1
            for value in scratched {
                if winning.contains(value) {
                    temp = temp << 1
                }
            }
            // need to divide by 2, since we started with 1 and not zero to be able to shift left
            res += temp / 2
        }
        print(res)
    }

    func runPart2() throws {
        var cardAmount = Array(repeating: 1, count: input.count)
        for (idx, (winning, scratched)) in input.enumerated() {
            var found = 0
            for value in scratched {
                if winning.contains(value) {
                    found += 1
                }
            }

            guard found > 0 else {
                continue
            }

            for offset in 1...found where offset + idx < input.count {
                let newIdx = idx + offset
                cardAmount[newIdx] += cardAmount[idx]
            }
        }
        print(cardAmount.reduce(0, +))
    }
}
