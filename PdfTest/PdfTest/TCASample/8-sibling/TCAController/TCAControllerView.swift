//
//  TCAControllerView.swift
//  PdfTest
//
//  Created by 김민우 on 11/17/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCAControllerView: View {
    @Bindable var store: StoreOf<TCAController>

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("카운터 제어기", systemImage: "slider.horizontal.3")
                .font(.headline)

            Text("버튼을 눌러 형제 피처의 카운터 값을 조절할 수 있습니다.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 40) {
                Button {
                    store.send(.decrement)
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title.weight(.semibold))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.red)
                        Text("감소")
                            .font(.footnote.bold())
                            .foregroundStyle(.primary)
                    }
                    .frame(width: 90, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)

                Button {
                    store.send(.increment)
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title.weight(.semibold))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.green)
                        Text("증가")
                            .font(.footnote.bold())
                            .foregroundStyle(.primary)
                    }
                    .frame(width: 90, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.green.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}


// MARK: Preview
#Preview {
    TCAControllerView(
        store: Store(
            initialState: TCAController.State(),
            reducer: { TCAController() }
        )
    )
    .padding()
}
