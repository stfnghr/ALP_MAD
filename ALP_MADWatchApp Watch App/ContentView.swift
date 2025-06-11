//
//  ContentView.swift
//  ALP_MADWatchApp Watch App
//
//  Created by student on 05/06/25.
//

// ALP_MADWatchApp Watch App/ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivityProvider: WatchConnectivityProvider

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 8) {
                if connectivityProvider.receivedPosts.isEmpty {
                    Text(connectivityProvider.lastErrorMessage ?? "No new LOST item alerts.\n\nOpen the iPhone app to sync or create new posts.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(connectivityProvider.receivedPosts) { post in
                            PostNotificationRowView(post: post)
                        }
                    }
                    .listStyle(.plain)
                }

                if let lastUpdate = connectivityProvider.lastUpdateTimestamp {
                    Text("Updated: \(lastUpdate, style: .time)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
                
//                Button { // Keep the refresh button
//                    connectivityProvider.requestDataFromIOS()
//                } label: {
//                    Label("Refresh Alerts", systemImage: "arrow.clockwise")
//                }
                // .padding(.top, 4) // Removed to make it more compact like default watchOS apps
            }
            .navigationTitle("Lost Item Alerts")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let mockConnectivity = WatchConnectivityProvider()
        let author = UserModel(name: "iOS User", email: "ios@test.com", phoneNumber: "")
        mockConnectivity.receivedPosts = [
            PostModel(author: author, itemName: "Lost Blue Backpack", description: "Canvas", location: "Cafeteria", postDate: Date(), status: true),
            PostModel(author: author, itemName: "Missing Red Scarf", description: "Wool", location: "Lecture Hall A", postDate: Date().addingTimeInterval(-600), status: true)
        ]
        mockConnectivity.lastUpdateTimestamp = Date()
        
        return ContentView()
            .environmentObject(mockConnectivity)
    }
}
