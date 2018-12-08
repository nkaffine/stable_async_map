//
//  AsyncronousMapExtension.swift
//  AsyncronousMap
//
//  Created by Nicholas Kaffine on 12/7/18.
//  Copyright © 2018 Nicholas Kaffine. All rights reserved.
//

import Foundation

public extension Collection
{
    public func stableAsycMap<T>(_ transform: (Element, @escaping (T) -> Void) throws -> Void, completion: @escaping ([T]) -> Void) rethrows -> Void
    {
        let n = count
        if n == 0
        {
            completion([])
        }
        
        var result = ContiguousArray<TemporaryResult<T>>()
        result.reserveCapacity(self.count)
        
        var processingQueue = ContiguousArray<ProcessingItem>()
        processingQueue.reserveCapacity(self.count)
        for _ in 0..<n
        {
            processingQueue.append(ProcessingItem())
        }
        
        var i = startIndex
        var j = processingQueue.startIndex
        
        for _ in 0..<n
        {
            let temp = TemporaryResult<T>()
            let processingItem = processingQueue[j]
            let innerCompletion: (T) -> Void =
            { item in
                temp.result = item
                processingItem.complete()
                let isProcessing = !processingQueue.filter({$0.waiting}).isEmpty
                if !isProcessing
                {
                    completion(result.compactMap {$0.result})
                }
            }
            result.append(temp)
            try transform(self[i], innerCompletion)
            formIndex(after: &i)
            processingQueue.formIndex(after: &j)
        }
    }
}

private class TemporaryResult<T>
{
    var result: T?
    
    init(result: T? = nil)
    {
        self.result = result
    }
}

private class ProcessingItem
{
    var waiting: Bool
    
    init()
    {
        waiting = true
    }
    
    func complete()
    {
        waiting = false
    }
}
