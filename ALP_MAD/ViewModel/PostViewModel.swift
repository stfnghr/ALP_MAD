//
//  PostViewModel.swift
//  ALP_MAD
//
//  Created by student on 27/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth // For current user

class PostViewModel: ObservableObject {
    @Published var posts: [PostModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var postCreationSuccess: Bool = false
    @Published var postUpdateSuccess: Bool = false
    @Published var postDeletionSuccess: Bool = false
    @Published var userPosts: [PostModel] = [] // For "My Posts" view

    private var postsRef: DatabaseReference = Database.database().reference().child("posts")
    private var usersRef: DatabaseReference = Database.database().reference().child("users") 

    var postDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy h:mm a"
        return formatter
    }

    var commentDisplayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }

    var commentDisplayTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }

    init() {
        fetchPosts() // Fetch all posts on initialization
    }

    
    func fetchPosts() {
        self.isLoading = true
        postsRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            guard snapshot.exists(), let value = snapshot.value as? [String: Any] else {
                self.posts = []
                print("Firebase: No posts found or data malformed at /posts.")
                return
            }

            var fetchedPosts: [PostModel] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970 

            for (_, postData) in value {
                guard let postDict = postData as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: postDict) else {
                    print("Firebase: Failed to serialize post data for one item: \(postData)")
                    continue
                }
                do {
                    let post = try decoder.decode(PostModel.self, from: jsonData)
                    fetchedPosts.append(post)
                } catch {
                    print("Firebase: Failed to decode post: \(error.localizedDescription), JSON: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
                }
            }
            self.posts = fetchedPosts.sorted(by: { $0.postDate > $1.postDate }) // Show newest first
            self.errorMessage = nil
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.errorMessage = "Firebase: Failed to fetch posts: \(error.localizedDescription)"
            print("Firebase: fetchPosts cancelled: \(error.localizedDescription)")
        }
    }
    
    func fetchUserPosts() {
        guard let currentFirebaseUser = Auth.auth().currentUser, let currentUserEmail = currentFirebaseUser.email else {
            self.userPosts = []
            self.errorMessage = "User not authenticated or email not available to fetch their posts."
            return
        }
        
        self.isLoading = true
        postsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            guard snapshot.exists(), let value = snapshot.value as? [String: Any] else {
                self.userPosts = []
                print("Firebase: No posts found when fetching for user \(currentUserEmail).")
                return
            }

            var fetchedUserPosts: [PostModel] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

            for (_, postData) in value {
                guard let postDict = postData as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: postDict) else {
                    continue
                }
                do {
                    let post = try decoder.decode(PostModel.self, from: jsonData)
                    if post.author.email == currentUserEmail {
                        fetchedUserPosts.append(post)
                    }
                } catch {
                    print("Firebase: Failed to decode post during user post fetch: \(error.localizedDescription)")
                }
            }
            self.userPosts = fetchedUserPosts.sorted(by: { $0.postDate > $1.postDate })
            self.errorMessage = nil
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.errorMessage = "Firebase: Failed to fetch user posts: \(error.localizedDescription)"
        }
    }


    // CREATE POST
    func addPost(itemName: String, description: String, location: String, status: Bool) {
        self.isLoading = true
        self.postCreationSuccess = false
        self.errorMessage = nil

        guard let firebaseUser = Auth.auth().currentUser else {
            self.errorMessage = "User not authenticated. Please log in to post."
            self.isLoading = false
            return
        }

  
        usersRef.child(firebaseUser.uid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            var authorDetails: UserModel
            if snapshot.exists(), let userData = snapshot.value as? [String: Any] {
                authorDetails = UserModel(
                    name: userData["name"] as? String ?? firebaseUser.displayName ?? "Anonymous",
                    nim: userData["nim"] as? String ?? "",
                    email: userData["email"] as? String ?? firebaseUser.email ?? "no-email@example.com",
                    password: "",
                    phoneNumber: userData["phoneNumber"] as? String ?? ""
                )
            } else {
                print("Firebase: User details not found in /users/\(firebaseUser.uid). Using basic Firebase Auth info for post author.")
                authorDetails = UserModel(
                    name: firebaseUser.displayName ?? "Anonymous",
                    nim: "",
                    email: firebaseUser.email ?? "no-email@example.com",
                    password: "",
                    phoneNumber: firebaseUser.phoneNumber ?? ""
                )
            }

            let newPost = PostModel(
                author: authorDetails,
                itemName: itemName,
                description: description,
                location: location,
                postDate: Date(),
                status: status
            )

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970

            guard let jsonData = try? encoder.encode(newPost),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                self.errorMessage = "Failed to encode post data before saving."
                self.isLoading = false
                return
            }
            
            self.postsRef.child(newPost.id.uuidString).setValue(json) { [weak self] error, _ in
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Firebase: Failed to create post: \(error.localizedDescription)"
                    self.postCreationSuccess = false
                } else {
                    self.postCreationSuccess = true
                    self.errorMessage = nil
                }
            }
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.errorMessage = "Firebase: Failed to fetch author details for post: \(error.localizedDescription)"
        }
    }

    // UPDATE POST
    func updatePost(post: PostModel) {
        self.isLoading = true
        self.postUpdateSuccess = false
        self.errorMessage = nil

        guard let firebaseUser = Auth.auth().currentUser, let currentUserEmail = firebaseUser.email else {
            self.errorMessage = "User not authenticated or email unavailable to update post."
            self.isLoading = false
            return
        }
        
        guard post.author.email == currentUserEmail else {
            self.errorMessage = "You are not authorized to edit this post (email mismatch)."
            self.isLoading = false
            return
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970

        var postToSave = post
        

        guard let jsonData = try? encoder.encode(postToSave),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            self.errorMessage = "Failed to encode post data for update."
            self.isLoading = false
            return
        }

        self.postsRef.child(post.id.uuidString).setValue(json) { [weak self] error, _ in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.errorMessage = "Firebase: Failed to update post: \(error.localizedDescription)"
                self.postUpdateSuccess = false
            } else {
                self.postUpdateSuccess = true
                self.errorMessage = nil
            }
        }
    }

    // DELETE POST
    func deletePost(post: PostModel) {
        self.isLoading = true
        self.postDeletionSuccess = false
        self.errorMessage = nil

        guard let firebaseUser = Auth.auth().currentUser, let currentUserEmail = firebaseUser.email else {
            self.errorMessage = "User not authenticated or email unavailable to delete post."
            self.isLoading = false
            return
        }

        guard post.author.email == currentUserEmail else {
            self.errorMessage = "You are not authorized to delete this post (email mismatch)."
            self.isLoading = false
            return
        }

        self.postsRef.child(post.id.uuidString).removeValue { [weak self] error, _ in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.errorMessage = "Firebase: Failed to delete post: \(error.localizedDescription)"
                self.postDeletionSuccess = false
            } else {
                self.postDeletionSuccess = true
                self.errorMessage = nil
                
            }
        }
    }
}
