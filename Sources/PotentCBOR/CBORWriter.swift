//
//  CBORWriter.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public struct CBORWriter {

  public enum StreamableItemType: UInt8 {
    case map = 0xBF
    case array = 0x9F
    case string = 0x7F
    case byteString = 0x5F
  }

  private(set) var stream: CBOROutputStream

  public init(stream: CBOROutputStream) {
    self.stream = stream
  }

  /// Encodes a single CBOR item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encode(_ value: CBOR) throws {
    switch value {
    case .null: try encodeNull()
    case .undefined: try encodeUndefined()
    case .unsignedInt(let uint): try encodeVarUInt(uint)
    case .negativeInt(let nint): try encodeNegativeInt(Int64(bitPattern: ~nint))
    case .byteString(let str): try encodeByteString(str)
    case .utf8String(let str): try encodeString(str)
    case .array(let array): try encodeArray(array)
    case .map(let map): try encodeMap(map)
    case .tagged(let tag, let value): try encodeTagged(tag: tag, value: value)
    case .simple(let value): try encodeSimpleValue(value)
    case .boolean(let bool): try encodeBool(bool)
    case .half(let half): try encodeHalf(half)
    case .float(let float): try encodeFloat(float)
    case .double(let double): try encodeDouble(double)
    }
  }

  /// Encodes any signed/unsigned integer, `or`ing `majorType` and `additional` data with first byte
  private func encodeInt(_ val: Int, majorType: UInt8, additional: UInt8 = 0) throws {
    try encodeInt(val, modifier: (majorType << 5) | (additional & 0x1F))
  }

  /// Encodes any signed/unsigned integer, `or`ing `modifier` with first byte
  private func encodeInt<T>(_ val: T, modifier: UInt8) throws where T: FixedWidthInteger, T: SignedInteger {
    if val < 0 {
      try encodeNegativeInt(Int64(val), modifier: modifier)
    }
    else {
      try encodeVarUInt(UInt64(val), modifier: modifier)
    }
  }

  /// Encodes any standard signed integer item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeInt<T>(_ val: T) throws where T: FixedWidthInteger, T: SignedInteger {
    try encodeInt(val, modifier: 0)
  }

  // MARK: - major 0: unsigned integer

  /// Encodes an 8bit unsigned integer, `or`ing `modifier` with first byte
  private func encodeUInt8(_ val: UInt8, modifier: UInt8 = 0) throws {
    if val < 24 {
      try stream.writeByte(val | modifier)
    }
    else {
      try stream.writeByte(0x18 | modifier)
      try stream.writeByte(val)
    }
  }

  /// Encodes a 16bit unsigned integer, `or`ing `modifier` with first byte
  private func encodeUInt16(_ val: UInt16, modifier: UInt8 = 0) throws {
    try stream.writeByte(0x19 | modifier)
    try stream.writeInt(val)
  }

  /// Encodes a 32bit unsigned integer, `or`ing `modifier` with first byte
  private func encodeUInt32(_ val: UInt32, modifier: UInt8 = 0) throws {
    try stream.writeByte(0x1A | modifier)
    try stream.writeInt(val)
  }

  /// Encodes a 64bit unsigned integer, `or`ing `modifier` with first byte
  private func encodeUInt64(_ val: UInt64, modifier: UInt8 = 0) throws {
    try stream.writeByte(0x1B | modifier)
    try stream.writeInt(val)
  }

  /// Encodes any standard unsigned integer item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeUInt<T>(_ val: T) throws where T: FixedWidthInteger, T: UnsignedInteger {
    try encodeUInt(val, modifier: 0)
  }

  /// Encodes any unsigned integer, `or`ing `modifier` with first byte
  private func encodeUInt<T>(_ val: T, modifier: UInt8) throws where T: FixedWidthInteger, T: UnsignedInteger {
    guard let value = UInt64(exactly: val) else { fatalError("invalid unsigned integer") }
    try encodeVarUInt(value, modifier: modifier)
  }

  /// Encodes any unsigned integer, `or`ing `modifier` with first byte
  private func encodeVarUInt(_ val: UInt64, modifier: UInt8 = 0) throws {
    switch val {
    case let val where val <= UInt8.max: try encodeUInt8(UInt8(val), modifier: modifier)
    case let val where val <= UInt16.max: try encodeUInt16(UInt16(val), modifier: modifier)
    case let val where val <= UInt32.max: try encodeUInt32(UInt32(val), modifier: modifier)
    default: try encodeUInt64(val, modifier: modifier)
    }
  }

  // MARK: - major 1: negative integer

  /// Encodes any negative integer item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeNegativeInt(_ val: Int64) throws {
    try encodeNegativeInt(val, modifier: 0)
  }

  private func encodeNegativeInt(_ val: Int64, modifier: UInt8) throws {
    assert(val < 0)
    try encodeVarUInt(~UInt64(bitPattern: val), modifier: 0b0010_0000 | modifier)
  }

  // MARK: - major 2: bytestring

  /// Encodes provided data as a byte string item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeByteString(_ str: Data) throws {
    try encodeInt(str.count, majorType: 0b010)
    try stream.writeBytes(str)
  }

  // MARK: - major 3: UTF8 string

  /// Encodes provided data as a UTF-8 string item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeString(_ str: String) throws {
    let len = str.utf8.count
    try encodeInt(len, majorType: 0b011)
    try str.withCString { ptr in
      try ptr.withMemoryRebound(to: UInt8.self, capacity: len) { ptr in
        try stream.writeBytes(UnsafeBufferPointer(start: ptr, count: len))
      }
    }
  }

  // MARK: - major 4: array of data items

  /// Encodes an array of CBOR items.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeArray(_ array: CBOR.Array) throws {
    try encodeInt(array.count, majorType: 0b100)
    try encodeArrayChunk(array)
  }

  /// Encodes an array chunk of CBOR items.
  ///
  /// - Note: This is specifically for use when creating
  /// indefinite arrays; see `encodeStreamStart` & `encodeStreamEnd`.
  /// Any number of chunks can be encoded in an indefinite array.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeArrayChunk(_ chunk: CBOR.Array) throws {
    for item in chunk {
      try encode(item)
    }
  }

  // MARK: - major 5: a map of pairs of data items

  /// Encodes a map of CBOR item pairs.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeMap(_ map: CBOR.Map) throws {
    try encodeInt(map.count, majorType: 0b101)
    try encodeMapChunk(map)
  }

  /// Encodes a map chunk of CBOR item pairs.
  ///
  /// - Note: This is specifically for use when creating
  /// indefinite maps; see `encodeStreamStart` & `encodeStreamEnd`.
  /// Any number of chunks can be encoded in an indefinite map.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeMapChunk(_ map: CBOR.Map) throws {
    for (key, value) in map {
      try encode(key)
      try encode(value)
    }
  }

  // MARK: - major 6: tagged values

  /// Encodes a tagged CBOR item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeTagged(tag: CBOR.Tag, value: CBOR) throws {
    try encodeVarUInt(tag.rawValue, modifier: 0b1100_0000)
    try encode(value)
  }

  // MARK: - major 7: floats, simple values, the 'break' stop code

  public func encodeSimpleValue(_ val: UInt8) throws {
    if val < 24 {
      try stream.writeByte(0b1110_0000 | val)
    }
    else {
      try stream.writeByte(0xF8)
      try stream.writeByte(val)
    }
  }

  /// Encodes CBOR null item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeNull() throws {
    try stream.writeByte(0xF6)
  }

  /// Encodes CBOR undefined item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeUndefined() throws {
    try stream.writeByte(0xF7)
  }

  /// Encodes Half item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeHalf(_ val: CBOR.Half) throws {
    try stream.writeByte(0xF9)
    try stream.writeInt(val.bitPattern)
  }

  /// Encodes Float item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeFloat(_ val: CBOR.Float) throws {
    try stream.writeByte(0xFA)
    try stream.writeInt(val.bitPattern)
  }

  /// Encodes Double item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeDouble(_ val: CBOR.Double) throws {
    try stream.writeByte(0xFB)
    try stream.writeInt(val.bitPattern)
  }

  /// Encodes Bool item.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeBool(_ val: Bool) throws {
    try stream.writeByte(val ? 0xF5 : 0xF4)
  }

  // MARK: - Indefinite length items

  /// Encodes a CBOR value indicating the opening of an indefinite-length data item.
  /// The user is responsible encoding subsequent valid CBOR items.
  ///
  /// - Attention: The user must end the indefinite item encoding with the end
  /// indicator, which can be encoded with `encodeStreamEnd()`.
  ///
  /// - Parameters:
  ///     - type: The type of indefinite-item to begin encoding.
  ///         - map: Indefinite map item (requires encoding zero or more "pairs" of items only)
  ///         - array: Indefinite array item
  ///         - string: Indefinite string item (requires encoding zero or more `string` items only)
  ///         - byteString: Indefinite string item (requires encoding zero or more `byte-string` items only)
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeIndefiniteStart(for type: StreamableItemType) throws {
    try stream.writeByte(type.rawValue)
  }

  // Encodes the indefinite-item end indicator.
  ///
  /// - Throws:
  ///     - `Swift.Error`: If any I/O error occurs
  public func encodeIndefiniteEnd() throws {
    try stream.writeByte(0xFF)
  }

}
