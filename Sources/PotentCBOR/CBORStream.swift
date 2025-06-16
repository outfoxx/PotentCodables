//
//  CBORStream.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// A source stream of bytes that can be used to retrieve CBOR encoded data
public protocol CBORInputStream: AnyObject {

  func readByte() throws -> UInt8
  func readBytes<T>(into: UnsafeMutablePointer<T>) throws
  func readBytes(count: Int) throws -> Data
  func readInt<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger

}


/// A destination stream of bytes that can be used to store CBOR encoded data
public protocol CBOROutputStream: AnyObject {

  func writeByte(_ byte: UInt8) throws
  func writeBytes(_ ptr: UnsafeBufferPointer<UInt8>) throws
  func writeBytes(_ data: Data) throws
  func writeInt<T>(_ int: T) throws where T: FixedWidthInteger

}


public extension CBORInputStream {

  func readInt<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger {
    var value: T = 0
    try readBytes(into: &value)
    return T(bigEndian: value)
  }

}

public extension CBOROutputStream {

  func writeInt<T>(_ int: T) throws where T: FixedWidthInteger {
    try withUnsafeBytes(of: int.bigEndian) { ptr in
      try writeBytes(ptr.bindMemory(to: UInt8.self))
    }
  }

}


/// A ``CBORInputStream`` & ``CBOROutputStream`` targeting a single `Data` value
public class CBORDataStream: CBORInputStream, CBOROutputStream {

  public private(set) var data: Data
  private var offset: Int

  public init(data: Data = Data(), offset: Int = 0) {
    self.data = data
    self.offset = offset + data.startIndex
  }

  public func reset() {
    data.removeAll()
    offset = data.startIndex
  }

  func checkAvailable(count: Int) throws {
    if (offset + count) > data.endIndex {
      throw CBORSerialization.Error.unexpectedEndOfStream
    }
  }

  public func readByte() throws -> UInt8 {
    try checkAvailable(count: 1)
    defer { offset += 1 }
    return data[offset]
  }

  public func readBytes<T>(into ptr: UnsafeMutablePointer<T>) throws {
    let size = MemoryLayout<T>.size
    try checkAvailable(count: size)
    defer { offset += size }
    data.copyBytes(to: UnsafeMutableBufferPointer(start: ptr, count: 1), from: offset ..< (offset + size))
  }

  public func readBytes(count: Int) throws -> Data {
    try checkAvailable(count: count)
    defer { offset += count }
    return data.subdata(in: offset ..< (offset + count))
  }

  public func writeByte(_ byte: UInt8) throws {
    data.append(byte)
  }

  public func writeBytes(_ ptr: UnsafeBufferPointer<UInt8>) throws {
    guard let baseAddress = ptr.baseAddress else {
      return
    }
    data.append(baseAddress, count: ptr.count)
  }

  public func writeBytes(_ data: Data) throws {
    self.data.append(data)
  }

}
