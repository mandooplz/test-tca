//
//  TCATodoBoard.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import ComposableArchitecture
import Foundation


// MARK: Object
@Reducer
struct TCATodoBoard {
    // MARK: state
    @ObservableState
    struct State: Equatable {
        var todo = TCATodo.State()
        var counter = TCATodoCounter.State()
        var statusMessage: String?
        var boardLog: [String] = []
    }


    // MARK: action
    enum Action: Equatable {
        case todo(TCATodo.Action)
        case counter(TCATodoCounter.Action)
        case dismissStatusMessage
    }


    // MARK: body
    var body: some Reducer<State, Action> {
        Scope(state: \.todo, action: \.todo) {
            TCATodo()
        }

        Scope(state: \.counter, action: \.counter) {
            TCATodoCounter()
        }

        Reduce { state, action in
            switch action {
            case .todo(.toggleImportant):
                let message = state.todo.isImportant
                ? "이 Todo가 중요하게 설정되었습니다."
                : "이 Todo의 중요 표시가 해제되었습니다."
                state.statusMessage = message
                state.boardLog.append("💡 \(message)")
                return .none

            case .todo(.setNote):
                let note = state.todo.note.trimmingCharacters(in: .whitespacesAndNewlines)
                let message = note.isEmpty ? "메모가 비워졌습니다." : "메모 업데이트: \(note)"
                state.boardLog.append("📝 \(message)")
                return .none

            case .counter(.delegate(.reachedTen)):
                let message = "카운터가 \(state.counter.target)회에 도달했습니다!"
                state.statusMessage = message
                state.boardLog.append("🎯 \(message)")
                state.counter.count = 0
                return .none

            case .dismissStatusMessage:
                state.statusMessage = nil
                return .none

            case .counter:
                return .none

            case .todo:
                return .none
            }
        }
    }
}
