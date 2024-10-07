import SwiftUI

struct ExportOptionsView: View {
    @ObservedObject var viewModel: SummaryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Options")
                .font(.headline)
            
            Button(action: {
                ExportManager.exportAsPDF(content: viewModel.summary,
                                          fontSize: viewModel.fontSize,
                                          alignment: viewModel.textAlignment.toNSTextAlignment(),
                                          fileName: "Transcription")
                dismiss()
            }) {
                Label("Export as PDF", systemImage: "doc.fill")
            }
            .buttonStyle(.bordered)
            
            Button(action: {
                ExportManager.exportAsTXT(content: viewModel.summary, fileName: "Transcription")
                dismiss()
            }) {
                Label("Export as TXT", systemImage: "doc.text.fill")
            }
            .buttonStyle(.bordered)
            
            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding()
        .frame(width: 250, height: 200)
    }
}

extension TextAlignment {
    func toNSTextAlignment() -> NSTextAlignment {
        switch self {
        case .leading:
            return .left
        case .center:
            return .center
        case .trailing:
            return .right
        }
    }
}
