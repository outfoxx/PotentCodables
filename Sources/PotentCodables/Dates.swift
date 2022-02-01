//
//  Dates.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation

public struct SuffixedDateFormatter {

  public static func optionalFractionalSeconds(basePattern: String) -> SuffixedDateFormatter {
    SuffixedDateFormatter(basePattern: basePattern, secondsPattern: ".S") { $0.contains(".") }
  }

  private let noSuffixes: DateFormatter
  private let zoneSuffix: DateFormatter
  private let secondsSuffix: DateFormatter
  private let zoneAndSecondsSuffixes: DateFormatter
  private let checkHasSeconds: (String) -> Bool

  public init(basePattern: String, secondsPattern: String, checkHasSeconds: @escaping (String) -> Bool) {
    self.checkHasSeconds = checkHasSeconds

    noSuffixes = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = basePattern
      return formatter
    }()

    zoneSuffix = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "\(basePattern)XXXX"
      return formatter
    }()

    secondsSuffix = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "\(basePattern)\(secondsPattern)"
      return formatter
    }()

    zoneAndSecondsSuffixes = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "\(basePattern)\(secondsPattern)XXXX"
      return formatter
    }()
  }

  public func date(from string: String) -> ZonedDate? {
    let parsedDate: Date?
    let zoneStartIndex = string.firstIndex { $0 == "-" || $0 == "+" || $0 == "Z" } ?? string.endIndex
    let stringWithoutZone = String(string[string.startIndex ..< zoneStartIndex])
    let hasZone = string != stringWithoutZone
    if checkHasSeconds(stringWithoutZone) && hasZone {
      parsedDate = zoneAndSecondsSuffixes.date(from: string)
    }
    else if checkHasSeconds(stringWithoutZone) {
      parsedDate = secondsSuffix.date(from: string)
    }
    else if hasZone {
      parsedDate = zoneSuffix.date(from: string)
    }
    else {
      parsedDate = noSuffixes.date(from: string)
    }
    guard parsedDate != nil else {
      return nil
    }
    let parsedTimeZone = TimeZone.timeZone(from: string) ?? .current
    return ZonedDate(date: parsedDate!, timeZone: parsedTimeZone)
  }

}
