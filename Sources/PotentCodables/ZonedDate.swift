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

public struct ZonedDate: Equatable, Hashable, Codable {

  public var date: Date
  public var timeZone: TimeZone

  public var utcDate: Date {
    if timeZone == .utc {
      return date
    }
    let offset = timeZone.daylightSavingTimeOffset(for: date)
    return Date(timeInterval: -offset, since: date)
  }

  public init(date: Date, timeZone: TimeZone) {
    self.date = date
    self.timeZone = timeZone
  }

}

extension ZonedDate: CustomStringConvertible {

  public var description: String {
    return Formatters.for(timeZone: timeZone).string(from: date)
  }

}

private enum Formatters {

  private static var formatters: [TimeZone: DateFormatter] = [:]
  private static let formattersLock = NSLock()

  static func `for`(timeZone: TimeZone) -> DateFormatter {
    formattersLock.lock()
    defer { formattersLock.unlock() }

    if let found = formatters[timeZone] {
      return found
    }

    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = timeZone
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXXX"

    formatters[timeZone] = formatter

    return formatter
  }

}
