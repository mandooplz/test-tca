//
//  PDFGenerator.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import Foundation
import PDFKit
import UIKit

/// 텍스트를 받아서 PDF로 만들고, 앱의 Documents 폴더에 저장한 뒤 URL을 반환
func generateSummaryPDF(text: String, fileName: String) -> URL? {
    let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // A4 비슷한 사이즈 (pt 단위)
    let format = UIGraphicsPDFRendererFormat()
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

    let data = renderer.pdfData { context in
        context.beginPage()

        let insetRect = pageRect.insetBy(dx: 32, dy: 32)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraphStyle
        ]

        let attributedText = NSAttributedString(string: text, attributes: attrs)
        attributedText.draw(in: insetRect)
    }

    do {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = docsURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("PDF 저장 실패:", error)
        return nil
    }
}
