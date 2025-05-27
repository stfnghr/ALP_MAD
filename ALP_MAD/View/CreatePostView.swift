//
//  CreatePostView.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

// View Folder/CreatePostView.swift
import SwiftUI

struct CreatePostView: View {
    @State private var itemName: String = ""
    @State private var lostLocation: String = "" // This was the original name
    @State private var descriptionText: String = ""

    // Instantiate the PostViewModel
    @StateObject private var postViewModel = PostViewModel()

    // For displaying alerts
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Post") // Title of the page
                    .font(.system(size: 36, weight: .bold))
                    .padding(.top, 10)
                    .padding(.bottom, 5)

                // Item Name Input
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

                // Location Input (using original variable name 'lostLocation')
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location:") // Label changed slightly for generality
                        .font(.system(size: 16, weight: .bold))
                    TextField("Location of Item", text: $lostLocation) // Original was "Lost Location"
                        .font(.system(size: 16))
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(UIColor.systemGray6))
                        )
                }
                .frame(minHeight: 100)
                .frame(maxWidth: .infinity)

                // Description Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description:")
                        .font(.system(size: 16, weight: .bold))
                    TextField("Description", text: $descriptionText, axis: .vertical) // Using TextField with .vertical axis
                        .font(.system(size: 16))
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .lineLimit(3...) // Allow multiple lines, expanding
                }
                .frame(minHeight: 120) // Increased minHeight for description
                .frame(maxWidth: .infinity)

                // Image Placeholder (as per original code)
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
                    // Image picker functionality would be added here later
                }
                .padding(.bottom, 15)
                
                Spacer().frame(minHeight: 100) // Adjusted spacer
                
                // POST Button
                Button(action: {
                    // Call the ViewModel to create the post
                    postViewModel.createPost(
                        itemName: itemName,
                        description: descriptionText,
                        location: lostLocation // Pass the location
                    )
                }) {
                    if postViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.orange.opacity(0.7)) // Slightly dim if loading
                            .cornerRadius(30)
                    } else {
                        Text("POST")
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
        // Handle success or error messages from PostViewModel
        .onChange(of: postViewModel.postCreationSuccess) { successState in
            if successState {
                self.alertTitle = "Post Created!"
                self.alertMessage = "Your item has been posted (with dummy data)."
                self.showAlert = true
                // Reset fields after successful post
                self.itemName = ""
                self.lostLocation = ""
                self.descriptionText = ""
                postViewModel.postCreationSuccess = false // Reset the flag in ViewModel
            }
        }
        .onChange(of: postViewModel.errorMessage) { newErrorMessage in
            if let message = newErrorMessage, !message.isEmpty {
                self.alertTitle = "Error"
                self.alertMessage = message
                self.showAlert = true
                postViewModel.errorMessage = nil // Reset the error message in ViewModel
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// Preview from your original code
#Preview {
    NavigationView {
        CreatePostView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("") // Keeping original empty title for preview consistency
    }
}
