/// View Folder/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedIndex = 0
    let options = ["All Posts", "My Posts"]
    @State private var showingCreatePostView = false
    @State private var showingEditPostView = false
    @State private var postToEdit: PostModel? = nil

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter Posts", selection: $selectedIndex) {
                    ForEach(0..<options.count, id: \.self) { index in
                        Text(options[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedIndex) { newIndex in
                    if newIndex == 0 {
                        postViewModel.fetchPosts()
                    } else if newIndex == 1 {
                        postViewModel.fetchUserPosts()
                    }
                }

                if postViewModel.isLoading && (selectedIndex == 0 ? postViewModel.posts.isEmpty : postViewModel.userPosts.isEmpty) {
                    ProgressView("Loading posts...")
                        .padding()
                } else if let errorMessage = postViewModel.errorMessage,
                          (selectedIndex == 0 ? postViewModel.posts.isEmpty : postViewModel.userPosts.isEmpty) {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                ScrollView {
                    let postsToDisplay = selectedIndex == 0 ? postViewModel.posts : postViewModel.userPosts
                    
                    if postsToDisplay.isEmpty && !postViewModel.isLoading {
                        Text(selectedIndex == 0 ? "No posts available yet." : "You haven't created any posts yet.")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(postsToDisplay) { post in
                                VStack { // Wrap Card and Edit button
                                    NavigationLink(destination: PostDetailView(post: post)
                                        .environmentObject(authViewModel)
                                        .environmentObject(postViewModel) // Pass postViewModel if PostDetailView needs it
                                    ) {
                                        HomeCardView(post: post)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    // Show Edit button only for "My Posts"
                                    if selectedIndex == 1 {
                                        Button(action: {
                                            self.postToEdit = post
                                            self.showingEditPostView = true
                                        }) {
                                            Text("Edit Post")
                                                .font(.caption.bold())
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .foregroundColor(.white)
                                                .background(Color.blue)
                                                .cornerRadius(8)
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
           
            }
            .sheet(isPresented: $showingCreatePostView) {
                CreatePostView()
            }
            .sheet(isPresented: $showingEditPostView) {
                if let post = postToEdit {
                    EditPostView(postToEdit: post)
                        .environmentObject(postViewModel)
                        .environmentObject(authViewModel) // If EditPostView needs it
                }
            }
            .onAppear {
                if selectedIndex == 0 {
                    if postViewModel.posts.isEmpty && !postViewModel.isLoading { 
                        postViewModel.fetchPosts()
                    }
                } else if selectedIndex == 1 {
                     postViewModel.fetchUserPosts() // Always fetch user posts for "My Posts" or if it's empty
                }
            }
        }
    }


#Preview {
    HomeView()
        .environmentObject(PostViewModel())
        .environmentObject(AuthViewModel())
}
