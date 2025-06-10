import FirebaseAuth
import FirebaseDatabase
import Foundation

@MainActor // Ensures UI updates happen on the main thread
class CommentViewModel: ObservableObject {
    @Published var comments: [CommentModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var commentCreationSuccess = false

    private let commentsRef = Database.database().reference().child("comments")
    private let usersRef = Database.database().reference().child("users")
    private let decoder = JSONDecoder()

    // MARK: - Intentions

    func addComment(text: String, to postId: String) {
        self.isLoading = true
        self.commentCreationSuccess = false
        self.errorMessage = nil

        guard let firebaseUser = Auth.auth().currentUser else {
            self.errorMessage = "User not authenticated. Please log in to comment."
            self.isLoading = false
            return
        }
        
        guard !text.isEmpty else {
            self.errorMessage = "Comment cannot be empty"
            self.isLoading = false
            return
        }

        // 1. Fetch user details first, just like in PostViewModel
        usersRef.child(firebaseUser.uid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            // Determine author details from the snapshot or fallback to Auth info
            let authorDetails: UserModel
            if snapshot.exists(), let userData = snapshot.value as? [String: Any] {
                authorDetails = UserModel(
                    name: userData["name"] as? String ?? firebaseUser.displayName ?? "Anonymous",
                    nim: userData["nim"] as? String ?? "",
                    email: userData["email"] as? String ?? firebaseUser.email ?? "no-email@example.com",
                    password: "", // Password should not be handled here
                    phoneNumber: userData["phoneNumber"] as? String ?? ""
                )
            } else {
                // Fallback if user is not in the 'users' table
                authorDetails = UserModel(
                    name: firebaseUser.displayName ?? "Anonymous",
                    nim: "",
                    email: firebaseUser.email ?? "no-email@example.com",
                    password: "",
                    phoneNumber: firebaseUser.phoneNumber ?? ""
                )
            }

            // 2. Create the comment model
            let newComment = CommentModel(
                author: authorDetails,
                text: text,
                commentDate: Date(),
                postId: postId
            )

            // 3. Encode the comment and save it (nested callback)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970

            guard let jsonData = try? encoder.encode(newComment),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                self.errorMessage = "Failed to encode comment data before saving."
                self.isLoading = false
                return
            }

            self.commentsRef.child(newComment.id.uuidString).setValue(json) { [weak self] error, _ in
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Firebase: Failed to create comment: \(error.localizedDescription)"
                    self.commentCreationSuccess = false
                } else {
                    self.commentCreationSuccess = true
                    self.errorMessage = nil
                    // Optionally, you might want to re-fetch comments here
                }
            }
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.errorMessage = "Firebase: Failed to fetch author details for comment: \(error.localizedDescription)"
        }
    }

    func fetchComments(for postId: String) {
        self.isLoading = true
        self.errorMessage = nil

        commentsRef
            .queryOrdered(byChild: "postId")
            .queryEqual(toValue: postId)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
                self.isLoading = false
                
                guard snapshot.exists(), let commentsDict = snapshot.value as? [String: Any] else {
                    self.comments = [] // No comments found for this post
                    return
                }

                var fetchedComments: [CommentModel] = []
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                for (_, commentData) in commentsDict {
                    guard let commentDict = commentData as? [String: Any],
                          let jsonData = try? JSONSerialization.data(withJSONObject: commentDict) else {
                        print("Firebase: Failed to serialize a comment's data.")
                        continue
                    }
                    do {
                        let comment = try decoder.decode(CommentModel.self, from: jsonData)
                        fetchedComments.append(comment)
                    } catch {
                        print("Firebase: Failed to decode comment: \(error.localizedDescription)")
                    }
                }

                self.comments = fetchedComments.sorted { $0.commentDate > $1.commentDate }
                self.errorMessage = nil

            } withCancel: { [weak self] error in
                guard let self = self else { return }
                self.isLoading = false
                self.errorMessage = "Firebase: Failed to fetch comments: \(error.localizedDescription)"
            }
    }
}
