import Foundation
/// https://qiita.com/marty-suzuki/items/496f211e22cad1f8de19
extension DispatchQueue {
    func debounce(delay: DispatchTimeInterval) -> (_ action: @escaping () -> Void) -> Void {
        var lastFireTime: DispatchTime = .now()

        return { [weak self, delay] action in
            let deadline: DispatchTime = .now() + delay
            lastFireTime = .now()
            self?.asyncAfter(deadline: deadline) { [delay] in
                let now: DispatchTime = .now()
                let when: DispatchTime = lastFireTime + delay
                if now < when { return }
                lastFireTime = .now()
                action()
            }
        }
    }
    
    func throttle(delay: DispatchTimeInterval) -> (_ action: @escaping () -> Void) -> Void {
        var lastFireTime: DispatchTime = .now()

        return { [weak self, delay] action in
            let deadline: DispatchTime = .now() + delay
            self?.asyncAfter(deadline: deadline) { [delay] in
                let now: DispatchTime = .now()
                let when: DispatchTime = lastFireTime + delay
                if now < when { return }
                lastFireTime = .now()
                action()
            }
        }
    }
}
