//
//  BigInts.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation


extension BigUInt {

  init(serialized data: Data) {
    self.init(data)
  }

  func serialized() -> Data { serialize() }

}

extension BigInt {

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
