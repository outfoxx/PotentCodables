//
//  ASN1Tests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentASN1
import PotentCodables
import XCTest


class ASN1Tests: XCTestCase {

  func testExplicitSchema() throws {

    struct TestStruct: Codable, Equatable {
      let a: Int
      let b: String
      let c: [Bool]
    }

    let TestStructSchema: Schema =
      .sequence([
        "a": .integer(),
        "b": .string(kind: .utf8),
        "c": .setOf(.boolean()),
      ])


    let src = TestStruct(a: 5, b: "BBB", c: [false, true, false])
    let srcData = try ASN1Encoder(schema: TestStructSchema).encode(src)
    let dst = try ASN1Decoder(schema: TestStructSchema).decode(TestStruct.self, from: srcData)

    XCTAssertEqual(src, dst)
  }

  func testDecodeASN1Null() throws {

    struct TestStruct: Codable, Equatable {
      let a: String
      let b: ASN1
    }

    let TestStructSchema: Schema =
      .sequence([
        "a": .string(kind: .utf8),
        "b": .choiceOf([.integer(), .null]),
      ])

    let src = TestStruct(a: "test", b: .null)
    let srcData = try ASN1Encoder(schema: TestStructSchema).encode(src)
    let dst = try ASN1Decoder(schema: TestStructSchema).decode(TestStruct.self, from: srcData)

    XCTAssertEqual(src, dst)
  }

  func testGeneralizedTimeEncodingDecoding() throws {

    struct TestStruct: Codable, Equatable {
      let a: AnyTime
      let b: AnyTime
    }

    let TestStructSchema: Schema =
      .sequence([
        "a": .time(kind: .generalized),
        "b": .time(kind: .generalized),
      ])

    let src = TestStruct(
      a: AnyTime(date: Date().truncatedToSecs, timeZone: .utc, kind: .generalized),
      b: AnyTime(date: Date().truncatedToSecs, timeZone: .timeZone(from: "+1122")!, kind: .generalized)
    )
    let srcData = try ASN1Encoder(schema: TestStructSchema).encode(src)
    let dst = try ASN1Decoder(schema: TestStructSchema).decode(TestStruct.self, from: srcData)

    XCTAssertEqual(src, dst)
  }

  func testGeneralizedTimeReadingWriting() throws {

    let writer = DERWriter()
    try writer.write(ASN1.tagged(24, "22221111223344".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567".data(using: .ascii)!))

    try writer.write(ASN1.tagged(24, "22221111223344Z".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567Z".data(using: .ascii)!))

    try writer.write(ASN1.tagged(24, "22221111223344+11:22:33".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567+11:22:33".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344+112233".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567+112233".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344+11:22".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567+11:22".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344+1122".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567+1122".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344+11".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567+11".data(using: .ascii)!))

    try writer.write(ASN1.tagged(24, "22221111223344-11:22:33".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567-11:22:33".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344-112233".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567-112233".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344-11:22".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567-11:22".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344-1122".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567-1122".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344-11".data(using: .ascii)!))
    try writer.write(ASN1.tagged(24, "22221111223344.567-11".data(using: .ascii)!))

    let values = try DERReader.parse(data: writer.data)

    func date(_ index: Int) -> TimeInterval { values[index].generalizedTimeValue!.date.timeIntervalSince1970 }
    func tz(_ index: Int) -> TimeZone { values[index].generalizedTimeValue!.timeZone }
    func offset(_ index: Int) -> Int { values[index].generalizedTimeValue!.timeZone.secondsFromGMT() }

    XCTAssertEqual(date(0), 7_979_553_224.0)
    XCTAssertEqual(tz(0), .current)
    XCTAssertEqual(date(1), 7_979_553_224.567)
    XCTAssertEqual(tz(1), .current)

    XCTAssertEqual(date(2), 7_979_553_224)
    XCTAssertEqual(tz(2), .utc)
    XCTAssertEqual(date(3), 7_979_553_224.567)
    XCTAssertEqual(tz(3), .utc)

    XCTAssertEqual(date(4), 7_979_553_224 - 40953)
    XCTAssertEqual(offset(4), 40980)
    XCTAssertEqual(date(5), 7_979_553_224.567 - 40953)
    XCTAssertEqual(offset(5), 40980)
    XCTAssertEqual(date(6), 7_979_553_224 - 40953)
    XCTAssertEqual(offset(6), 40980)
    XCTAssertEqual(date(7), 7_979_553_224.567 - 40953)
    XCTAssertEqual(offset(7), 40980)
    XCTAssertEqual(date(8), 7_979_553_224 - 40920)
    XCTAssertEqual(offset(8), 40920)
    XCTAssertEqual(date(9), 7_979_553_224.567 - 40920)
    XCTAssertEqual(offset(9), 40920)
    XCTAssertEqual(date(10), 7_979_553_224 - 40920)
    XCTAssertEqual(offset(10), 40920)
    XCTAssertEqual(date(11), 7_979_553_224.567 - 40920)
    XCTAssertEqual(offset(11), 40920)
    XCTAssertEqual(date(12), 7_979_553_224 - 39600)
    XCTAssertEqual(offset(12), 39600)
    XCTAssertEqual(date(13), 7_979_553_224.567 - 39600)
    XCTAssertEqual(offset(13), 39600)

    XCTAssertEqual(date(14), 7_979_553_224 + 40953)
    XCTAssertEqual(offset(14), -40980)
    XCTAssertEqual(date(15), 7_979_553_224.567 + 40953)
    XCTAssertEqual(offset(15), -40980)
    XCTAssertEqual(date(16), 7_979_553_224 + 40953)
    XCTAssertEqual(offset(16), -40980)
    XCTAssertEqual(date(17), 7_979_553_224.567 + 40953)
    XCTAssertEqual(offset(17), -40980)
    XCTAssertEqual(date(18), 7_979_553_224 + 40920)
    XCTAssertEqual(offset(18), -40920)
    XCTAssertEqual(date(19), 7_979_553_224.567 + 40920)
    XCTAssertEqual(offset(19), -40920)
    XCTAssertEqual(date(20), 7_979_553_224 + 40920)
    XCTAssertEqual(offset(20), -40920)
    XCTAssertEqual(date(21), 7_979_553_224.567 + 40920)
    XCTAssertEqual(offset(21), -40920)
    XCTAssertEqual(date(22), 7_979_553_224 + 39600)
    XCTAssertEqual(offset(22), -39600)
    XCTAssertEqual(date(23), 7_979_553_224.567 + 39600)
    XCTAssertEqual(offset(23), -39600)
  }

}


extension Date {

  var truncatedToSecs: Date { Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.rounded()) }

  var millisecondsFromReferenceDate: TimeInterval {
    return (timeIntervalSinceReferenceDate * 1000.0).rounded() / 1000.0
  }

}
