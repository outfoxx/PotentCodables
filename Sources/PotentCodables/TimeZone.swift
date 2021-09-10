//
//  TimeZone.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 9/12/21.
//

import Foundation

extension TimeZone {

  public static let utc = TimeZone(identifier: "UTC")!

  public static func timeZone(from date: String) -> TimeZone? {
    guard let offset = offset(from: date) else {
      return nil
    }
    return TimeZone(secondsFromGMT: offset)
  }

  public static func offset(from date: String) -> Int? {
    guard let start = date.firstIndex(of: "+") ?? date.firstIndex(of: "-") ?? date.firstIndex(of: "Z") else {
      return nil
    }
    guard date[start] != "Z" else {
      return 0
    }

    let sign = date[start] == "+" ? 1 : -1
    func build(seconds: Int) -> Int? {
      return seconds * sign
    }

    let tz = date[date.index(after: start) ..< date.endIndex]

    if tz.count == 2 { // assume HH
      if let hour = Int(tz) {
        return build(seconds: hour * 3600)
      }
    }
    else if tz.count == 4 { // assume HHMM
      if let hour = Int(tz.dropLast(2)), let min = Int(tz.dropFirst(2)) {
        return build(seconds: (hour * 60 + min) * 60)
      }
    }
    else if tz.count == 5 { // assime HH:MM
      if let hour = Int(tz.dropLast(3)), let min = Int(tz.dropFirst(3)) {
        return build(seconds: (hour * 60 + min) * 60)
      }
    }
    else if tz.count == 6 { // assume HHMMSS
      if let hour = Int(tz.dropLast(4)), let min = Int(tz.dropFirst(2).dropLast(2)), let sec = Int(tz.dropFirst(4)) {
        return build(seconds: (hour * 60 + min) * 60 + sec)
      }
    }
    else if tz.count == 8 { // assime HH:MM:SS
      if let hour = Int(tz.dropLast(6)), let min = Int(tz.dropFirst(3).dropLast(3)), let sec = Int(tz.dropFirst(6)) {
        return build(seconds: (hour * 60 + min) * 60 + sec)
      }
    }

    return nil
  }

}
