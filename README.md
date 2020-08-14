# ReSwiftMonitorBrowser
- ReSwiftMonitor Browser for iOS, Mac OS. This project is heavily inspired by the [FluxorExplorer](https://github.com/FluxorOrg/FluxorExplorer).
- [ReSwiftMonitor](https://github.com/t-osawa-009/ReSwiftMonitor) plugin is required
<img src="https://github.com/t-osawa-009/ReSwiftMonitorBrowser/blob/master/assets/mac.png?raw=true" width="500">

## Usage
- Implementing ReSwiftMonitor
```swift
var middleware: [Middleware<AppState>] = {
    let monitorMiddleware = MonitorMiddleware.make(configuration: Configuration())
    let browserMiddleware = BrowserMiddleware.make()
    #if DEBUG
    return [monitorMiddleware, browserMiddleware]
    #elseif
    return []
    #endif
}()

let store = Store<AppState>(reducer: AppState.reducer(), state: AppState(), middleware: middleware)
```
- Launch your Reswift application
- Launch ReSwiftMonitorBrowser
- Allow network with each device by alert

## CONTRIBUTING
There's still a lot of work to do here. We would love to see you involved. You can find all the details on how to get started in the [Contributing Guide](https://github.com/t-osawa-009/ReSwiftMonitorBrowser/blob/master/CONTRIBUTING.md).

## License
ReSwiftMonitorBrowser is released under the MIT license. See LICENSE for details.
