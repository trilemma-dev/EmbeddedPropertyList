Using this framework you can read property lists embedded inside of a running application as well as those of
executables stored on disk. Built in support is provided for reading both embedded Info and launchd property lists.
Custom property list types can also be specified.

Property lists are returned as [`Data`](https://developer.apple.com/documentation/foundation/data) instances. In most
cases you'll want to deserialize using one of:
 * `ProperyListDecoder`'s
   [`decode(_:from:)`](https://developer.apple.com/documentation/foundation/propertylistdecoder/2895397-decode)
   function to decode the `Data` into a [`Decodable`](https://developer.apple.com/documentation/swift/decodable)
   you define
 * `PropertyListSerialization`'s 
   [`propertyList(from:options:format:)`](https://developer.apple.com/documentation/foundation/propertylistserialization/1409678-propertylist)
   function to decode the `Data` into an 
   [`NSDictionary`](https://developer.apple.com/documentation/foundation/nsdictionary) containing the contents of the
   property list

### Example — Read Internal, Create Decodable
Decode a launchd property list when running inside an executable into a custom `Decodable` struct:
```swift
struct LaunchdPropertyList: Decodable {
    public let machServices: [String : Bool]
    public let label: String
    
    private enum CodingKeys: CodingKey, String {
        case machServices = "MachServices"
        case label = "Label"
    }
}

let data = try EmbeddedPropertyListReader.launchd.readInternal()
let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: data)
```

### Example — Read External, Create NSDictionary
Decode an info property list in an external executable into an `NSDictionary`:
```swift
let executableURL = URL(fileUrlWithPath: <# path here #>)
let data = try EmbeddedPropertyListReader.info.readExternal(from: executableURL)
let plist = try PropertyListSerialization.propertyList(from: data,
                                                       format: nil) as? NSDictionary
```

### Example — Create Decodable Using BundleVersion
Decode an info property list, using `BundleVersion` to decode the 
 [`CFBundleVersion`](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleversion) 
entry:

```swift
struct InfoPropertyList: Decodable {
    public let version: BundleVersion
    public let bundleIdentifier: String
    
    private enum CodingKeys: CodingKey, String {
        case version = "CFBundleVersion"
        case bundleIdentifier = "CFBundleIdentifier"
    }
}

let data = try EmbeddedPropertyListReader.info.readInternal()
let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: data)
```
