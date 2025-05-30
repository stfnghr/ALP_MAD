//
//  ProfileView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State var isEditingProfile = false
    @Binding var showAuthSheet: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Text("Profile")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding()

                VStack(alignment: .leading, spacing: 20) {
                    Text("Name:")
                        .fontWeight(.semibold)
                    Text(userVM.userResponse.name)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 50)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(30)

                    Text("Email:")
                        .fontWeight(.semibold)
                    Text(userVM.userResponse.email)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 50)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(30)

                    Text("Phone Number:")
                        .fontWeight(.semibold)
                    Text(userVM.userResponse.phoneNumber)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 50)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(30)
                }

                HStack {
                    Button(action: {
                        userVM.myUser.name = userVM.userResponse.name
                        userVM.myUser.email = userVM.userResponse.email
                        userVM.myUser.phoneNumber = userVM.userResponse.phoneNumber

                        isEditingProfile = true
                    }) {
                        Text("Edit Profile")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(width: 150, height: 40)
                            .background(Color.orange)
                            .cornerRadius(20)
                    }
                    NavigationLink(destination: MainView()) {
                        Button(action: {
                            authVM.signOut()
                            authVM.checkUserSession()
                            if !authVM.isSignedIn {
                                showAuthSheet = true
                            }
                        }) {
                            Text("Log Out")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .padding()
                                .frame(width: 150, height: 40)
                                .background(Color.red)
                                .cornerRadius(20)
                        }
                    }
                }.padding(.top, 50)

                Spacer()
            }
            .padding()
            .onAppear {
                userVM.fetchUser()
            }
        }.fullScreenCover(isPresented: $isEditingProfile) {
            EditProfileView(isEditingProfile: $isEditingProfile)
                .environmentObject(userVM)
        }
    }
}

#Preview {
    ProfileView(showAuthSheet: .constant(false))
        .environmentObject(UserViewModel())
        .environmentObject(AuthViewModel())
}
