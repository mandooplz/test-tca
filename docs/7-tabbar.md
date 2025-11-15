# 7-tabbar — 탭 전환 상태 모델링

탭 UI를 추가하기 전에 탭 전환을 상태와 액션으로 먼저 표현할 수 있는 뼈대입니다.

## TCA 기능, 설명, 예시 코드

### 1. 탭 enum으로 뷰 선택 값 정의
- 설명: SwiftUI `TabView`와 매칭될 탭 식별자는 단순 enum으로 선언해 테스트가 쉽습니다.
```swift
enum Tab: Hashable {
    case home
    case settings
}
```

### 2. 최소 리듀서 골격 준비
- 설명: 실제 화면 상태가 들어가기 전이라도 `@Reducer`와 `State`/`Action`을 정의해 향후 기능을 끼워 넣을 수 있습니다.
```swift
@Reducer
struct TCATabhome {
    @ObservableState
    struct State: Equatable { }

    enum Action: Equatable {
        case selectTab(Tab)
    }
}
```

필요한 탭 상태나 자식 피처가 생기면 `State`에 프로퍼티를 추가하고 `body`에서 실제 로직을 구현하면 됩니다.
