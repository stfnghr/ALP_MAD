//
//  PostViewModel_Testing.swift
//  ALP_MAD
//
//  Created by student on 05/06/25.
//

import XCTest

@MainActor
final class PostViewModel_Testing: XCTestCase {
    
    private var viewmModel: PostViewModel!
    private var authVM: AuthViewModel!
    
    override func setUpWithError() throws {
        self.viewmModel = PostViewModel()
        self.authVM = AuthViewModel()
    }
    
    override func tearDownWithError() throws {
        self.viewmModel = nil
        self.authVM = nil
    }
    
    // FetchPosts
    func testFetchPosts() throws {
        let expectation = XCTestExpectation(description: "Fetch Posts From Firebase and expect posts array not to be empty")
        
        self.viewmModel.fetchPosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertFalse(
                self.viewmModel.posts.isEmpty,
                "Posts array should not be empty after fetching. Check Firebase data at '/posts'."
            )
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    //FetchUsersPosts
    func testFetchUserPosts() throws {
           let expectation = XCTestExpectation(description: "Fetch User's Posts From Firebase and expect posts array not to be empty")
           
           self.viewmModel.fetchUserPosts()
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
               XCTAssertFalse(
                   self.viewmModel.userPosts.isEmpty,
                   "userPosts array should not be empty after fetching."
               )
               expectation.fulfill()
           }
           
           wait(for: [expectation], timeout: 120.0)
       }

    
    //AddPost
    func testAddPost() throws {
        let expectation = XCTestExpectation(description: "Add a new post and check for success")
        
        self.viewmModel.addPost(
            itemName: "Kori's Laptop",
            description: "Lost black MacBook Pro, 13-inch, M1 chip.",
            location: "University Library, 2nd Floor",
            status: true
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Using a 4-second delay, adjust if needed
            XCTAssertTrue(
                self.viewmModel.postCreationSuccess,
                "postCreationSuccess should be true after successfully adding a post. Ensure a user is authenticated. Error: \(self.viewmModel.errorMessage ?? "No error message")"
            )
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 6.0)
    }
    
    //DeletePost
    func testDeletePost() throws {
        let expectation = XCTestExpectation(description: "Attempt to delete a user's post and check for success")
        
        self.viewmModel.fetchUserPosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            guard let postToDelete = self.viewmModel.userPosts.first else {
                XCTFail("Prerequisite not met: No user posts found to delete. Ensure the test user is authenticated and has at least one post.")
                expectation.fulfill()
                return
            }
            
            self.viewmModel.deletePost(post: postToDelete)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                XCTAssertTrue(
                    self.viewmModel.postDeletionSuccess,
                    "postDeletionSuccess should be true after successfully deleting a post. Error: \(self.viewmModel.errorMessage ?? "No error message")"
                )
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

func testUpdatePost() throws {
    let expectation = XCTestExpectation(description: "Update a User's posts")

    self.viewmModel.fetchUserPosts()

    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
        guard var postToUpdate = self.viewmModel.userPosts.first else {
            XCTFail("No user posts found to update.")
            expectation.fulfill()
            return
        }

        let originalItemName = postToUpdate.itemName
        let updatedItemName = "UPDATED: \(originalItemName) \(Int.random(in: 1...100))"
        postToUpdate.itemName = updatedItemName

        self.viewmModel.updatePost(post: postToUpdate)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertTrue(
                self.viewmModel.postUpdateSuccess,
                "postUpdateSuccess should be true after successfully updating a post. Error: \(self.viewmModel.errorMessage ?? "No error message")"
            )
            expectation.fulfill()
        }
    }
    
    wait(for: [expectation], timeout: 10.0)
}
    }
