import SwiftUI

struct PostDetailView: View {
    let post: PostModel
    @State private var commentText: String = ""
    @EnvironmentObject var postViewModel: PostViewModel
    @ObservedObject var commentViewModel: CommentViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        Text(post.author.name)
                        Text(postViewModel.postDateFormatter.string(from: post.postDate))
                            .font(.caption2)
                    }

                    Spacer()

                    Text(post.status ? "LOST" : "FOUND")
                        .frame(width: 80, height: 35)
                        .background(post.status ? Color(red: 1.0, green: 0.66, blue: 0.66) : Color.green.opacity(0.7))
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.bold)
                        .cornerRadius(10)
                }

                Image("Image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .foregroundColor(Color(UIColor.systemGray3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .padding()

                VStack(alignment: .leading) {
                    Text(post.itemName)
                    HStack {
                        Image(systemName: "location")
                        Text(post.location)
                            .font(.caption)
                    }
                    Text(post.description)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .padding()

                // Comments Section
                HStack {
                    Image(systemName: "ellipsis.message")
                    Text("Comments")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

                // Comments List
                if commentViewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if commentViewModel.comments.isEmpty {
                    Text("No comments yet")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding()
                } else {
                    ForEach(commentViewModel.comments) { comment in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(comment.author.name)
                                    .font(.subheadline)
                                Text(comment.text)
                                    .font(.caption)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(postViewModel.commentDisplayDateFormatter.string(from: comment.commentDate))
                                Text(postViewModel.commentDisplayTimeFormatter.string(from: comment.commentDate))
                            }
                            .font(.caption2)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        
                        Divider()
                    }
                }
            } // End ScrollView

            // Comment Input
            HStack {
                TextField("Add a comment...", text: $commentText)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Button(action: {
                    commentViewModel.addComment(commentText, to: post.id.uuidString)
                    commentText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(commentText.isEmpty ? .gray : .orange)
                        .padding(.leading, 5)
                }
                .disabled(commentText.isEmpty)
            }
            .padding()
        }
        .padding()
        .onAppear {
            commentViewModel.fetchComments(for: post.id.uuidString)
        }
        .alert(isPresented: .constant(commentViewModel.errorMessage != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(commentViewModel.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    commentViewModel.errorMessage = nil
                }
            )
        }
    }
}

#Preview {
    NavigationView {
        PostDetailView(post: PostModel(
            author: UserModel(name: "Preview User", email: "preview@example.com", password: ""),
            itemName: "Sample Item Name",
            description: "This is a sample description of the item.",
            location: "Sample Location",
            postDate: Date(),
            status: true
        ), commentViewModel: CommentViewModel())
        .environmentObject(PostViewModel())
        .environmentObject(CommentViewModel())
        .environmentObject(AuthViewModel())
    }
}
