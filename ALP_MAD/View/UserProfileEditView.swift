//
//  UserProfileEditView.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct UserProfileEditView: View {
    @State private var name: String = "Igny Romy"
    @State private var email: String = "ignyromy@student.ciputra.ac.id"
    @State private var phoneNumber: String = "0812-3456-7890"

    @Environment(\.presentationMode) var presentationMode

    private let cancelRedColor = Color.red
    private let saveGreenColor = Color.green

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Text("Profile")
                    .font(.system(size: 32, weight: .bold))
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 30)

            VStack(alignment: .leading, spacing: 8) {
                Text("Name:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.black)

                TextField("Enter your name", text: $name)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.black)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
                    .textContentType(.name)
                    .keyboardType(.default)
            }
            .padding(.bottom, 20)
            VStack(alignment: .leading, spacing: 8) {
                Text("Email:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.black)

                TextField("Enter your email", text: $email)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.black)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding(.bottom, 20)
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.black)

                TextField("Enter your phone number", text: $phoneNumber)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.black)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            }
            .padding(.bottom, 45)
            HStack(spacing: 20) {
                ActionButton(
                    title: "Cancel",
                    backgroundColor: cancelRedColor,
                    action: {
                        print("Cancel tapped")
                        presentationMode.wrappedValue.dismiss()
                    }
                )

                ActionButton(
                    title: "Save",
                    backgroundColor: saveGreenColor,
                    action: {
                        print("Save tapped")
                        print("Name: \(name), Email: \(email), Phone: \(phoneNumber)")
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }

            Spacer()
        }
        .padding(.horizontal, 25)
        .background(Color.white.ignoresSafeArea())
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct UserProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileEditView()
    }
}
