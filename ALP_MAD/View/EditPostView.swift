import SwiftUI

struct EditPostView: View {
    enum ItemStatus: String, CaseIterable {
        case lost = "LOST"
        case found = "FOUND"
    }

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var postViewModel: PostViewModel
    let postToEdit: PostModel?
    @State private var itemName: String = ""
    @State private var lostLocation: String = ""
    @State private var descriptionText: String = ""
    @State private var selectedStatus: ItemStatus = .lost
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Edit Post")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.top, 10)
                        .padding(.bottom, 5)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Item Name:")
                            .font(.system(size: 16, weight: .bold))
                        TextField("Item Name", text: $itemName)
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color(UIColor.systemGray6))
                            )
                    }
                    .frame(minHeight: 100)
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location:")
                            .font(.system(size: 16, weight: .bold))
                        TextField("Location of Item", text: $lostLocation)
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color(UIColor.systemGray6))
                            )
                    }
                    .frame(minHeight: 100)
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description:")
                            .font(.system(size: 16, weight: .bold))
                        TextField("Description", text: $descriptionText, axis: .vertical)
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color(UIColor.systemGray6))
                            )
                            .lineLimit(3...)
                    }
                    .frame(minHeight: 120)
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Image:")
                            .font(.system(size: 16, weight: .bold))

                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(UIColor.systemGray6))
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)

                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(UIColor.systemGray2))
                        }
                    }
                    .padding(.bottom, 15)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Status:")
                            .font(.system(size: 16, weight: .bold))

                        HStack(spacing: 20) {
                            Button(action: {
                                selectedStatus = .lost
                            }) {
                                Text(ItemStatus.lost.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedStatus == .lost ? Color.white : Color(UIColor.label).opacity(0.7))
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 5)
                                    .frame(minWidth: 0)
                                    .background(selectedStatus == .lost ? Color(red: 0.48, green: 0.83, blue: 0.44) : Color(UIColor.systemGray4))
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                selectedStatus = .found
                            }) {
                                Text(ItemStatus.found.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedStatus == .found ? Color.white : Color(UIColor.label).opacity(0.7))
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 5)
                                    .frame(minWidth: 50)
                                    .frame(minHeight: 0)
                                    .background(selectedStatus == .found ? Color(red: 0.48, green: 0.83, blue: 0.44) : Color(UIColor.systemGray4))
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                    }

                    Spacer().frame(minHeight: 80)

                    Button(action: {
                        guard let originalPost = postToEdit else {
                            self.alertTitle = "Error"
                            self.alertMessage = "No post to update."
                            self.showAlert = true
                            return
                        }

    
                        let updatedPost = PostModel(
                            id: originalPost.id,
                            author: originalPost.author,
                            itemName: itemName,
                            description: descriptionText,
                            location: lostLocation,
                            postDate: originalPost.postDate,
                            status: selectedStatus == .lost // Convert ItemStatus back to Bool
                        )
                        postViewModel.updatePost(post: updatedPost)
                    }) {
                        if postViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.orange.opacity(0.7))
                                .cornerRadius(30)
                        } else {
                            Text("SAVE CHANGES")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.orange)
                                .cornerRadius(30)
                        }
                    }
                    .disabled(itemName.isEmpty || lostLocation.isEmpty || descriptionText.isEmpty || postViewModel.isLoading)
                    .padding(.bottom, 20)

                }
                .padding(.horizontal, 25)
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: postViewModel.postUpdateSuccess) { successState in
                if successState {
                    self.alertTitle = "Post Updated!"
                    self.alertMessage = "Your item has been successfully updated."
                    self.showAlert = true
                    postViewModel.postUpdateSuccess = false
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertTitle == "Post Updated!" {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
         .onAppear {
         if let post = postToEdit {
         self.itemName = post.itemName
        self.lostLocation = post.location
        self.descriptionText = post.description
         self.selectedStatus = post.status ? .lost : .found
         }
        }
    }
}

#Preview {
    let sampleAuthor = UserModel(name: "Vivian Banshee", email: "Vivian@example.com")
    let samplePost = PostModel(
        author: sampleAuthor,
        itemName: "Vivian's Old Item Name",
        description: "Fight on, my friend. If you cannot face the suffering of life, then life itself will lose its meaning.",
        location: "Rhodes Island",
        postDate: Date(),
        status: true
    )
    return NavigationView {
        EditPostView(postToEdit: samplePost)
            .environmentObject(PostViewModel())
    }
}
