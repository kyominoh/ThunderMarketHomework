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
    private let configViewController = ConfigViewController()
    private lazy var pageViewControllers: [UIViewController] = [configViewController]
    var fakeViewControllers: [UIViewController] = []
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let alignChangeBtn: UIButton = UIButton(type: .system)
    var cellType: CellType = .full
    let viewModel = ContentViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupTabbar()
        self.setupPageViewController()
        self.setupFloatingButton()
    }
    func setupFloatingButton() {
        self.view.addSubview(alignChangeBtn)
        alignChangeBtn.addTarget(self, action: #selector(toggleAlign), for: .touchUpInside)
        alignChangeBtn.setTitle("정렬변경", for: .normal)
        alignChangeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(tabBar.snp.top).inset(50)
        }
    }
    
    private func setupTabbar() {
        let fakeOne = UIViewController()
        fakeOne.tabBarItem = UITabBarItem(title: "설정?", image: UIImage(systemName: "config"), tag: 0)
        fakeViewControllers.append(fakeOne)
        self.viewControllers = fakeViewControllers
        self.delegate = self
//        configViewController.onButtonTap = { [weak self] in
//            guard let self else { return }
//            let content = ContentDelegateTypeViewController()
//            self.pageViewControllers.append(content)
//            let fakeView = UIViewController()
//            fakeView.tabBarItem = UITabBarItem(title: "\(fakeViewControllers.count)", image: UIImage(systemName: "config"), tag: fakeViewControllers.count)
//            self.fakeViewControllers.append(fakeView)
//            self.viewControllers = self.fakeViewControllers
//        }
        
        addDelegateTypeView()
        addDifferableTypeView()
    }
    
    private func addDelegateTypeView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ContentDelegateTypeViewController") as? ContentDelegateTypeViewController {
            vc.contentDataSource = self
            self.pageViewControllers.append(vc)
            let fakeView = UIViewController()
            fakeView.tabBarItem = UITabBarItem(title: "\(fakeViewControllers.count)", image: UIImage(systemName: "config"), tag: fakeViewControllers.count)
            self.fakeViewControllers.append(fakeView)
            self.viewControllers = self.fakeViewControllers
        }
    }
    
    private func addDifferableTypeView() {
        let vc = ContentDifferableTypeViewController()
        self.pageViewControllers.append(vc)
        let fakeView = UIViewController()
        fakeView.tabBarItem = UITabBarItem(title: "\(fakeViewControllers.count)", image: UIImage(systemName: "config"), tag: fakeViewControllers.count)
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
        } else {
            cellType = .mini
        }
        self.pageViewControllers.forEach { vc in
            let viewCon = vc as? ContentViewAlignChange ?? nil
            if vc.viewIfLoaded != nil {
                viewCon?.toggleAlign(cellType: cellType)
            }
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

