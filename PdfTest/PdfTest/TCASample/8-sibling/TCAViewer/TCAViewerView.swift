//
//  TCAViewerView.swift
//  PdfTest
//
//  Created by 김민우 on 11/17/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCAViewerView: View {
    @Bindable var store: StoreOf<TCAViewer>

    var body: some View {
        VStack(spacing: 16) {
            Label("현재 카운트", systemImage: "eye")
                .font(.headline)

            Text("\(store.count)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: store.count)

            Text("컨트롤러 피처에서 버튼을 누르면 값이 실시간으로 갱신됩니다.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.15),
                            Color.indigo.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}


// MARK: Preview
#Preview {
    TCAViewerView(
        store: Store(
            initialState: TCAViewer.State(count: 3),
            reducer: { TCAViewer() }
        )
    )
    .padding()
}
