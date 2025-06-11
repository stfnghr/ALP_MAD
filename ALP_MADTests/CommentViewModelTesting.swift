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

    func testFetchComments() throws {
            let expectation = XCTestExpectation(
                description: "Fetch comments from Firebase and expect comments array not to be empty"
            )

            // The async fetch function is called.
            // We wrap it in a Task because it's an async function.
            Task {
                self.viewModel.fetchComments(for: "F6A9831C-7114-476B-AEB9-BFD862EBACAB")
            }

            // We wait for a fixed 3 seconds before checking the result,
            // just like in the testFetchPosts example.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                XCTAssertFalse(
                    self.viewModel.comments.isEmpty,
                    "Comments array should not be empty after fetching. Check Firebase data."
                )
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }

    func testAddComment() async throws {
            // --- Setup Phase ---
            // Ensure a user is signed in before performing the action
            self.authVM.myUser.email = "t@t.com"
            self.authVM.myUser.password = "123456"
            await self.authVM.signIn()
            
            // 1. Create an expectation, similar to testAddPost
            let expectation = XCTestExpectation(description: "Add a new comment and check for success")
            
            // --- Action Phase ---
            let text = "This is a unit test comment."
            let postId = "F6A9831C-7114-476B-AEB9-BFD862EBACAB" // Use a valid post ID from your test DB
            
            // Call the function that performs the asynchronous work
            viewModel.addComment(text: text, to: postId)
            
            // 2. Add a fixed delay before checking the result
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                // --- Assertion Phase ---
                XCTAssertTrue(
                    self.viewModel.commentCreationSuccess,
                    "commentCreationSuccess should be true after adding a comment. Error: \(self.viewModel.errorMessage ?? "No error message")"
                )
                // 3. Fulfill the expectation
                expectation.fulfill()
            }
            
            // 4. Wait for the expectation to be fulfilled
            await fulfillment(of: [expectation], timeout: 6.0)
        }

    func testPerformanceExample() throws {
        self.measure {
        }
    }
}
