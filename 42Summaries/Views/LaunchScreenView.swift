//
//  LaunchScreenView.swift
//  42Summaries
//
//  Created by Henry Rausch on 05.10.24.
//
import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        VStack {
            Image("AppIconImage") // Make sure this image is in your asset catalog
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
            
            Text("42Summaries")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .padding(.top, 20)
            
            Text("Transcribe and Summarize with Ease")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .edgesIgnoringSafeArea(.all)
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}
