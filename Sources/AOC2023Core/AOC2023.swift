//
//  File.swift
//  
//
//  Created by Philipp Wallrich on 01.12.22.
//

import Foundation

public final class AOC2023 {
    private let testInput: Bool

    public init(testInput: Bool) throws {
        self.testInput = testInput
    }

    public func run(day: Int, part: Part) async throws {
        let day = try getDay(day)

        switch part {
        case .first:
            try await day.runPart1()
        case .second:
            try await day.runPart2()
        }
    }

    private func getDay(_ number: Int) throws -> Day {
        switch number {
		case 22: return try Day22(testInput: testInput)
		case 21: return try Day21(testInput: testInput)
		case 20: return try Day20(testInput: testInput)
		case 19: return try Day19(testInput: testInput)
		case 18: return try Day18(testInput: testInput)
		case 17: return try Day17(testInput: testInput)
		case 16: return try Day16(testInput: testInput)
		case 15: return try Day15(testInput: testInput)
		case 14: return try Day14(testInput: testInput)
		case 13: return try Day13(testInput: testInput)
		case 12: return try Day12(testInput: testInput)
		case 11: return try Day11(testInput: testInput)
		case 10: return try Day10(testInput: testInput)
		case 9: return try Day9(testInput: testInput)
		case 8: return try Day8(testInput: testInput)
		case 7: return try Day7(testInput: testInput)
		case 6: return try Day6(testInput: testInput)
		case 5: return try Day5(testInput: testInput)
		case 4: return try Day4(testInput: testInput)
		case 3: return try Day3(testInput: testInput)
		case 2: return try Day2(testInput: testInput)
        case 1: return try Day1(testInput: testInput)
        default: throw DayError.notImplemented
        }
    }
}
