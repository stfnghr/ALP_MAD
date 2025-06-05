//
//  AuthViewModelTest.swift
//  ALP_MAD
//
//  Created by student on 05/06/25.
//

import FirebaseAuth
import XCTest

@MainActor
final class AuthViewModelTest: XCTestCase {

    private var authVM: AuthViewModel!

    override func setUpWithError() throws {
        self.authVM = AuthViewModel()
    }

    override func tearDownWithError() throws {
        self.authVM = nil
    }

    func testSignUp() async throws {
        self.authVM.myUser.email = "test\(UUID().uuidString.prefix(6))@test.com"
        self.authVM.myUser.password = "123456"
        self.authVM.myUser.name = "Test User"
        self.authVM.myUser.phoneNumber = "123456789"
        self.authVM.myUser.nim = "1122334455"

        await self.authVM.signUp()

        XCTAssertFalse(
            self.authVM.falseCredential,
            "Expected falseCredential to be false after successful signup.")
    }

    func testSignInWithInvalidCredentials() async throws {
        authVM.signOut()
        
        self.authVM.myUser.email = "invalid@test.com"
        self.authVM.myUser.password = "wrongpass"

        await self.authVM.signIn()

        XCTAssertTrue(
            self.authVM.falseCredential,
            "Expected falseCredential to be true for invalid sign-in.")
    }

    func testSignIn() async throws {
        self.authVM.myUser.email = "t@t.com"
        self.authVM.myUser.password = "123456"

        await self.authVM.signIn()

        XCTAssertFalse(
            self.authVM.falseCredential,
            "Expected falseCredential to be false for invalid sign-in."
        )
    }

    func testSignOut() {
        self.authVM.signOut()
        XCTAssertNil(
            Auth.auth().currentUser,
            "User should be signed out and currentUser should be nil.")
    }
}
