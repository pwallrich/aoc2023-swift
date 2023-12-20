import Foundation

class Day20: Day {
    var day: Int { 20 }
    let input: [Substring: Module]

    init(testInput: Bool) throws {
        let inputString: String

        if testInput {
            inputString = """
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
"""
        } else {
            inputString = try InputGetter.getInput(for: 20, part: .first)
        }
        var modules: [Substring: Module] = [:]
        for row in inputString.split(separator: "\n") {
            let arrowIndex = row.firstIndex(of: ">")!
            let stripped = row[row.index(after: arrowIndex)...]
                .filter { !$0.isWhitespace }
            let children = stripped.split(separator: ",")
            switch row.first {
            case "b": // broadcast
                let name = row.prefix(while: { !$0.isWhitespace })
                let module = Broadcast(children: children, name: name)
                modules[name] = module
            case "%": // flip flop
                let name = row.prefix(while: { !$0.isWhitespace }).dropFirst()
                let module = FlipFlop(children: children, name: name)
                modules[name] = module
            case "&": // conjunction
                let name = row.prefix(while: { !$0.isWhitespace }).dropFirst()
                let module = Conjunction(children: children, name: name)
                modules[name] = module
            default: fatalError()
            }
        }
        // initialise conjunctions with false for each input
        for (name, con) in modules where con is Conjunction {
            for (_, other) in modules where other.children.contains(name) {
                _ = con.process(pulse: false, from: other.name)
            }
        }
        let module = Output(children: [], name: "rx")
        modules["rx"] = module
        print(modules)

        self.input = modules
    }

    func runPart1() throws {
        let modules = input

        let brodcast = modules["broadcaster"]!
        var low = 0
        var high = 0
        for i in 0..<1000 {
            print(i)
            var toSend: [(Module, Bool, Substring)] = [(brodcast, false, "")]
            while !toSend.isEmpty {
                var temp: [(Module, Bool, Substring)] = []
                for (next, value, from) in toSend {
                    print("sending \(value) from \(from) to \(next.name)")
                    if value {
                        high += 1
                    } else {
                        low += 1
                    }
                    guard let res = next.process(pulse: value, from: from) else {
                        continue
                    }

                    // maybe build up a graph
                    let nextSteps = next.children.map { (modules[$0]!, res, next.name) }
                    temp.append(contentsOf: nextSteps)
                }
                toSend = temp
                print()
            }
        }
        print(high, low, high * low)
    }

    func runPart2() throws {
        let modules = input

        // This is highly dependen on the input
        // I visualized my graph and checked how it was build and the figured out which subgraphs there are
        // It might work for other inputs, but I don't know whether that's true
        let beforeRx = modules.filter { $0.value.children.contains("rx") }
        assert(beforeRx.count == 1)

        let brodcast = modules["broadcaster"]!
        var i = 0

        var rxInputs = modules.filter { $0.value.children.contains(beforeRx.keys.first!) }.mapValues { _ in 0 }

        while rxInputs.values.contains(0) {
            if i % 10000 == 0 {
                print(i)
            }
            i += 1
            var toSend: [(Module, Bool, Substring)] = [(brodcast, false, "")]
            while !toSend.isEmpty {
                var temp: [(Module, Bool, Substring)] = []
                for (next, value, from) in toSend {
                    guard let res = next.process(pulse: value, from: from) else {
                        continue
                    }
                    if let curr = rxInputs[next.name], curr == 0, res {
                        rxInputs[next.name] = i
                    }

                    let nextSteps = next.children.map { (modules[$0]!, res, next.name) }
                    temp.append(contentsOf: nextSteps)
                }
                toSend = temp
            }

        }
        print(rxInputs, leastCommonMultiple(numbers: Array(rxInputs.values)))
    }
}

protocol Module {
    var children: [Substring] { get }
    var name: Substring { get }
    var stateDescription: String { get }
    func process(pulse: Bool, from input: Substring) -> Bool?
}

class FlipFlop: Module {
    let children: [Substring]
    let name: Substring
    
    var stateDescription: String {
        "\(state)"
    }
    private var state: Bool = false

    init(children: [Substring], name: Substring, state: Bool = false) {
        self.children = children
        self.name = name
        self.state = state
    }

    func process(pulse: Bool, from input: Substring) -> Bool? {
        guard !pulse else {
            return nil
        }
        state.toggle()
        return state
    }
}

class Conjunction: Module {
    
    let children: [Substring]
    let name: Substring

    var stateDescription: String {
        states.reduce("") { $0 + "\($1.key): \($1.value)" }
    }

    private var states: [Substring: Bool] = [:]

    init(children: [Substring], name: Substring, states: [Substring : Bool] = [:]) {
        self.children = children
        self.name = name
        self.states = states
    }

    func process(pulse: Bool, from input: Substring) -> Bool? {
        states[input] = pulse

        return states.values.contains(false)
    }
}

struct Broadcast: Module {
    let children: [Substring]
    let name: Substring

    var stateDescription: String { "" }

    func process(pulse: Bool, from input: Substring) -> Bool? {
        return pulse
    }
}

class Output: Module {
    init(children: [Substring], name: Substring, last: Bool = true) {
        self.children = children
        self.name = name
        self.last = last
    }
    var stateDescription: String { "\(last)" }
    let children: [Substring]
    let name: Substring
    var last: Bool = true

    func process(pulse: Bool, from input: Substring) -> Bool? {
        last = pulse
        return nil
    }
}
