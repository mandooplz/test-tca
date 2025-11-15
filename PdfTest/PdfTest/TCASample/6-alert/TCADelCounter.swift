//
//  TCADelCounter.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: Object
@Reducer
struct TCADelCounter {
    // MARK: State
    @ObservableState
    struct State: Equatable {
        var count = 0

        // Alert는 @Presents 로 선언
        @Presents var alert: AlertState<Action.Alert>?
    }

    // MARK: Action
    enum Action: Equatable {
        case incrementButtonTapped
        case deleteButtonTapped

        // AlertState Button Action 전달
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case confirmDelete
            case cancel
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            // 카운터 증가
            case .incrementButtonTapped:
                state.count += 1
                state.alert = nil
                return .none

            // Alert 띄우기
            case .deleteButtonTapped:
                print("deleteButtonTapped가 호출되었습니다.")
                state.alert = AlertState {
                    TextState("Reset Counter?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDelete) {
                        TextState("Reset")
                    }
                    ButtonState(role: .cancel, action: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("This will set the counter to zero.")
                }
                return .none


            // Alert 내부 버튼 액션 처리
            case .alert(.presented(.confirmDelete)):
                state.count = 0
                state.alert = nil
                return .none

            case .alert(.presented(.cancel)):
                // 아무것도 안 함
                state.alert = nil
                return .none

            case .alert(.dismiss):
                // 사용자가 alert 외부 영역 탭해서 닫은 경우
                state.alert = nil
                return .none
            }
        }
    }
}
