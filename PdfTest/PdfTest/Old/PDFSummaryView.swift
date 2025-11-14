//
//  PDFSummaryView.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import SwiftUI
import SwiftData

struct PDFSummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showPicker = false
    @State private var selectedItem: SummaryPDF?   // ✅ 네비게이션 타깃

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Button("PDF 선택") {
                    showPicker = true
                }
                .buttonStyle(.borderedProminent)

                Text("PDF를 선택하면 프로젝트 상세화면에서 스크립트·요약·채팅을 진행합니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle("PDF 가져오기")
            .sheet(isPresented: $showPicker) {
                PDFDocumentPicker { url in
                    showPicker = false
                    handlePickedPDF(url)
                }
            }
            // ✅ SummaryPDF가 세팅되면 곧바로 상세화면으로 이동
            .navigationDestination(item: $selectedItem) { item in
                SavedSummaryDetailView(
                    item: item,
                    isNew: true,            // ✅ 새로 가져온 PDF라서 true
                    onOpenChat: {
                        // 채팅 탭으로 전환하는 콜백
                    }
                )
            }
        }
    }

    private func handlePickedPDF(_ url: URL) {
        guard let raw = PDFTextExtractor.extractText(from: url) else {
            print("PDF 텍스트 추출 실패")
            return
        }

        // 줄바꿈/공백 정리용 헬퍼 쓰고 있다면 여기서 사용
        let normalized = TextNormalizer.normalizePDFText(raw)

        let title = url.deletingPathExtension().lastPathComponent

        // ✅ 아직 요약 PDF는 없으니 pdfFileName은 빈 문자열로 시작
        let item = SummaryPDF(
            title: title,
            pdfFileName: "",
            originalScriptText: normalized,
            aiSummaryText: nil
        )

        selectedItem = item       // ✅ 이게 NavigationDestination를 태운다
    }
}
