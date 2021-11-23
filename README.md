Using this framework you can read property lists embedded inside of a running executable as well as those of executables
stored on disk. These types of executables are often Command Line Tools. Built-in support is provided for reading both
embedded info and launchd property lists. Custom property list types can also be specified.

To see a runnable sample app using this framework, check out
[SwiftAuthorizationSample](https://github.com/trilemma-dev/SwiftAuthorizationSample).

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftrilemma-dev%2FEmbeddedPropertyList%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/trilemma-dev/EmbeddedPropertyList)

# Usage
Property lists are returned as [`Data`](https://developer.apple.com/documentation/foundation/data) instances. Usually
you'll want to deserialize using one of:
 * `ProperyListDecoder`'s
   [`decode(_:from:)`](https://developer.apple.com/documentation/foundation/propertylistdecoder/2895397-decode)
   to deserialize the `Data` into a [`Decodable`](https://developer.apple.com/documentation/swift/decodable)
 * `PropertyListSerialization`'s 
   [`propertyList(from:options:format:)`](https://developer.apple.com/documentation/foundation/propertylistserialization/1409678-propertylist)
   to deserialize the `Data` into an [`NSDictionary`](https://developer.apple.com/documentation/foundation/nsdictionary)

### Example — Read Internal, Create `Decodable`
When running inside an executable, decode a launchd property list into a custom `Decodable` struct:
```swift
struct LaunchdPropertyList: Decodable {
    let machServices: [String : Bool]
    let label: String
    
    private enum CodingKeys: String, CodingKey {
        case machServices = "MachServices"
        case label = "Label"
    }
}

let data = try EmbeddedPropertyListReader.launchd.readInternal()
let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: data)
```

### Example — Read External, Create `NSDictionary`
For an external executable, deserialize an info property list as an `NSDictionary`:
```swift
let executableURL = URL(fileUrlWithPath: <# path here #>)
let data = try EmbeddedPropertyListReader.info.readExternal(from: executableURL)
let plist = try PropertyListSerialization.propertyList(from: data,
                                                       options: .mutableContainersAndLeaves,
                                                       format: nil) as? NSDictionary
```

### Example — Create `Decodable` Using `BundleVersion`
Decode an info property list, using `BundleVersion` to decode the 
 [`CFBundleVersion`](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleversion) 
entry:

```swift
struct InfoPropertyList: Decodable {
    let bundleVersion: BundleVersion
    let bundleIdentifier: String
    
    private enum CodingKeys: String, CodingKey {
        case bundleVersion = "CFBundleVersion"
        case bundleIdentifier = "CFBundleIdentifier"
    }
}

let data = try EmbeddedPropertyListReader.info.readInternal()
let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: data)
```
