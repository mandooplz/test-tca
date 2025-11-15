//
//  TCATodoView.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCATodoView: View {
    @Bindable var store: StoreOf<TCATodo>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.title)
                        .font(.title3.bold())

                    Label(
                        store.isImportant ? "지금 해야 할 중요한 작업" : "중요 표시가 꺼져 있어요",
                        systemImage: store.isImportant ? "star.fill" : "star"
                    )
                    .font(.footnote)
                    .foregroundStyle(store.isImportant ? .orange : .secondary)
                }

                Spacer(minLength: 16)

                Button {
                    store.send(.toggleImportant)
                } label: {
                    Image(systemName: store.isImportant ? "exclamationmark.triangle.fill" : "exclamationmark.triangle")
                        .font(.title3)
                        .foregroundStyle(store.isImportant ? .orange : .gray)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(store.isImportant ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("메모")
                    .font(.headline)

                TextField(
                    "메모를 입력하면 부모 보드에서 로그를 남겨요",
                    text: Binding(
                        get: { store.note },
                        set: { store.send(.setNote($0)) }
                    )
                )
                .textFieldStyle(.roundedBorder)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}


// MARK: Preview
#Preview {
    TCATodoView(
        store: Store(
            initialState: TCATodo.State(),
            reducer: { TCATodo() }
        )
    )
    .padding()
}
