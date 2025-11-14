//
//  ChatTabView.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import SwiftUI
import SwiftData

struct ChatTabView: View {
    @EnvironmentObject private var chatStore: ChatSessionStore
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SummaryPDF.createdAt, order: .reverse)
    private var items: [SummaryPDF]

    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isSending = false
    @State private var isPreparingContext = false
    @State private var errorMessage: String?
    @State private var showProjectPicker = false

    private let alanClient: AlanAPIClient

    init() {
        let baseURL = URL(string: "https://kdt-api-function.azurewebsites.net/api/v1")!
        let alanClientKey = "d6027b9d-710f-4c04-ab63-550aa2cb6b8c"   // 네가 쓰는 키로 맞춰라
        self.alanClient = AlanAPIClient(baseURL: baseURL, clientID: alanClientKey)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                projectSelector

                Divider()

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                }

                if isPreparingContext {
                    ProgressView("프로젝트 요약 준비 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if chatStore.contextText.isEmpty || chatStore.currentItem == nil {
                    Text("아래 프로젝트에서 하나를 선택해 요약 기반 채팅을 시작하세요.")
                        .foregroundStyle(.secondary)
                        .padding()
                    Spacer()
                } else {
                    chatContent
                }
            }
            .navigationTitle(chatStore.currentItem?.title ?? "채팅")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                errorMessage ?? "",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { _ in errorMessage = nil }
                )
            ) {
                Button("확인", role: .cancel) {}
            }
        }
        // ⬇️ 이 위치에 onChange / onAppear 붙이기
        .onChange(of: chatStore.currentItem?.id) { _ in
            if let project = chatStore.currentItem {
                loadMessages(for: project)
                if messages.isEmpty {
                    addGreeting(for: project)
                }
            } else {
                messages.removeAll()
            }
        }
        .onAppear {
            if let project = chatStore.currentItem {
                loadMessages(for: project)
                if messages.isEmpty {
                    addGreeting(for: project)
                }
            }
        }
        // ⬇️ 그 다음에 sheet
        .sheet(isPresented: $showProjectPicker) {
            NavigationStack {
                List {
                    if items.isEmpty {
                        Text("저장된 프로젝트가 없습니다.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(items) { item in
                            Button {
                                showProjectPicker = false
                                selectProject(item)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.blue)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.body)
                                            .lineLimit(1)
                                        Text(item.createdAt, style: .date)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .navigationTitle("프로젝트 선택")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("닫기") {
                            showProjectPicker = false
                        }
                    }
                }
            }
        }
    }


    

    // MARK: - 상단 프로젝트 선택 영역

    private var projectSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("프로젝트 선택")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let current = chatStore.currentItem {
                    Text("· 현재 선택: \(current.title)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if items.isEmpty {
                Text("저장된 프로젝트가 없습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(items) { item in
                            Button {
                                selectProject(item)
                            } label: {
                                Text(item.title)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        item.id == chatStore.currentItem?.id
                                        ? Color.blue.opacity(0.2)
                                        : Color.gray.opacity(0.15)
                                    )
                                    .foregroundColor(
                                        item.id == chatStore.currentItem?.id
                                        ? .blue
                                        : .primary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding([.horizontal, .top])
    }

    private func selectProject(_ item: SummaryPDF) {
        Task {
            await MainActor.run {
                isPreparingContext = true
                errorMessage = nil
                messages.removeAll()
            }

            // 1) PDF 텍스트 추출
            let docsURL = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask).first!
            let fileURL = docsURL.appendingPathComponent(item.pdfFileName)

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                await MainActor.run {
                    isPreparingContext = false
                    errorMessage = "PDF 파일이 존재하지 않습니다."
                }
                return
            }

            let extracted = PDFTextExtractor.extractText(from: fileURL)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            guard !extracted.isEmpty else {
                await MainActor.run {
                    isPreparingContext = false
                    errorMessage = "PDF에서 스크립트를 추출할 수 없습니다."
                }
                return
            }

            // 2) 컨텍스트 결정: 요약이 있으면 요약, 없으면 한 번 요약 시도
            var contextToUse = extracted
            var localError: String?

            if let stored = item.aiSummaryText, !stored.isEmpty {
                // 이미 저장된 요약 사용
                contextToUse = stored
            } else {
                // 처음인 경우 한 번만 요약 호출
                do {
                    let limited = String(extracted.prefix(4000))
                    let prompt = """
                    아래는 어떤 문서의 전체 스크립트입니다. 이 내용을 한국어로 핵심만 요약해줘.

                    \(limited)
                    """
                    let res = try await alanClient.question(content: prompt)
                    contextToUse = res.content
                    item.aiSummaryText = res.content   // ✅ 모델에도 저장
                } catch {
                    localError = "Ai 요약 중 오류가 발생했습니다. 대신 원문으로 채팅을 진행합니다."
                    contextToUse = extracted
                }
            }

            // 3) 컨텍스트 + 기존 채팅 복원 + 없으면 인사 추가
            await MainActor.run {
                chatStore.currentItem = item
                chatStore.contextText = contextToUse

                loadMessages(for: item)   // ✅ 프로젝트별 저장된 대화 불러옴

                if messages.isEmpty {
                    addGreeting(for: item)
                }

                if let localError {
                    errorMessage = localError
                }
                isPreparingContext = false
            }
        }
    }

    private func addGreeting(for project: SummaryPDF) {
        guard !chatStore.contextText.isEmpty else { return }

        let greetingText = "안녕하세요! '\(project.title)' 문서 내용(또는 요약)을 기반으로 궁금한 점을 물어보세요."
        let greeting = ChatMessage(
            isUser: false,
            text: greetingText,
            createdAt: Date()
        )
        messages.append(greeting)

        let entity = ChatMessageEntity(
            id: greeting.id,
            createdAt: greeting.createdAt,
            isUser: false,
            text: greeting.text,
            project: project
        )
        modelContext.insert(entity)
    }
    
    private func loadMessages(for item: SummaryPDF) {
        let targetID = item.id   // ✅ 외부 값은 이런 식으로 캡처

        let descriptor = FetchDescriptor<ChatMessageEntity>(
            predicate: #Predicate<ChatMessageEntity> { message in
                message.project?.id == targetID
            },
            sortBy: [SortDescriptor(\.createdAt)]
        )

        do {
            let stored = try modelContext.fetch(descriptor)
            messages = stored.map {
                ChatMessage(
                    isUser: $0.isUser,
                    text: $0.text,
                    createdAt: $0.createdAt
                )
            }
        } catch {
            print("loadMessages fetch error:", error)
            messages = []
        }
    }


    // MARK: - 채팅 UI

    private var chatContent: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            messageRow(message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }
                .onChange(of: messages.count) { _ in
                    if let lastID = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(alignment: .bottom, spacing: 8) {
                TextField("질문을 입력하세요", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button {
                    sendMessage()
                } label: {
                    if isSending {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
            .padding(8)
        }
    }

    private func messageRow(_ message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                Spacer()
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - 전송 로직

    private func sendMessage() {
        let question = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty,
              !isSending,
              !chatStore.contextText.isEmpty,
              let project = chatStore.currentItem else { return }

        let userMsg = ChatMessage(isUser: true, text: question, createdAt: Date())
        messages.append(userMsg)
        inputText = ""
        isSending = true

        // ✅ SwiftData에 유저 메시지 저장
        let userEntity = ChatMessageEntity(
            id: userMsg.id,
            createdAt: userMsg.createdAt,
            isUser: true,
            text: userMsg.text,
            project: project
        )
        modelContext.insert(userEntity)

        let context = chatStore.contextText

        Task {
            do {
                let prompt = """
                아래는 어떤 문서(또는 그 요약)의 텍스트입니다:

                \(context.prefix(4000))

                위 내용을 최대한 반영해서, 사용자의 질문에 한국어로 자세히 답변해줘.

                질문: \(question)
                """
                let response = try await alanClient.question(content: prompt)

                let botMsg = ChatMessage(
                    isUser: false,
                    text: response.content,
                    createdAt: Date()
                )

                await MainActor.run {
                    messages.append(botMsg)
                    isSending = false

                    // ✅ SwiftData에 봇 메시지도 저장
                    let botEntity = ChatMessageEntity(
                        id: botMsg.id,
                        createdAt: botMsg.createdAt,
                        isUser: false,
                        text: botMsg.text,
                        project: project
                    )
                    modelContext.insert(botEntity)
                }
            } catch {
                let errMsg = ChatMessage(
                    isUser: false,
                    text: "답변 중 오류가 발생했습니다: \(error.localizedDescription)",
                    createdAt: Date()
                )
                await MainActor.run {
                    messages.append(errMsg)
                    isSending = false

                    let errEntity = ChatMessageEntity(
                        id: errMsg.id,
                        createdAt: errMsg.createdAt,
                        isUser: false,
                        text: errMsg.text,
                        project: project
                    )
                    modelContext.insert(errEntity)
                }
            }
        }
    }

}

// 말풍선용 모델
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let isUser: Bool
    let text: String
    let createdAt: Date
}
