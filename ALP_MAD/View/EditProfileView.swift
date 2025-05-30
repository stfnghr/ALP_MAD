//
//  EditProfileView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State var email = ""
    @State var phoneNumber = ""
    @State var saveButtonDisabled: Bool = true
    @Binding var isEditingProfile: Bool
    
    var body: some View {
        VStack {
            Text("Profile")
                .font(.title)
                .fontWeight(.semibold)
                .padding()

            VStack(alignment: .leading, spacing: 20) {
                Text("Name:")
                    .fontWeight(.semibold)
                TextField("Name", text: $userVM.myUser.name)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
                
                Text("Email:")
                    .fontWeight(.semibold)
                TextField("Email", text: $userVM.myUser.email)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
                
                Text("Phone Number:")
                    .fontWeight(.semibold)
                TextField("Phone Number", text: $userVM.myUser.phoneNumber)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
            }
            
            HStack {
                Button(action: {
                    isEditingProfile = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 150, height: 40)
                        .background(Color.red)
                        .cornerRadius(20)
                }
                
                Button(action: {
                    userVM.updateUser()
                    isEditingProfile = false
                    userVM.fetchUser()
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 150, height: 40)
                        .background(Color.green)
                        .cornerRadius(20)
                }
            } .padding(.top, 50)
        }
        .padding()
        
        Spacer()
    }
}

#Preview {
    EditProfileView(isEditingProfile: .constant(true))
        .environmentObject(UserViewModel())
}
