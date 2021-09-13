//
//  Dates.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 9/12/21.
//

import Foundation

public struct ISO8601SuffixedDateFormatter {

  private let noSuffixes: DateFormatter
  private let zoneSuffix: DateFormatter
  private let fractionalSecondsSuffix: DateFormatter
  private let zoneAndFractionalSecondsSuffixes: DateFormatter

  public init(basePattern: String) {
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

    fractionalSecondsSuffix = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "\(basePattern).S"
      return formatter
    }()

    zoneAndFractionalSecondsSuffixes = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "\(basePattern).SXXXX"
      return formatter
    }()
  }

  public func date(from string: String) -> ZonedDate? {
    let parsedDate: Date?
    if string.hasFractionalSeconds && string.hasZone {
      parsedDate = zoneAndFractionalSecondsSuffixes.date(from: string)
    }
    else if string.hasFractionalSeconds {
      parsedDate = fractionalSecondsSuffix.date(from: string)
    }
    else if string.hasZone {
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

private extension String {
  var hasFractionalSeconds: Bool { contains(".") }
  var hasZone: Bool { contains("+") || contains("-") || contains("Z") }
}
