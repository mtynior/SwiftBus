<div align="center">
    <img src="https://user-images.githubusercontent.com/6362174/213769534-7ad3b0b9-31e0-4358-8bdf-79aa443a482a.png" height="256" />
    <h1>SwiftBus</h1>
    <h3>A simple and lightweight Event Bus library written in Swift and powered by Combine</h3>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/language-Swift-orange" />
  <img src="https://img.shields.io/badge/Powered&nbsp;by-Combine-orange" />  
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" />
</p>

## Getting started 

### Swift Package Manager
You can add SwiftBus to your project by adding it as a dependency in your `Package.swift` file:
```swift
// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyProject",
    products: [
        .library(name: "MyProject", targets: ["MyProject"])
    ],
    dependencies: [
         .package(url: "https://github.com/mtynior/SwiftBus.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "MyProject", dependencies: ["SwiftBus"]),
        .testTarget(name: "MyProjectTests", dependencies: ["MyProject"])
    ]
)
```

### Xcode

<p align="center">
    <img src="https://res.cloudinary.com/mtynior/image/upload/v1634748957/development/match_xcode_oleolc.jpg">
</p>

Open your project in Xcode, then:
1. Click File -> Add Packages,
2. In the search bar type: `https://github.com/mtynior/SwiftBus.git` and press `Enter`,
3. Once Xcode finds the library, set Dependency rule to `Up to next major version`,
4. Click Add Package,
5. Select the desired Target (If you have multiple targets, you can add the dependency manually from Xcode)
6. Confirm selection by clicking on Add Package.

### TL;DR
SwiftBus allows to send and receive custom events that conform to empty `EventRepresentable` protocol:

```swift
import SwiftBus
import Combine

// 1. Define custom event
struct RebelsActivityDetectedEvent: EventRepresentable {
    let planet: String
    let distanceInParsecs: Int
}

// 2. Create EventBus
let eventBus: EventTransmittable = EventBus()
var subscriptions: Set<AnyCancellable> = []

// 3. Add event handlers and store the reference to a subscription
eventBus.onReceive(RebelsActivityDetectedEvent.self) { event in
  print("Detected rebels \(event.distanceInParsecs) parsecs from us on \(event.planet)")
}
.store(in: &subscriptions)

// 4. Send event
let event = RebelsActivityDetectedEvent(planet: "Hoth", distanceInParsecs: 12)
eventBus.send(event)
```

### Named events
If you don't want a custom event structure, you can send and receive a named event:

```swift
import SwiftBus
import Combine

// 1. Create EventBus
let eventBus: EventTransmittable = EventBus()
var subscriptions: Set<AnyCancellable> = []

// 2. Add handler for named event with params
eventBus.onReceive("RebelsActivityDetected") { params in
  print("Detected rebels \(params["distanceInParsecs"]) parsecs from us on \(params["planet"])")
}
.store(in: &subscriptions)

// 3. Add handler for named event without params
eventBus.onReceive("JumpedToHyperspace") { _ in
  print("Jumped to hyperspace")
}
.store(in: &subscriptions)

// 4. Send named event with params
eventBus.send("RebelsActivityDetected", params: ["planet": "Hoth", "distanceInParsecs": 12])

// 5. Send named event without params
eventBus.send("JumpedToHyperspace")
```

### Receiving events on different threads
By default, events are received on the same thread that was used to send the event.
SwiftBus allows to switch threads that are used to receive events:

```swift
// Receive event on Main Thread
eventBus.onReceive(RebelsActivityDetectedEvent.self, performOn: DispatchQueue.main) { _ in
  print("This will be executed on the main thread")
}
.store(in: &subscriptions)

// Receive event on Background Thread
eventBus.onReceive("JumpedToHyperspace", performOn: DispatchQueue.global(qos: .background) { _ in
  print("This will be executed on the background thread")
}
.store(in: &subscriptions)

```

## License
SwiftBus is released under the MIT license. See LICENSE for details.
