import Combine
import Foundation

/// Represents the life cycle of the timer
public enum ThrimerAction {
    /// Timer is not running
    case idle

    /// Timer has been started
    case start

    /// Timer has been paused. Will include `TimerInterval` for remaining time
    case pause(TimeInterval)

    /// Timer has completed and will no longer run
    case completed

    /// Timer has been stopped
    case stop
}

extension ThrimerAction: Equatable {}

public class Thrimer: ObservableObject {
    /// Provides a value representing the current state of the `Timer`
    @Published public private(set) var thrimerAction: ThrimerAction = .idle

    /// Remaining duration of current `Timer`
    private var interval: TimeInterval

    /// Indicates if `Timer` is repeating
    private var repeats = false

    /// Set when a timer starts running. Used for calculating remaining time on resumed timer.
    private var startTime: Date? {
        didSet {
            if startTime != nil {
                thrimerAction = .start
            }
        }
    }

    /// Tracks remaining time on a paused `Timer`
    private var pausedInterval: TimeInterval? {
        didSet {
            if let pausedInterval = pausedInterval {
                thrimerAction = .pause(pausedInterval)
            }
        }
    }

    /// Tracks timer publishers for cancellation
    private var cancellables = Set<AnyCancellable>()

    /// Indicates when `Timer` has been paused
    public var isPaused: Bool {
        pausedInterval != nil
    }

    /// Indicates if `Timer` is running
    public var isRunning: Bool {
        !cancellables.isEmpty
    }

    /// Computed property indicates time remaining. Will be nil if no timer is active.
    public var timeRemaining: TimeInterval? {
        if let startTime = startTime {
            let interval = Date().timeIntervalSince(startTime)

            return round(interval * 1000) / 1000
        }

        return nil
    }

    /// Initialize Thrimer object
    ///
    /// - Parameters:
    ///   - interval: Duration of timer in seconds
    ///   - repeats: Should timer repeat. Default value is false
    ///   - autostart: Should timer start immediately. Default value is true
    public init(interval: TimeInterval,
                repeats: Bool = false,
                autostart: Bool = true) {
        self.interval = interval
        self.repeats = repeats

        if autostart {
            start()
        }
    }

    deinit {
        cancel()
    }

    /// Starts a timer
    ///
    /// This will cancel any currently running timers and start
    /// a new one.
    public func start() {
        // Ensure there is no existing timer running
        cancel()
        Timer.publish(every: interval,
                      on: .main,
                      in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleTimerCompletion()
            }
            .store(in: &cancellables)
        startTime = Date()
    }

    /// Stops a timer
    public func stop() {
        cancel()
        thrimerAction = .stop
    }

    /// Pauses active timer
    public func pause() {
        if isRunning,
           let startTime = startTime {
            cancel()
            pausedInterval = Date().timeIntervalSince(startTime)
        }
    }

    /// Resumes a paused timer
    public func resume() {
        if let pausedInterval = pausedInterval {
            interval = pausedInterval
            start()
        }
    }

    // MARK: Private functions

    /// Called when timer completes
    private func handleTimerCompletion() {
        if repeats {
            thrimerAction = .completed
            startTime = Date()
        } else {
            cancel()
            thrimerAction = .completed
            thrimerAction = .idle
        }
    }

    /// Called when timer needs to be disposed of
    private func cancel() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        cancellables.removeAll()
        reset()
    }

    /// Resets time variables
    private func reset() {
        if startTime != nil {
            startTime = nil
        }
        if pausedInterval != nil {
            pausedInterval = nil
        }
    }
}
