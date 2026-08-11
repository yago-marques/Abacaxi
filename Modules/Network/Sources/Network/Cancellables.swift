import Foundation
import NetworkInterfaces

struct URLSessionTaskCancellable: Cancellable {
    let task: URLSessionTask
    func cancel() { task.cancel() }
}

struct NoopCancellable: Cancellable {
    func cancel() {}
}
