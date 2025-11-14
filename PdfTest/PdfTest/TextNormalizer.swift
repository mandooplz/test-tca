//
//  TextNormalizer.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import Foundation

enum TextNormalizer {
    /// PDF에서 뽑은 텍스트를 사람 읽기 좋게 정리
    static func normalizePDFText(_ raw: String) -> String {
        // 1) 개행 통일
        var text = raw
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        // 2) 탭 → 공백
        text = text.replacingOccurrences(of: "\t", with: " ")

        // 3) 연속 공백 줄이기 (2칸 이상 → 1칸)
        while text.contains("  ") {
            text = text.replacingOccurrences(of: "  ", with: " ")
        }

        // 4) 줄 단위로 나눠서 "빈 줄은 문단 구분", "나머지는 한 줄로 합치기"
        let lines = text.components(separatedBy: "\n")

        var paragraphs: [String] = []
        var current = ""

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                // 빈 줄: 문단 종료
                if !current.isEmpty {
                    paragraphs.append(current)
                    current = ""
                }
            } else {
                if current.isEmpty {
                    current = trimmed
                } else {
                    // 문단 안 줄바꿈은 공백으로 이어 붙이기
                    current += " " + trimmed
                }
            }
        }

        if !current.isEmpty {
            paragraphs.append(current)
        }

        // 5) 문단 사이에 빈 줄 하나씩
        return paragraphs.joined(separator: "\n\n")
    }
}

