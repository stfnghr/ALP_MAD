//
//  AuthViewModel.swift
//  ALP_MAD
//
//  Created by student on 27/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isSignedIn: Bool = false
    @Published var myUser: UserModel = UserModel()
    @Published var falseCredential: Bool = false

    init() {
        checkUserSession()
    }

    func checkUserSession() {
        user = Auth.auth().currentUser
        isSignedIn = user != nil
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }

    func signIn() async {
        do {
            _ = try await Auth.auth().signIn(withEmail: myUser.email, password: myUser.password)
                self.falseCredential = false
        } catch {
                self.falseCredential = true
        }
    }

    
    func signUp() async {
        do {
            let result = try await Auth.auth().createUser(
                withEmail: myUser.email,
                password: myUser.password
            )
            self.falseCredential = false

            //getting new user id
            let uid = result.user.uid

            let userData: [String: Any] = [
                "name": myUser.name,
                "nim": myUser.nim,
                "email": myUser.email,
                "phoneNumber": myUser.phoneNumber
            ]

            //put additional data on the database
            let ref = Database.database().reference()
            try await ref.child("users").child(uid).setValue(userData)
        } catch {
            let nsError = error as NSError
            print("Firebase Auth Error - Code: \(nsError.code), Domain: \(nsError.domain), Message: \(nsError.localizedDescription)")
            self.falseCredential = true
        }
    }
    
    func resetForm() {
        myUser = UserModel(name: "", nim: "", email: "", password: "", phoneNumber: "")
    }
}

