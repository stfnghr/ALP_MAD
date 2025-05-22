//
//  HomeCardView.swift
//  ALP_MAD
//
//  Created by Stefanie Agahari on 22/05/25.
//

import SwiftUI

struct HomeCardView: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Your Name")
                    Text("May 22, 2025 10:00 AM")
                        .font(.caption2)
                }
                
                Spacer()

                Text("LOST")
                    .frame(width: 80, height: 30)
                    .background(Color(red: 1.0, green: 0.66, blue: 0.66))
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .cornerRadius(10)

            }

            Image("image")
                .resizable()
                .frame(width: 350, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
                .padding()

            Text("Kacamata")
                .font(.caption)

            Divider()
                .padding()
        } .padding()
    }
}

#Preview {
    HomeCardView()
}
