//
//  ContentView.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct ContentView: View {
    // Mengamati status otentikasi dari environment
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack {
            // Jika pengguna sudah masuk (isSignedIn is true)
            if authVM.isSignedIn {
                // Tampilkan MainView yang berisi TabView
                MainView()
            } else {
                // Jika tidak, tampilkan LoginSignUpView
                LoginSignUpView()
            }
        }
        .onAppear {
            // Setiap kali view ini muncul, periksa kembali sesi pengguna
            // Ini untuk memastikan statusnya selalu terbaru saat aplikasi dibuka
            authVM.checkUserSession()
        }
    }
}

#Preview {
    ContentView()
        // Jangan lupa inject ViewModel untuk kebutuhan preview
        .environmentObject(AuthViewModel())
}
