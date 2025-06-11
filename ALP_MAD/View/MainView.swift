//
//  MainView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        // Langsung tampilkan TabView tanpa logika kondisional
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            CreatePostView()
                .tabItem {
                    Label("New Post", systemImage: "plus.square.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .onAppear {
                    userViewModel.fetchUser()
                }
        }
        .tint(.orange)
    }
}

#Preview {
    MainView()
        .environmentObject(UserViewModel())
        .environmentObject(PostViewModel())
        .environmentObject(AuthViewModel())
}
