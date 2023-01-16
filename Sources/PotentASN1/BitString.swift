//
//  BitString.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentCodables


/// ASN.1 `BIT STRING` value.
///
public struct BitString: Equatable, Hashable, CustomStringConvertible {

  /// Total number of bits.
  public var length: Int
  /// Byte storage for bits.
  public var bytes: Data

  /// Initialize with total bit length and byte storage.
  ///
  /// - Parameters:
  ///   - length: Total number of bits.
  ///   - bytes: Byte storage for bits.
  ///
  public init(length: Int, bytes: Data) {
    self.bytes = bytes
    self.length = length
  }

  /// Initialize with byte data storage.
  ///
  /// The total bit count of the bit string is assumed to be
  /// all the bits the provided in the `bytes` parameter.
  ///
  /// - Parameter bytes: Byte storage for bits.
  ///
  public init(bytes: Data) {
    self.bytes = bytes
    length = bytes.count * 8
  }

  /// Initialize with bit flags.
  ///
  /// - Parameter bitFlags: Array of bit flags.
  ///
  public init(bitFlags: [Bool]) {
    var lastUsedIdx = 0
    var bits = Data(repeating: 0, count: (bitFlags.count + 7) / 8)
    for (bitIndex, flag) in bitFlags.enumerated() where flag {
      let byteOffset = bitIndex / 8
      let bitOffset = bitIndex % 8
      let dstBitMask = UInt8(0x80) >> bitOffset
      bits[byteOffset] |= dstBitMask
      lastUsedIdx = bitIndex
    }
    self.init(length: lastUsedIdx + 1, bytes: bits.prefix(through: lastUsedIdx / 8))
  }

  /// Initialize with string of bit flags.
  ///
  /// - Parameter flags: String of bit flags. Each character of the string must be a `1` or `0`.
  /// - Returns: Initialized ``BitString`` or `nil` if any character of the string is not a `1` or `0`.
  ///
  public init?(bitFlags: String) {
    guard bitFlags.allSatisfy({ $0 == "1" || $0 == "0" }) else { return nil }
    self.init(bitFlags: bitFlags.map { $0 == "1" })
  }

  /// Initialize with collection of octets.
  ///
  /// The initialized bit string will only be as large as required to
  /// fit the used bits of the provided octets and no larger.
  ///
  /// - Parameter octets: Octets of integer to initialize from.
  ///
  public init<C>(octets: C) where C: RandomAccessCollection, C.Element == UInt8, C.Index == Int {
    var lastUsedIdx = 0
    var bits = Data(repeating: 0, count: octets.count)
    let bitLength = octets.count * 8
    for bitIndex in 0 ..< bitLength {
      let byteOffset = bitIndex / 8
      let bitOffset = bitIndex % 8
      let srcBitMask = UInt8(0x01) << bitOffset
      if octets[byteOffset] & srcBitMask == srcBitMask {
        let dstBitMask = UInt8(0x80) >> bitOffset
        bits[byteOffset] |= dstBitMask
        lastUsedIdx = bitIndex
      }
    }
    self.init(length: lastUsedIdx + 1, bytes: bits.prefix(through: lastUsedIdx / 8))
  }

  /// Initialize with octets of a fixed width integer.
  ///
  /// The initialized bit string will only be as large as required to
  /// fit the used bits of the provided octets and no larger.
  ///
  /// - Parameter bitPattern: Integer to initialize from.
  ///
  public init<I>(bitPattern int: I) where I: FixedWidthInteger {
    self = withUnsafeBytes(of: int) { Self(octets: $0) }
  }

  /// Copy the octets which represent the used bits of the value
  /// into the provided collection.
  ///
  /// - Parameter into: Target octet collection to copy to.
  ///
  public func copyOctets<C>(into octets: inout C) where C: MutableCollection, C.Element == UInt8, C.Index == Int {
    let bitLength = min(octets.count * 8, length)
    for bitIndex in 0 ..< bitLength {
      let byteOffset = bitIndex / 8
      let bitOffset = bitIndex % 8
      let srcBitMask = UInt8(0x80) >> bitOffset
      if bytes[byteOffset] & srcBitMask == srcBitMask {
        let dstBitMask = UInt8(0x01) << bitOffset
        octets[byteOffset] |= dstBitMask
      }
    }
  }


  /// Copied octets of the bit string, returned as `Data`.
  ///
  /// - Parameter max: Maximum number of octets to copy or `nil` to copy all.
  /// - Returns: Copied octets.
  ///
  public func octets(max: Int? = nil) -> Data {
    var octets = Data(repeating: 0, count: max ?? bytes.count)
    copyOctets(into: &octets)
    return octets
  }

  /// Copied octets of the bit string, returned as a fixed-width integer.
  ///
  /// - Parameter type: Type of fixed-width integer.
  /// - Returns: Copied octets as fixed-width integer.
  ///
  public func integer<I>(_ type: I.Type) -> I where I: FixedWidthInteger {
    var int: I = 0
    withUnsafeMutableBytes(of: &int) { ptr in
      var ptr = ptr
      copyOctets(into: &ptr)
    }
    return int
  }

  /// Collection of bit flags.
  public var bitFlags: [Bool] {
    var flags = [Bool]()
    for bitIndex in 0 ..< length {
      let byteOffset = bitIndex / 8
      let bitOffset = bitIndex % 8
      let srcBitMask = UInt8(0x80) >> bitOffset
      flags.append(bytes[byteOffset] & srcBitMask == srcBitMask)
    }
    return flags
  }

  /// String of bit flags as text representation with each character a `0` or `1`.
  public var bitFlagString: String {
    return bitFlags.map { $0 ? "1" : "0" }.joined(separator: "")
  }

  public var description: String { bitFlagString }

}


extension BitString: Codable {

  /// Decodes the value from a string of bit flags where each
  /// character is a `0` or `1`.
  ///
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    guard let value = Self(bitFlags: try container.decode(String.self)) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "BIT STRING must be all '0' or '1' values"
      )
    }
    self = value
  }

  /// Encodes the value into a string of bit flags where each
  /// character is a `0` or `1`.
  ///
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }

}
