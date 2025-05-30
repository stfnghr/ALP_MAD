//
//  MainView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

// View Folder/MainView.swift
import SwiftUI

struct MainView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showAuthSheet = false

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    Text("Placeholder for Create Post Tab")
                        .tabItem {
                            Label("New Post", systemImage: "plus.square.fill")
                        }

                    ProfileView(showAuthSheet: $showAuthSheet)
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .onAppear {
                            userViewModel.fetchUser()
                        }
                }
                .tint(.orange)
            } else {
                // show nothing but the white void instead of the mainview underneath the funny login sheet
            }
        }
        .onAppear {
            if !authViewModel.isSignedIn {
                showAuthSheet = true
            }
        }
        .fullScreenCover(isPresented: $showAuthSheet) {
            LoginSignUpView(showAuthSheet: $showAuthSheet)
        }
    }
}


#Preview {
    MainView()
        .environmentObject(UserViewModel())
        .environmentObject(PostViewModel())
        .environmentObject(AuthViewModel())
}
