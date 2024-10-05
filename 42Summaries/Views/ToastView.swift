//
//  ToastView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 05.10.24.
//
import SwiftUI

struct ToastView: View {
    let message: String
    let duration: Double
    let dismissAction: () -> Void
    
    @State private var opacity: Double = 0
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color(.windowBackgroundColor).opacity(0.9))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .shadow(radius: 5)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismissAction()
                    }
                }
            }
    }
}
