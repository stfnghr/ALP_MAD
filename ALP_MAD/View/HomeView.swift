//
//  HomeView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedIndex = 0
    let options = ["All Posts", "My Posts"]
    
    // Example data array to loop through
    let cardsData = Array(1...5) // Or your real data model here

    var body: some View {
        VStack {
            Text("App Name")
                .font(.title)
                .fontWeight(.semibold)
                .padding()

            Picker("Select an option", selection: $selectedIndex) {
                ForEach(0..<options.count, id: \.self) { index in
                    Text(options[index])
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(cardsData, id: \.self) { item in
                        NavigationLink(destination: PostDetailView()) {
                            HomeCardView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        
    }
}

#Preview {
    HomeView()
}
