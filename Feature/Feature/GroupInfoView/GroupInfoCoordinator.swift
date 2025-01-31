//
//  GroupInfoCoordinator.swift
//  Feature
//
//  Created by 이숲 on 12/5/24.
//

import Core
import UIKit

public protocol GroupInfoListener: AnyObject {
    func exitGroupButtonDidTap()
}

final class GroupInfoCoordinator: Coordinator, GroupInfoCoordinatable {
    weak var listener: GroupInfoListener?
    private let viewModel: GroupInfoViewModel

    init(viewModel: GroupInfoViewModel) {
        self.viewModel = viewModel
        let viewController = GroupInfoViewController(viewModel: viewModel)
        super.init(viewController: viewController)
        viewModel.coordinator = self
    }

    func exitGroupButtonDidTap() {
        listener?.exitGroupButtonDidTap()
    }
}
