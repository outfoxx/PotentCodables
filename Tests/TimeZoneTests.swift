//
//  TimeZoneTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import XCTest

class TimeZoneTests: XCTestCase {

  func testParsingOffsets() throws {

    let noOff = TimeZone.offset(from: "20201212111111.000")
    XCTAssertNil(noOff)

    let utcOff = TimeZone.offset(from: "20201212111111.000Z")
    XCTAssertEqual(utcOff, 0)

    let aheadSecsOff1 = TimeZone.offset(from: "20201212111111.000+123456")
    XCTAssertEqual(aheadSecsOff1, 45296)
    let aheadSecsOff2 = TimeZone.offset(from: "20201212111111.000+12:34:56")
    XCTAssertEqual(aheadSecsOff2, 45296)

    let behindSecsOff1 = TimeZone.offset(from: "20201212111111.000-123456")
    XCTAssertEqual(behindSecsOff1, -45296)
    let behindSecsOff2 = TimeZone.offset(from: "20201212111111.000-12:34:56")
    XCTAssertEqual(behindSecsOff2, -45296)

    let aheadMinsOff1 = TimeZone.offset(from: "20201212111111.000+1234")
    XCTAssertEqual(aheadMinsOff1, 45240)
    let aheadMinsOff2 = TimeZone.offset(from: "20201212111111.000+12:34")
    XCTAssertEqual(aheadMinsOff2, 45240)

    let behindMinsOff1 = TimeZone.offset(from: "20201212111111.000-1234")
    XCTAssertEqual(behindMinsOff1, -45240)
    let behindMinsOff2 = TimeZone.offset(from: "20201212111111.000-12:34")
    XCTAssertEqual(behindMinsOff2, -45240)

    let aheadHrsOff = TimeZone.offset(from: "20201212111111.000+12")
    XCTAssertEqual(aheadHrsOff, 43200)

    let behindHrsOff = TimeZone.offset(from: "20201212111111.000-12")
    XCTAssertEqual(behindHrsOff, -43200)
  }

  func testParsingTimeZones() throws {

    let noTZ = TimeZone.timeZone(from: "20201212111111.000")
    XCTAssertNil(noTZ)

    let utcTZ = TimeZone.timeZone(from: "20201212111111.000Z")
    XCTAssertEqual(utcTZ?.secondsFromGMT(), 0)

    let aheadSecsTZ1 = TimeZone.timeZone(from: "20201212111111.000+123456")
    XCTAssertEqual(aheadSecsTZ1?.secondsFromGMT(), 45296)
    let aheadSecsTZ2 = TimeZone.timeZone(from: "20201212111111.000+12:34:56")
    XCTAssertEqual(aheadSecsTZ2?.secondsFromGMT(), 45296)

    let behindSecsTZ1 = TimeZone.timeZone(from: "20201212111111.000-123456")
    XCTAssertEqual(behindSecsTZ1?.secondsFromGMT(), -45296)
    let behindSecsTZ2 = TimeZone.timeZone(from: "20201212111111.000-12:34:56")
    XCTAssertEqual(behindSecsTZ2?.secondsFromGMT(), -45296)

    let aheadMinsTZ1 = TimeZone.timeZone(from: "20201212111111.000+1234")
    XCTAssertEqual(aheadMinsTZ1?.secondsFromGMT(), 45240)
    let aheadMinsTZ2 = TimeZone.timeZone(from: "20201212111111.000+12:34")
    XCTAssertEqual(aheadMinsTZ2?.secondsFromGMT(), 45240)

    let behindMinsTZ1 = TimeZone.timeZone(from: "20201212111111.000-1234")
    XCTAssertEqual(behindMinsTZ1?.secondsFromGMT(), -45240)
    let behindMinsTZ2 = TimeZone.timeZone(from: "20201212111111.000-12:34")
    XCTAssertEqual(behindMinsTZ2?.secondsFromGMT(), -45240)

    let aheadHrsTZ = TimeZone.timeZone(from: "20201212111111.000+12")
    XCTAssertEqual(aheadHrsTZ?.secondsFromGMT(), 43200)

    let behindHrsTZ = TimeZone.timeZone(from: "20201212111111.000-12")
    XCTAssertEqual(behindHrsTZ?.secondsFromGMT(), -43200)
  }

}
