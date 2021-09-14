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

public extension TimeZone {

  static let utc = TimeZone(identifier: "UTC")!

  static func timeZone(from date: String) -> TimeZone? {
    guard let offset = offset(from: date) else {
      return nil
    }
    return TimeZone(secondsFromGMT: offset)
  }

  static func offset(from date: String) -> Int? {
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
      if let hour = Int(timeZone.dropLast(4)), let min = Int(timeZone.dropFirst(2).dropLast(2)), let sec = Int(timeZone.dropFirst(4)) {
        return build(seconds: (hour * 60 + min) * 60 + sec)
      }
    }
    else if timeZone.count == 8 { // assime HH:MM:SS
      if let hour = Int(timeZone.dropLast(6)), let min = Int(timeZone.dropFirst(3).dropLast(3)), let sec = Int(timeZone.dropFirst(6)) {
        return build(seconds: (hour * 60 + min) * 60 + sec)
      }
    }

    return nil
  }

}
