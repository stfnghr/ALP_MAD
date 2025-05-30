//
//  MainView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

// View Folder/MainView.swift
import SwiftUI

struct MainView: View {
    @StateObject var postViewModel = PostViewModel()
    @StateObject var authViewModel: AuthViewModel
    @State private var showAuthSheet: Bool = false

    init(authViewModel: AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }


    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        Text("Placeholder for Create Post Tab") // Replace with actual CreatePostView or button
                             .tabItem {
                                 Label("New Post", systemImage: "plus.square.fill")
                             }

                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                }
                .tint(.orange)
                // Inject the PostViewModel into the environment for HomeView and CreatePostView
                .environmentObject(postViewModel)
                .environmentObject(authViewModel) // Also pass authViewModel if needed by tabs
            } else {
                // Show LoginSignUpView if not signed in
                LoginSignUpView(showAuthSheet: $authViewModel.isSignedIn) // Pass binding
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            authViewModel.checkUserSession()
        }
    }
}

#Preview {
    MainView(authViewModel: AuthViewModel())
}
