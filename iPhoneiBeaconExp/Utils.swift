//
//  Utils.swift
//  iPhoneiBeaconExp
//
//  Created by Fang-Pen Lin on 2/16/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import Foundation
import UIKit

struct Utils {
    static let apiURL: URL = {
        let env = ProcessInfo.processInfo.environment
        if let url = env["API_URL"] {
            return URL(string: url)!
        }
        return URL(string: "https://ibeacon-experiment-api2.herokuapp.com")!
    }()
    
    static func urlEncode(dict: [String: String]) -> String {
        return dict
            .map { (key, value) -> String in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
    }
}

extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Date.iso8601Formatter.date(from: self)
    }
}

// ref: http://stackoverflow.com/a/27759550/25077
extension UIDevice {
    public var modelCode: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        } ?? "Unknown"
    }
}
