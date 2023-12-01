//
//  File.swift
//  
//
//  Created by Philipp Wallrich on 01.12.21.
//

import Foundation

protocol Day {
    func runPart1() async throws
    func runPart2() async throws
}

class InputGetter {
    static func getInput(for day: Int, part: Part) throws -> String {
        let name = "input_\(day)_\(part.rawValue)"
        guard let inputURL = Bundle.module.url(forResource: name, withExtension: "txt") else {
            print("couldn't find input named: \(name)")
            throw DayError.noInputFound
        }
        return try String(contentsOf: inputURL)
    }
}

enum DayError: Error {
    case notImplemented
    case noInputFound
    case invalidInput
}
