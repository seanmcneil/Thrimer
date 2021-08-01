import Combine
import XCTest

@testable import Thrimer

class ThrimerTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
    }

    /// Verify that timer has correct values while running
    func testStartTimer() {
        let thrimer = Thrimer(interval: 5.0, repeats: false)
        thrimer.start()
        let expect = expectation(description: "test")
        let startTime = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(thrimer.isRunning)
            XCTAssertNotNil(thrimer.timeRemaining)
            XCTAssertEqual(Date().timeIntervalSince(startTime),
                           thrimer.timeRemaining!,
                           accuracy: 0.1)
            expect.fulfill()
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    /// Validate the lifecycle of timer actions
    func testTimerActionsCycle() {
        let timerInterval = 3.0
        let thrimer = Thrimer(interval: timerInterval)
        // Setup expectations
        let expectStart = expectation(description: "start")
        let expectComplete = expectation(description: "complete")
        let expectIdle = expectation(description: "idle")
        let expectations = [expectStart, expectComplete, expectIdle]

        let startTime = Date()
        thrimer.$thrimerAction
            .removeDuplicates()
            .sink { action in
                switch action {
                case .idle:
                    expectIdle.fulfill()

                case .start:
                    expectStart.fulfill()

                case .completed:
                    XCTAssertEqual(Date().timeIntervalSince(startTime),
                                   timerInterval,
                                   accuracy: 0.1)
                    expectComplete.fulfill()

                default:
                    XCTFail("Unexpected action")
                }
            }
            .store(in: &cancellables)

        wait(for: expectations,
             timeout: timerInterval + 1.0,
             enforceOrder: true)
    }

    /// Verify that the timer properly repeats in the expected sequence
    /// and interval
    func testStartTimerRepeats() {
        let timerInterval = 0.5
        let thrimer = Thrimer(interval: timerInterval,
                              repeats: true)
        // Setup expectations
        let expectFirst = expectation(description: "first")
        let expectSecond = expectation(description: "second")
        let expectThird = expectation(description: "third")
        let expectations = [expectFirst, expectSecond, expectThird]
        var usedExpectations = expectations
        var startTime = Date()
        thrimer.$thrimerAction
            .sink { action in
                switch action {
                case .start:
                    startTime = Date()

                case .completed:
                    XCTAssertEqual(Date().timeIntervalSince(startTime),
                                   timerInterval,
                                   accuracy: 0.1)
                    XCTAssertFalse(usedExpectations.isEmpty)
                    let expect = usedExpectations.removeFirst()
                    expect.fulfill()

                default:
                    break
                }
            }
            .store(in: &cancellables)

        wait(for: expectations,
             timeout: 1.75,
             enforceOrder: true)
    }

    /// Verify that setting the timer object to nil is properly handled
    func testSetTimerNil() {
        var thrimer: Thrimer? = Thrimer(interval: 5.0, repeats: false)
        thrimer?.start()
        let expectIsRunning = expectation(description: "testIsRunning")
        let expectIsNil = expectation(description: "testIsNil")
        let expectations = [expectIsRunning, expectIsNil]

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssert(thrimer?.isRunning == true)
            thrimer = nil
            expectIsRunning.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertNil(thrimer)
            expectIsNil.fulfill()
        }

        wait(for: expectations, timeout: 4.0, enforceOrder: true)
    }

    /// Verify that the correct actions and values are presented when
    /// pausing and then resuming the timer.
    func testPauseAndResume() {
        let thrimer = Thrimer(interval: 5.0, repeats: false)
        let expectStart = expectation(description: "start")
        let expectPause = expectation(description: "pause")
        let expectResume = expectation(description: "resume")
        let expectCompleted = expectation(description: "completed")
        let expectIdle = expectation(description: "idle")
        let expectations = [expectStart, expectPause, expectResume, expectCompleted, expectIdle]
        var usedExpectations = expectations

        thrimer.$thrimerAction
            .sink { action in
                switch action {
                case .completed:
                    XCTAssertFalse(usedExpectations.isEmpty)
                    let expect = usedExpectations.removeFirst()
                    expect.fulfill()

                case .idle:
                    XCTAssertFalse(usedExpectations.isEmpty)
                    let expect = usedExpectations.removeFirst()
                    expect.fulfill()

                case let .pause(interval):
                    XCTAssertEqual(interval,
                                   1.0,
                                   accuracy: 0.1)
                    XCTAssertFalse(usedExpectations.isEmpty)
                    let expect = usedExpectations.removeFirst()
                    expect.fulfill()

                case .start:
                    XCTAssertFalse(usedExpectations.isEmpty)
                    let expect = usedExpectations.removeFirst()
                    expect.fulfill()

                case .stop:
                    XCTFail("Should not occur")
                }
            }
            .store(in: &cancellables)

        XCTAssertTrue(thrimer.isRunning)
        sleep(1)
        thrimer.pause()
        XCTAssertTrue(thrimer.isPaused)
        sleep(1)
        XCTAssertNil(thrimer.timeRemaining)
        thrimer.resume()
        XCTAssertNotNil(thrimer.timeRemaining)
        XCTAssertTrue(thrimer.isRunning)

        wait(for: expectations, timeout: 4.0, enforceOrder: true)
    }

    /// Verify that the timer has the correct properties and completes
    /// in the expected order.
    func testCompletion() {
        let expectStart = expectation(description: "expectStart")
        let expectCompleted = expectation(description: "expectCompleted")
        let expectIdle = expectation(description: "expectIdle")
        let expectations = [expectStart, expectCompleted, expectIdle]
        let thrimer = Thrimer(interval: 2.0,
                              autostart: true)
        XCTAssertTrue(thrimer.isRunning)
        XCTAssertNotNil(thrimer.timeRemaining)
        thrimer.$thrimerAction
            .sink { action in
                switch action {
                case .start:
                    expectStart.fulfill()

                case .completed:
                    XCTAssertFalse(thrimer.isRunning)
                    XCTAssertNil(thrimer.timeRemaining)
                    expectCompleted.fulfill()

                case .idle:
                    expectIdle.fulfill()

                default:
                    XCTFail("Unexpected action")
                }
            }
            .store(in: &cancellables)

        wait(for: expectations,
             timeout: 3.0,
             enforceOrder: true)
    }

    // Verify that restarting an active timer produces the correct sequence
    // of actions and properties
    func testTimerRestart() {
        let thrimer = Thrimer(interval: 2.0)

        let expectStart = expectation(description: "expectStart")
        let expectRestart = expectation(description: "expectRestart")
        let expectCompleted = expectation(description: "expectCompleted")
        let expectIdle = expectation(description: "expectIdle")
        let expectations = [expectStart, expectRestart, expectCompleted, expectIdle]
        var startActions = [expectStart, expectRestart]

        let startTime = Date()
        thrimer.$thrimerAction
            .sink { action in
                switch action {
                case .start:
                    XCTAssertFalse(startActions.isEmpty)
                    let expect = startActions.removeFirst()
                    expect.fulfill()

                case .completed:
                    let timeElapsed = Date().timeIntervalSince(startTime)
                    XCTAssertGreaterThan(timeElapsed, 3.0)
                    expectCompleted.fulfill()

                case .idle:
                    expectIdle.fulfill()

                default:
                    XCTFail("Unexpected action")
                }
            }
            .store(in: &cancellables)
        sleep(1)
        thrimer.start()

        wait(for: expectations,
             timeout: 4.0,
             enforceOrder: true)
    }

    func testTimerStop() {
        let thrimer = Thrimer(interval: 2.0)

        let expectStart = expectation(description: "expectStart")
        let expectStop = expectation(description: "expectStop")
        let expectations = [expectStart, expectStop]

        let startTime = Date()
        thrimer.$thrimerAction
            .sink { action in
                switch action {
                case .start:
                    expectStart.fulfill()

                case .stop:
                    let timeElapsed = Date().timeIntervalSince(startTime)
                    XCTAssertGreaterThan(timeElapsed, 1.0)
                    XCTAssertFalse(thrimer.isRunning)
                    XCTAssertNil(thrimer.timeRemaining)
                    expectStop.fulfill()

                default:
                    XCTFail("Unexpected action")
                }
            }
            .store(in: &cancellables)
        sleep(1)
        thrimer.stop()

        wait(for: expectations,
             timeout: 3.0,
             enforceOrder: true)
    }
}
