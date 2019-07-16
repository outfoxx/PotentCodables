//
//  File.swift
//  
//
//  Created by Kevin Wooten on 7/13/19.
//

import Foundation
import PotentCodables
import BigInt


/// ASN.1 `BIT STRING` value.
///
public struct BitString: Equatable, Hashable, CustomStringConvertible {

  public var length: Int
  public var bytes: Data

  public init(length: Int, bytes: Data) {
    self.bytes = bytes
    self.length = length
  }

  public init(bitString bytes: Data) {
    self.bytes = bytes
    self.length = bytes.count * 8
  }

  public init(octetString octets: Data) {
    self.init(octets: octets)
  }

  public init(flags: [Bool]) {
    var lastUsedIdx = 0
    var bits = Data(repeating: 0, count: (flags.count + 7) / 8)
    for (bitIndex, flag) in flags.enumerated() {
      if flag {
        let byteOffset = bitIndex / 8
        let bitOffset = bitIndex % 8
        let dstBitMask = UInt8(0x80) >> bitOffset
        bits[byteOffset] |= dstBitMask
        lastUsedIdx = bitIndex
      }
    }
    self.init(length: lastUsedIdx + 1, bytes: bits.prefix(through: lastUsedIdx / 8))
  }

  public init?(flags: String) {
    guard flags.allSatisfy({ $0 == "1" || $0 == "0" }) else { return nil }
    self.init(flags: flags.map { $0 == "1" })
  }

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

  public init<I>(bitPattern int: I) where I: FixedWidthInteger {
    self = withUnsafeBytes(of: int) { Self(octets: $0) }
  }

  public func copyOctets<C>(into octets: inout C) where C: MutableCollection, C.Element == UInt8, C.Index == Int {
    let bitLength = min(octets.count  * 8, self.length)
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

  public func octets(max: Int? = nil) -> Data {
    var octets = Data(repeating: 0, count: max ?? bytes.count)
    copyOctets(into: &octets)
    return octets
  }

  public func integer<I>(_ type: I.Type) -> I where I: FixedWidthInteger {
    var int: I = 0
    withUnsafeMutableBytes(of: &int) { ptr in
      var ptr = ptr
      copyOctets(into: &ptr)
    }
    return int
  }

  public var flags: [Bool] {
    var flags = [Bool]()
    for bitIndex in 0 ..< length {
      let byteOffset = bitIndex / 8
      let bitOffset = bitIndex % 8
      let srcBitMask = UInt8(0x80) >> bitOffset
      flags.append(bytes[byteOffset] & srcBitMask == srcBitMask)
    }
    return flags
  }

  public var description: String {
    return flags.map { $0 ? "1" : "0" }.joined(separator: "")
  }

}


extension BitString: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    guard let value = Self(flags: try container.decode(String.self)) else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "BIT STRING must be all '0' or '1' values")
    }
    self = value
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }

}
