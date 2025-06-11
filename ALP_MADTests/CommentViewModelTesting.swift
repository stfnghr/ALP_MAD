//
//  CommentViewModelTesting.swift
//  ALP_MADTests
//
//  Created by student on 05/06/25.
//

import XCTest

@MainActor
final class CommentViewModelTesting: XCTestCase {

    private var viewModel: CommentViewModel!
    private var authVM: AuthViewModel!

    override func setUpWithError() throws {
        self.viewModel = CommentViewModel()
        self.authVM = AuthViewModel()
    }

    override func tearDownWithError() throws {
        self.viewModel = nil
        self.authVM = nil
    }

    func testFetchComments() {
        let expectation = XCTestExpectation(
            description: "Fetch comments from Firebase")

        Task {
            self.viewModel.fetchComments(
                for: "F6A9831C-7114-476B-AEB9-BFD862EBACAB")

            DispatchQueue.main.async {
                XCTAssertFalse(
                    self.viewModel.comments.isEmpty,
                    "Comments array should not be empty"
                )
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testAddComment() async throws {
        self.authVM.myUser.email = "t@t.com"
        self.authVM.myUser.password = "123456"

        await self.authVM.signIn()

        let text = "Test Unit Comment"
        let postId = "F6A9831C-7114-476B-AEB9-BFD862EBACAB"

        viewModel.addComment(text: text, to: postId)

        XCTAssertTrue(
            viewModel.commentCreationSuccess,
            "addComment should set commentCreationSuccess to true"
        )
    }

    func testPerformanceExample() throws {
        self.measure {
        }
    }
}
