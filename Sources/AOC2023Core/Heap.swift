//
//  File.swift
//  
//
//  Created by Philipp Wallrich on 17.12.23.
//

import Foundation

/// This is a simple Heap implementation which can be used as a priority queue.
class Heap<T:Comparable> {
    typealias HeapComparator = (_ l:T,_ r:T) -> Bool
    var heap = [T]()
    var count:Int {
        get {
            heap.count
        }
    }

    var comparator:HeapComparator


    /// bubbleUp is called after appending the item to the end of the queue.  Depending on the comparator,
    /// it will bubbleUp to its approriate spot
    /// - Parameter idx: Index to bubble up.  This starts after insert with last index being passed in.
    private func bubbleUp(idx:Int) {
        let parent = (idx - 1) / 2

        if idx <= 0 {
            return
        }

        if comparator(heap[idx], heap[parent]) {
            heap.swapAt(parent, idx)
            bubbleUp(idx: parent)
        }
    }


    /// Heapify the current heap.  This method walks down the children and rearranges them in comparator order.
    /// - Parameter idx: index to heapify.
    private func heapify(_ idx:Int) {
        let left = idx * 2 + 1
        let right = idx * 2 + 2

        var comp = idx

        if count > left && comparator(heap[left], heap[comp]) {
            comp = left
        }
        if count > right && comparator(heap[right], heap[comp]) {
            comp = right
        }
        if comp != idx {
            heap.swapAt(comp, idx)
            heapify(comp)
        }
    }

    init(comparator:@escaping HeapComparator) {
        self.comparator = comparator
    }


    /// Insert item into the heap.  This walks up the parents. This is a O(log n) operation
    /// - Parameter item: item that is comparable.
    func insert(_ item:T) {
        heap.append(item)
        bubbleUp(idx: count-1)
    }


    /// Get the top item in the heap based on comparator. This is a 0(1) operation
    /// - Returns: top item or nil if empty.
    func getTop() -> T? {
        return heap.first
    }


    /// Remove the top item.  This is a O(log n) operation
    /// - Returns: returns top item based on comparator or nil if empty.
    func popTop() -> T? {
        let item = heap.first
        if count > 1 {
            // set the top to the last element and heapify
            // this means we can remove the last after "poping" the first.
            heap[0] = heap[count-1]
            heap.removeLast()
            heapify(0)
        }
        else if count == 1{
            heap.removeLast()
        }
        else {
            return nil
        }

        return item
    }
}
