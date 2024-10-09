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
            
            Text(appState.modelState.description)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.top, 10)
            
            ProgressView(value: appState.modelDownloadProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 200)
                .padding(.top, 20)
            
            Text("\(Int(appState.modelDownloadProgress * 100))%")
                .font(.caption)
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .edgesIgnoringSafeArea(.all)
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
            .environmentObject(AppState())
    }
}
