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

import BigInt
import Foundation

public extension BigUInt {

  var integerValue: Int? {
    guard bitWidth < UInt.bitWidth else { return nil }
    return Int(words[0])
  }

  var unsignedIntegerValue: UInt? {
    guard bitWidth <= UInt.bitWidth else { return nil }
    return words[0]
  }

  init(serialized data: Data) {
    self.init(data)
  }

  func serialized() -> Data { serialize() }

}

public extension BigInt {

  var integerValue: Int? {
    guard bitWidth <= UInt.bitWidth else { return nil }
    if sign == .minus {
      return Int((~words[0]) + 1)
    }
    return Int(words[0])
  }

  var unsignedIntegerValue: UInt? {
    guard bitWidth <= UInt.bitWidth else { return nil }
    return words[0]
  }

  /// Initializes an integer from the bits stored inside a piece of `Data`.
  /// The data is assumed to be the two's compliment base-256 representation, in network (big-endian) byte order.
  init(serialized data: Data) {
    let sign: Sign
    let magnitude: BigUInt
    if (data[0] & 0x80) == 0x80 {
      sign = .minus
      magnitude = BigUInt(data.twosCompliment())
    }
    else {
      sign = .plus
      magnitude = BigUInt(data)
    }
    self.init(sign: sign, magnitude: magnitude)
  }

  /// Return a `Data` value that contains the two's compliment base-256 representation of this integer, in network (big-endian) byte order.
  func serialized() -> Data {
    var bytes = magnitude.serialize()
    if bytes.isEmpty || (bytes[0] & 0x80) == 0x80 {
      // Make room for sign
      bytes.insert(0, at: 0)
    }
    if sign == .plus {
      return bytes
    }
    return bytes.twosCompliment()
  }

}

private extension Data {

  /// Two's compliment of _big endian_ integer
  func twosCompliment() -> Data {
    var data = self
    var increment = true
    for index in stride(from: data.count - 1, through: 0, by: -1) {
      if increment {
        (data[index], increment) = (~data[index]).addingReportingOverflow(1)
      }
      else {
        data[index] = ~data[index]
      }
    }
    return data
  }

}
