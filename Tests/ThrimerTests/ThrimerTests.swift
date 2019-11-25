import XCTest
import Thrimer

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
        thrimer.start()
        
        XCTAssertTrue(thrimer.isRunning)
        sleep(1)
        thrimer.pause()
        XCTAssertTrue(thrimer.isPaused)
        sleep(1)
        XCTAssertEqual(Double(thrimer.timeRemaining ?? 0.0), 2.0, accuracy: 0.03, "nice")
        thrimer.resume()
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
