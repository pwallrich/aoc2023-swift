import Foundation

class Day25: Day {
    var day: Int { 25 }
    let input: String
    let grid: [Substring: [Substring]]
    let pairs: [(Substring, Substring)]
    let all: Set<Substring>

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr
"""
        } else {
            inputString = try InputGetter.getInput(for: 25, part: .first)
        }
        self.input = inputString
        var grid: [Substring: [Substring]] = [:]
        var pairs: [(Substring, Substring)] = []
        var all: Set<Substring> = []
        for row in inputString.split(separator: "\n") {
            let colonIdx = row.firstIndex(of: ":")!
            let start = row[..<colonIdx]
            let after = row.index(colonIdx, offsetBy: 2)
            all.insert(start)
            for other in row[after...].split(separator: " ") {
                grid[start, default: []].append(other)
                grid[other, default: []].append(start)
                pairs.append((start, other))
                all.insert(other)
            }
        }

        self.grid = grid
        self.pairs = pairs
        self.all = all
    }

    func runPart1() throws {
        print(grid.count)
        print(grid.map { $0.value.count}.reduce(0, +))
        print(pairs.count)

        print(pairs.combinations(ofCount: 3).count)
        var c = 0

        // found with graphviz visualisation
        let comb: [(Substring, Substring)] = [("zhb", "vxr"), ("jbx", "sml"), ("szh", "vqj")]
        // for comb in pairs.combinations(ofCount: 3) {
            if c % 100 == 0 {
                print(c)
            }
            c += 1
            var grid = grid

            for c in comb {
                grid[c.0] = grid[c.0]!.filter { $0 != c.1 }
                grid[c.1] = grid[c.1]!.filter { $0 != c.0 }
            }

            var curr = comb[0].0
            var seen: Set<Substring> = []
            var grids: [Set<Substring>] = []
            while true {
                var subGrid: Set<Substring> = []
                findSubGrid(in: grid, start: curr, seen: &subGrid)
                seen.formUnion(subGrid)
                grids.append(subGrid)

                if seen == all {
                    if grids.count == 2 {
                        print(grids[0].count * grids[1].count)
                        return
                    }
                    break
                }
                if grids.count > 2 {
                    break
                }
                curr = all.first { !seen.contains($0) }!
            }
        // }
    }

    func findSubGrid(in grid: [Substring: [Substring]], start: Substring, seen: inout Set<Substring>) {
        if seen.contains(start) {
            return
        }
        seen.insert(start)
        guard let children = grid[start] else {
            return
        }

        for child in children {
            findSubGrid(in: grid, start: child, seen: &seen)
        }

        return
    }

    func runPart2() throws {}
}
