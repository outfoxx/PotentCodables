# Reading and Writing CBOR

Reading and writing CBOR encoded data to/from ``PotentCBOR/CBOR`` tree values.

## Overview

### Reading CBOR

``PotentCBOR/CBORSerialization`` can read CBOR encoded data into ``PotentCBOR/CBOR`` tree values.

```swift
import PotentCBOR

let cbor1Value = CBORSerialization.cbor(from: cborData)
```

### Writing CBOR

``PotentCBOR/CBORSerialization`` can be used to write ``PotentCBOR/CBOR`` values as CBOR 
encoded data.

```swift
import PotentCBOR

let cborData = CBORSerialization.data(from: .array([.utf8String("Hello CBOR"), .boolean(true)]))
print(cborData.base64EncodedString())
```

### Tree Values

``PotentCBOR/CBOR`` tree values can be manually queried for their value or values.

```swift
if let string = cborValue.utf8StringValue {
  print(string)
}

if let array = cborValue.arrayValue {
  array.forEach { print($0) }
}
// Alternatively, array values can use subscripting
print(cbor1Value[0])

if let map = cborValue.mapValue {
  map.forEach { (key, value) in print("\(key) = \(value)") }
}
// Alternatively, map values can use subscripting or dynamic member lookup
print(cborValue["myField"])
print(cborValue.myField)
```
