//
//  File.swift
//  
//
//  Created by Philipp Wallrich on 01.12.23.
//

import Foundation

class Day1: Day {
    var day: Int { 1 }
    let input: [Substring]

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
"""
        } else {
            inputString = try InputGetter.getInput(for: 1, part: .first)
        }

        self.input = inputString
            .split(separator: "\n")
    }

    func runPart1() throws {
        let val = input.map {
            let first = $0.first { $0.isNumber }!
            let second = $0.last { $0.isNumber }!
            return Int(String(first))! * 10 + Int(String(second))!
        }.reduce(0, +)
        print(val)
    }

    let digits = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    func runPart2() throws {
        let val = input.map { foo -> Int in
            let (first, second) = foo.getFirstAndLastNumber(digits: digits)
            return Int(String(first))! * 10 + Int(String(second))!
        }
        .reduce(0, +)
        print(val)
    }
}

fileprivate extension Substring {
    func getFirstAndLastNumber(digits: [String]) -> (Int, Int) {
        let first: Int = {
            for idx in self.indices {
                let char = self[idx]
                if char.isNumber {
                    return Int(String(char))!
                }
                for (nIdx, d) in digits.enumerated() {
                    if self[idx...].hasPrefix(d) {
                        return nIdx + 1
                    }
                }
            }
            fatalError()
        }()
        let second: Int = {
            for idx in self.indices.reversed() {
                let char = self[idx]
                if char.isNumber {
                    return Int(String(char))!
                }
                for (nIdx, d) in digits.enumerated() {
                    let reversedSubstring = self[...idx].reversed()
                    let reversedNumber = d.reversed()
                    if reversedSubstring.starts(with: reversedNumber) {
                        return nIdx + 1
                    }
                }
            }
            fatalError()
        }()
        return (first, second)
    }
}
