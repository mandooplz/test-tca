# test-tca

TCA(The-Composable-Architecture) 연습을 위한 테스트 iOS App 프로젝트입니다.

## 기본 개념

- **State**: 화면에 필요한 데이터를 표현하는 구조체입니다.
- **Action**: 사용자 입력이나 비동기 응답 등 상태를 변경시키는 모든 이벤트입니다.
- **Reducer**: `State`와 `Action`을 받아 새로운 상태를 리턴하는 순수 함수입니다.
- **Store**: `State`를 보관하고 `Reducer`를 실행해 액션을 처리하는 중앙 허브이며 View에서 관찰합니다.
- **View**: `Store`를 주입받아 상태를 표시하고 액션을 전송합니다.

## 간단한 예제

```swift
import ComposableArchitecture
import SwiftUI


// MARK: Object
@Reducer
struct CounterFeature {
    // MARK: state
    @ObservableState
    struct State: Equatable {
        var count = 0
    }


    // MARK: action
    enum Action {
        case increment
        case decrement
    }
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increment:
                state.count += 1
                return .none
            case .decrement:
                state.count -= 1
                return .none
            }
        }
    }
}

struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
        VStack {
            Text("\(store.count)")
            HStack {
                Button("-") { store.send(.decrement) }
                Button("+") { store.send(.increment) }
            }
        }.font(.largeTitle)
    }
}
```

## Navigation

TCA에서 내비게이션은 push, pop을 호출하는 것이 아니라 State를 바꾸는 방식입니다.

1. Tree-based navigation
2. Stack-based navigation
3. Dismissal

## Dependencies

## Sharding State

## Concurrency

## Bindings

## 참고

- ![TCA Github Repo](https://github.com/pointfreeco/swift-composable-architecture)
