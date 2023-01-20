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


public extension BigUInt {

  /// Initializes an integer from the provided `Data` in ASN.1 DER format.
  ///
  /// - Parameter data: Base-256 representation, in network (big-endian) byte order.
  ///
  init(derEncoded data: Data) {
    self.init(data)
  }

  /// Encodes the integer to `Data` in  ASN.1 DER format.
  ///
  /// - Returns: Base-256 representation, in network (big-endian) byte order.
  ///
  func derEncoded() -> Data { serialize() }

}

public extension BigInt {

  /// Initializes an integer from the provided `Data` in ASN.1 DER format.
  ///
  /// - Parameter data: Two's compliment, base-256 representation, in network (big-endian) byte order.
  ///
  init(derEncoded data: Data) {
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

  /// Encodes the integer to `Data` in  ASN.1 DER format.
  ///
  /// - Returns: Two's compliment, base-256 representation, in network (big-endian) byte order.
  /// 
  func derEncoded() -> Data {
    var bytes = magnitude.serialize()
    if bytes.isEmpty || (bytes[0] & 0x80) == 0x80 {
      // Make room for sign
      bytes.insert(0, at: 0)
    }
    if sign == .plus {
      return bytes
    }
    var twos = bytes.twosCompliment()
    // Compact
    while twos.canRemoveLeadingByte() {
      twos.remove(at: 0)
    }
    return twos
  }

}

private extension Data {

  func canRemoveLeadingByte() -> Bool {
    count > 1 && ((self[0] == 0xff && self[1] & 0x80 == 0x80) || (self[0] == 0x00 && self[1] & 0x80 == 0x00))
  }

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
