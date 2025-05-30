//
//  ALP_MADApp.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//


import SwiftUI
import FirebaseCore
import FirebaseAppCheck

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
        #endif
    }
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authVM)
                .environmentObject(userVM)
                .environmentObject(postVM)
        }
    }
}




//testing push
