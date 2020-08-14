import Foundation

class Variable<Value> {
    var value: Value {
        didSet {
            onUpdate?(value)
        }
    }
    
    var onUpdate: ((Value) -> Void)? {
        didSet {
            onUpdate?(value)
        }
    }
    
    init(_ value: Value, _ onUpdate: ((Value) -> Void)? = nil) {
        self.value = value
        self.onUpdate = onUpdate
        self.onUpdate?(value)
    }
}
