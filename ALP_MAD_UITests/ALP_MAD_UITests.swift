//
//  ALP_MAD_UITests.swift
//  ALP_MAD_UITests
//
//  Created by student on 05/06/25.
//

import XCTest

final class ALP_MAD_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let addCommentButton = app.buttons["addCommentButton"]
        XCTAssertTrue(addCommentButton.exists)
        addCommentButton.tap()
        
        let commentField = app.textFields["commentTextField"]
        XCTAssertTrue(commentField.exists)
        commentField.tap()
        commentField.typeText("Test Comment")
        
        // add more testing for each features guys :D
        
        app.swipeUp()
        app.swipeUp()
        app.keyboards.buttons["return"].tap()
        sleep(1)
        
        // saveButton.tap() -> uncomment this when u're done adding saveButton
        
        XCTAssertFalse(commentField.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
