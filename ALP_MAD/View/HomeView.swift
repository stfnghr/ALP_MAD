import SwiftUI

struct HomeView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedIndex = 0 // Basically use to check if its 'All Posts' or 'My Posts'
    let options = ["All Posts", "My Posts"]
    @State private var showingCreatePostView = false
    @State private var showingEditPostView = false
    @State private var postToEdit: PostModel? = nil
    @State private var showingDeleteAlert = false
    @State private var postToDelete: PostModel? = nil

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
                                VStack(alignment: .leading) {
                                    NavigationLink(destination: PostDetailView(post: post)
                                        .environmentObject(authViewModel)
                                        .environmentObject(postViewModel)
                                    ) {
                                        HomeCardView(post: post)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                        
                                    if selectedIndex == 1 {
                                        HStack(spacing: 10) {
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

                                            Button(action: {
                                                self.postToDelete = post
                                                self.showingDeleteAlert = true
                                            }) {
                                                Text("Delete")
                                                    .font(.caption.bold())
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 16)
                                                    .foregroundColor(.white)
                                                    .background(Color.red)
                                                    .cornerRadius(8)
                                            }
                                            Spacer() 
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
                        .environmentObject(authViewModel)
                }
            }
            .alert("Delete Post", isPresented: $showingDeleteAlert, presenting: postToDelete) { postToDelete in
                Button("Delete", role: .destructive) {
                    postViewModel.deletePost(post: postToDelete)
                }
                Button("Cancel", role: .cancel) { }
            } message: { postToDelete in
                Text("Are you sure you want to delete the post titled \"\(postToDelete.itemName)\"? This action cannot be undone.")
            }
            .onAppear {
                if selectedIndex == 0 {
                    if postViewModel.posts.isEmpty && !postViewModel.isLoading {
                        postViewModel.fetchPosts()
                    }
                } else if selectedIndex == 1 {
                     postViewModel.fetchUserPosts()
                }
            }
    
    }
}


#Preview {
    HomeView()
        .environmentObject(PostViewModel())
        .environmentObject(AuthViewModel())
}
