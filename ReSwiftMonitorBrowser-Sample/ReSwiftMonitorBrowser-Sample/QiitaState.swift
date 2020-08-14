import Foundation
import ReSwift

struct QiitaState: StateType {
    var isLoading = false
    var error: Error?
    var qiitaObjects: [QiitaObject] = []
}

extension QiitaState {
    static func reducer(action: Action, state: QiitaState?) -> QiitaState {
        var state = state ?? QiitaState()
        guard let action = action as? QiitaActionEnum else {
            return state
        }
        
        switch action {
        case .isLoading(let _isLoading):
            state.isLoading = _isLoading
        case .error(let _error):
            state.error = _error
        case .responseQiitaObjects(let array):
            state.qiitaObjects = array
        }
        return state
    }
}

enum QiitaActionEnum: Action {
    case error(Error)
    case isLoading(Bool)
    case responseQiitaObjects([QiitaObject])
}
