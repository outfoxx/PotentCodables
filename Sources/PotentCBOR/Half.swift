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

import Accelerate
import Foundation

public typealias Half = Float16

/// 16bit floating point container
///
/// - Note: This is purely a data transfer value to use
/// as a placeholder until Swift gains a native Float16 alue
public struct Float16: Equatable, Hashable, ExpressibleByFloatLiteral {

  private var storage: UInt16

  /// Initialize value with its `UInt16` bit pattern
  ///
  /// - Parameter bitPattern: 16bits representing the floating point bits
  public init(bitPattern: UInt16) {
    storage = bitPattern
  }

  /// Initialize value from a 32 bit float
  ///
  /// - Parameter value: 32bit floating value
  public init(_ value: Float) {
    storage = 0
    var value = value
    float32to16(input: &value, output: &storage)
  }

  public init(floatLiteral value: Float) {
    storage = 0
    var value = value
    float32to16(input: &value, output: &storage)
  }

  public var bitPattern: UInt16 {
    return storage
  }

  /// The value as a 32bit floating point
  ///
  /// - Note: This uses a correct but _slow_ method
  /// of translating between 32 and 16 bit values;
  /// it should not be used in performance oriented
  /// code.
  public var floatValue: Float {
    get {
      var storage = self.storage
      var result = Float(0)
      float16to32(input: &storage, output: &result)
      return result
    }
    set {
      var newValue = newValue
      float32to16(input: &newValue, output: &storage)
    }
  }

}


private func float16to32(input: UnsafeMutablePointer<UInt16>, output: UnsafeMutableRawPointer) {
  var bufferFloat16 = vImage_Buffer(data: input, height: 1, width: 1, rowBytes: 2)
  var bufferFloat32 = vImage_Buffer(data: output, height: 1, width: 1, rowBytes: 4)
  if vImageConvert_Planar16FtoPlanarF(&bufferFloat16, &bufferFloat32, 0) != kvImageNoError {
    fatalError("Error converting float16 to float32")
  }
}

private func float32to16(input: UnsafeMutablePointer<Float>, output: UnsafeMutableRawPointer) {
  var bufferFloat32 = vImage_Buffer(data: input, height: 1, width: 1, rowBytes: 4)
  var bufferFloat16 = vImage_Buffer(data: output, height: 1, width: 1, rowBytes: 2)
  if vImageConvert_PlanarFtoPlanar16F(&bufferFloat32, &bufferFloat16, 0) != kvImageNoError {
    fatalError("Error converting float32 to float16")
  }
}
