//
//  Extensions.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation

extension Data {
    
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

extension Notification.Name {
    static let peripheralAdded = Notification.Name("perhipheralAdded")
    static let peripheralUpdated = Notification.Name("perhipheralUpdated")
}
