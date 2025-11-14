//
//  SavedSummaryListView.swift
//  PdfTest
//

import SwiftUI
import SwiftData

struct SavedSummaryListView: View {
    /// 3번째 탭(채팅)으로 전환해달라고 RootTabView에 알려주는 콜백
    let onOpenChatTab: () -> Void

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var chatStore: ChatSessionStore

    @Query(sort: \SummaryPDF.createdAt, order: .reverse)
    private var items: [SummaryPDF]

    var body: some View {
        NavigationStack {
            List {
                if items.isEmpty {
                    Text("저장된 프로젝트가 없습니다.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(items) { item in
                        NavigationLink {
                            SavedSummaryDetailView(item: item, isNew: false, onOpenChat: { onOpenChatTab() })
                        }  label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(item.createdAt, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("저장된 요약들")
            .toolbar {
                EditButton()
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            modelContext.delete(item)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: SummaryPDF.self)
    return SavedSummaryListView(onOpenChatTab: {})
        .environment(\.modelContext, container.mainContext)
        .environmentObject(ChatSessionStore())
}
