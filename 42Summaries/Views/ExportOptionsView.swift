import SwiftUI

struct ExportOptionsView: View {
    @ObservedObject var viewModel: SummaryViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Options")
                .font(.title)
                .fontWeight(.bold)
            
            Button("Export as PDF") {
                ExportManager.exportAsPDF(content: appState.summary, fontSize: viewModel.fontSize, alignment: viewModel.textAlignment.toNSTextAlignment(), fileName: "Summary")
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("Export as TXT") {
                ExportManager.exportAsTXT(content: appState.summary, fileName: "Summary")
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
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
