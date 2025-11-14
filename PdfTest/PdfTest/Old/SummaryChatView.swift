//
//  SummaryChatView.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import SwiftUI
import SwiftData
import PDFKit

struct SummaryChatView: View {
    let item: SummaryPDF
    
    // Alan 클라이언트
    private let alanClient: AlanAPIClient
    
    @State private var contextText: String = ""      // PDF에서 뽑은 텍스트
    @State private var isLoadingContext = true
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isSending = false
    
    // Alan 클라 초기화
    init(item: SummaryPDF) {
        self.item = item
        
        let baseURL = URL(string: "https://kdt-api-function.azurewebsites.net/api/v1")!
        let alanClientKey = "d6027b9d-710f-4c04-ab63-550aa2cb6b8c"
        self.alanClient = AlanAPIClient(baseURL: baseURL, clientID: alanClientKey)
    }
    
    var body: some View {
        VStack {
            if isLoadingContext {
                ProgressView("PDF 요약 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if contextText.isEmpty {
                Text("PDF에서 텍스트를 읽어오지 못했습니다.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                chatContent
            }
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadContextAndGreet()
        }
    }
    
    // MARK: - Chat UI
    
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
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending || contextText.isEmpty)
            }
            .padding(.all, 8)
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
    
    // MARK: - Logic
    
    @MainActor
    private func loadContextAndGreet() async {
        // 1) PDF에서 텍스트 읽기
        let docsURL = FileManager.default.urls(for: .documentDirectory,
                                               in: .userDomainMask).first!
        let fileURL = docsURL.appendingPathComponent(item.pdfFileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            isLoadingContext = false
            messages.append(ChatMessage(
                isUser: false,
                text: "저장된 PDF 파일을 찾을 수 없습니다.",
                createdAt: Date()
            ))
            return
        }
        
        if let text = PDFTextExtractor.extractText(from: fileURL)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            contextText = text
        } else {
            contextText = ""
        }
        
        isLoadingContext = false
        
        // 2) Alan 인사 메시지
        let greeting = ChatMessage(
            isUser: false,
            text: "안녕하세요! 이 PDF 요약 내용에 대해 궁금한 점을 물어보세요. 내용 안에서 최대한 자세히 설명해 줄게요.",
            createdAt: Date()
        )
        messages.append(greeting)
    }
    
    private func sendMessage() {
        let question = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isSending, !contextText.isEmpty else { return }
        
        let userMsg = ChatMessage(isUser: true, text: question, createdAt: Date())
        messages.append(userMsg)
        inputText = ""
        isSending = true
        
        Task {
            do {
                // 컨텍스트 + 질문을 한 번에 Alan에 전달
                let prompt = """
                아래는 어떤 PDF 문서에 대한 요약 내용입니다:

                \(contextText.prefix(4000))

                위 요약 내용을 참고해서, 사용자의 질문에 한국어로 답변해줘.
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
                }
            }
        }
    }
}
