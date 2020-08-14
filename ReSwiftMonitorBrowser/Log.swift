import Foundation
import os.log

private var formatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = .behavior10_4
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    return dateFormatter
}()

func logMessage(message: String, filename: String = #file, line: Int = #line, function: String = #function) {
    let dateAndTime = formatter.string(from: Date())
    let lastPathComponent = URL(fileURLWithPath: filename).lastPathComponent

    let formattedLog = "\(dateAndTime) | \(lastPathComponent):\(line): ( \(function) ): \(message)"
    os_log("%@", formattedLog)
}
