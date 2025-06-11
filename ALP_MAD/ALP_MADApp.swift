//
//  ALP_MADApp.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import FirebaseAuth

@main
struct ALP_MADApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var userVM = UserViewModel()
    @StateObject private var postVM = PostViewModel()

    init() {
        FirebaseApp.configure()
      
        #if DEBUG
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
                try? Auth.auth().signOut()
        #endif
    }
    
    
    var body: some Scene {
        WindowGroup {
            // --- PERUBAHAN DI SINI ---
            // 1. Atur ContentView sebagai root view aplikasi.
            ContentView()
                // 2. Tetap inject semua view model yang diperlukan ke environment.
                //    ContentView dan semua turunannya sekarang dapat mengaksesnya.
                .environmentObject(authVM)
                .environmentObject(userVM)
                .environmentObject(postVM)
        }
    }
}
