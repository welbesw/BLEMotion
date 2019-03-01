//
//  SynchronizedDictionary.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation

public class SynchronizedDictionary<K, T> where K: Hashable {
    
    private var accessQueue: DispatchQueue!
    
    private var internalDict: [K: T]
    
    init(queueName: String) {
        accessQueue = DispatchQueue(label: queueName, qos: .default)
        internalDict = [:]
    }
    
    var count: Int {
        var count = 0
        accessQueue.sync {
            count = internalDict.count
        }
        return count
    }
    
    public subscript(key: K) -> T? {
        get {
            var element: T?
            accessQueue.sync {
                element = internalDict[key]
            }
            return element
        }
        set(newValue) {
            accessQueue.async(flags: .barrier) {
                self.internalDict[key] = newValue
            }
        }
    }
    
    //Get a copy of the dictionary
    public func dictionary() -> [K: T] {
        var dictionary: [K: T] = [:]
        accessQueue.sync {
            dictionary = internalDict
        }
        return dictionary
    }
    
    //Set the internal dictionary to a new dictionary
    public func setDictionary(_ dictionary: [K: T], completion: (() -> Void)? = nil) {
        accessQueue.async(flags: .barrier) {
            self.internalDict = dictionary
            completion?()
        }
    }
    
    func removeValue(forKey key: K, completion: ((T?) -> Void)? = nil) {
        accessQueue.async(flags: .barrier) {
            let removedValue = self.internalDict.removeValue(forKey: key)
            completion?(removedValue)
        }
    }
}
