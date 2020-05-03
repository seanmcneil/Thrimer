# Thrimer

## Requirements

### Version 2.0
- iOS 13.0+
- Xcode 11.4+
- Swift 5.2+

### Version 1.0
- iOS 11.0+
- Xcode 10.2+
- Swift 5.0+

## Instructions

### Basic setup

Import the framework:

```swift
import Thrimer
```

It is recommended that you set an instance variable for Thrimer:
```swift
class ViewController: UIViewController {
var thrimer: Thrimer?
```

### Express setup with Delegation

Initialize your property, delegate and start automatically with optional value, creating a non-repeating timer that runs for 10 seconds.
```swift
thrimer = Thrimer(interval: 10.0, delegate: self, repeats: false)
```

### Express setup with Combine Publisher

Initialize your property and start automatically, creating a non-repeating timer that runs for 10 seconds.
```swift
thrimer = Thrimer(interval: 10.0, repeats: false)
```

While you are not obliged to configure the delegate when observing the publisher, `Thrimer` will still call the delegate and send events to it should it also be configured.

### Standard timer

Initialize your property, the following creates a non-repeating timer that runs for 10 seconds and does not auto start.
```swift
thrimer = Thrimer(interval: 10.0, repeats: false, autostart: false)
```

### When using delegation

Next, set the delegate:
```swift
thrimer?.delegate = self
```

To receive updates when the timer completes, you must comform to the ThrimerDelegate:
```swift
extension ViewController: ThrimerDelegate {
    func thrimerEvent(thrimer: Thrimer) {
        // Event triggered
    }
}
```

### When using publisher

You can assign a sink to the publisher for `Thrimer` events.
```swift
let cancellable = thrimer.didCompleteTimer.sink { _ in
    // Perform action
}
```

And start the timer when you are ready:
```swift
thrimer?.start()
```

### Pause timer

This creates a non-repeating timer with a 10 second duration.

```swift
let thrimer = Thrimer(interval: 10.0, repeats: false, autostart: false)
thrimer.delegate = self
thrimer.start()
```

Once the timer is running, you can now pause it:

```swift
thrimer.pause()
```

You can check to see if it is paused:

```swift
if thrimer.isPaused  {
    print("Timer is paused")
}
```

You can check to see how much time is remaining on the timer:
```swift
print(thrimer.timeRemaining ?? "Timer is not paused")
```

Finally, you can resume it:

```swift
thrimer.resume()
```

## Author

Sean McNeil

## License

Thrimer is available under the MIT license. See the LICENSE file for more info.
