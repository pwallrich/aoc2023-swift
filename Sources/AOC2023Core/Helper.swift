//
//  File.swift
//  
//
//  Created by Philipp Wallrich on 08.12.23.
//

import Foundation

func leastCommonMultiple(numbers: [Int]) -> Int {
    guard let primes = findPrimesUntil(limit: numbers.max()!) else {
        return numbers.reduce(1, *)
    }
    var values = numbers
    var res = 1
    var currPrimeIdx = 0
    while values.contains(where: { $0 != 1 }) {
        var found = false
        for (idx, value) in values.enumerated() {
            if value % primes[currPrimeIdx] == 0 {
                values[idx] /= primes[currPrimeIdx]
                found = true
            }
        }
        if !found {
            currPrimeIdx += 1
        } else {
            res *= primes[currPrimeIdx]
        }
    }
    return res
}

func findPrimesUntil(limit: Int) -> [Int]? {
    guard limit > 1 else {
        return nil
    }

    var primes =  [Bool](repeating: true, count: limit+1)

    for i in 0..<2 {
        primes[i] = false
    }

    for j in 2..<primes.count where primes[j] {
        var k = 2
        while k * j < primes.count {
            primes[k * j] = false
            k += 1
        }
    }

    return primes.enumerated().compactMap { (index: Int, element: Bool) -> Int? in
        if element {
            return index
        }
        return nil
    }
}
