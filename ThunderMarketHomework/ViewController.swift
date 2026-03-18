//
//  ViewController.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/17/26.
//

import SnapKit
import UIKit

class ViewController: UITabBarController {
    private let vcOne = TabOneViewController()
    private let vcTwo = TabTwoViewController()
    private lazy var subViews = [vcOne, vcTwo]
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupTabbar()
        self.setupPageViewController()
    }
    
    private func setupTabbar() {
        let fakeOne = UIViewController()
        fakeOne.tabBarItem = UITabBarItem(title: "MAN", image: UIImage(systemName: "person"), tag: 0)
        let fakeTwo = UIViewController()
        fakeTwo.tabBarItem = UITabBarItem(title: "WOMAN", image: UIImage(systemName: "person.fill"), tag: 1)
        self.viewControllers = [fakeOne, fakeTwo]
        self.delegate = self
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
        pageViewController.setViewControllers([subViews[0]], direction: .forward, animated: false)
    }
}

extension ViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController),
              index != selectedIndex else { return false }
        let direction: UIPageViewController.NavigationDirection = index > selectedIndex ? .forward : .reverse
        pageViewController.setViewControllers([subViews[index]], direction: direction, animated: true)
        self.selectedIndex = index
        return false
    }
}

extension ViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = subViews.firstIndex(of: viewController), index > 0 else { return nil }
        return subViews[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = subViews.firstIndex(of: viewController), index < subViews.count - 1 else { return nil }
        return subViews[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed { 
            if let currentVC = pageViewController.viewControllers?.first,
               let index = subViews.firstIndex(of: currentVC) {
                self.selectedIndex = index
            }
        }
    }
}
