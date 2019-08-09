//
//  BigInts.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

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
  init(_ data: Data) {
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
  func serialize() -> Data {
    var bytes = magnitude.serialize()
    if sign == .minus {
      // Make room for sign (if needed)
      if (bytes[0] & 0x80) == 0x80 {
        bytes.insert(0, at: 0)
      }
      return bytes.twosCompliment()
    }
    return bytes
  }

}

private extension Data {

  /// Two's compliment of _big endian_ integer
  func twosCompliment() -> Data {
    var data = self
    var increment = true
    for i in stride(from: data.count - 1, through: 0, by: -1) {
      if increment {
        (data[i], increment) = (~data[i]).addingReportingOverflow(1)
      }
      else {
        data[i] = ~data[i]
      }
    }
    return data
  }

}
