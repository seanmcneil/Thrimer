# Thrimer

## Requirements

### Version 1.0
- iOS 13.0+
- Xcode 12.4+
- Swift 5.5+

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

### Express setup with Publisher

Initialize your property and start automatically, creating a non-repeating timer that runs for 10 seconds.
```swift
thrimer = Thrimer(interval: 10.0, repeats: false)
```

### Standard timer

Initialize your property, the following creates a non-repeating timer that runs for 10 seconds and does not auto start.
```swift
thrimer = Thrimer(interval: 10.0, repeats: false, autostart: false)
```

And start the timer when you are ready:
```swift
thrimer?.start()
```

### Pause timer

This creates a non-repeating timer with a 10 second duration.

```swift
let thrimer = Thrimer(interval: 10.0, repeats: false, autostart: false)
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

### Stop timer

If you need to stop the timer:

```swift
thrimer.stop()
```

### Support

If you find an issue or can think of an improvement, issues and pull requests are always welcome. 

For pull requests, please be sure to ensure your work is covered with existing or new unit tests.

## Author

Sean McNeil

## License

Thrimer is available under the MIT license. See the LICENSE file for more info.
