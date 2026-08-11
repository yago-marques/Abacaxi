//
//  StubCoordinator.swift
//  GeneralInterfaces
//
//  Created by Yago Marques on 10/08/26.
//
@testable import GeneralInterfaces
import UIKit

final class CoordinatorStub: Coordinator {
    private(set) var startCalled = false
    private(set) var handledAction: CoordinatorAction?
    var navigationController: UINavigationController = .init()

    func start() {
        startCalled = true
    }

    func handle(_ action: CoordinatorAction) {
        handledAction = action
    }
}
