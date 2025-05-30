//
//  UserViewModel.swift
//  ALP_MAD
//
//  Created by student on 30/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var userResponse: UserResponseModel = UserResponseModel()
    @Published var myUser: UserModel = UserModel()
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let data = snapshot.value else { return }
            print("Received data: \(data)")
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let decodedUser = try JSONDecoder().decode(UserResponseModel.self, from: jsonData)
                    self.userResponse = decodedUser
                } catch {
                    print("Failed to decode user: \(error.localizedDescription)")
                }
        })
    }
    
    func updateUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let updatedData: [String: Any] = [
            "name": myUser.name,
            "email": myUser.email,
            "phoneNumber": myUser.phoneNumber
        ]

        let ref = Database.database().reference().child("users").child(uid)
        ref.updateChildValues(updatedData) { error, _ in
            if let error = error {
                print("Failed to update user: \(error.localizedDescription)")
            } else {
                print("Successfully updated user data")
            }
        }
    }

}
