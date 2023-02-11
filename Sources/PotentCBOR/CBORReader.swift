//
//  CBORReader.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


internal struct CBORReader {

  typealias Error = CBORSerialization.Error

  private let stream: CBORInputStream

  init(stream: CBORInputStream) {
    self.stream = stream
  }

  private func readHalf() throws -> CBOR.Half {
    return CBOR.Half(bitPattern: try stream.readInt(UInt16.self))
  }

  private func readFloat() throws -> CBOR.Float {
    return CBOR.Float(bitPattern: try stream.readInt(UInt32.self))
  }

  private func readDouble() throws -> CBOR.Double {
    return CBOR.Double(bitPattern: try stream.readInt(UInt64.self))
  }

  private func readVarUInt(_ initByte: UInt8, base: UInt8) throws -> UInt64 {
    guard initByte > base + 0x17 else { return UInt64(initByte - base) }

    switch try VarUIntSize.from(serialized: initByte) {
    case .uint8: return UInt64(try stream.readInt(UInt8.self))
    case .uint16: return UInt64(try stream.readInt(UInt16.self))
    case .uint32: return UInt64(try stream.readInt(UInt32.self))
    case .uint64: return UInt64(try stream.readInt(UInt64.self))
    }
  }

  private func readLength(_ initByte: UInt8, base: UInt8) throws -> Int {
    let length = try readVarUInt(initByte, base: base)

    guard length <= Int.max else {
      throw Error.sequenceTooLong
    }

    return Int(length)
  }

  /// Decodes `count` CBOR items.
  ///
  /// - Returns: An array of the decoded items
  /// - Throws:
  ///     - `CBORSerialization.Error`: If corrupted data is encountered,
  ///     including `.invalidBreak` if a break indicator is encountered in
  ///     an item slot
  ///     - `Swift.Error`: If any I/O error occurs
  private func decodeItems(count: Int) throws -> CBOR.Array {
    var result: CBOR.Array = []
    for _ in 0 ..< count {
      let item = try decodeRequiredItem()
      result.append(item)
    }
    return result
  }

  /// Decodes CBOR items until an indefinite-element break indicator
  /// is encountered.
  ///
  /// - Returns: An array of the decoded items
  /// - Throws:
  ///     - `CBORSerialization.Error`: If corrupted data is encountered
  ///     - `Swift.Error`: If any I/O error occurs
  private func decodeItemsUntilBreak() throws -> CBOR.Array {
    var result: CBOR.Array = []
    while let item = try decodeItem() {
      result.append(item)
    }
    return result
  }

  /// Decodes `count` key-value pairs of CBOR items.
  ///
  /// - Returns: A map of the decoded key-value pairs
  /// - Throws:
  ///     - `CBORSerialization.Error`: If corrupted data is encountered,
  ///     including `.invalidBreak` if a break indicator is encountered in
  ///     the either the key or value slot
  ///     - `Swift.Error`: If any I/O error occurs
  private func decodeItemPairs(count: Int) throws -> CBOR.Map {
    var result: CBOR.Map = [:]
    for _ in 0 ..< count {
      let key = try decodeRequiredItem()
      let val = try decodeRequiredItem()
      result[key] = val
    }
    return result
  }

  /// Decodes key-value pairs of CBOR items until an indefinite-element
  /// break indicator is encontered.
  ///
  /// - Returns: A map of the decoded key-value pairs
  /// - Throws:
  ///     - `CBORSerialization.Error`: If corrupted data is encountered,
  ///     including `.invalidBreak` if a break indicator is encountered in
  ///     the value slot
  ///     - `Swift.Error`: If any I/O error occurs
  private func decodeItemPairsUntilBreak() throws -> CBOR.Map {
    var result: CBOR.Map = [:]
    while let key = try decodeItem() {
      let val = try decodeRequiredItem()
      result[key] = val
    }
    return result
  }

