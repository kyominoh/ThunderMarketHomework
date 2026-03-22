//
//  ViewController.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/17/26.
//

import SnapKit
import UIKit

struct ContentViewModel {
    let usecase = RandomUsecase()
    public func fetchData(page: Int, param: RandomUserParam) async throws -> RandomResponse<RandomData> { 
        try await self.usecase.fetchData(page: page, param: param)
    }
}

class ViewController: UITabBarController {
    lazy var pageViewControllers: [UIViewController] = []
    var fakeViewControllers: [UIViewController] = []
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let alignChangeBtn: UIButton = UIButton(type: .system)
    var cellType: CellType = .full
    let viewModel = ContentViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupTabbar()
//        addConfigView()
        addDelegateTypeView()
        addDifferableTypeView()
        self.setupPageViewController()
        self.setupFloatingButton()
    }
    func setupFloatingButton() {
        self.view.addSubview(alignChangeBtn)
        alignChangeBtn.addTarget(self, action: #selector(toggleAlign), for: .touchUpInside)
        alignChangeBtn.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        alignChangeBtn.tintColor = .white
        alignChangeBtn.backgroundColor = .systemBlue
        alignChangeBtn.layer.cornerRadius = 10
        alignChangeBtn.clipsToBounds = true
        alignChangeBtn.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        alignChangeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(self.tabBar.snp.top).inset(-20)
        }
    }
    
    private func setupTabbar() {
        self.viewControllers = fakeViewControllers
        self.delegate = self
    }
    
    private func addConfigView() {
        let configViewController = ConfigViewController()
        let fakeOne = UIViewController()
        fakeOne.tabBarItem = UITabBarItem(title: "설정?", image: UIImage(systemName: "config"), tag: 0)
        fakeViewControllers.append(fakeOne)
        self.pageViewControllers.append(configViewController)
        self.viewControllers = self.fakeViewControllers
        configViewController.onButtonTap = { [weak self] in
            guard let self else { return }
            let content = ContentDelegateTypeViewController()
            self.pageViewControllers.append(content)
            let fakeView = UIViewController()
            fakeView.tabBarItem = UITabBarItem(title: "\(fakeViewControllers.count)", image: UIImage(systemName: "list.bullet"), tag: fakeViewControllers.count)
            self.fakeViewControllers.append(fakeView)
            self.viewControllers = self.fakeViewControllers
        }
    }
    
    private func addDelegateTypeView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ContentDelegateTypeViewController") as? ContentDelegateTypeViewController {
            vc.contentDataSource = self
            let nav = UINavigationController(rootViewController: vc)
            self.pageViewControllers.append(nav)
            let fakeView = UIViewController()
            fakeView.tabBarItem = UITabBarItem(title: "Delegate+Rx", image: UIImage(systemName: "list.star"), tag: fakeViewControllers.count)
            self.fakeViewControllers.append(fakeView)
            self.viewControllers = self.fakeViewControllers
        }
    }
    
    private func addDifferableTypeView() {
        let vc = ContentDifferableTypeViewController()
        self.pageViewControllers.append(vc)
        let fakeView = UIViewController()
        fakeView.tabBarItem = UITabBarItem(title: "Diff+TCA", image: UIImage(systemName: "list.bullet"), tag: fakeViewControllers.count)
        self.fakeViewControllers.append(fakeView)
        self.viewControllers = self.fakeViewControllers
    }
    
    private func setupPageViewController() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(tabBar.snp.top)
        }
        pageViewController.setViewControllers([pageViewControllers[0]], direction: .forward, animated: false)
    }
    
    @objc func toggleAlign() {
        if cellType == .mini { 
            cellType = .full
            alignChangeBtn.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        } else {
            cellType = .mini
            alignChangeBtn.setImage(UIImage(systemName: "rectangle.grid.1x2"), for: .normal)
        }
        self.pageViewControllers.forEach { vc in
            let target = (vc as? UINavigationController)?.topViewController ?? vc
            guard let viewCon = target as? ContentViewAlignChange,
                  target.viewIfLoaded != nil else { return }
            viewCon.toggleAlign(cellType: cellType)
        }
    }
}

protocol ContentViewAlignChange {
    func toggleAlign(cellType: CellType)
}

protocol ContentViewDataSource {
    func getData(page: Int, param: RandomUserParam) async throws -> RandomResponse<RandomData>
}

extension ViewController: ContentViewDataSource {
    func getData(page: Int, param: RandomUserParam) async throws -> RandomResponse<RandomData> {
        try await self.viewModel.fetchData(page: page, param: param)
    }
}

extension ViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController),
              index != selectedIndex else { return false }
        let direction: UIPageViewController.NavigationDirection = index > selectedIndex ? .forward : .reverse
        pageViewController.setViewControllers([pageViewControllers[index]], direction: direction, animated: true)
        self.selectedIndex = index
        return false
    }
}

extension ViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageViewControllers.firstIndex(of: viewController), index > 0 else { return nil }
        return pageViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pageViewControllers.firstIndex(of: viewController), index < pageViewControllers.count - 1 else { return nil }
        return pageViewControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed { 
            if let currentVC = pageViewController.viewControllers?.first,
               let index = pageViewControllers.firstIndex(of: currentVC) {
                self.selectedIndex = index
            }
        }
    }
}

