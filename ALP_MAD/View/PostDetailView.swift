import SwiftUI

struct PostDetailView: View {
    @State private var commentText: String = ""

    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Your Name")
                        Text("May 22, 2025 10:00 AM")
                            .font(.caption2)
                    }

                    Spacer()

                    Text("LOST")
                        .frame(width: 80, height: 35)
                        .background(Color(red: 1.0, green: 0.66, blue: 0.66))
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.bold)
                        .cornerRadius(10)
                }

                Image("image")
                    .resizable()
                    .frame(width: 350, height: 350)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .padding()

                VStack(alignment: .leading) {
                    Text("Item Name")

                    HStack {
                        Image(systemName: "location")
                        Text("Location")
                            .font(.caption)
                    }

                    Text("Description")
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
                        Text("May 22, 2025")
                        Text("10:00 AM")
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
                    print("Submitted comment: \(commentText)")
                    commentText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.orange)
                        .padding(.leading, 5)
                }
            }
        } .padding()
    }
}

#Preview {
    PostDetailView()
}
