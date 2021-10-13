# ``EmbeddedPropertyList``

Read property lists embedded inside of Mach-O executables.

## Overview
Using this framework you can read property lists embedded inside of a running executable as well as those of
executables stored on disk. These types of executables are often Command Line Tools. Built-in support is provided for
reading both embedded info and launchd property lists. Custom property list types can also be specified.

> Note: Only 64-bit Intel and ARM executables (or universal binary slices) are supported. Mac OS X 10.6 
Snow Leopard was the last 32-bit OS. macOS 10.14 Mojave was the last to run 32-bit binaries.

## Usage
Property lists are returned as [`Data`](https://developer.apple.com/documentation/foundation/data) instances. Usually
you'll want to deserialize using one of:
 * `ProperyListDecoder`'s
   [`decode(_:from:)`](https://developer.apple.com/documentation/foundation/propertylistdecoder/2895397-decode)
   to deserialize the `Data` into a [`Decodable`](https://developer.apple.com/documentation/swift/decodable)
 * `PropertyListSerialization`'s 
   [`propertyList(from:options:format:)`](https://developer.apple.com/documentation/foundation/propertylistserialization/1409678-propertylist)
   to deserialize the `Data` into an [`NSDictionary`](https://developer.apple.com/documentation/foundation/nsdictionary)

#### Example — Read Internal, Create Decodable
When running inside an executable, decode a launchd property list into a custom `Decodable` struct:
```swift
struct LaunchdPropertyList: Decodable {
    let machServices: [String : Bool]
    let label: String
    
    private enum CodingKeys: CodingKey, String {
        case machServices = "MachServices"
        case label = "Label"
    }
}

let data = try EmbeddedPropertyListReader.launchd.readInternal()
let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, 
                                             from: data)
```

#### Example — Read External, Create NSDictionary
For an external executable, deserialize an info property list as an `NSDictionary`:
```swift
let executableURL = URL(fileUrlWithPath: <# path here #>)
let data = try EmbeddedPropertyListReader.info.readExternal(from: executableURL)
let plist = try PropertyListSerialization.propertyList(from: data,
                                                       options: .mutableContainersAndLeaves,
                                                       format: nil) as? NSDictionary
```

#### Example — Create Decodable Using Version
Decode an info property list, using ``Version`` to decode the 
 [`CFBundleVersion`](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleversion) 
entry:

```swift
struct InfoPropertyList: Decodable {
    let bundleVersion: Version
    let bundleIdentifier: String
    
    private enum CodingKeys: CodingKey, String {
        case bundleVersion = "CFBundleVersion"
        case bundleIdentifier = "CFBundleIdentifier"
    }
}

let data = try EmbeddedPropertyListReader.info.readInternal()
let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: data)
```

#### Comparing Property Lists
In some circumstances you may want to directly compare two property lists. If you want to compare their true on disk
representations, you can 
[compare them as `Data` instances](https://developer.apple.com/documentation/foundation/data/2293245). However, because
there are multiple encoding formats for property lists in most cases you should first deserialize them before performing
a comparison.

## Topics

### Reader

- ``EmbeddedPropertyListReader``

### Property List Types

- ``Version``

### Errors

- ``ReadError``
