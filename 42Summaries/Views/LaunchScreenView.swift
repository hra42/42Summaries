import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Image("AppIconImage") // Make sure this image is in your asset catalog
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
            
            Text("42Summaries")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .padding(.top, 20)
            
            Text("Initializing...")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.top, 10)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding(.top, 20)
            
            Text(appState.modelState.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .edgesIgnoringSafeArea(.all)
    }
}
