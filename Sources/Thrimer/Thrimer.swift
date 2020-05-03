
import Foundation
import Combine

public protocol ThrimerDelegate: class {
    /// Called by the delegate when the timer completes
    ///
    /// - Parameter thrimer: Thrimer instance
    func thrimerEvent(thrimer: Thrimer)
}

public class Thrimer {
    // Set at initialization, or when a paused timer resumes. Provides timer duration
    private var interval: TimeInterval
    // Set at initialization, indicates if the timer should repeat. Default is false.
    private var repeats = false
    // Set when a timer starts running. Used for calculating remaining time on resumed timer.
    private var startTime: Date?
    // Tracks remaining time on a paused timer.
    private var pausedInterval: TimeInterval?
    // Publisher for timer
    private let didCompleteTimerPublisher = PassthroughSubject<Void, Never>()
    // Tracks timer publishers for cancellation
    private var cancellables = Set<AnyCancellable>()
    // Delegate variable
    weak public var delegate: ThrimerDelegate?
    // Computed property indicates if timer is paused
    public var isPaused: Bool {
        return pausedInterval != nil
    }
    // Computed property indicates if timer is running
    public var isRunning: Bool {
        return !cancellables.isEmpty
    }
    // Exposes publisher for consuming objects
    public var didCompleteTimer: PassthroughSubject<Void, Never> {
        didCompleteTimerPublisher
    }
    // Computed property indicates time remaining. Will be nil if no timer is active.
    public var timeRemaining: TimeInterval? {
        if let startTime = startTime {
            return Date().timeIntervalSince(startTime)
        }
        
        return nil
    }
    
    /// Custom initializer
    ///
    /// - Parameters:
    ///   - interval: Duration of timer
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
    
    /// Initialize Thrimer object with a delegate
    ///
    /// - Parameters:
    ///   - interval: Duration of timer
    ///   - delegate: Delegate
    ///   - autostart: Should timer start immediately. Default value is true
    ///   - repeats: Should timer repeat. Default value is false
    public init(interval: TimeInterval,
                delegate: ThrimerDelegate,
                repeats: Bool = false,
                autostart: Bool = true) {
        self.interval = interval
        self.delegate = delegate
        self.repeats = repeats
        
        if autostart {
            start()
        }
    }
    
    deinit {
        cancel()
    }

    /// Starts a timer
    public func start() {
        // Ensure there is no existing timer running
        cancel()
        let cancellableSink = Timer.publish(every: interval,
                                            on: RunLoop.main,
                                            in: .default)
            .autoconnect()
            .removeDuplicates()
            .sink { [weak self] receivedTimeStamp in
                self?.handleTimerCompletion()
            }
        cancellables.insert(cancellableSink)
        startTime = Date()
    }
    
    
    /// Pauses active timer
    public func pause() {
        if isRunning,
            let startTime = startTime {
            pausedInterval = Date().timeIntervalSince(startTime)
            cancel()
        }
    }
    
    /// Resumes a paused timer
    public func resume() {
        if let pausedInterval = pausedInterval {
            interval = pausedInterval
            start()
        }
    }

    /// Called when timer completes
    private func handleTimerCompletion() {
        didCompleteTimerPublisher.send(())
        delegate?.thrimerEvent(thrimer: self)
        if !repeats {
            cancel()
        }
    }

    /// Called when timer needs to be disposed of
    private func cancel() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        cancellables.removeAll()
        startTime = nil
    }
}
