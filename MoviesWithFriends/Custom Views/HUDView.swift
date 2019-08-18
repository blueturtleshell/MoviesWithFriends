//
//  HUDView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/1/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class HUDView: UIView {

    enum AccessoryType {
        case none
        case image(imageName: String)
        case activityIndicator
    }

    var text = ""
    var accessoryType: AccessoryType = .none

    class func hud(inView view: UIView, animated: Bool) -> HUDView {
        let hudView = HUDView(frame: view.bounds)
        hudView.isOpaque = false

        view.addSubview(hudView)
        view.isUserInteractionEnabled = false

        hudView.show(animated: animated)
        return hudView
    }

    func remove(from view: UIView) {
        removeFromSuperview()
        view.isUserInteractionEnabled = true
    }

    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 120
        let boxHeight: CGFloat = 120

        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)

        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()

        switch accessoryType {
        case .image(let imageName):
            if let image = UIImage(named: imageName) {
                let imagePoint = CGPoint(
                    x: center.x - round(image.size.width / 2),
                    y: center.y - round(image.size.height / 2) - boxHeight / 8)
                image.draw(at: imagePoint)
            }
        case .activityIndicator:
            let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            addSubview(activityIndicator)
            activityIndicator.center = CGPoint(x: center.x, y: center.y - (activityIndicator.frame.height / 2))
            activityIndicator.startAnimating()
        default:
            break
        }

        let attribs = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                        NSAttributedString.Key.foregroundColor: UIColor.white ]

        let textSize = text.size(withAttributes: attribs)

        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)

        text.draw(at: textPoint, withAttributes: attribs)
    }

    private func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5, options: [], animations: {
                            self.alpha = 1
                            self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}
