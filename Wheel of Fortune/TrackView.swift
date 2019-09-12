//
// Created by admin on 2019-09-10.
// Copyright (c) 2019 Slava Kornienko. All rights reserved.
//

import UIKit

class TrackView: UIView {

    private var trackPoints = [CGPoint]()
    private var carImageImage: UIImageView!
    private var currentPath = CGMutablePath()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }

    private func initView() {
        let carImage = UIImage(named: "f1_car")!
        let imageView = UIImageView(image: carImage)
        imageView.frame = CGRect(origin: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2),
                                 size: CGSize(width: 30, height: 80))
        imageView.transform = imageView.transform.rotated(by: 90.0 * .pi / 180)
        self.addSubview(imageView)

        self.carImageImage = imageView
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let touch = touches.first else {
            return
        }

        let point = touch.location(in: self)
        print(point)

        self.trackPoints.append(point)
        self.updateCarPathAnimation()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }

        let point = touch.location(in: self)
        print(point)

        self.trackPoints.append(point)
        self.updateCarPathAnimation()

    }

    private func updateCarPathAnimation() {
        let animKey = "super key"

        let currentPoint: CGPoint = self.carImageImage.layer.presentation()?.position ?? self.carImageImage.layer.position

        self.currentPath = self.smoothPoints(SwiftSimplify.simplify([currentPoint] + self.trackPoints, tolerance: 0.5))
        self.currentPath.move(to: currentPoint)


        let pixelPerSec: CGFloat = 100
        let duration = TimeInterval(self.currentPath.length / pixelPerSec)

        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + duration) {
            objc_sync_enter(self)
            self.trackPoints.remove(at: 0)
            objc_sync_exit(self)
        }

        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = self.currentPath
        anim.duration = duration
        anim.calculationMode = .paced
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        anim.delegate = self
        anim.rotationMode = .rotateAuto

        self.carImageImage.layer.add(anim, forKey: animKey)
        self.setNeedsDisplay()
    }

    // https://stackoverflow.com/questions/8702696/drawing-smooth-curves-methods-needed
    private func smoothPoints(_ points: [CGPoint]) -> CGMutablePath {
        let bezierPath = CGMutablePath()
        var prevPoint: CGPoint?
        var isFirst = true

        for point in points {
            if let prevPoint = prevPoint {
                let midPoint = CGPoint(x: (point.x + prevPoint.x) / 2, y: (point.y + prevPoint.y) / 2)
                if isFirst {
                    bezierPath.addLine(to: midPoint)
                } else {
                    bezierPath.addQuadCurve(to: midPoint, control: prevPoint)
                }
                isFirst = false
            } else {
                bezierPath.move(to: point)
            }
            prevPoint = point
        }
        if let prevPoint = prevPoint {
            bezierPath.addLine(to: prevPoint)
        }
        return bezierPath
    }


    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        let bezierPath = UIBezierPath(cgPath: self.currentPath)
        ctx.setStrokeColor(UIColor.white.cgColor)
        bezierPath.lineWidth = 2
        bezierPath.stroke()
    }
}

extension TrackView: CAAnimationDelegate {

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.currentPath = CGMutablePath()
            self.setNeedsDisplay()
        }
    }
}