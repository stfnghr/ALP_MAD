//
//  CommentViewModelTesting.swift
//  ALP_MADTests
//
//  Created by student on 05/06/25.
//

import XCTest

final class CommentViewModelTesting: XCTestCase {

    private var viewModel = CommentViewModel!

    override func setUpWithError() throws {
        self.viewModel = CommentViewModel()
    }

    override func tearDownWithError() throws {
        self.viewModel = nil
    }

    func testFetchComments() throws {
        let expectation = XCTestExpectation(
            description: "Fetch comments from Firebase"
        )

        self.viewModel.fetchComments {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                XCTAssertFalse(
                    self.viewModel.comments.isEmpty,
                    "Comments array should not be empty"
                )
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }
  
    func testAddComment() throws {
        let comment = CommentModel(
            author: "abcde",
            text: "Hello World",
            commentDate: Date(),
            postId: ""
        )

        let result = viewModel.addComment(comment: comment)

        XCTAssertTrue(result, "addComment should return true for valid input")
    }

    func testPerformanceExample() throws {
        //     This is an example of a performance test case.
        self.measure {
            //     Put the code you want to measure the time of here.
        }
    }
}
