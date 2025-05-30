import SwiftUI

struct PostDetailView: View {
    let post: PostModel // Functionality: Still takes a PostModel
    @State private var commentText: String = "" // Functionality: For comment input

    // Date formatter to match "May 22, 2025 10:00 AM"
    private var postDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy h:mm a"
        return formatter
    }

    // Date formatters for the example comment section
    private var commentDisplayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }

    private var commentDisplayTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }

    var body: some View {
        VStack { // Matches target design's root VStack
            ScrollView {
                // Top HStack: Author, Date, Status
                HStack {
                    VStack(alignment: .leading) {
                        Text(post.author.name) // Dynamic data
                        Text(postDateFormatter.string(from: post.postDate)) // Dynamic data
                            .font(.caption2) // Matches target design
                    }

                    Spacer()

                    Text(post.status ? "LOST" : "FOUND") // Dynamic data
                        .frame(width: 80, height: 35) // Matches target design
                        .background(post.status ? Color(red: 1.0, green: 0.66, blue: 0.66) : Color.green.opacity(0.7)) // Dynamic background
                        .foregroundColor(.white) // Matches target design
                        .font(.headline) // Matches target design
                        .fontWeight(.bold) // Matches target design
                        .cornerRadius(10) // Matches target design
                }

                // Image placeholder - matches target design structure
                // Target used Image("image"), we use a system placeholder
                Image("Image") // Placeholder
                    .resizable()
                    .scaledToFit() // Ensure placeholder scales reasonably
                    .frame(width: 350, height: 350) // Matches target design
                    .foregroundColor(Color(UIColor.systemGray3)) // Placeholder color
                    .overlay( // Matches target design
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .padding() // Matches target design

                // Item Info VStack - matches target design structure
                VStack(alignment: .leading) {
                    Text(post.itemName) // Dynamic data. Target had "Item Name"
                    HStack {
                        Image(systemName: "location") // Matches target design
                        Text(post.location) // Dynamic data. Target had "Location"
                            .font(.caption) // Matches target design
                    }
                    Text(post.description) // Dynamic data. Target had "Description"
                        .font(.caption) // Matches target design
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Matches target design

                Divider() // Matches target design
                    .padding() // Matches target design

                // Comments Header HStack - matches target design structure
                HStack {
                    Image(systemName: "ellipsis.message") // Matches target design
                    Text("Comments") // Matches target design
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Matches target design
                .padding(.bottom, 20) // Matches target design

                // Example Comment HStack - matches target design structure (static example for now)
                HStack {
                    VStack(alignment: .leading) {
                        Text("User Name") // Static example from target
                        Text("Comment") // Static example from target
                            .font(.caption) // Matches target design
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        // Using example date/time values for layout consistency
                        Text(commentDisplayDateFormatter.string(from: Date().addingTimeInterval(-3600*24))) // Example: "May 29, 2025"
                        Text(commentDisplayTimeFormatter.string(from: Date().addingTimeInterval(-3600*2)))    // Example: "2:56 AM"
                    }
                    .font(.caption) // Matches target design
                    .foregroundColor(.gray) // Matches target design
                }

                Divider() // Matches target design
                    .padding() // Matches target design
            } // End ScrollView

            // Comment Input HStack - matches target design structure
            HStack {
                TextField("Add a comment...", text: $commentText) // Functionality: binding
                    .padding(10) // Matches target design
                    .background(Color(UIColor.systemGray6)) // Matches target design
                    .cornerRadius(10) // Matches target design

                Button(action: {
                    // Functionality: print and clear
                    print("Submitted comment: \(commentText) for post ID: \(post.id)")
                    commentText = ""
                }) {
                    Image(systemName: "paperplane.fill") // Matches target design
                        .foregroundColor(commentText.isEmpty ? .gray : .orange) // Retained dynamic color
                        .padding(.leading, 5) // Matches target design
                }
                .disabled(commentText.isEmpty) // Retained disabled state
            }
        }
        .padding() // Matches target design's root VStack padding
        // Note: The target design did not show a .navigationTitle for PostDetailView itself
    }
}

#Preview {
    // The target design's preview was PostDetailView()
    // To make our dynamic view work in preview, we provide a sample PostModel
    NavigationView { // Wrapping in NavigationView for better preview context
        PostDetailView(post: PostModel(
            author: UserModel(name: "Preview User", email: "preview@example.com", password: ""), // Ensure UserModel can be init'd
            itemName: "Sample Item Name",
            description: "This is a sample description of the item.",
            location: "Sample Location",
            postDate: Date(),
            status: true // true for LOST, false for FOUND
        ))
    }
}
