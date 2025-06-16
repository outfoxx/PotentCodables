# Reading and Writing ASN.1

Reading and writing ASN.1 encoded data to/from ``PotentASN1/ASN1`` tree values.

## Overview

``PotentASN1/ASN1Serialization`` can read ASN.1 DER encoded data into ``PotentASN1/ASN1`` tree values and write 
``PotentASN1/ASN1`` tree values to ASN.1 DER encoded data.

> Note: PotentASN1 only supports the `DER` encoding format.

### Reading ASN.1

```swift
import PotentASN1

let asn1Value = try ASN1Serialization.asn1(fromDER: derData)
```

### Writing ASN.1

``PotentASN1/ASN1Serialization`` can be used to write ``PotentASN1/ASN1`` values as ASN.1 encoded data values.

```swift
import PotentASN1

let derData = try ASN1Serialization.der(from: .sequence([.utf8String("Hello ASN.1"), .integer(5)]))
print(derData.base64EncodedString())
```

### ASN1 Tree Values

``PotentASN1/ASN1`` values can be manually queried for it's value or values.

```swift
if let string = asn1Value.utf8StringValue {
  print(string)
}

if let sequence = asn1Value.sequenceValue {
  sequence.forEach { print($0) }
}
// Alternatively, sequence values can use subscripting
print(asn1Value[0])
```
