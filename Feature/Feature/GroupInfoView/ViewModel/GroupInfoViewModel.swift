//
//  GroupInfoViewModel.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine
import Domain
import DomainInterface

class GroupInfoViewModel: ViewModelProtocol {
    typealias Input = GroupInfoViewInput
    typealias Output = GroupInfoViewOutput
    
    let usecase: UpdateGroupInfoUseCaseInterface
    
    init(usecase: UpdateGroupInfoUseCaseInterface) {
        self.usecase = usecase
    }
    
    public convenience init() {
        let usecase = UpdateGroupInfoUseCase(title: "우리들의 추억 만들기")
        self.init(usecase: usecase)
    }
    
    var output = PassthroughSubject<GroupInfoViewOutput, Never>()
    var cancellables: Set<AnyCancellable> = []
    
    func transform(input: AnyPublisher<GroupInfoViewInput, Never>) -> AnyPublisher<GroupInfoViewOutput, Never> {
        input.sink { [weak self] inputResult in
            switch inputResult {
            case .viewDidLoad:
                self?.userStateDidChanged()
            case .exitGroupButtonDidTab:
                self?.exitGroupButtonDidTab()
            }
        }
        .store(in: &cancellables)
        
        usecase.invitedUser.sink { [weak self] invitedUserResult in
            self?.output.send(.userDidInvited(user: invitedUserResult))
        }
        .store(in: &cancellables)
        usecase.updatedUser.sink { [weak self] updatedUserResult in
            self?.output.send(.userStateDidChanged(user: updatedUserResult))
        }
        .store(in: &cancellables)
        usecase.updatedTitle.sink { [weak self] updatedTitle in
            self?.output.send(.titleDidChanged(title: updatedTitle))
        }
        .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

private extension GroupInfoViewModel {
    func userStateDidChanged() {
        output.send(.userStateDidChanged(user: InvitedUser(id: "건우",
                                                     name: "건우",
                                                     state: .notConnected)))
    }
    
    func exitGroupButtonDidTab() { }
}

enum GroupInfoViewInput {
    case viewDidLoad
    case exitGroupButtonDidTab
}

enum GroupInfoViewOutput {
    case userStateDidChanged(user: DomainInterface.InvitedUser)
    case userDidInvited(user: DomainInterface.InvitedUser)
    case titleDidChanged(title: String)
}

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    var output: PassthroughSubject<Output, Never> { get set }
    var cancellables: Set<AnyCancellable> { get set }
 
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
