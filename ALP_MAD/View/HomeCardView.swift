// View Folder/HomeCardView.swift
import SwiftUI

struct HomeCardView: View {
    let post: PostModel

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(post.author.name)
                        .font(.headline)
                    Text(dateFormatter.string(from: post.postDate))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()

                Text(post.status ? "LOST" : "FOUND")
                    .frame(width: 80, height: 30)
                    .background(post.status ? Color(red: 1.0, green: 0.66, blue: 0.66) : Color.green.opacity(0.7))
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .cornerRadius(10)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemGray6))

                Image("example-image")
                    .resizable()
                    .scaledToFill()
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Text(post.itemName)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(post.description)
                .font(.caption)
                .lineLimit(2)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.orange)
                Text(post.location)
                    .font(.caption)
            }

            Divider()
                .padding(.top, 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    // Sample PostModel for preview
    let sampleAuthor = UserModel(name: "Jane Doe", email: "jane@example.com")
    let samplePost = PostModel(
        author: sampleAuthor,
        itemName: "Preview Item",
        description: "This is a detailed description of the item that was lost or found. It can span multiple lines.",
        location: "Campus Library",
        postDate: Date(),
        status: true
    )
    HomeCardView(post: samplePost)
        .padding()
        .background(Color.gray.opacity(0.1))
}
