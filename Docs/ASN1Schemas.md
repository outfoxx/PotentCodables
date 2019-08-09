
# ASN.1 Schemas

The ASN.1 format requires a `Schema` be passed to direct its encoding/decoding and resolve ambiguities that exist when attempting to support `Encodable` and/or `Decodable`.  It is a simple "DSL" that allows specification of schema that provides capabilities similar to those in the official ASN.1 syntax.

For example, the following is the schema for RFC-5280's `TBSCertificate`:
```swift
  let TBSCertificate: Schema =
    .sequence([
      "version": .version(.explicit(0, Version)),
      "serialNumber": CertificateSerialNumber,
      "signature": AlgorithmIdentifier(SignatureAlgorithms),
      "issuer": Name,
      "validity": Validity,
      "subject": Name,
      "subjectPublicKeyInfo": SubjectPublicKeyInfo,
      "issuerUniqueID": .versioned(range: 1...2, .implicit(1, UniqueIdentifier)),
      "subjectUniqueID": .versioned(range: 1...2, .implicit(2, UniqueIdentifier)),
      "extensions": .versioned(range: 2...2, .explicit(3, Extensions))
    ])
```

# TODO
Finish Schema Documentation!
