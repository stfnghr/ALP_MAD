import SwiftUI

enum ItemStatus: String, CaseIterable {
    case lost = "LOST"
    case found = "FOUND"
}

struct EditPostView: View {
    @State private var itemName: String = ""
    @State private var lostLocation: String = ""
    @State private var descriptionText: String = ""
    @State private var selectedStatus: ItemStatus = .lost

    let selectedButtonBackgroundColor = Color(red: 0.48, green: 0.83, blue: 0.44)
    let unselectedButtonBackgroundColor = Color(UIColor.systemGray4)
    let selectedButtonTextColor = Color.white
    let unselectedButtonTextColor = Color(UIColor.label).opacity(0.7)

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
                
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Status:")
                        .font(.system(size: 16, weight: .bold))
          
                    HStack(spacing: 20) {
                        Button(action: {
                            selectedStatus = .lost
                        }) {
                            Text(ItemStatus.lost.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedStatus == .lost ? selectedButtonTextColor : unselectedButtonTextColor)
                                // CORRECTED PADDING: Chained horizontal and vertical
                                .padding(.horizontal, 30)
                                .padding(.vertical, 5)
                                .frame(minWidth: 0)
                                .background(selectedStatus == .lost ? selectedButtonBackgroundColor : unselectedButtonBackgroundColor)
                                .cornerRadius(8)
                        }
                        
                  
                        Button(action: {
                            selectedStatus = .found
                        }) {
                            Text(ItemStatus.found.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedStatus == .found ? selectedButtonTextColor : unselectedButtonTextColor)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 5)
                                .frame(minWidth: 50)
                                .frame(minHeight: 0)
                                .background(selectedStatus == .found ? selectedButtonBackgroundColor : unselectedButtonBackgroundColor)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                }

                Spacer().frame(minHeight: 80)
                
                Button(action: {
                    print("POST button tapped")
                    print("Item Name: \(itemName)")
                    print("Lost Location: \(lostLocation)")
                    print("Description: \(descriptionText)")
                    print("Status: \(selectedStatus.rawValue)")
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
        EditPostView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
    }
}
