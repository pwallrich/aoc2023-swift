import Foundation

class Day15: Day {
    var day: Int { 15 }
    let input: String

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
        } else {
            inputString = try InputGetter.getInput(for: 15, part: .first)
        }
        self.input = inputString
    }

    func runPart1() throws {
        let values = input.split(separator: ",")
        var res = 0
        for value in values {
            let h = hash(value)
            print(value, h)
            res += h
        }

        print(res)
    }

    func runPart2() throws {
        let values = input.split(separator: ",")
        var boxes: [[(Substring, Int)]] = Array(repeating: [], count: 256)
        for (idx, value) in values.enumerated() {
            if idx % 100 == 0 {
                print("at \(idx) of \(values.count)")
            }
            let splitIdx = value.firstIndex { $0 == "=" || $0 == "-" }!
            let h = hash(value[..<splitIdx])

            let itemIndex = boxes[h].firstIndex {
                $0.0 == value[..<splitIdx]
            }

            switch value[splitIdx] {
            case "-":
                guard let itemIndex else { break }
                boxes[h].remove(at: itemIndex)
            case "=":
                let indexAfter = value.index(after: splitIdx)
                let length = Int(String(value[indexAfter...]))!
                if let itemIndex {
                    boxes[h][itemIndex] = (value[..<splitIdx], length)
                } else {
                    boxes[h].append((value[..<splitIdx], length))
                }
            default:
                fatalError()
            }
        }
        var res = 0
        for (idx, box) in boxes.enumerated() {
            for (lensIdx, lens) in box.enumerated() {
                res += (idx + 1) * (lensIdx + 1) * lens.1
            }
        }

        print(res)
    }

    func hash(_ string: Substring) -> Int {
        var current: Int = 0
        for char in string {
            current += Int(char.asciiValue!)
            current *= 17
            current %= 256
        }
        return current
    }
}
