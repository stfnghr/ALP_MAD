//
//  ALP_MADWatchAppApp.swift
//  ALP_MADWatchApp Watch App
//
//  Created by student on 05/06/25.
//

import SwiftUI

@main
struct ALP_MADWatchApp_Watch_AppApp: App {
    @StateObject private var connectivityProvider = WatchConnectivityProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityProvider)
        }
    }
}
