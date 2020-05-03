import XCTest
import Combine

@testable import Thrimer

class ThrimerTests: XCTestCase {
    var isCompletedExpectation: XCTestExpectation?
    
    func testStartTimer() {
        let thrimer = Thrimer(interval: 5.0, repeats: false)
        thrimer.start()
        let expect = expectation(description: "test")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(thrimer.isRunning)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
        }
    }
    
    func testStartTimerPublisher() {
        let thrimer = Thrimer(interval: 3.0)
        let expect = expectation(description: "test")
        let startTime = Date()
        let cancellable = thrimer.didCompleteTimer.sink { _ in
            expect.fulfill()
        }
        thrimer.start()
        
        waitForExpectations(timeout: 4.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(Date().timeIntervalSince(startTime), 3.0, accuracy: 0.03, "nice")
            cancellable.cancel()
        }
    }
    
    func testStartTimerPublisherRepeats() {
        let thrimer = Thrimer(interval: 2.0, repeats: true)
        let expect = expectation(description: "test")
        let startTime = Date()
        var hasReceived = false
        let cancellable = thrimer.didCompleteTimer.sink { _ in
            if hasReceived {
                expect.fulfill()
            } else {
                hasReceived = true
            }
        }
        thrimer.start()
        
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(Date().timeIntervalSince(startTime), 4.0, accuracy: 0.03, "nice")
            cancellable.cancel()
        }
    }
    
    func testStartTimerPublisherNoRepeats() {
        let thrimer = Thrimer(interval: 2.0, repeats: false)
        let expect = expectation(description: "test")
        let startTime = Date()
        let cancellable = thrimer.didCompleteTimer.sink { _ in
            expect.fulfill()
        }
        thrimer.start()
        
        waitForExpectations(timeout: 2.5) { error in
            XCTAssertNil(error)
            XCTAssertEqual(Date().timeIntervalSince(startTime), 2.0, accuracy: 0.03, "nice")
            XCTAssertFalse(thrimer.isRunning)
            cancellable.cancel()
        }
    }
    
    func testSetTimerNil() {
        var thrimer: Thrimer? = Thrimer(interval: 5.0, repeats: false)
        thrimer?.start()
        let expectIsRunning = expectation(description: "testIsRunning")
        let expectIsNil = expectation(description: "testIsNil")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssert(thrimer?.isRunning == true)
            thrimer = nil
            expectIsRunning.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertNil(thrimer)
            expectIsNil.fulfill()
        }
        
        waitForExpectations(timeout: 4.0) { error in
            XCTAssertNil(error)
        }
    }
    
    func testPauseAndResume() {
        let thrimer = Thrimer(interval: 5.0, repeats: false)
        
        XCTAssertTrue(thrimer.isRunning)
        sleep(1)
        thrimer.pause()
        XCTAssertTrue(thrimer.isPaused)
        sleep(1)
        XCTAssertNil(thrimer.timeRemaining)
        thrimer.resume()
        XCTAssertNotNil(thrimer.timeRemaining)
        XCTAssertTrue(thrimer.isRunning)
    }

    func testCompletion() {
        isCompletedExpectation = expectation(description: "test")
        let thrimer = Thrimer(interval: 2.0,
                              delegate: self,
                              autostart: true)
        XCTAssertTrue(thrimer.isRunning)
        XCTAssertNotNil(thrimer.timeRemaining)
        
        waitForExpectations(timeout: 3.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(thrimer.timeRemaining)
        }
    }
    
    func testViewModelOutOfScope() {
        let expect = expectation(description: "test")
        var viewModel: ViewModel? = ViewModel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertNotNil(viewModel)
            viewModel = nil
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 3.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(viewModel)
        }
    }
}

extension ThrimerTests: ThrimerDelegate {
    func thrimerEvent(thrimer: Thrimer) {
        isCompletedExpectation?.fulfill()
    }
}

class ViewModel: ThrimerDelegate {
    var thrimer: Thrimer?

    init() {
        thrimer = Thrimer(interval: 2.0,
                          delegate: self,
                          autostart: true)
    }
    
    func thrimerEvent(thrimer: Thrimer) {
        fatalError("Should not be called")
    }
}
