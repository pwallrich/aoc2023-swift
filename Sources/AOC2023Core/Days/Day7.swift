import Foundation

class Day7: Day {
    var day: Int { 7 }
    let input: [(Substring, Int)]

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
32T3K 765
T55J5 684
KK677 28
KTJJT 220
KJTJT 483
"""
        } else {
            inputString = try InputGetter.getInput(for: 7, part: .first)
        }
        self.input = inputString
        .split(separator: "\n")
        .map { row in 
            let values = row.split(separator: " ")
            assert(values.count == 2)
            return (values[0], Int(String(values[1]))!)
        }
    }

    func runPart1() throws {
        let hands: [Hand] = input
            .map { .init(from: $0) }
            .sorted()

        let result = hands.enumerated()
            .map { ($0.offset + 1) * $0.element.bet }
            .reduce(0, +)

        print(result)
    }

    func runPart2() throws {
        let hands: [Hand] = input
            .map { .init(from: $0, isPart2: true) }
            .sorted()

        let result = hands.enumerated()
            .map { ($0.offset + 1) * $0.element.bet }
            .reduce(0, +)

        print(result)
        
//        assert(["K": 5, "J": 0].getHandTypePart2() == 6, "KKKKK")
//        assert(["K": 4, "J": 1].getHandTypePart2() == 6, "KKKKJ")
//        assert(["K": 3, "J": 2].getHandTypePart2() == 6, "KKKJJ")
//        assert(["K": 2, "J": 3].getHandTypePart2() == 6, "KKJJJ")
//        assert(["K": 1, "J": 4].getHandTypePart2() == 6, "KJJJJ")
//        assert(["K": 0, "J": 5].getHandTypePart2() == 6, "JJJJJ")
//
//        assert(["Q": 1, "K": 4, "J": 0].getHandTypePart2() == 5, "QKKKK")
//        assert(["Q": 1, "K": 3, "J": 1].getHandTypePart2() == 5, "QKKKJ")
//        assert(["Q": 1, "K": 2, "J": 2].getHandTypePart2() == 5, "QKKJJ")
//        assert(["Q": 1, "K": 1, "J": 3].getHandTypePart2() == 5, "QKJJJ")
//        assert(["Q": 1, "K": 1, "J": 3].getHandTypePart2() == 5, "QKJJJ")
//
//        assert(["Q": 2, "K": 3, "J": 0].getHandTypePart2() == 4, "QQKKK")
//        assert(["Q": 2, "K": 2, "J": 1].getHandTypePart2() == 4, "QQKKJ")
//
//        assert(["Q": 1, "T": 1, "K": 3, "J": 0].getHandTypePart2() == 3, "QTKKK")
//        assert(["Q": 1, "T": 1, "K": 2, "J": 1].getHandTypePart2() == 3, "QTKKJ")
//        assert(["Q": 1, "T": 1, "K": 1, "J": 2].getHandTypePart2() == 3, "QTKJJ")
//
//        assert(["Q": 1, "T": 2, "K": 2, "J": 0].getHandTypePart2() == 2, "QTTKK")
//
//        assert(["Q": 1, "T": 1, "A": 1, "K": 2, "J": 0].getHandTypePart2() == 1, "QTAKK")
//        assert(["Q": 1, "T": 1, "A": 1, "K": 1, "J": 1].getHandTypePart2() == 1, "QTAKJ")
    }

    struct Hand: Comparable {
        let cards: [Int]
        let bet: Int
        let type: HandType

        init(from values: (Substring, Int), isPart2: Bool = false) {
            self.bet = values.1

            self.cards = values.0.map { value in
                switch value {
                case "0"..."9":
                    return Int(String(value))!
                case "T":
                    return 10
                case "J":
                    return isPart2 ? -1 : 11
                case "Q":
                    return 12
                case "K":
                    return 13
                case "A":
                    return 14
                default:
                    fatalError()
                }
            }
            
            let cards = values.0.reduce(into: [:]) { $0[$1, default: 0] += 1} 
            type = isPart2 ? cards.getHandTypePart2() : cards.getHandType()
        }

        static func < (lhs: Day7.Hand, rhs: Day7.Hand) -> Bool {
            if lhs.type > rhs.type {
                return false
            } 
            if lhs.type < rhs.type {
                return true
            }
            for i in 0..<lhs.cards.count where lhs.cards[i] != rhs.cards[i] {
                return lhs.cards[i] < rhs.cards[i]
            }
            return false
        }
    }

    enum HandType: Int, Comparable {
        case highest, pair, twoPair, three, fullHouse, four, five

        static func < (lhs: Day7.HandType, rhs: Day7.HandType) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

extension Dictionary where Key == Character, Value == Int {
    func getHandType() -> Day7.HandType {
        let max = self.values.max()!
        if max == 5 {
            return .five
        }
        if max == 4 {
            return .four
        }
        if (self.values.contains(2) && self.values.contains(3)) {
            return .fullHouse
        }
        if max == 3 {
            return .three
        }
        if self.values.compactMap({ $0 == 2 ? $0 : nil }).count == 2 {
            return .twoPair
        }
        if max == 2 {
            return .pair
        }
        return .highest
    }

    func getHandTypePart2() -> Day7.HandType {
        let jAmount = self["J"] ?? 0

        guard jAmount != 0 else {
            return getHandType()
        }
        guard jAmount != 5 && jAmount != 4 else {
            return .five
        }

        var mutable = self
        mutable["J"] = nil
        let hand = mutable.getHandType()

        switch (hand, jAmount) {
        case(.four, 1), (.three, 2), (.pair, 3):
            return .five
        case (.three, 1), (.pair, 2), (.highest, 3):
            return .four
        case (.twoPair, 1):
            return .fullHouse
        case (.highest, 2), (.pair, 1):
            return .three
        case (.highest, 1):
            return .pair
        default:
            fatalError()
        }
    }
}
