//
//  TranscriptionProgressView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

struct TranscriptionProgressView: View {
    let progress: Double
    let status: TranscriptionStatus
    
    var body: some View {
        VStack {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
            
            HStack {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                Text(status.rawValue)
                    .foregroundColor(status.color)
            }
        }
    }
}

struct TranscriptionProgressView_Previews: PreviewProvider {
    static var previews: some View {
        TranscriptionProgressView(progress: 0.5, status: .transcribing)
    }
}
