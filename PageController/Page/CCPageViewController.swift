//
//  CCPageViewController.swift
//  MapboxDemo
//
//  Created by 程超 on 2022/9/18.
//

import UIKit

@objc protocol CCPageViewScrollDelegate: NSObjectProtocol {
    @objc optional func pageView(page: CCPageViewController,
                  scrollPercentage: CGFloat,
                  direction: UIPageViewController.NavigationDirection)
    @objc optional func pageView(page: CCPageViewController,
                  completeAtIndex: Int)
}

class CCPageViewController: UIPageViewController {

    weak var scrollDelegate: CCPageViewScrollDelegate?
    var controllers: [UIViewController]?
    var scrollView: UIScrollView?
    var currentIndex: Int?
    private var isAutoScroll: Bool = false
    
    convenience init(transitionStyle: UIPageViewController.TransitionStyle = .scroll,
                     orientation: UIPageViewController.NavigationOrientation,
                     controllers: [UIViewController]) {
        
        self.init(transitionStyle: transitionStyle, navigationOrientation: orientation)

        self.delegate = self
        self.dataSource = self
        self.controllers = controllers

        self.view.subviews.forEach { [weak self] subView in
            guard let self = self else {return}
            guard let scrollView = subView as? UIScrollView else { return }
            scrollView.delegate = self
            self.scrollView = scrollView
        }
    
        setController(at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func setController(at index: Int) {
        guard let controller = viewController(at: index) else {return}
        
        if let currentIndex = currentIndex {
            if index > currentIndex {
                isAutoScroll = true
                self.setViewControllers([controller],
                                        direction: .forward,
                                        animated: true) { [weak self] result in
                    guard let self = self else {return}
                    self.autoSelectComplete(at: index)
                }
            }
            if index < currentIndex {
                isAutoScroll = true
                self.setViewControllers([controller],
                                        direction: .reverse,
                                        animated: true) { [weak self] result in
                    guard let self = self else {return}
                    self.autoSelectComplete(at: index)
                }

            }
        } else {
            isAutoScroll = true
            self.setViewControllers([controller],
                                    direction: .reverse,
                                    animated: false) { [weak self] result in
                guard let self = self else {return}
                self.autoSelectComplete(at: index)
            }
        }
    }
    
    private func autoSelectComplete(at index: Int) {
        self.isAutoScroll = false
        self.currentIndex = index
        
        if let scrollDelegate = scrollDelegate {
            scrollDelegate.pageView?(page: self, completeAtIndex: index)
        }
    }
    
    private func viewController(at index: Int) -> UIViewController? {
        guard let controllers = controllers else {return nil}
        guard index < controllers.count && index >= 0 else {return nil}
        return controllers[index]
    }
    
    private func index(of controller: UIViewController) -> Int? {
        guard let controllers = controllers else {return nil}
        for (index, con) in controllers.enumerated() {
            if con == controller {
                return index
            }
        }
        return nil
    }
}

extension CCPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = index(of: viewController) else {return nil}
        if index == 0 {return nil}
        index -= 1
        return self.viewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = index(of: viewController) else {return nil}
        index += 1
        return self.viewController(at: index)
    }
}

extension CCPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isAutoScroll else {return}
        guard let currentIndex = currentIndex else {return}
        guard let controllers = controllers else {return}
        
        let maxWidth: CGFloat = view.width
        let x = scrollView.contentOffset.x
        if x == 0 && currentIndex > 0 {
            self.currentIndex = currentIndex - 1
        }
        
        if x == maxWidth * 2 && currentIndex < controllers.count-1 {
            self.currentIndex = currentIndex + 1
        }

        if x > maxWidth {
            if let scrollDelegate = scrollDelegate {
                let percentage = (x - maxWidth)/maxWidth
                scrollDelegate.pageView?(page: self, scrollPercentage: percentage, direction: .forward)
            }
        }
        
        if x < maxWidth {
            if let scrollDelegate = scrollDelegate {
                let percentage = (maxWidth - x)/maxWidth
                scrollDelegate.pageView?(page: self, scrollPercentage: percentage, direction: .reverse)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let scrollDelegate = scrollDelegate, let currentIndex = self.currentIndex {
            scrollDelegate.pageView?(page: self, completeAtIndex: currentIndex)
        }
    }
}
