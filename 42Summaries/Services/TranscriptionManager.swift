//
//  TranscriptionManager.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import Foundation
import Combine

class TranscriptionManager: ObservableObject {
    @Published private(set) var progress: Double = 0.0
    @Published var status: TranscriptionStatus = .notStarted
    
    private var timer: Timer?
    
    func setProgress(_ newValue: Double) {
        progress = min(max(newValue, 0.0), 1.0)
    }
    
    func startTranscription() {
        status = .preparing
        setProgress(0.0)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.progress < 1.0 {
                self.setProgress(self.progress + 0.1)
                if self.progress > 0.3 && self.status == .preparing {
                    self.status = .transcribing
                }
            } else {
                timer.invalidate()
                self.status = .completed
            }
        }
    }
    
    func cancelTranscription() {
        timer?.invalidate()
        timer = nil
        status = .notStarted
        setProgress(0.0)
    }
}
