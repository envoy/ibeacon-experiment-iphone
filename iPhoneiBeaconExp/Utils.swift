//
//  Utils.swift
//  iPhoneiBeaconExp
//
//  Created by Fang-Pen Lin on 2/16/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import Foundation

struct Utils {
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
