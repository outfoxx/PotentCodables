/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
import PotentCodables


/// Allows encoding _any_ ASN.1 time value while controlling the specific ASN.1 type.
///
public struct AnyTime: Equatable, Hashable, Codable {


  public enum Kind: Int, Equatable, Hashable, Codable {
    case utc
    case generalized
  }


  public var kind: Kind?
  public var zonedDate: ZonedDate

  public init(_ zonedDate: ZonedDate, kind: Kind? = nil) {
    self.kind = kind
    self.zonedDate = zonedDate
  }

  public init(date: Date, timeZone: TimeZone, kind: Kind? = nil) {
    self.kind = kind
    zonedDate = ZonedDate(date: date, timeZone: timeZone)
  }

}
