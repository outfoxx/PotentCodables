//
//  Assertions.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
@testable import PotentJSON
import XCTest


public func AssertDecodingTypeMismatch(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case DecodingError.typeMismatch = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

public func AssertDecodingDataCorrupted(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case DecodingError.dataCorrupted = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

public func AssertDecodingKeyNotFound(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case DecodingError.keyNotFound = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

public func AssertDecodingValueNotFound(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case DecodingError.valueNotFound = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

public func AssertEncodingInvalidValue(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case EncodingError.invalidValue = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

public func AssertJSONErrorInvalidData(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case JSONReader.Error.invalidData = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}
