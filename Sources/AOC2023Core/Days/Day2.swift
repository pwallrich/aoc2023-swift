import Foundation
import RegexBuilder

class Day2: Day {
    var day: Int { 2 }
    let input: [[(blue: Int, red: Int, green: Int)]]

    static let gameRegex = Regex {
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
        Capture {
            ChoiceOf {
                ","
                ";"
                "\n"
                ""
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

        let matches = inputString
            .matches(of: Self.gameRegex)

        var input: [[(blue: Int, red: Int, green: Int)]] = []
        var currentGame: [(blue: Int, red: Int, green: Int)] = []
        var currentRound: (blue: Int, red: Int, green: Int) = (0,0,0)

        for match in matches {
            switch match.output.2 {
            case "green":
                currentRound.green = match.output.1
            case "blue":
                currentRound.blue = match.output.1
            case "red":
                currentRound.red = match.output.1
            default:
                fatalError()
            }

            switch match.output.3 {
            case ";":
                currentGame.append(currentRound)
                currentRound = (0,0,0)
            case "\n":
                currentGame.append(currentRound)
                currentRound = (0,0,0)
                input.append(currentGame)
                currentGame = []
            case "":
                currentGame.append(currentRound)
                input.append(currentGame)
            default:
                break
            }
        }
        self.input = input

    }

    func runPart1() throws {
        let result = input
            .enumerated()
            .filter {
                !$0.element.contains(where: { $0.blue > 14 || $0.green > 13 || $0.red > 12 })
            }.map { $0.offset + 1 }
            .reduce(0, +)
        print(result)
    }

    func runPart2() throws {
        let result = input
            .map { row -> (red: Int, blue: Int, green: Int) in
                let maxRed = row.map(\.red).max()!
                let maxBlue = row.map(\.blue).max()!
                let maxGreen = row.map(\.green).max()!
                return (maxRed, maxBlue, maxGreen)
            }.map { $0.0 * $0.1 * $0.2  }
            .reduce(0, +)
        print(result)
    }
}
