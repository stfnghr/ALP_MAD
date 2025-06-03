// View Folder/CreatePostView.swift
import SwiftUI

struct CreatePostView: View {
 
    @State private var itemName: String = ""
    @State private var lostLocation: String = ""
    @State private var descriptionText: String = ""
    @EnvironmentObject var postViewModel: PostViewModel
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Post")
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
                    
                    Spacer().frame(minHeight: 80)
                    
                    Button(action: {
                        postViewModel.addPost(
                            itemName: itemName,
                            description: descriptionText,
                            location: lostLocation,
                            status: true
                        )
                    }) {
                        if postViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.orange.opacity(0.7))
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
                    // Basically just a check the buttomn will be disabled if any of the three fields is empty

                }
                .padding(.horizontal, 25)
            }
            .onChange(of: postViewModel.postCreationSuccess) { successState in
                if successState {
                    self.alertTitle = "Post Created!"
                    self.alertMessage = "Your item has been successfully posted."
                    self.showAlert = true
                    self.itemName = ""
                    self.lostLocation = ""
                    self.descriptionText = ""
                    postViewModel.postCreationSuccess = false
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                // alert message thats shown when a post is succesfully made
            }
        }
    }
}

#Preview {
    NavigationView {
        CreatePostView()
            .environmentObject(PostViewModel())
            .environmentObject(AuthViewModel())

    }
}
