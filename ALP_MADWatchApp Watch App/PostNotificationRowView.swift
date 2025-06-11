//
//  PostNotificationRowView.swift
//  ALP_MADWatchApp Watch App
//
//  Created by student on 11/06/25.
//

import SwiftUI

struct PostNotificationRowView: View {
    let post: PostModel

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("🚨 LOST ITEM ALERT 🚨")
                .font(.caption2)
                .foregroundColor(.red)
                .fontWeight(.bold)
            
            Text(post.itemName)
                .font(.headline)
                .lineLimit(2)

            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text(post.location)
                    .font(.caption)
                    .lineLimit(1)
            }

            Text("Posted by: \(post.author.name)")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text("On: \(dateFormatter.string(from: post.postDate))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

struct PostNotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleAuthor = UserModel(name: "Jane Doe", email: "jane@example.com", phoneNumber: "12345")
        let samplePost = PostModel(
            author: sampleAuthor,
            itemName: "Lost Black Cat Eye Glasses with Gold Trim",
            description: "Very important prescription glasses.",
            location: "University Library - 2nd Floor Study Area",
            postDate: Date().addingTimeInterval(-3600 * 2),
            status: true
        )
        List {
            PostNotificationRowView(post: samplePost)
            PostNotificationRowView(post: samplePost)
        }
    }
}
