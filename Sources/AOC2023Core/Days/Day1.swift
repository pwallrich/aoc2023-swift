//
//  File.swift
//  
//
//  Created by Philipp Wallrich on 01.12.23.
//

import Foundation
import RegexBuilder

class Day1: Day {
    var day: Int { 1 }
    let input: [String]

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
            .components(separatedBy: "\n")
    }

    let digits = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    func runPart1() throws {
        let val = input.map { foo -> Int in
            let first = foo.first { $0.isNumber }!
            let second = foo.reversed().first { $0.isNumber }!
            return Int(String(first))! * 10 + Int(String(second))!
        }
        .reduce(0, +)
        print(val)
    }

    func runPart2() throws {
        let val = input.map { foo -> Int in
            let (first, second) = foo.getFirstAndLastNumber(digits: digits)
            return Int(String(first))! * 10 + Int(String(second))!
        }
        .reduce(0, +)
        print(val)
    }


}

fileprivate extension String {
    func getFirstAndLastNumber(digits: [String]) -> (Int, Int) {
        let first: Int = {
            for (idx,char) in self.enumerated() {
                if char.isNumber {
                    return Int(String(char))!
                }
                for (nIdx, d) in digits.enumerated() {
                    if self.dropFirst(idx).hasPrefix(d) {
                        return nIdx + 1
                    }
                }
            }
            fatalError()
        }()

        let second: Int = {
            for (idx,char) in self.reversed().enumerated() {
                if char.isNumber {
                    return Int(String(char))!
                }
                for (nIdx, d) in digits.enumerated() {
                    let reversedSubstring = String(self.reversed().dropFirst(idx))
                    let reversedNumber = String(d.reversed())
                    if reversedSubstring.hasPrefix(reversedNumber) {
                        return nIdx + 1
                    }
                }
            }
            fatalError()
        }()
        return (first, second)
    }
}
