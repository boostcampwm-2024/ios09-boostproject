//
//  GroupInfoViewModel.swift
//  Feature
//
//  Created by Yune gim on 11/6/24.
//

import Combine
import Domain
import DomainInterface

public class GroupInfoViewModel: ViewModelProtocol {
    typealias Input = GroupInfoViewInput
    typealias Output = GroupInfoViewOutput
    
    private var users = [DomainInterface.InvitedUser]()
    private var title: String = ""
    let usecase: UpdateGroupInfoUseCaseInterface
    
    public init(usecase: UpdateGroupInfoUseCaseInterface) {
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
                self?.output.send(.titleDidChanged(title: self?.title ?? ""))
            case .exitGroupButtonDidTab:
                self?.exitGroupButtonDidTab()
            }
        }
        .store(in: &cancellables)
        
        usecase.invitedUser.sink { [weak self] invitedUserResult in
            self?.userDidInvited(user: invitedUserResult)
        }
        .store(in: &cancellables)
        
        usecase.updatedUser.sink { [weak self] updatedUserResult in
            self?.userStateDidChanged(user: updatedUserResult)
        }
        .store(in: &cancellables)
        
        usecase.updatedTitle.sink { [weak self] updatedTitle in
            self?.title = updatedTitle
            self?.output.send(.titleDidChanged(title: updatedTitle))
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

private extension GroupInfoViewModel {
    func userStateDidChanged(user: DomainInterface.InvitedUser) {
        for index in users.indices {
            guard users[index].id == user.id else { continue }
            users[index].updateState(to: user.state)
        }
        output.send(.userStateDidChanged(user: user))
    }
    
    func userDidInvited(user: DomainInterface.InvitedUser) {
        users.append(user)
        output.send(.userDidInvited(user: user))
        output.send(.groupCountDidChanged(count: users.count))
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
    case groupCountDidChanged(count: Int)
    case titleDidChanged(title: String)
}

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    var output: PassthroughSubject<Output, Never> { get set }
    var cancellables: Set<AnyCancellable> { get set }
 
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
