//
//  CreatePostView.swift
//  ALP_MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct CreatePostView: View {
    @State private var itemName: String = ""
    @State private var lostLocation: String = ""
    @State private var descriptionText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Post")
                    .font(.system(size: 36, weight: .bold))
                    .padding(.top, 10)
                    .padding(.bottom, 5)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Item Name:")
                        .font(.system(size: 16, weight: .bold))
                    TextField("Item Name", text: $itemName)
                        .font(.system(size: 16))
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(UIColor.systemGray6))
                        )
                }
                .frame(minHeight: 100)
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Lost Location:")
                        .font(.system(size: 16, weight: .bold))
                    TextField("Lost Location", text: $lostLocation)
                        .font(.system(size: 16))
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(UIColor.systemGray6))
                        )
                }
                .frame(minHeight: 100)
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Description:")
                        .font(.system(size: 16, weight: .bold))
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .font(.system(size: 16))
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .lineLimit(1...)
                }
                .frame(minHeight: 100)
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Image:")
                        .font(.system(size: 16, weight: .bold))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(UIColor.systemGray6))
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)

                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(UIColor.systemGray2))
                    }
                }
                .padding(.bottom, 15)
                Spacer().frame(minHeight: 180)
                
                Button(action: {
                    print("POST button tapped")
                    print("Item Name: \(itemName)")
                    print("Lost Location: \(lostLocation)")
                    print("Description: \(descriptionText)")
                }) {
                    Text("POST")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.orange)
                        .cornerRadius(30)
                }
                .padding(.bottom, 20)

            }
            .padding(.horizontal, 25)
        }
    }
    
}

#Preview {
    NavigationView {
        CreatePostView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
    }
}
