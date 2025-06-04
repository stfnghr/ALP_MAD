import SwiftUI

struct PostDetailView: View {
    let post: PostModel
    @State private var commentText: String = ""
    @EnvironmentObject var postViewModel: PostViewModel
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

                HStack {
                    Image(systemName: "ellipsis.message")
                    Text("Comments")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

                HStack {
                    VStack(alignment: .leading) {
                        Text("User Name")
                        Text("Comment")
                            .font(.caption)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(postViewModel.commentDisplayDateFormatter.string(from: Date().addingTimeInterval(-3600*24)))
                        Text(postViewModel.commentDisplayTimeFormatter.string(from: Date().addingTimeInterval(-3600*2)))
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }

                Divider()
                    .padding()
            } 

            HStack {
                TextField("Add a comment...", text: $commentText)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Button(action: {
                    print("Submitted comment: \(commentText) for post ID: \(post.id)")
                    commentText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(commentText.isEmpty ? .gray : .orange)
                        .padding(.leading, 5)
                }
                .disabled(commentText.isEmpty)
            }
        }
        .padding()
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
        ))
        .environmentObject(PostViewModel())
        .environmentObject(AuthViewModel()) 
    }
}
