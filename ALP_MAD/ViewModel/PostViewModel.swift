//
//  PostViewModel.swift
//  ALP_MAD
//
//  Created by student on 27/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import WatchConnectivity

@MainActor
class PostViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var posts: [PostModel] = []
    @Published var userPosts: [PostModel] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var postCreationSuccess: Bool = false
    @Published var postUpdateSuccess: Bool = false
    @Published var postDeletionSuccess: Bool = false

    private var postsRef: DatabaseReference = Database.database().reference().child("posts")
    private var usersRef: DatabaseReference = Database.database().reference().child("users")

    var session: WCSession

    // MARK: - Formatters
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

    // MARK: - Initialization
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
            print("iOS: WCSession activation initiated.")
        } else {
            print("iOS: WCSession is not supported on this device.")
        }
        
        fetchPosts() // Fetch all posts on initialization
    }

    // MARK: - WCSessionDelegate (iOS side)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("iOS: WCSession activation failed: \(error.localizedDescription)")
                self.errorMessage = "Watch connection failed: \(error.localizedDescription)"
                return
            }
            print("iOS: WCSession activated with state: \(activationState.rawValue). Reachable: \(session.isReachable)")
            if activationState == .activated {
                self.sendAllPostsToWatchAppContext()
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS: WCSession did become inactive.")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("iOS: WCSession did deactivate. Attempting to reactivate...")
        self.session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            print("iOS: Received message from Watch: \(message)")
            if message["request"] as? String == "refreshPosts" {
                print("iOS: Watch requested post refresh. Fetching posts...")
                self.fetchPosts()
                self.fetchUserPosts()
            }
        }
    }
    
    // MARK: - Sending Data to Watch

    private func postsToDictionaryArray(postsToConvert: [PostModel]) -> [[String: Any]] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        return postsToConvert.compactMap { post in
            do {
                let jsonData = try encoder.encode(post)
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    return dictionary
                }
            } catch {
                print("iOS: Error encoding post for Watch: \(error.localizedDescription), Post: \(post.itemName)")
            }
            return nil
        }
    }

    func sendAllPostsToWatchAppContext() {
        guard WCSession.isSupported(), session.activationState == .activated else {
            print("iOS: WCSession not supported or not active. Cannot update Watch application context.")
            return
        }
        
        let postsForWatchContext = postsToDictionaryArray(postsToConvert: self.posts)
        let applicationContext: [String: Any] = [
            "allPosts": postsForWatchContext,
            "lastUpdateIOS": Date().timeIntervalSince1970
        ]

        do {
            try session.updateApplicationContext(applicationContext)
            print("iOS: Successfully sent \(postsForWatchContext.count) posts to Watch via application context.")
        } catch {
            print("iOS: Error updating Watch application context: \(error.localizedDescription)")
            // self.errorMessage = "Failed to sync with Watch." // Optional UI feedback
        }
    }

    private func sendPostUpdateMessageToWatch(_ post: PostModel) {
        guard WCSession.isSupported(), session.activationState == .activated else {
            print("iOS: WCSession not ready for immediate message about post update.")
            return
        }
        // No reachability check here, sendMessage can queue if supported.

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        do {
            let jsonData = try encoder.encode(post)
            guard let postDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                print("iOS: Could not create dictionary for post update message.")
                return
            }
            
            let message = ["updatedPost": postDictionary]
            
            session.sendMessage(message, replyHandler: nil) { error in
                DispatchQueue.main.async {
                     print("iOS: Error sending 'updatedPost' message to Watch: \(error.localizedDescription)")
                }
            }
            print("iOS: Sent 'updatedPost' message to Watch for item: \(post.itemName), Status: \(post.status ? "LOST" : "FOUND")")
        } catch {
            print("iOS: Error encoding or preparing 'updatedPost' message: \(error.localizedDescription)")
        }
    }

    // MARK: - Firebase Fetch Operations

    func fetchPosts() {
        self.isLoading = true
        self.errorMessage = nil
        
        postsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            
            guard snapshot.exists(), let value = snapshot.value as? [String: Any] else {
                self.posts = []
                self.sendAllPostsToWatchAppContext()
                print("Firebase: No posts found or data malformed at /posts.")
                return
            }

            var fetchedPosts: [PostModel] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

            for (key, postData) in value {
                guard let postDict = postData as? [String: Any] else {
                    print("Firebase: Post data for key \(key) is not a dictionary: \(postData)")
                    continue
                }
                var mutablePostDict = postDict
                // Assuming PostModel's ID is correctly part of the JSON saved,
                // or if the key is the ID and PostModel expects it.
                // If id is generated by PostModel `id = UUID()` it will be in json.
                // If firebase key is the ID, it must be added to dict before decode if not in value.
                // Your PostModel has `id = UUID()`, so it should be in the JSON.

                guard let jsonData = try? JSONSerialization.data(withJSONObject: mutablePostDict) else {
                    print("Firebase: Failed to serialize post data for key \(key): \(mutablePostDict)")
                    continue
                }
                do {
                    let post = try decoder.decode(PostModel.self, from: jsonData)
                    fetchedPosts.append(post)
                } catch {
                    print("Firebase: Failed to decode post (key: \(key)): \(error.localizedDescription), JSON: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
                }
            }
            self.posts = fetchedPosts.sorted(by: { $0.postDate > $1.postDate })
            self.sendAllPostsToWatchAppContext()
            print("Firebase: Fetched and processed \(self.posts.count) total posts.")
            
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
        self.errorMessage = nil
        
        postsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            
            guard snapshot.exists(), let value = snapshot.value as? [String: Any] else {
                self.userPosts = []
                print("Firebase: No posts found when attempting to fetch for user \(currentUserEmail).")
                return
            }

            var fetchedUserPosts: [PostModel] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

            for (key, postData) in value {
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
                    print("Firebase: Failed to decode post (key: \(key)) during user post fetch: \(error.localizedDescription)")
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
    
    // MARK: - Firebase CUD Operations

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

            let authorDetails: UserModel
            if userSnapshot.exists(), let userData = userSnapshot.value as? [String: Any] {
                authorDetails = UserModel(
                    name: userData["name"] as? String ?? firebaseUser.displayName ?? "Anonymous",
                    nim: userData["nim"] as? String ?? "",
                    email: userData["email"] as? String ?? firebaseUser.email ?? "unknown@example.com",
                    phoneNumber: userData["phoneNumber"] as? String ?? ""
                )
            } else {
                print("Firebase: User details not found in /users/\(firebaseUser.uid). Using basic Firebase Auth info.")
                authorDetails = UserModel(
                    name: firebaseUser.displayName ?? "Anonymous",
                    nim: "",
                    email: firebaseUser.email ?? "unknown@example.com",
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
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Firebase: Failed to create post: \(error.localizedDescription)"
                        self.postCreationSuccess = false
                    } else {
                        self.postCreationSuccess = true
                        self.errorMessage = nil
                        self.fetchPosts()
                        self.sendPostUpdateMessageToWatch(newPost) // Send message for any new post
                    }
                }
            }
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.errorMessage = "Firebase: Failed to fetch author details: \(error.localizedDescription)"
        }
    }
    
    func updatePost(post: PostModel) {
        self.isLoading = true
        self.postUpdateSuccess = false
        self.errorMessage = nil

        guard let firebaseUser = Auth.auth().currentUser, let currentUserEmail = firebaseUser.email, post.author.email == currentUserEmail else {
            self.errorMessage = "Not authorized or not authenticated to update this post."
            self.isLoading = false
            return
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        guard let jsonData = try? encoder.encode(post),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            self.errorMessage = "Failed to encode post data for update."
            self.isLoading = false
            return
        }

        self.postsRef.child(post.id.uuidString).setValue(json) { [weak self] error, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Firebase: Failed to update post: \(error.localizedDescription)"
                    self.postUpdateSuccess = false
                } else {
                    self.postUpdateSuccess = true
                    self.errorMessage = nil
                    self.fetchPosts()
                    self.fetchUserPosts()
                    self.sendPostUpdateMessageToWatch(post) // Send message for the updated post
                }
            }
        }
    }
    
    func deletePost(post: PostModel) {
        self.isLoading = true
        self.postDeletionSuccess = false
        self.errorMessage = nil

        guard let firebaseUser = Auth.auth().currentUser, let currentUserEmail = firebaseUser.email, post.author.email == currentUserEmail else {
            self.errorMessage = "Not authorized or not authenticated to delete this post."
            self.isLoading = false
            return
        }

        self.postsRef.child(post.id.uuidString).removeValue { [weak self] error, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Firebase: Failed to delete post: \(error.localizedDescription)"
                    self.postDeletionSuccess = false
                } else {
                    self.postDeletionSuccess = true
                    self.errorMessage = nil
                    self.fetchPosts()
                    self.fetchUserPosts()
                    // After deletion, the Watch will get the updated full list via sendAllPostsToWatchAppContext()
                    // called by fetchPosts(). If the deleted item was LOST, it will disappear from Watch.
                }
            }
        }
    }
}
