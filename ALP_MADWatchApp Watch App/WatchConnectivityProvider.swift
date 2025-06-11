//
//  WatchConnectivityProvider.swift
//  ALP_MADWatchApp Watch App
//
//  Created by student on 11/06/25.
//

import Foundation
import WatchConnectivity
import WatchKit // For WKInterfaceDevice

@MainActor // Ensures UI updates and delegate methods run on the main thread
class WatchConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    @Published var receivedPosts: [PostModel] = [] // Will only store LOST items
    @Published var lastErrorMessage: String? = nil
    @Published var lastUpdateTimestamp: Date? = nil

    var session: WCSession

    // MARK: - Initialization
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
            print("Watch: WCSession activation initiated.")
        } else {
            print("Watch: WCSession is not supported on this device.")
            self.lastErrorMessage = "WatchConnectivity not supported."
        }
    }

    // MARK: - WCSessionDelegate Methods

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.lastErrorMessage = "Watch WCSession activation failed: \(error.localizedDescription)"
                print(self.lastErrorMessage!)
                return
            }
            self.lastErrorMessage = nil
            print("Watch: WCSession activated with state: \(activationState.rawValue). Reachable: \(session.isReachable)")
            
            if activationState == .activated {
                if !session.receivedApplicationContext.isEmpty {
                     print("Watch: Processing existing received application context on activation.")
                     self.processApplicationContext(session.receivedApplicationContext)
                }
                if session.isReachable {
                    print("Watch: Session active and reachable. Requesting initial data.")
                    self.requestDataFromIOS()
                } else {
                    print("Watch: Session active but iPhone not immediately reachable.")
                }
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            print("Watch: iOS App Reachability changed to \(session.isReachable).")
            if session.isReachable {
                self.lastErrorMessage = nil
                print("Watch: iPhone became reachable. Requesting data.")
                self.requestDataFromIOS()
            } else {
                self.lastErrorMessage = "iPhone is not reachable."
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            print("Watch: Received application context. Keys: \(applicationContext.keys)")
            self.processApplicationContext(applicationContext)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("Watch: Received message. Keys: \(message.keys)")
            if let postData = message["updatedPost"] as? [String: Any] { // Changed key
                print("Watch: Processing 'updatedPost' from message.")
                self.decodeAndProcessSinglePost(postData: postData, fromMessage: true)
            }
        }
    }
    
    // MARK: - Data Processing Logic

    private func processApplicationContext(_ applicationContext: [String: Any]) {
        guard let postsDataArray = applicationContext["allPosts"] as? [[String: Any]] else {
            if applicationContext["allPosts"] == nil {
                 self.lastErrorMessage = "Watch: Context from iOS is missing 'allPosts' key."
            } else {
                 self.lastErrorMessage = "Watch: 'allPosts' in context from iOS is not in the expected array format."
            }
            print(self.lastErrorMessage ?? "Watch: Unknown error processing application context structure.")
            
            if (applicationContext["allPosts"] as? [[String:Any]])?.isEmpty ?? false {
                 self.receivedPosts = []
                 print("Watch: Received empty 'allPosts' array from context. Clearing local posts.")
            }
            return
        }

        var newlyDecodedLostPosts: [PostModel] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        for postData in postsDataArray {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
                let post = try decoder.decode(PostModel.self, from: jsonData)
                if post.status == true {
                    newlyDecodedLostPosts.append(post)
                }
            } catch {
                print("Watch: Error decoding a post from context: \(error.localizedDescription). Data: \(postData)")
                if self.lastErrorMessage == nil {
                     self.lastErrorMessage = "Watch: Error decoding some post data from iPhone."
                }
            }
        }
        
        self.receivedPosts = newlyDecodedLostPosts.sorted(by: { $0.postDate > $1.postDate })
        
        if let updateTimestampDouble = applicationContext["lastUpdateIOS"] as? TimeInterval {
            self.lastUpdateTimestamp = Date(timeIntervalSince1970: updateTimestampDouble)
        } else {
            self.lastUpdateTimestamp = Date()
        }
        
        if newlyDecodedLostPosts.count == postsDataArray.count && postsDataArray.count > 0 { // Or some other success condition
             self.lastErrorMessage = nil
        } else if newlyDecodedLostPosts.isEmpty && postsDataArray.isEmpty {
            self.lastErrorMessage = nil // No posts is not an error
        }
        print("Watch: Updated with \(self.receivedPosts.count) LOST posts from application context.")
    }

    private func decodeAndProcessSinglePost(postData: [String: Any], fromMessage: Bool) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
            let updatedPost = try decoder.decode(PostModel.self, from: jsonData)

            let existingPostIndex = self.receivedPosts.firstIndex(where: { $0.id == updatedPost.id })

            if updatedPost.status == true { // Item is LOST
                if let index = existingPostIndex {
                    self.receivedPosts[index] = updatedPost
                    print("Watch: Updated existing LOST post via message: \(updatedPost.itemName)")
                } else {
                    self.receivedPosts.append(updatedPost)
                    print("Watch: Added new LOST post via message: \(updatedPost.itemName)")
                }
                if fromMessage { WKInterfaceDevice.current().play(.notification) }
            } else { // Item is FOUND (status == false)
                if let index = existingPostIndex {
                    let removedPost = self.receivedPosts.remove(at: index)
                    print("Watch: Item '\(removedPost.itemName)' status changed to FOUND, removed from alerts list.")
                    if fromMessage { WKInterfaceDevice.current().play(.success) }
                } else {
                    print("Watch: Received update for a FOUND item not currently in LOST alerts: \(updatedPost.itemName)")
                }
            }
            
            self.receivedPosts.sort(by: { $0.postDate > $1.postDate })
            self.lastUpdateTimestamp = Date()
            self.lastErrorMessage = nil

        } catch {
            self.lastErrorMessage = "Watch: Error decoding single post from message: \(error.localizedDescription)"
            print(self.lastErrorMessage! + ". Data: \(postData)")
        }
    }
    
    func requestDataFromIOS() {
        guard WCSession.isSupported(), session.activationState == .activated else {
            self.lastErrorMessage = "Watch: Session not active, cannot send message."
            print(self.lastErrorMessage!)
            return
        }
        guard session.isReachable else {
            self.lastErrorMessage = "Watch: iPhone not reachable to request data."
            print(self.lastErrorMessage!)
            return
        }
        
        let message = ["request": "refreshPosts"]
        session.sendMessage(message, replyHandler: nil) { error in
            DispatchQueue.main.async {
                self.lastErrorMessage = "Watch: Error sending refresh request to iOS: \(error.localizedDescription)"
                print(self.lastErrorMessage!)
            }
        }
        print("Watch: Sent 'refreshPosts' request to iOS.")
    }
}
