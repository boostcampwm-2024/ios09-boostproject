//
//  MovieEditViewController.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import Combine
import SnapKit
import UIKit

public final class SharedMovieEditViewController: UIViewController {
    private let viewModel: SharedVideoEditViewModel
    private let input = PassthroughSubject<SharedVideoEditViewInput, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let moviePlayerView = VideoPlayerView()
    
    public init(viewModel: SharedVideoEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchies()
        setupViewConstraints()
        setupViewAttributes()
        setupViewBinding()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

private extension SharedMovieEditViewController {
    enum Constants {
        static let topMargin: CGFloat = 14
        static let playerViewRatio: CGFloat = 9 / 16
    }
}

private extension SharedMovieEditViewController {
    func setupViewHierarchies() {
        view.addSubview(moviePlayerView)
    }
    
    func setupViewConstraints() {
        moviePlayerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(moviePlayerView.snp.width).multipliedBy(Constants.playerViewRatio)
        }
    }
    
    func setupViewAttributes() {
        view.backgroundColor = .black
    }
    
    func setupViewBinding() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { output in
            }
            .store(in: &cancellables)
    }
}
