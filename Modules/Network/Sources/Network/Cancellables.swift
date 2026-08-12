import Foundation
import NetworkInterfaces

struct URLSessionTaskCancellable: CancellableProtocol {
    let task: URLSessionTask
    func cancel() { task.cancel() }
}

struct NoopCancellable: CancellableProtocol {
    func cancel() {}
}
