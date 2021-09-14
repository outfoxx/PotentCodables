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
    if string.hasFractionalSeconds, string.hasZone {
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
