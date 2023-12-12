import Foundation
import RegexBuilder

class Day12: Day {
    var day: Int { 12 }
    let input: [String]

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
"""
//            inputString = "???#????????????.??. 7,1"
        } else {
            inputString = try InputGetter.getInput(for: 12, part: .first)
        }
        self.input = inputString
            .components(separatedBy: "\n")
    }

    func runPart1() async throws {
        let res = input
            .enumerated()
            .map { (idx, row) in
                print("at \(idx)")
                let split = row.split(separator: " ")
                let numbers = split[1].split(separator: ",").map { Int(String($0))! }
                let string = String(split[0] + ".")
                var cache: [CacheKey: Int] = [:]
                let combinations = self.calculateWayCount(cache: &cache, string: string[string.startIndex...], currentLength: nil, remaining: numbers)
                print(combinations)
                return combinations
            }.reduce(0, +)
        print(res)
    }

    func runPart2() async throws {
        let res = await withTaskGroup(of: Int.self) { group in
            for row in input {
                group.addTask {
                    let split = row.split(separator: " ")
                    let numbers = split[1].split(separator: ",").map { Int(String($0))! }
                    let string = Array(repeating: String(split[0]), count: 5).joined(separator: "?")
                    let pattern = Array(repeating: numbers, count: 5).flatMap { $0 }
                    var cache: [CacheKey: Int] = [:]
                    let combinations = self.calculateWayCount(cache: &cache, string: string[string.startIndex...], currentLength: nil, remaining: pattern)

                    return combinations
                }
            }
            return await group.reduce(0, +)
        }
        print(res)
    }

    struct CacheKey: Hashable {
        let sLength: Int
        let withing: Int
        let remaining: Int
    }

    func calculateWayCount(cache: inout [CacheKey: Int], string: Substring, currentLength: Int?, remaining: [Int]) -> Int {
        guard !string.isEmpty else {
            switch (currentLength, remaining.count) {
            case (nil, 0): 
                return 1
            case let (.some(x), 1) where x == remaining[0]: 
                return 1
            default: 
                return 0
            }
        }
        guard !(currentLength != nil && remaining.isEmpty) else {
            return 0
        }

        let cacheKey = CacheKey(sLength: string.count, withing: currentLength ?? 0, remaining: remaining.count)
        if let cached = cache[cacheKey] {
            return cached
        }
        var ways = 0
        switch (string.first, currentLength) {
        case let (".", .some(x)) where x != remaining[0]: 
            ways = 0
        case (".", .some):
            ways = calculateWayCount(cache: &cache, string: string.dropFirst(), currentLength: nil, remaining: Array(remaining[1...]))
        case (".", .none):
            ways = calculateWayCount(cache: &cache,string: string.dropFirst(), currentLength: nil, remaining: remaining)
        case let ("#", .some(x)):
            ways = calculateWayCount(cache: &cache,string: string.dropFirst(), currentLength: x + 1, remaining: remaining)
        case ("#", .none):
            ways = calculateWayCount(cache: &cache,string: string.dropFirst(), currentLength: 1, remaining: remaining)
        case let ("?", .some(x)):
            var temp = calculateWayCount(cache: &cache,string: string.dropFirst(), currentLength: x + 1, remaining: remaining)
            if x == remaining[0] {
                temp += calculateWayCount(cache: &cache,string: string.dropFirst(), currentLength: nil, remaining: Array(remaining[1...]))
            }
            ways += temp
        case ("?", .none):
            var temp = calculateWayCount(cache: &cache,string: string.dropFirst(), currentLength: 1, remaining: remaining)
            temp += calculateWayCount(cache: &cache,string: string.dropFirst(), currentLength: nil, remaining: remaining)
            ways = temp
        default: fatalError()
        }

        cache[cacheKey] = ways
        return ways
    }
}
