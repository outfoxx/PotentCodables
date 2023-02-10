# Using AnyValue

Decode and encode "any" structured value using ``PotentCodables/AnyValue``

## Overview

Sometimes it is necessary to decode values of any type or that can take on any structure; unfortunately Swift's 
`Codable` is not well suited for this purpose. PotentCodables provides ``PotentCodables/AnyValue`` to fill the gap.

Using ``PotentCodables/AnyValue`` is simple, just use it wherever you would normally use an `Any`. Since 
``PotentCodables/AnyValue`` supports `Codable` everything else works as normal including Swift's automatic codable
generation.
```swift
struct Account : Codable {
  let name: String
  let data: AnyValue                  // `data` can store and scalar or complex value
  let dataDict: [String: AnyValue]    // `dataDict` is required to be a dictionary of name to any values
  let dataArray: [AnyValue]           // `dataArray` is required to be an array of any values
}
```

The example `Account` struct above has a `data` property that can take on any value supported by the codable system.

For example when decoding from JSON, any value or tree of values (including _null_, _bool_, _string_, _number_,
_arrray_ or _object_) could be saved in the `data` property. Encoding the same `Account` value back to JSON will produce
equivalent serialized JSON regardless of the contents of the `data` field.

``PotentCodables/AnyValue`` has lots of features to make building and using them natural in Swift, like "dynamic member
lookup" to access fields of a ``PotentCodables/AnyValue/dictionary(_:)``. See the documentation for complete details.

### Performance
Although ``PotentCodables/AnyValue`` is compatible with any conformant `Codable` encoder or decoder, PotentCodables
decoders specifically have shortcuts to decode the proper values in a more performant fashion and should be used when
possible.
