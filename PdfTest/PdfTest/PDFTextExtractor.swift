//
//  PDFTextExtractor.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//
import Foundation
import PDFKit

enum PDFTextExtractor {
    static func extractText(from url: URL) -> String? {
        guard let document = PDFDocument(url: url) else { return nil }
        
        var fullText = ""
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex),
                  let pageText = page.string else { continue }
            fullText += pageText + "\n\n"
        }
        return fullText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