  /// Decodes any CBOR item that is not an indefinite-element break indicator.
  ///
  /// - Returns: A non-break CBOR item
  /// - Throws:
  ///     - `CBORSerialization.Error`: If corrupted data is encountered,
  ///     including `.invalidBreak` if an indefinite-element indicator is
  ///     encountered
  ///     - `Swift.Error`: If any I/O error occurs
  func decodeRequiredItem() throws -> CBOR {
    guard let item = try decodeItem() else { throw Error.invalidBreak }
    return item
  }

  /// Decodes any CBOR item
  ///
  /// - Returns: A CBOR item or nil if an indefinite-element break indicator.
  /// - Throws:
  ///     - `CBORSerialization.Error`: If corrupted data is encountered
  ///     - `Swift.Error`: If any I/O error occurs
  private func decodeItem() throws -> CBOR? {
    let initByte = try stream.readByte()

    switch initByte {
    // positive integers
    case 0x00 ... 0x1B:
      return .unsignedInt(try readVarUInt(initByte, base: 0x00))

    // negative integers
    case 0x20 ... 0x3B:
      return .negativeInt(try readVarUInt(initByte, base: 0x20))

    // byte strings
    case 0x40 ... 0x5B:
      let numBytes = try readLength(initByte, base: 0x40)
      return .byteString(try stream.readBytes(count: numBytes))
    case 0x5F:
      return .byteString(try readIndefiniteByteString())

    // utf-8 strings
    case 0x60 ... 0x7B:
      return .utf8String(try readFiniteString(initByte: initByte))
    case 0x7F:
      return .utf8String(try readIndefiniteString())

    // arrays
    case 0x80 ... 0x9B:
      let itemCount = try readLength(initByte, base: 0x80)
      return .array(try decodeItems(count: itemCount))
    case 0x9F:
      return .array(try decodeItemsUntilBreak())

    // pairs
    case 0xA0 ... 0xBB:
      let itemPairCount = try readLength(initByte, base: 0xA0)
      return .map(try decodeItemPairs(count: itemPairCount))
    case 0xBF:
      return .map(try decodeItemPairsUntilBreak())

    // tagged values
    case 0xC0 ... 0xDB:
      let tag = try readVarUInt(initByte, base: 0xC0)
      let item = try decodeRequiredItem()
      return .tagged(CBOR.Tag(rawValue: tag), item)

    case 0xE0 ... 0xF3:
      return .simple(initByte - 0xE0)

    case 0xF4:
      return .boolean(false)

    case 0xF5:
      return .boolean(true)

    case 0xF6:
      return .null

    case 0xF7:
      return .undefined

    case 0xF8:
      return .simple(try stream.readByte())

    case 0xF9:
      return .half(try readHalf())
    case 0xFA:
      return .float(try readFloat())
    case 0xFB:
      return .double(try readDouble())

    case 0xFF:
      return nil

    default:
      throw Error.invalidItemType
    }
  }

  private func readFiniteString(initByte: UInt8) throws -> String {
    let numBytes = try readLength(initByte, base: 0x60)
    guard let string = String(data: try stream.readBytes(count: numBytes), encoding: .utf8) else {
      throw Error.invalidUTF8String
    }
    return string
  }

  private func readIndefiniteString() throws -> String {
    return try decodeItemsUntilBreak().map { item -> String in
      guard case .utf8String(let string) = item else { throw Error.invalidIndefiniteElement }
      return string
    }.joined(separator: "")
  }

  private func readIndefiniteByteString() throws -> Data {
    let datas = try decodeItemsUntilBreak().map { cbor -> Data in
      guard case .byteString(let bytes) = cbor else { throw Error.invalidIndefiniteElement }
      return bytes
    }.joined()
    return Data(datas)
  }

}

private enum VarUIntSize: UInt8 {
  case uint8 = 0
  case uint16 = 1
  case uint32 = 2
  case uint64 = 3

  static func from(serialized value: UInt8) throws -> VarUIntSize {
    switch value & 0b11 {
    case 0: return .uint8
    case 1: return .uint16
    case 2: return .uint32
    case 3: return .uint64
    default:
      // mask only allows values from 0-3
      throw CBORSerialization.Error.invalidIntegerSize
    }
  }
}
