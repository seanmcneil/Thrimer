
import Foundation

public protocol ThrimerDelegate: class {
    /// Called by the delegate when the timer completes
    ///
    /// - Parameter thrimer: Thrimer instance
    func thrimerEvent(thrimer: Thrimer)
}

public class Thrimer {
    private var timer: Timer? {
        didSet {
            if timer != nil {
                startTime = Date()
                pausedInterval = nil
            }
        }
    }
    
    // Set at initialization, or when a paused timer resumes. Provides timer duration
    private var interval: TimeInterval
    // Set at initialization, indicates if the timer should repeat. Default is false.
    private var repeats = false
    // Set when a timer starts running. Used for calculating remaining time on resumed timer.
    private var startTime: Date?
    // Tracks remaining time on a paused timer.
    private var pausedInterval: TimeInterval?
    // Delegate variable
    weak public var delegate: ThrimerDelegate?
    // Computed property indicates if timer is paused
    public var isPaused: Bool {
        return pausedInterval != nil
    }
    // Computed property indicates if timer is running
    public var isRunning: Bool {
        return timer != nil
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
    public init(interval: TimeInterval,
                repeats: Bool = false) {
        self.interval = interval
        self.repeats = repeats
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
                autostart: Bool,
                repeats: Bool = false) {
        self.interval = interval
        self.delegate = delegate
        self.repeats = repeats
        
        if autostart {
            start()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    /// Starts a timer
    public func start() {
        timer = Timer.scheduledTimer(withTimeInterval: interval,
                                     repeats: repeats,
                                     block: { [weak self] _ in
                                        guard let strongSelf = self else { return }
                                        
                                        strongSelf.delegate?.thrimerEvent(thrimer: strongSelf)
                                        strongSelf.startTime = nil
                                        if !strongSelf.repeats {
                                            strongSelf.terminateTimer()
                                        }
        })
    }
    
    /// Pauses active timer
    public func pause() {
        if isRunning,
            let startTime = startTime {
            pausedInterval = Date().timeIntervalSince(startTime)
            terminateTimer()
        }
    }
    
    /// Resumes a paused timer
    public func resume() {
        if let pausedInterval = pausedInterval {
            interval = pausedInterval
            start()
        }
    }

    /// Called when a timer needs to be removed
    private func terminateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
