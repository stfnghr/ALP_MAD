//
//  ProfileView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

import SwiftUI

struct ProfileView: View {

    var body: some View {
        VStack {
            Text("Profile")
                .font(.title)
                .fontWeight(.semibold)
                .padding()

            VStack(alignment: .leading, spacing: 20) {
                Text("Name:")
                    .fontWeight(.semibold)
                Text("Igny Romy")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)

                Text("Email:")
                    .fontWeight(.semibold)
                Text("ignyromy@email")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)

                Text("Phone Number:")
                    .fontWeight(.semibold)
                Text("0812-3456-7890")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(30)
            }

            HStack {
                NavigationLink(destination: EditProfileView()) {
                    Text("Edit Profile")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 150, height: 40)
                        .background(Color.orange)
                        .cornerRadius(20)
                }

                // ntar diganti NavLink
                Button(action: {}) {
                    Text("Log Out")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(width: 150, height: 40)
                        .background(Color.red)
                        .cornerRadius(20)
                }
            } .padding(.top, 50)
            
            Spacer()
        } .padding()
    }
}

#Preview {
    ProfileView()
}
