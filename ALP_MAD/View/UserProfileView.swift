//
//  UserProfileView.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct UserProfileView: View {
    @State private var selectedTab: Int = 1

    private var tabItemOrange = Color.orange
    private var tabItemGray = Color.gray

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        UITabBar.appearance().unselectedItemTintColor = UIColor(tabItemGray)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home Page")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)

            ProfileScreenDetailView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(1)
        }
        .accentColor(tabItemOrange)
    }
}

struct ProfileScreenDetailView: View {
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

            InfoFieldView(label: "Name:", value: "Igny Romy")
                .padding(.bottom, 20)

            InfoFieldView(
                label: "Email:",
                value: "ignyromy@student.ciputra.ac.id"
            )
            .padding(.bottom, 20)
            InfoFieldView(label: "Phone Number:", value: "0812-3456-7890")
                .padding(.bottom, 45)
            HStack(spacing: 20) {
                ActionButton(
                    title: "Edit Profile",
                    backgroundColor: Color.orange,
                    action: {
                        print("Edit Profile tapped")
                    }
                )

                ActionButton(
                    title: "Log Out",
                    backgroundColor: Color.red,
                    action: {
                        print("Log Out tapped")
                    }
                )
            }

            Spacer()
        }
        .padding(.horizontal, 25)
        .background(Color.white.ignoresSafeArea())
    }
}

struct InfoFieldView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.black)

            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.black)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 50)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(30)
        }
    }
}

struct ActionButton: View {
    let title: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(25)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
