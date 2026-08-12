//
//  StubCoordinator.swift
//  GeneralInterfaces
//
//  Created by Yago Marques on 10/08/26.
//
@testable import GeneralInterfaces
import UIKit

final class CoordinatorStub: CoordinatorProtocol {
    private(set) var startCalled = false
    private(set) var handledAction: CoordinatorActionProtocol?
    var navigationController: UINavigationController = .init()
    weak var parentCoordinator: CoordinatorProtocol?

    func start() {
        startCalled = true
    }

    func handle(_ action: CoordinatorActionProtocol) {
        handledAction = action
    }
}
