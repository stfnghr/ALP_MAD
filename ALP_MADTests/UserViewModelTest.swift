//
//  UserViewModelTest.swift
//  ALP_MAD
//
//  Created by student on 05/06/25.
//

import XCTest
import FirebaseAuth

@MainActor
final class UserViewModelTest: XCTestCase {
    
    private var userVM: UserViewModel!
    private var authVM: AuthViewModel!

    override func setUpWithError() throws {
        self.userVM = UserViewModel()
        self.authVM = AuthViewModel()
    }

    override func tearDownWithError() throws {
        self.userVM = nil
        self.authVM = nil
    }
    
    func testFetchUser() async throws {
        self.authVM.myUser.email = "t@t.com"
        self.authVM.myUser.password = "123456"

        await self.authVM.signIn()
        
        self.userVM.fetchUser()
        
        XCTAssertNotNil(self.userVM.userResponse)
    }

    func testUpdateUser() async throws {
        self.authVM.myUser.email = "t@t.com"
        self.authVM.myUser.password = "123456"
        
        await self.authVM.signIn()
        
        self.userVM.myUser.email = "t@t.com"
        self.userVM.myUser.name = "test"
        self.userVM.myUser.phoneNumber = "0812312323"
        
        let expectation = XCTestExpectation(description: "Wait for user update to complete")
        
        // Observe userUpdated change
        let cancellable = self.userVM.$userUpdated.sink { updated in
            if updated {
                expectation.fulfill()
            }
        }

        self.userVM.updateUser()

        // Wait for the expectation to be fulfilled or timeout
        await fulfillment(of: [expectation], timeout: 5.0)

        cancellable.cancel() // clean up the Combine subscription

        XCTAssertTrue(
            self.userVM.userUpdated,
            "Expected userUpdated to be true for updating user."
        )
    }

}
