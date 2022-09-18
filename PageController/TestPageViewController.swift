//
//  TestPageViewController.swift
//  MapboxDemo
//
//  Created by 程超 on 2022/9/18.
//

import UIKit

class TestPageViewController: UIViewController {

    let titles: [String] = ["娱乐","动漫","巨精彩的电影","体育","controller","demos"]
    
    lazy var page: CCPageViewController = {
        var vcs: [UIViewController] = []
        for title in titles {
            let vc = TestViewController()
            vc.info = title
            vcs.append(vc)
        }
        
        let page = CCPageViewController(orientation: .horizontal,
                                        controllers: vcs)
        page.scrollDelegate = self
        return page
    }()
    
    lazy var segment: CCSegmentControl = {
        let seg = CCSegmentControl(frame: CGRect(x: 0, y: 140, width: view.width, height: 40),
                                   titles: titles,
                                   style: .auto)
        seg.backgroundColor = .lightGray
        seg.delegate = self
        return seg
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(segment)
        
        self.addChild(page)
        page.view.frame = CGRect(x: 0, y: 180, width: view.width, height: 400)
        self.view.addSubview(page.view)
    }

}

extension TestPageViewController: CCPageViewScrollDelegate {
    
    func pageView(page: CCPageViewController, scrollPercentage: CGFloat, direction: UIPageViewController.NavigationDirection) {
        segment.moveTo(direction, percentage: scrollPercentage)
    }

}

extension TestPageViewController: CCSegmentControlDelegate {
    
    func segment(segment: CCSegmentControl, selectAt index: Int) {
        page.setController(at: index)
    }
}
