import Foundation
import RegexBuilder

class Day19: Day {
    var day: Int { 19 }
    let workflows: [Substring: Workflow]
    let itemsString: Substring

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
"""
        } else {
            inputString = try InputGetter.getInput(for: 19, part: .first)
        }

        let split = inputString.split(separator: "\n\n")

        var workflows: [Substring: Workflow] = [:]
        for row in split[0].split(separator: "\n") {
            let open = row.firstIndex(of: "{")!
            let name = row[..<open]
            var rules: [Workflow.Rule] = []
            for match in row[open...].matches(of: ruleRegex) {
                rules.append(.init(param: match.output.1, comparator: match.output.2, toCompare: match.output.3, dest: match.output.4))
            }
            let lastIdx = row.index(after: row.lastIndex(of: ",")!)
            let finally = row[lastIdx...].dropLast()
            workflows[name] = .init(rules: rules, finally: finally)
        }
        itemsString = split[1]
        self.workflows = workflows
    }

    struct Item {
        let x: Int
        let m: Int
        let a: Int
        let s: Int
    }

    let ruleRegex = Regex {
        Capture {
            OneOrMore(.word)
        }
        Capture {
            ChoiceOf {
                "<"
                ">"
            }
        }
        TryCapture {
            OneOrMore(.digit)
        } transform: { Int($0) }
        ":"
        Capture {
            OneOrMore(.word)
        }
    }

    let itemRegex = Regex {
        Capture {
            OneOrMore(.word)
        }
        "="
        TryCapture {
            OneOrMore(.digit)
        } transform: { Int($0) }
    }

    struct Workflow {
        struct Rule {
            let param: Substring
            let toCompare: Int
            let dest: Substring
            let comp: Substring

            init(param: Substring, comparator: Substring, toCompare: Int, dest: Substring) {
                self.dest = dest
                self.toCompare = toCompare
                self.comp = comparator
                self.param = param
            }

            func compare(item: Item) -> Bool {
                let value = switch param {
                case "a": item.a
                case "x": item.x
                case "m": item.m
                case "s": item.s
                default: fatalError()
                }
                switch comp {
                case "<": return value < toCompare
                case ">": return value > toCompare
                default: fatalError()
                }
            }
        }
        let rules: [Rule]
        let finally: Substring
    }

    func runPart1() throws {
        var res = 0
        for item in itemsString.split(separator: "\n") {
            let match = item.matches(of: itemRegex)
            let item = Item(x: match.first { $0.output.1 == "x"}!.output.2,
                            m: match.first { $0.output.1 == "m"}!.output.2,
                            a: match.first { $0.output.1 == "a"}!.output.2,
                            s: match.first { $0.output.1 == "s"}!.output.2)
            let acc = check(item: item, workflows: workflows)
            if acc {
                res += item.x + item.m + item.a + item.s
            }
        }

        print(res)
    }

    func check(item: Item, workflows: [Substring: Workflow]) -> Bool {
        var currentName: Substring = "in"

        while currentName != "R" && currentName != "A" {
            let rule = workflows[currentName]!
            currentName = findMatchingRule(for: item, in: rule.rules) ?? rule.finally
        }
        return currentName == "A"
    }

    func findMatchingRule(for item: Item, in rules: [Workflow.Rule]) -> Substring? {
        for rule in rules {
            guard rule.compare(item: item) else {
                continue
            }
            return rule.dest
        }
        return nil
    }

    func runPart2() throws {
        let start = workflows["in"]!

        let matchRanges: [Substring: Range<Int>] = [
            "x": 1..<4001,
            "m": 1..<4001,
            "a": 1..<4001,
            "s": 1..<4001
        ]

        let res = split(workflow: start, ranges: matchRanges)
        print(res)
    }

    func split(workflow: Workflow, ranges: [Substring: Range<Int>]) -> Int {
        if !ranges.values.map(\.count).contains(where: { $0 != 0 }) {
            return 0
        }
        var res = 0
        var startPoints = ranges
        for rule in workflow.rules {
            let curr = startPoints[rule.param]!
            let currRange: Range<Int>
            let remainingRange: Range<Int>

            switch rule.comp {
            case "<":
                guard curr.upperBound > rule.toCompare else {
                    continue
                }
                currRange = curr.lowerBound..<rule.toCompare
                remainingRange = rule.toCompare..<curr.upperBound
            case ">":
                guard curr.lowerBound < rule.toCompare else {
                    continue
                }
                currRange = (rule.toCompare + 1)..<curr.upperBound
                remainingRange = curr.lowerBound..<(rule.toCompare + 1)
            default:
                fatalError()
            }

            var currentPoints = startPoints
            currentPoints[rule.param] = currRange

            startPoints[rule.param] = remainingRange

            if rule.dest == "A" {
                res += currentPoints.values.map(\.count).reduce(1, *)
                continue
            }
            if rule.dest == "R" {
                continue
            }

            let child = workflows[rule.dest]!
            res += split(workflow: child, ranges: currentPoints)
        }
        if workflow.finally == "A" {
            res += startPoints.values.map(\.count).reduce(1, *)
        } else if workflow.finally != "R" {
            let child = workflows[workflow.finally]!
            res += split(workflow: child, ranges: startPoints)
        }

        return res
    }
}
