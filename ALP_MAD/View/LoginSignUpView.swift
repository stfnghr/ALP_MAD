//
//  LoginView.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct LoginSignUpView: View {
    // Binding @Binding var showAuthSheet: Bool dihilangkan
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var signUpClicked: Bool = true

    var body: some View {
        ZStack {
            Color.orange
                .edgesIgnoringSafeArea(.all)
            if signUpClicked {
                // LOGIN Card
                VStack(spacing: 24) {
                    VStack {
                        Text("Log In")
                            .font(.system(size: 32, weight: .bold))
                            .padding(30)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Email")
                                .padding(.leading, 15)
                            TextField("Enter your UC Email", text: $authVM.myUser.email)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                            
                            Spacer()
                                .frame(height: 10)

                            Text("Password")
                                .padding(.leading, 15)
                            SecureField("Enter your Password", text: $authVM.myUser.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                            
                            if authVM.falseCredential {
                                Text("Invalid Username and Password")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.red)
                            }
                        }
                        
                        // Sign Up text
                        HStack {
                            Spacer()
                            Text("Don't have an account yet?")
                                .font(.footnote)
                            Button(action: {
                                signUpClicked = false
                            }) {
                                Text("Sign Up")
                                    .font(.footnote)
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                        }.padding(.top, 30)
                    }
                    .padding(10)
                    .padding(.vertical)
                    .font(.system(size: 12))

                    // Login Button
                    Button(action: {
                        Task {
                            await authVM.signIn()
                            if !authVM.falseCredential {
                                authVM.checkUserSession()
                                // Logika untuk menutup sheet dihilangkan
                                authVM.myUser = UserModel()
                            } else {
                                authVM.resetForm()
                            }
                        }
                    }) {
                        Text("LOG IN")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 5)
                .padding(.horizontal, 20)
            } else {
                //SIGNUP card
                VStack(spacing: 24) {
                    Text("Sign Up")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.top, 30)

                    VStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Name")
                                .padding(.leading)
                            TextField("Name", text: $authVM.myUser.name)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("NIM")
                                .padding(.leading)
                            TextField("NIM", text: $authVM.myUser.nim)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Phone Number")
                                .padding(.leading)
                            TextField("Phone Number", text: $authVM.myUser.phoneNumber)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                        }

                        VStack(alignment: .leading) {
                            Text("Email")
                                .padding(.leading)
                            TextField("Enter your UC Email", text: $authVM.myUser.email)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                        }

                        VStack(alignment: .leading) {
                            Text("Password")
                                .padding(.leading)
                            SecureField("Make a Password", text: $authVM.myUser.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                            
                            if authVM.falseCredential {
                                Text("Invalid Username or Password")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.red)
                            }
                        }
                        
                        // Already have account
                        HStack {
                            Spacer()
                            Text("Already have an account?")
                                .font(.footnote)
                            Button(action: {
                                signUpClicked = true
                            }) {
                                Text("Log In")
                                    .font(.footnote)
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                        }.padding(.top, 15)

                    }
                    .padding(.vertical)
                    .padding(.horizontal, 10)
                    .font(.system(size: 12))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                    // Sign Up Button
                    Button(action: {
                        Task {
                            await authVM.signUp()
                            if !authVM.falseCredential {
                                authVM.checkUserSession()
                                // Logika untuk menutup sheet dihilangkan
                                authVM.myUser = UserModel()
                            }
                            
                            signUpClicked = true
                        }
                    }) {
                        Text("SIGN UP")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)

                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 5)
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    // Binding showAuthSheet dihilangkan dari preview
    LoginSignUpView()
        .environmentObject(AuthViewModel())
}
