import Foundation
import RegexBuilder
class Day5: Day {
    var day: Int { 5 }
    let input: String

    static let regex = Regex {
        TryCapture {
            OneOrMore(.digit)
        } transform: { Int($0) }
    }

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""
        } else {
            inputString = try InputGetter.getInput(for: 5, part: .first)
        }
        self.input = inputString
    }

    func runPart1() throws {
        let rows = input.split(separator: "\n")
        let seedColon = rows[0].firstIndex(of: ":")!
        let seeds = rows[0][seedColon...].matches(of: Self.regex).map(\.output.1)
        print(seeds)
        var idx = 2

        var currentValues = seeds
        while idx < rows.count {
            print("at idx: \(idx)")
            let (mapping, newIdx) = parseMapping(startIdx: idx, rows: rows)
            var nextValues: [Int] = []
            for value in currentValues {
                var newValue = value
                for (range, offset) in mapping {
                    if range.contains(value) {
                        newValue = value + offset
                        break
                    }
                }
                nextValues.append(newValue)
            }
            currentValues = nextValues
            idx = newIdx + 1
        }
        print(currentValues.min()!)
    }

    func runPart2() throws {
        let rows = input.split(separator: "\n")
        var seedRanges = getSeedRanges(from: rows[0])
        let mappings = getMappings(from: rows)
        // THE SOLUTION ONLY WORKS, BECAUSE THERE ARE NO OVERLAPPING RANGES!!!

//        for mapping in mappings {
//            for (mappingRange, _) in mapping {
//                for (other, _ ) in mapping {
//                    guard other != mappingRange else { continue }
//                    assert(!mappingRange.overlaps(other))
//                }
//            }
//        }

        for mapping in mappings {
            var mappedSeeds: [Range<Int>] = []
            for seedRange in seedRanges {
                var currMapped: [Range<Int>: Int] = [:]
                // do mapping for all the values, that are in the specific ranges
                for (mappingRange, offset) in mapping where mappingRange.overlaps(seedRange) {
                    let lower = max(mappingRange.lowerBound, seedRange.lowerBound)
                    let upper = min(mappingRange.upperBound, seedRange.upperBound)

                    currMapped[lower..<upper] = offset
                }

                guard !currMapped.isEmpty else {
                    mappedSeeds.append(seedRange)
                    continue
                }
                let sorted = currMapped.sorted { $0.key.lowerBound < $1.key.lowerBound }
                var currentLowest = seedRange.lowerBound
                // actually map each mapped region and fill up the spaces in between
                for mapped in sorted {
                    if mapped.key.lowerBound <= currentLowest {
                        mappedSeeds.append((mapped.key.lowerBound + mapped.value)..<(mapped.key.upperBound + mapped.value))
                    } else {
                        mappedSeeds.append(currentLowest..<mapped.key.lowerBound)
                        mappedSeeds.append((mapped.key.lowerBound + mapped.value)..<(mapped.key.upperBound + mapped.value))
                    }
                    currentLowest = mapped.key.upperBound
                }
                if currentLowest < seedRange.upperBound {
                    mappedSeeds.append(currentLowest..<seedRange.upperBound)
                }

            }
            seedRanges = mappedSeeds
        }
        print(seedRanges.min { $0.lowerBound < $1.lowerBound }!.lowerBound)
    }

    func getMappings(from rows: [Substring]) -> [[Range<Int>: Int]] {
        var idx = 2
        var mappings: [[Range<Int>: Int]] = []
        while idx < rows.count {
            let (mapping, newIdx) = parseMapping(startIdx: idx, rows: rows)
            mappings.append(mapping)
            idx = newIdx + 1
        }
        return mappings
    }

    func getSeedRanges(from input: Substring) -> [Range<Int>] {
        let seedColon = input.firstIndex(of: ":")!
        let seeds = input[seedColon...].matches(of: Self.regex).map(\.output.1)
        var seedRanges: [Range<Int>] = []

        for seed in stride(from: 0, to: seeds.count, by: 2) {
            let start = seeds[seed]
            let length = seeds[seed + 1]
            seedRanges.append(start..<(start + length))
        }
        return seedRanges
    }

    func parseMapping(startIdx: Int, rows: [Substring]) -> ([Range<Int>: Int], Int) {
        var toMap: [Range<Int>: Int] = [:]
        for (idx, row) in rows[startIdx...].enumerated() {
            guard row.first!.isNumber else {
                return (toMap, idx + startIdx)
            }
            let values = row.matches(of: Self.regex).map(\.output.1)
            assert(values.count == 3)
            let range = values[1]..<(values[1] + values[2])
            let offset = values[0] - values[1]
            toMap[range] = offset
        }
        return (toMap, rows.count)
    }
}
