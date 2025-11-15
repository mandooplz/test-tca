
# 1-object — 기본 카운터

가장 작은 형태의 리듀서와 스토어를 통해 TCA의 핵심 데이터 흐름을 보여 줍니다.

## TCA 기능, 설명, 예시 코드

### 1. `@Reducer`와 `Reduce`로 비즈니스 로직 정의
- 설명: `TCACounter`는 상태와 액션을 한곳에 정의하고 `Reduce` 블록에서 증감 로직을 처리합니다.
```swift
@Reducer
struct TCACounter {
    @ObservableState
    struct State: Equatable {
        var count: Int = 0
    }

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
```

### 2. `StoreOf`를 SwiftUI 뷰에 주입
- 설명: 뷰에서 `StoreOf<TCACounter>`를 보관해 상태를 읽고 `.send`로 액션을 전송합니다.
```swift
struct TCACounterView: View {
    @State var store: StoreOf<TCACounter>

    var body: some View {
        VStack(spacing: 24) {
            Text("\(store.count)")
            HStack(spacing: 32) {
                Button { store.send(.decrement) } label: {
                    Image(systemName: "minus")
                }
                Button { store.send(.increment) } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
```

### 3. 미리보기에서 독립 스토어 생성
- 설명: `Store(initialState:reducer:)`로 미리보기에서 리듀서를 실행해 UI만으로 상태 변화를 확인합니다.
```swift
#Preview {
    TCACounterView(
        store: Store(
            initialState: TCACounter.State(),
            reducer: { TCACounter() }
        )
    )
}
```
