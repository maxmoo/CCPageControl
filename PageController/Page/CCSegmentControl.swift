//
//  CCSegmentControl.swift
//  MapboxDemo
//
//  Created by 程超 on 2022/9/18.
//

import UIKit

class CCSegmentItem: UIButton {
    
    var select: Bool = false {
        didSet {
            if select {
                self.setTitleColor(.red, for: .normal)
            } else {
                self.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        self.setTitle(title, for: .normal)
    }
}

@objc protocol CCSegmentControlDelegate: NSObjectProtocol {
    @objc optional func segment(segment: CCSegmentControl, selectAt index: Int)
}

enum CCSegmentControlStyle {
    case auto
    case average
}

class CCSegmentControl: UIView {

    weak var delegate: CCSegmentControlDelegate?
    
    private lazy var bottomFlag: UIView = {
        let view = UIView(frame: CGRect(x: 0,
                                        y: self.height - bottomFlagHeight,
                                        width: 30,
                                        height: bottomFlagHeight))
        view.backgroundColor = .red
        return view
    }()
    
    private let bottomFlagHeight: CGFloat = 5
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: self.bounds)
        scroll.showsHorizontalScrollIndicator = false
        scroll.height = scroll.height
        return scroll
    }()
    
    private var items: [CCSegmentItem] = []
    
    private var currentIndex: Int = 0
    
    private var animating: Bool = false
    
    convenience init(frame: CGRect, titles: [String], style: CCSegmentControlStyle = .auto) {
        self.init(frame: frame)
        self.addSubview(scrollView)
        createContentView(titles: titles, style: style)
    }
    
    private func createContentView(titles: [String], style: CCSegmentControlStyle) {
        var items: [CCSegmentItem] = []
        let font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        var maxWidth: CGFloat = 0
        let gap: CGFloat = 10
        var itemWidth: CGFloat = (self.width - CGFloat(titles.count+1)*gap)/CGFloat(titles.count)
        
        for (index, title) in titles.enumerated() {
            if style == .auto {
                itemWidth = title.ex_width(font: font) + 20
            }
            let item = CCSegmentItem(frame: CGRect(x: maxWidth + gap, y: 0, width: itemWidth, height: scrollView.height - bottomFlagHeight), title: title)
            item.backgroundColor = .purple
            item.titleLabel?.font = font
            item.tag = index
            item.addTarget(self, action: #selector(itemSelect(_:)), for: .touchUpInside)
            maxWidth = item.right
            scrollView.addSubview(item)
            items.append(item)
        }
        self.items = items
        scrollView.addSubview(bottomFlag)
        scrollView.contentSize = CGSize(width: maxWidth + gap, height: scrollView.height)
        selectAtIndex(0, auto: true)
    }
    
    private func selectAtIndex(_ index: Int, auto: Bool = false) {
        guard index < items.count && index >= 0 else {return}
        guard !animating else {return}
        
        for (ind, item) in items.enumerated() {
            if ind == index {
                item.select = true
                scrollAtItem(item)
                bottomFlagMoveTo(index)
                currentIndex = index
            } else {
                item.select = false
            }
        }
        
        if !auto {
            if let delegate = delegate {
                delegate.segment?(segment: self, selectAt: currentIndex)
            }
        }
    }
    
    @objc func itemSelect(_ sender: CCSegmentItem) {
        selectAtIndex(sender.tag)
    }
    
    private func scrollAtItem(_ item: CCSegmentItem) {
        let x = item.centerX
        var offSetX = x > scrollView.width/2 ? x - scrollView.width/2 : 0
        if offSetX > scrollView.contentSize.width - scrollView.width {
            offSetX = scrollView.contentSize.width - scrollView.width
        }
        scrollView.setContentOffset(CGPoint(x: offSetX , y: 0), animated: true)
    }
    
    private func bottomFlagMoveTo(_ index: Int, animate: Bool = true) {
        guard index >= 0 && index < items.count else {return}
        animating = true
        let centerX = self.items[index].centerX
        UIView.animate(withDuration: 0.3) {
            self.bottomFlag.centerX = centerX
        } completion: { _ in
            self.animating = false
        }
    }
    
    func moveTo(_ index: Int, percentage: CGFloat) {
        guard index < items.count && index >= 0 else {return}
        // item move 待补充
        let currentItem = items[currentIndex]
        // bottom flag
        let indexItem = items[index]
        
        let aimX = (indexItem.centerX - currentItem.centerX) * percentage + currentItem.centerX
        UIView.animate(withDuration: 0.02) {
            self.bottomFlag.centerX = aimX
            if percentage >= 1 {
                self.selectAtIndex(index, auto: true)
            }
        }
    }
    
    func moveTo(_ direction: UIPageViewController.NavigationDirection,
                percentage: CGFloat) {
        
        if direction == .forward {
            moveTo(currentIndex + 1, percentage: percentage)
        } else {
            moveTo(currentIndex - 1, percentage: percentage)
        }
    }
    
}
