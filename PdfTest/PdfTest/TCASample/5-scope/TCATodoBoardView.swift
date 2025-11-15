//
//  TCATodoBoardView.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCATodoBoardView: View {
    @Bindable var store: StoreOf<TCATodoBoard>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let message = store.statusMessage {
                        HStack {
                            Label(message, systemImage: "sparkles")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                            Spacer()
                            Button {
                                store.send(.dismissStatusMessage)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.callout)
                                    .foregroundStyle(.gray.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }

                    TCATodoView(
                        store: store.scope(state: \.todo, action: \.todo)
                    )

                    TCATodoCounterView(
                        store: store.scope(state: \.counter, action: \.counter)
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("부모 피처 로그")
                            .font(.headline)

                        if store.boardLog.isEmpty {
                            Text("자식 피처와 상호작용하면 로그가 쌓입니다.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(store.boardLog.enumerated()), id: \.offset) { item in
                                Text(item.element)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color(.secondarySystemBackground))
                                    )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Scope 샘플")
        }
    }
}


// MARK: Preview
#Preview {
    TCATodoBoardView(
        store: Store(
            initialState: TCATodoBoard.State(),
            reducer: { TCATodoBoard() }
        )
    )
}
