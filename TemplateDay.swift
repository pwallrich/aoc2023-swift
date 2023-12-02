import Foundation

class Day1: Day {
    var day: Int { 1 }
    let input: String

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = "foo"
        } else {
            inputString = try InputGetter.getInput(for: 1, part: .first)
        }
        self.input = inputString
    }

    func runPart1() throws {}

    func runPart2() throws {}
}
