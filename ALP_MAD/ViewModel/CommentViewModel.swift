import FirebaseAuth
import FirebaseDatabase
import Foundation

@MainActor // Ensures UI updates happen on the main thread
class CommentViewModel: ObservableObject {
    @Published var comments: [CommentModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var commentCreationSuccess = false

    private let postsRef = Database.database().reference().child("posts")
    private let usersRef = Database.database().reference().child("users")
    private let commentsRef = Database.database().reference().child("comments")
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: - Intentions

    func addComment(_ text: String, to postId: String) async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not authenticated"
            return
        }
        
        guard !text.isEmpty else {
            errorMessage = "Comment cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil
        commentCreationSuccess = false
        
        defer { isLoading = false }

        do {
            // The high-level logic remains clean and sequential
            async let author = fetchUserDetails(user: user)
            async let post = fetchPost(postId: postId)
            
            let newComment = CommentModel(
                author: try await author,
                text: text,
                commentDate: Date(),
                postId: postId
            )
            
            try await saveComment(newComment)
            commentCreationSuccess = true
            
        } catch {
            errorMessage = "Failed to post comment: \(error.localizedDescription)"
        }
    }

    func fetchComments(for postId: String) async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }

        do {
            // 1. Await the result from the database
            let snapshot = try await commentsRef
                .queryOrdered(byChild: "postId")
                .queryEqual(toValue: postId)
                .observeSingleEvent(of: .value)

            guard snapshot.exists(), let commentsDict = snapshot.value as? [String: Any] else {
                self.comments = []
                return
            }

            // 2. Manually serialize and decode the data
            let commentsData = try JSONSerialization.data(withJSONObject: Array(commentsDict.values))
            let fetchedComments = try self.decoder.decode([CommentModel].self, from: commentsData)

            self.comments = fetchedComments.sorted { $0.commentDate > $1.commentDate }

        } catch {
            errorMessage = "Failed to fetch comments: \(error.localizedDescription)"
            print("Decoding error: \(error)")
        }
    }

    // MARK: - Private Helper Functions (Async without FirebaseDatabaseSwift)

    private func fetchPost(postId: String) async throws -> PostModel {
        try await withCheckedThrowingContinuation { continuation in
            postsRef.child(postId).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let postData = snapshot.value else {
                    continuation.resume(throwing: NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Post not found"]))
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: postData)
                    let post = try self.decoder.decode(PostModel.self, from: jsonData)
                    continuation.resume(returning: post)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchUserDetails(user: User) async throws -> UserModel {
        // This function now returns a default user if one doesn't exist in the DB,
        // which is often more robust than throwing an error.
        try await withCheckedThrowingContinuation { continuation in
            usersRef.child(user.uid).observeSingleEvent(of: .value) { snapshot in
                // If user exists in DB, decode them
                if snapshot.exists(), let userData = snapshot.value {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: userData)
                        let userDetails = try self.decoder.decode(UserModel.self, from: jsonData)
                        continuation.resume(returning: userDetails)
                        return
                    } catch {
                        // If decoding fails, fall through to create a default user
                        print("Failed to decode user, creating default. Error: \(error)")
                    }
                }
                
                // Fallback: If user not in DB or decoding failed, create a default from Auth
                let defaultUser = UserModel(
                    name: user.displayName ?? "Anonymous",
                    nim: "",
                    email: user.email ?? "",
                    password: "",
                    phoneNumber: user.phoneNumber ?? ""
                )
                continuation.resume(returning: defaultUser)
            }
        }
    }

    private func saveComment(_ comment: CommentModel) async throws {
        // 1. Encode our Swift model to a JSON dictionary
        let commentData = try encoder.encode(comment)
        let commentJSON = try JSONSerialization.jsonObject(with: commentData) as? [String: Any]
        
        guard let finalJSON = commentJSON else {
            throw NSError(domain: "AppError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create JSON for comment"])
        }
        
        // 2. Wrap the callback-based setValue in a continuation
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            commentsRef.child(comment.id.uuidString).setValue(finalJSON) { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
