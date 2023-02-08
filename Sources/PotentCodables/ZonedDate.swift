//
//  ZonedDate.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// Date and explicit specific time zone.
///
public struct ZonedDate: Equatable, Hashable, Codable {

  /// Date in UTC time zone.
  public var date: Date
  /// Explicit time zone .
  public var timeZone: TimeZone

  /// Date adjusted to UTC time zone.
  public var utcDate: Date {
    if timeZone == .utc {
      return date
    }
    let offset = timeZone.daylightSavingTimeOffset(for: date)
    return Date(timeInterval: -offset, since: date)
  }

  /// Initialize with a date in UTC time zone and explicit time zone.
  ///
  public init(date: Date, timeZone: TimeZone) {
    self.date = date
    self.timeZone = timeZone
  }

  private static let iso8601Parser = ISO8601FlexibleDateFormatter()

  public init?(iso8601Encoded string: String) {
    guard let zonedDate = Self.iso8601Parser.date(from: string) else {
      return nil
    }
    self.date = zonedDate.date
    self.timeZone = zonedDate.timeZone
  }

  public func iso8601EncodedString() -> String {
    return Formatters.for(timeZone: timeZone).string(from: date)
  }

}

private enum Formatters {

  private static var formatters: [TimeZone: ISO8601DateFormatter] = [:]
  private static let formattersLock = NSLock()

  static func `for`(timeZone: TimeZone) -> ISO8601DateFormatter {
    formattersLock.lock()
    defer { formattersLock.unlock() }

    if let found = formatters[timeZone] {
      return found
    }

    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
    formatter.timeZone = timeZone

    formatters[timeZone] = formatter

    return formatter
  }

}

private struct ISO8601FlexibleDateFormatter {

  private let noSuffixes: ISO8601DateFormatter
  private let zoneSuffix: ISO8601DateFormatter
  private let fractionalSecondsSuffix: ISO8601DateFormatter
  private let zoneAndFractionalSecondsSuffixes: ISO8601DateFormatter

  public init() {
    noSuffixes = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime]
      formatter.timeZone = .utc
      return formatter
    }()

    zoneSuffix = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
      formatter.timeZone = .utc
      return formatter
    }()

    fractionalSecondsSuffix = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      formatter.timeZone = .utc
      return formatter
    }()

    zoneAndFractionalSecondsSuffixes = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
      formatter.timeZone = .utc
      return formatter
    }()
  }

  public func date(from string: String) -> ZonedDate? {
    let parsedDate: Date?
    let hasSeconds: Bool
    let hasZone: Bool
    let timeZone: TimeZone
    if let timeStartIndex = string.firstIndex(of: "T") {
      let time = string[timeStartIndex...]
      let zoneStartIndex = time.firstIndex { (char: Character) in
        char == "-" || char == "+" || char == "Z"
      } ?? time.endIndex
      let timeWithoutZone = time[time.startIndex ..< zoneStartIndex]
      hasSeconds = timeWithoutZone.contains(".")
      hasZone = zoneStartIndex != time.endIndex
      timeZone = TimeZone.timeZone(from: String(time[zoneStartIndex...])) ?? .current
    }
    else {
      hasSeconds = false
      hasZone = false
      timeZone = .current
    }

    if hasSeconds && hasZone {
      parsedDate = zoneAndFractionalSecondsSuffixes.date(from: string)
    }
    else if hasSeconds {
      parsedDate = fractionalSecondsSuffix.date(from: string)
    }
    else if hasZone {
      parsedDate = zoneSuffix.date(from: string)
    }
    else {
      parsedDate = noSuffixes.date(from: string)
    }
    if let parsedDate = parsedDate {
      return ZonedDate(date: parsedDate, timeZone: timeZone)
    }
    return nil
  }

}
