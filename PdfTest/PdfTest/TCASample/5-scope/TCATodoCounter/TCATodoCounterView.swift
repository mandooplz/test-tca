//
//  TCATodoCounterView.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCATodoCounterView: View {
    @Bindable var store: StoreOf<TCATodoCounter>

    private var progress: Double {
        guard store.target > 0 else { return 0 }
        return min(Double(store.count) / Double(store.target), 1)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("완료 카운터")
                        .font(.headline)

                    Text("카운터가 \(store.target)회에 도달하면 부모 피처가 축하 메시지를 띄웁니다.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(store.count)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(store.count >= store.target ? .orange : .primary)
            }

            ProgressView(value: progress)
                .tint(store.count >= store.target ? .orange : .blue)

            HStack(spacing: 24) {
                Button {
                    store.send(.decrement)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.red)
                }

                Button {
                    store.send(.increment)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.green)
                }
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
    TCATodoCounterView(
        store: Store(
            initialState: TCATodoCounter.State(count: 8),
            reducer: { TCATodoCounter() }
        )
    )
    .padding()
}
