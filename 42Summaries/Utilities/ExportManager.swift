//
//  ExportManager.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import Foundation
import AppKit
import CoreGraphics
import CoreText
import UniformTypeIdentifiers

class ExportManager {
    static func exportAsPDF(content: String, fontSize: CGFloat, alignment: NSTextAlignment, fileName: String) {
        let pdfData = generatePDF(from: content, fontSize: fontSize, alignment: alignment)
        saveFile(data: pdfData, fileName: fileName, fileType: "pdf")
    }
    
    static func exportAsTXT(content: String, fileName: String) {
        guard let data = content.data(using: .utf8) else {
            return
        }
        saveFile(data: data, fileName: fileName, fileType: "txt")
    }
    
    private static func generatePDF(from content: String, fontSize: CGFloat, alignment: NSTextAlignment) -> Data {
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
        
        var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792) // 8.5x11 inches at 72 dpi
        
        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else {
            return Data()
        }
        
        pdfContext.beginPDFPage(nil)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize),
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSAttributedString(string: content, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        let framePath = CGPath(rect: CGRect(x: 50, y: 50, width: 512, height: 692), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), framePath, nil)
        
        CTFrameDraw(frame, pdfContext)
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        return pdfData as Data
    }
    
    private static func saveFile(data: Data, fileName: String, fileType: String) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: fileType)!]
        savePanel.nameFieldStringValue = fileName
        
        savePanel.begin { result in
            if result == .OK {
                guard let url = savePanel.url else { return }
                do {
                    try data.write(to: url)
                } catch {
                }
            }
        }
    }
}
