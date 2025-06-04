import Foundation
import FirebaseDatabase
import FirebaseAuth

class CommentViewModel: ObservableObject {
    @Published var comments: [CommentModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var commentCreationSuccess = false
    
    private let postsRef = Database.database().reference().child("posts")
    private let usersRef = Database.database().reference().child("users")
    
//    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .secondsSince1970
//        return decoder
//    }()
    
//    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .secondsSince1970
//        return encoder
//    }()
    
    // MARK: - Date Formatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yy"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    // MARK: - Public Methods
    
    func addComment(_ text: String, to postId: String) {
        guard !text.isEmpty else {
            errorMessage = "Comment cannot be empty"
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        commentCreationSuccess = false
        errorMessage = nil
        
        // 1. Fetch post details
        fetchPost(postId: postId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let post):
                // 2. Fetch or create user details
                self.fetchUserDetails(user: user) { userResult in
                    switch userResult {
                    case .success(let userDetails):
                        // 3. Create and save comment
                        self.saveComment(
                            text: text,
                            post: post,
                            author: userDetails
                        ) { commentResult in
                            switch commentResult {
                            case .success:
                                self.commentCreationSuccess = true
                            case .failure(let error):
                                self.errorMessage = error.localizedDescription
                            }
                            self.isLoading = false
                        }
                        
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchPost(postId: String, completion: @escaping (Result<PostModel, Error>) -> Void) {
        postsRef.child(postId).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let postData = snapshot.value as? [String: Any] else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not found"])))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: postData)
                let post = try JSONDecoder().decode(PostModel.self, from: jsonData)
                completion(.success(post))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func fetchUserDetails(user: User, completion: @escaping (Result<UserModel, Error>) -> Void) {
        usersRef.child(user.uid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let userData = snapshot.value as? [String: Any] {
                let userDetails = UserModel(
                    name: userData["name"] as? String ?? user.displayName ?? "Anonymous",
                    nim: userData["nim"] as? String ?? "",
                    email: userData["email"] as? String ?? user.email ?? "",
                    password: "",
                    phoneNumber: userData["phoneNumber"] as? String ?? user.phoneNumber ?? ""
                )
                completion(.success(userDetails))
            } else {
                // Fallback to basic auth info if user details not found
                let userDetails = UserModel(
                    name: user.displayName ?? "Anonymous",
                    nim: "",
                    email: user.email ?? "",
                    password: "",
                    phoneNumber: user.phoneNumber ?? ""
                )
                completion(.success(userDetails))
            }
        }
    }
    
    private func saveComment(
        text: String,
        post: PostModel,
        author: UserModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let newComment = CommentModel(
            author: author,
            text: text,
            commentDate: Date()
        )
        
        do {
            let jsonData = try encoder.encode(newComment)
            guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize comment"])))
                return
            }
            
            postsRef.child(post.id.uuidString).child("comments").child(newComment.id.uuidString).setValue(json) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
