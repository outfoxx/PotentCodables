# Schema based Encoding and Decoding

Use ASN.1 schemas to encode and decode to or from Swift structs and classes.

## Overview

ASN.1 is a position based format and lacks encoded field names for it's values; instead ASN.1 provides field names
and formats via ASN.1 schema notation.

To allow mapping ASN.1 data to Swift structures and classes, ``PotentASN1/ASN1Encoder`` and ``PotentASN1/ASN1Encoder``
require a provided ``PotentASN1/Schema`` to direct the encoding and/or decoding of Swift types.

For example, the following is the schema for RFC-5280's `Certificate`:
```swift
import PotentASN1

let certificateSchema: Schema =
  .sequence([
    "tbsCertificate": TBSCertificateSchema,
    "signatureAlgorithm": SignatureAlgorithmSchema,
    "signatureValue": .bitString,
  ])
```
> Note: The above example `certificateSchema` references `TBSCertificateSchema` and `SignatureAlgorithmSchema` that
are not provided here. The [Shield](https://github.com/outfoxx/Shield) Swift package provides complete support for
reading and writing PKCS types and the schemas it defines can be examined to see complete, complex ASN.1 schema
examples.

Using the `certificateSchema` schema a DER encoded certificate can be decoded using an ``PotentASN1/ASN1Decoder``.
```swift
import PotentASN1

struct Certificate {
  var tbsCertificate: TBSCertificate // defined elsewhere
  var signatureAlgorithm: SignatureAlgorithm // defined elsewhere
  var signatureValue: BitString
}

let certificate = ASN1Decoder(schema: certificateSchema).decode(Certificate.self, from: certificateData)
```
