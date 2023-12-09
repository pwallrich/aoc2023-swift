import Foundation

class Day9: Day {
    var day: Int { 9 }
    let input: [[Int]]

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""
        } else {
            inputString = try InputGetter.getInput(for: 9, part: .first)
        }
        self.input = inputString
            .split(separator: "\n")
            .map { row in
                row
                    .split(separator: " ")
                    .map { Int(String($0))! }
            }
    }

    func runPart1() throws {
        var res = 0
        for row in input {
            let next = findNextValue(for: row, extrapolation: extrapolateNextValue(for:))
            res += next
        }
        print(res)
    }

    func runPart2() throws {
        var res = 0
        for row in input {
            let next = findNextValue(for: row, extrapolation: extrapolatePreviousValue(for:))
            res += next
        }
        print(res)
    }

    func findNextValue(for sequence: [Int], extrapolation: (ArraySlice<[Int]>) -> Int) -> Int {
        var differences = [sequence]
        while let current = differences.last, current.contains(where: { $0 != 0 }) {
            if current.count % 10 == 0 {
                print(current.count)
            }
            let next = getDifferences(for: current)
            differences.append(next)
        }

        let value = extrapolation(differences[0...])
        return value
    }

    func getDifferences(for sequence: [Int]) -> [Int] {
        var differences: [Int] = []
        if sequence.count == 1 {
            return [0]
        }
        for idx in 0..<(sequence.count - 1) {
            differences.append(sequence[idx + 1] - sequence[idx])
        }
        assert(differences.count == sequence.count - 1)
        return differences
    }

    func extrapolateNextValue(for sequences: ArraySlice<[Int]>) -> Int {
        if sequences.count == 0 {
            fatalError()
        }
        if sequences.count == 1 {
            return sequences.first!.last!
        }
        if sequences.count % 10 == 0 {
            print("at recursion depth: \(sequences.count)")
        }
        let idxAfterFirst = sequences.startIndex + 1
        let value = extrapolateNextValue(for: sequences[idxAfterFirst...]) + sequences.first!.last!
        return value
    }

    func extrapolatePreviousValue(for sequences: ArraySlice<[Int]>) -> Int {
        if sequences.count == 0 {
            fatalError()
        }
        if sequences.count == 1 {
            return sequences.first!.last!
        }
        if sequences.count % 10 == 0 {
            print("at recursion depth: \(sequences.count)")
        }
        let idxAfterFirst = sequences.startIndex + 1
        let value = sequences.first!.first! - extrapolatePreviousValue(for: sequences[idxAfterFirst...])
        return value
    }
}
