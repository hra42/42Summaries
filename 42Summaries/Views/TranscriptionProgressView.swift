//
//  TranscriptionProgressView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//

import SwiftUI

struct TranscriptionProgressView: View {
    @Binding var progress: Double
    @Binding var status: TranscriptionStatus
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 10)
            
            Text(status.message)
                .font(.headline)
            
            if status == .completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 50))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct TranscriptionProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TranscriptionProgressView(progress: .constant(0.0), status: .constant(.notStarted))
            TranscriptionProgressView(progress: .constant(0.3), status: .constant(.preparing))
            TranscriptionProgressView(progress: .constant(0.7), status: .constant(.transcribing))
            TranscriptionProgressView(progress: .constant(1.0), status: .constant(.completed))
            TranscriptionProgressView(progress: .constant(0.0), status: .constant(.error("File not found")))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

