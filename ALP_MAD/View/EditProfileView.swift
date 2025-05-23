//
//  EditProfileView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

import SwiftUI

struct EditProfileView: View {
    
    @State var name = ""
    @State var email = ""
    @State var phoneNumber = ""
    @State var saveButtonDisabled: Bool = true
    
    var body: some View {
        VStack {
            Text("Profile")
                .font(.title)
                .fontWeight(.semibold)
                .padding()

            VStack(alignment: .leading, spacing: 20) {
                Text("Name:")
                    .fontWeight(.semibold)
                TextField("Name", text: $name)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
                
                Text("Email:")
                    .fontWeight(.semibold)
                TextField("Email", text: $email)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
                
                Text("Phone Number:")
                    .fontWeight(.semibold)
                TextField("Phone Number", text: $phoneNumber)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
            }
            
            HStack {
                Button(action: {}) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 150, height: 40)
                        .background(Color.red)
                        .cornerRadius(20)
                }
                
                Button(action: {}) {
                    Text("Save")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 150, height: 40)
                        .background(Color.green)
                        .cornerRadius(20)
                }
            } .padding(.top, 50)
        } .padding()
        
        Spacer()
    }
}

#Preview {
    EditProfileView()
}
