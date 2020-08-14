import Foundation
import ReSwift

struct AppState: StateType {
    var qiitaState = QiitaState()
    static func reducer() -> Reducer<AppState> {
        return { action, state in
            var state = state ?? AppState()
            state.qiitaState = QiitaState.reducer(action: action, state: state.qiitaState)
            return state
        }
    }
}
