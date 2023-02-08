//
//  TimeZone.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation

public extension TimeZone {

  static let utc = TimeZone(identifier: "UTC").unsafelyUnwrapped

  static func timeZone(from date: String) -> TimeZone? {
    guard let offset = offset(from: date) else {
      return nil
    }
    if offset == 0 {
      return utc
    }
    return TimeZone(secondsFromGMT: offset)
  }

  static func offset(from date: String) -> Int? {
    guard let start = date.firstIndex(of: "+") ?? date.firstIndex(of: "-") ?? date.firstIndex(of: "Z") else {
      return nil
    }
    guard date[start...] != "Z" else {
      return 0
    }

    let sign = date[start] == "+" ? 1 : -1
    func build(seconds: Int) -> Int? {
      return seconds * sign
    }

    let timeZone = date[date.index(after: start) ..< date.endIndex]

    if timeZone.count == 2 { // assume HH
      if let hour = Int(timeZone) {
        return build(seconds: hour * 3600)
      }
    }
    else if timeZone.count == 4 { // assume HHMM
      if let hour = Int(timeZone.dropLast(2)), let min = Int(timeZone.dropFirst(2)) {
        return build(seconds: (hour * 60 + min) * 60)
      }
    }
    else if timeZone.count == 5 { // assime HH:MM
      if let hour = Int(timeZone.dropLast(3)), let min = Int(timeZone.dropFirst(3)) {
        return build(seconds: (hour * 60 + min) * 60)
      }
    }
    else if timeZone.count == 6 { // assume HHMMSS
      if let hour = Int(timeZone.dropLast(4)),
         let min = Int(timeZone.dropFirst(2).dropLast(2)),
         let sec = Int(timeZone.dropFirst(4)) {
        return build(seconds: (hour * 60 + min) * 60 + sec)
      }
    }
    else if timeZone.count == 8 { // assime HH:MM:SS
      if let hour = Int(timeZone.dropLast(6)),
         let min = Int(timeZone.dropFirst(3).dropLast(3)),
         let sec = Int(timeZone.dropFirst(6)) {
        return build(seconds: (hour * 60 + min) * 60 + sec)
      }
    }

    return nil
  }

}
