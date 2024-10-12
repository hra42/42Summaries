// ExportOptionsView.swift

import SwiftUI

struct ExportOptionsView: View {
    let content: String
    let fileName: String
    @Binding var fontSize: CGFloat
    @Binding var textAlignment: TextAlignment
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Options")
                .font(.title)
                .fontWeight(.bold)
            
            Button("Export as PDF") {
                ExportManager.exportAsPDF(content: content, fontSize: fontSize, alignment: textAlignment.toNSTextAlignment(), fileName: fileName)
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("Export as TXT") {
                ExportManager.exportAsTXT(content: content, fileName: fileName)
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
