/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
