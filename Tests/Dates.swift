//
//  Dates.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation

extension Date {

  var truncatedToSecs: Date {
    Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.rounded())
  }

  var truncatedToMillisecs: Date {
    Date(timeIntervalSinceReferenceDate: millisecondsFromReferenceDate)
  }

  var millisecondsFromReferenceDate: TimeInterval {
    return (timeIntervalSinceReferenceDate * 1000.0).rounded() / 1000.0
  }

}
