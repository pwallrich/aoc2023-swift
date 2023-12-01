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
        case 1: return try Day1(testInput: testInput)
        default: throw DayError.notImplemented
        }
    }
}
