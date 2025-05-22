import SwiftUI

struct HomeView: View {
    @State private var selectedIndex = 0
    let options = ["All Posts", "My Posts"]

    var body: some View {
        NavigationStack {
            VStack {
                Text("App Name")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding()

                Picker("", selection: $selectedIndex) {
                    ForEach(0..<options.count, id: \.self) { index in
                        Text(options[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView {
                    VStack(spacing: 16) {
                        NavigationLink(destination: PostDetailView()) {
                            HomeCardView()
                        }
                        .buttonStyle(PlainButtonStyle()) // Optional: Removes blue highlight
                    }
                    .padding()
                }
            } 
        } .tint(.orange)
    }
}

#Preview {
    HomeView()
}
