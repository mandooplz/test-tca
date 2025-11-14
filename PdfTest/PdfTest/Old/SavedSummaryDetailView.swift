//
//  SavedSummaryDetailView.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import SwiftUI
import PDFKit
import SwiftData

enum DetailMode {
    case script
    case aiSummary
    case none
}

struct SavedSummaryDetailView: View {
    let item: SummaryPDF
    let isNew: Bool                  // 새로 연 문서인가?
    let onOpenChat: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var chatStore: ChatSessionStore

    @State private var mode: DetailMode = .script
    @State private var scriptText: String = ""
    @State private var aiSummaryText: String = ""
    @State private var isLoadingScript = true
    @State private var isSummarizing = false
    @State private var errorMessage: String?

    @State private var isSavedToProject: Bool   // 프로젝트에 저장 여부
    @State private var isSummarySaved: Bool = false

    // ✅ 세 가지 확인 다이얼로그용 플래그
    @State private var showSummaryConfirm = false
    @State private var showLeaveConfirm = false
    @State private var showChatSaveConfirm = false

    private let alanClient: AlanAPIClient

    init(item: SummaryPDF, isNew: Bool, onOpenChat: @escaping () -> Void) {
        self.item = item
        self.isNew = isNew
        self.onOpenChat = onOpenChat

        let baseURL = URL(string: "https://kdt-api-function.azurewebsites.net/api/v1")!
        let alanClientKey = "d6027b9d-710f-4c04-ab63-550aa2cb6b8c"
        self.alanClient = AlanAPIClient(baseURL: baseURL, clientID: alanClientKey)

        // 새 문서면 아직 저장 안된 상태, 기존 프로젝트에서 들어온 경우는 저장된 상태
        _isSavedToProject = State(initialValue: !isNew)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 세그먼트 버튼
            HStack {
                segmentButton(title: "스크립트", mode: .script)
                segmentButton(title: "요약", mode: .aiSummary)

                Button {
                    openChat()
                } label: {
                    Text("채팅")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(scriptText.isEmpty && aiSummaryText.isEmpty)
            }
            .padding()

            Divider()

            // 본문
            contentView
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    handleBack()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .task {
            await loadScript()                       // 원본 텍스트 로딩
            aiSummaryText = item.aiSummaryText ?? "" // 저장된 요약 불러오기
            if !aiSummaryText.isEmpty { isSummarySaved = true }
        }
        // 오류 알럿
        .alert(
            errorMessage ?? "",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )
        ) {
            Button("확인", role: .cancel) {}
        }
        // ✅ 1) 요약 요청 확인
        .confirmationDialog(
            "Ai 요약을 요청할까요?",
            isPresented: $showSummaryConfirm
        ) {
            Button("예") {
                mode = .aiSummary
                summarizeScript()
            }
            Button("아니오", role: .cancel) {
                mode = .aiSummary   // 요약은 안 하고 화면만 전환
            }
        } message: {
            Text("이 문서 내용을 Ai에게 요약 요청합니다.")
        }
        // ✅ 2) 뒤로가기 시 저장 여부 확인
        .confirmationDialog(
            "이 파일을 저장하시겠습니까?",
            isPresented: $showLeaveConfirm
        ) {
            Button("예") {
                saveToProjectIfNeeded()
                dismiss()
            }
            Button("아니오", role: .destructive) {
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("저장하지 않고 나가면 이 문서는 프로젝트 목록에 남지 않습니다.")
        }
        // ✅ 3) 채팅 사용 전 저장 안내
        .confirmationDialog(
            "채팅은 파일 저장 후 사용 가능합니다.",
            isPresented: $showChatSaveConfirm
        ) {
            Button("예") {
                // 요약이 없으면 저장할 수 없음
                let summary = aiSummaryText.trimmingCharacters(in: .whitespacesAndNewlines)
                if summary.isEmpty {
                    errorMessage = "먼저 요약을 생성한 뒤 저장할 수 있습니다."
                } else {
                    // 저장 + 채팅 진입
                    saveSummaryPDFAndProject()
                }
            }
            Button("아니오", role: .cancel) {}
        } message: {
            Text("지금 파일을 저장하고 채팅을 시작할까요?")
        }
    }

    // MARK: - UI 구성

    private func segmentButton(title: String, mode target: DetailMode) -> some View {
        Button {
            switch target {
            case .aiSummary:
                // 요약 탭 눌렀을 때: 예/아니오 먼저
                showSummaryConfirm = true
            default:
                mode = target
            }
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(mode == target ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
                .foregroundColor(mode == target ? .blue : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch mode {
        case .script:
            if isLoadingScript {
                ProgressView("스크립트 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if scriptText.isEmpty {
                Text("PDF에서 텍스트를 추출할 수 없습니다.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    Text(scriptText)    // 전체 원본 텍스트
                        .font(.system(size: 14))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }

        case .aiSummary:
            aiSummaryView

        case .none:
            Spacer()
        }
    }

    private var aiSummaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isSummarizing {
                ProgressView("Ai 요약 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if aiSummaryText.isEmpty {
                Text("아직 요약이 없습니다. 상단에서 '요약' 탭을 눌러 요약을 요청하세요.")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    Text(aiSummaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                }
            }

            HStack {
                Button {
                    // 여기서도 바로 요약하지 않고 같은 확인 플로우 사용
                    showSummaryConfirm = true
                } label: {
                    Text(isSummarizing ? "요약 중..." : "다시 요약")
                }
                .buttonStyle(.bordered)
                .disabled(isSummarizing)

                Button {
                    saveSummaryPDFAndProject()
                } label: {
                    Text(isSavedToProject ? "파일 저장됨" : "파일 저장하기")
                }
                .buttonStyle(.borderedProminent)
                .tint(isSavedToProject ? .green : .blue)
                .disabled(aiSummaryText.isEmpty || isSummarizing)
            }
        }
        .padding()
    }

    // MARK: - Logic

    /// 뒤로가기 처리
    private func handleBack() {
        if isSavedToProject || !isNew {
            dismiss()
        } else {
            showLeaveConfirm = true
        }
    }

    /// 원본 스크립트를 로드 (1순위: DB 저장본, 2순위: PDF에서 추출)
    @MainActor
    private func loadScript() async {
        isLoadingScript = true

        // 1) DB에 저장된 원본 스크립트가 있으면 그걸 우선 사용
        if let stored = item.originalScriptText, !stored.isEmpty {
            scriptText = stored
            isLoadingScript = false
            return
        }

        // 2) (옛 데이터용) pdfFileName에서 추출
        let docsURL = FileManager.default.urls(for: .documentDirectory,
                                               in: .userDomainMask).first!
        let fileURL = docsURL.appendingPathComponent(item.pdfFileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            isLoadingScript = false
            errorMessage = "PDF 파일이 존재하지 않습니다."
            scriptText = ""
            return
        }

        if let text = PDFTextExtractor.extractText(from: fileURL) {
            scriptText = text
        } else {
            scriptText = ""
        }

        isLoadingScript = false
    }

    // MARK: - Ai 요약 (직렬 + URL 8,000 이하)

    private func summarizeScript() {
        var text = scriptText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            errorMessage = "스크립트가 비어 있어 요약할 수 없습니다."
            return
        }

        // 공백/줄바꿈 정리
        text = text
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")

        while text.contains("  ") {
            text = text.replacingOccurrences(of: "  ", with: " ")
        }

        let chunks = chunk(text: text, size: 500)
        let maxURLLength = 8_000

        Task {
            do {
                isSummarizing = true
                errorMessage = nil
                isSummarySaved = false
                aiSummaryText = ""

                var partialSummaries: [String] = []

                for (index, baseChunk) in chunks.enumerated() {
                    var currentChunk = baseChunk

                    while true {
                        let prompt = """
                        아래는 문서의 일부입니다. 이 부분만 한국어로 1~2문장으로 요약해줘.

                        \(currentChunk)
                        """

                        let urlLen = alanClient.urlLength(for: prompt)
                        print(">>> chunk \(index + 1)/\(chunks.count), chars=\(currentChunk.count), urlLen=\(urlLen)")

                        if urlLen <= maxURLLength {
                            let res = try await alanClient.question(content: prompt)
                            let cleaned = cleanedChunkSummary(res.content)
                            partialSummaries.append("● \(cleaned)")
                            break
                        }

                        let newCount = Int(Double(currentChunk.count) * 0.8)
                        if newCount < 100 {
                            let res = try await alanClient.question(content: prompt)
                            let cleaned = cleanedChunkSummary(res.content)
                            partialSummaries.append("● \(cleaned)")
                            break
                        }

                        currentChunk = String(currentChunk.prefix(newCount))
                    }
                }

                let merged = partialSummaries.joined(separator: "\n\n")
                aiSummaryText = merged
                item.aiSummaryText = merged

            } catch {
                errorMessage = "Ai 요약 중 오류: \(error.localizedDescription)"
                print("Alan error:", error)
            }

            isSummarizing = false
        }
    }

    // 텍스트 chunk 유틸
    private func chunk(text: String, size: Int) -> [String] {
        var result: [String] = []
        var current = text.startIndex

        while current < text.endIndex {
            let end = text.index(current, offsetBy: size,
                                 limitedBy: text.endIndex) ?? text.endIndex
            result.append(String(text[current..<end]))
            current = end
        }
        return result
    }

    /// 요약 PDF 생성 + 프로젝트에 insert + (새/기존 상관없이) 채팅 진입
    private func saveSummaryPDFAndProject() {
        let summary = aiSummaryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !summary.isEmpty else { return }

        let fileName = item.pdfFileName.isEmpty
            ? "\(UUID().uuidString).pdf"
            : item.pdfFileName

        guard let url = generateSummaryPDF(text: summary, fileName: fileName) else {
            errorMessage = "요약 PDF 생성에 실패했습니다."
            return
        }

        print("요약 PDF 저장:", url)

        item.pdfFileName = fileName
        item.aiSummaryText = summary

        saveToProjectIfNeeded()
        isSavedToProject = true
        isSummarySaved = true

        // ✅ 저장 직후: 채팅 컨텍스트 세팅 + 채팅 탭으로 전환 + 현재 화면 닫기
        DispatchQueue.main.async {
            startChat()   // chatStore.currentItem, contextText 세팅 + onOpenChat() 호출
            dismiss()     // 디테일 화면 pop (탭2/탭1 루트로 돌아감)
        }
    }


    private func saveToProjectIfNeeded() {
        if !isSavedToProject {
            modelContext.insert(item)
            isSavedToProject = true
        }
    }

    /// 채팅 탭 버튼 눌렀을 때
    private func openChat() {
        // 새 문서 + 아직 저장 안 함 → 안내 문구 + 예/아니오
        if isNew && !isSavedToProject {
            showChatSaveConfirm = true
            return
        }
        // 이미 저장된 상태면 바로 채팅 시작
        startChat()
    }

    /// 실제 채팅 컨텍스트 세팅 + 탭 전환
    private func startChat() {
        var ctx = ""

        if !aiSummaryText.isEmpty {
            ctx = aiSummaryText
            if (item.aiSummaryText ?? "").isEmpty {
                item.aiSummaryText = aiSummaryText
            }
        } else {
            ctx = scriptText.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard !ctx.isEmpty else {
            errorMessage = "채팅에 사용할 내용이 없습니다."
            return
        }

        chatStore.currentItem = item
        chatStore.contextText = ctx
        onOpenChat()
    }

    // 요약 텍스트 정리: "이 문서는 ..." 제거
    private func cleanedChunkSummary(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let prefixes = [
            "이 문서는",
            "이 문서는 ",
            "이 문서는요",
            "이 문서는요 "
        ]

        for prefix in prefixes {
            if result.hasPrefix(prefix) {
                result.removeFirst(prefix.count)
                break
            }
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    let sample = SummaryPDF(title: "샘플", pdfFileName: "")
    return NavigationStack {
        SavedSummaryDetailView(item: sample, isNew: true, onOpenChat: {})
            .environmentObject(ChatSessionStore())
    }
}
