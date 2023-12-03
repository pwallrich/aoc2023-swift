import Foundation
import RegexBuilder

class Day3: Day {
    var day: Int { 3 }
    let input: String

    let regex = Regex {
        TryCapture {
            OneOrMore(.digit)
        } transform: { Int($0) }
    }

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......598.
...$.*....
.664.598..
"""
        } else {
            inputString = try InputGetter.getInput(for: 3, part: .first)
        }
        self.input = inputString
    }

    func runPart1() throws {
        let rowLength = input.enumerated().first { $0.element == "\n" }!.offset

        let input = input.filter { !$0.isNewline }
        var res = 0
        for match in input.matches(of: regex) where input.isPart(range: match.range, rowLength: rowLength) {
//            print("adding \(match.output.1)")
            res += match.output.1
        }
        print(res)


    }

    func runPart2() throws {
        let rowLength = input.enumerated().first { $0.element == "\n" }!.offset

        let input: [Character] = input.filter { !$0.isNewline }
        var res = 0
        for (idx, char) in input.enumerated() where char == "*" {

            var points: [Int] = []
            // keep track, so no duplicates are added
            var usedIndices: Set<Int> = []
            for adj in [-rowLength - 1, -rowLength, -rowLength + 1, -1, +1, rowLength - 1, rowLength, rowLength + 1] {
                let idxToCheck = idx + adj
                guard input.indices.contains(idxToCheck),
                      input[idxToCheck].isNumber else {
                    continue
                }
                var lower = idxToCheck
                var upper = idxToCheck
                var result: [Character] = []
                var current = idxToCheck
                // fill up to left
                while input.indices.contains(current), input[current].isNumber {
                    result = [input[current]] + result
                    lower = current
                    current -= 1
                }
                current = idxToCheck + 1
                // fill up to right
                while input.indices.contains(current), input[current].isNumber {
                    result.append(input[current])
                    upper = current
                    current += 1
                }
                // if any of the digits is already checked, the whole range was checked
                guard !usedIndices.contains(lower) else { continue }
                points.append(Int(String(result))!)
                (lower...upper).forEach { usedIndices.insert($0) }

            }
            guard points.count == 2 else { continue }
            res += points.reduce(1, *)
        }

        print(res)
    }
}

private extension String {
    func isPart(range: Range<String.Index>, rowLength: Int) -> Bool {
        let startIdx = distance(from: startIndex, to: range.lowerBound)
        let endIdx = distance(from: startIndex, to: range.upperBound)
        // symbol before
        if startIdx - 1 > 0 {
            let char = self[index(before: range.lowerBound)]
            if !(char == "." || char.isNumber) {
                return true
            }
        }
        // symbol after
        if endIdx < self.count {
            let char = self[range.upperBound]
            if !(char == "." || char.isNumber || char.isNewline) {
                return true
            }
        }
        // up
        if (startIdx - rowLength) - 1 > 0 {
            let start = index(startIndex, offsetBy: startIdx - rowLength - 1)
            let end = index(startIndex, offsetBy: endIdx - rowLength)
            let substring = self[start...end]
            for char in substring {
                if !(char == "." || char.isNumber || char.isNewline) {
                    return true
                }
            }
        }
        // down
        if (endIdx + rowLength) < self.count  {
            let start = index(startIndex, offsetBy: startIdx + rowLength - 1)
            let end = index(startIndex, offsetBy: endIdx + rowLength)
            let substring = self[start...end]
            for char in substring {
                if !(char == "." || char.isNumber || char.isNewline) {
                    return true
                }
            }
        }
        return false
    }
}
