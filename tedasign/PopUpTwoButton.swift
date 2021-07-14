//
//  PopUpTwoButton.swift
//  tedasign
//
//  Created by Manuchet Rungraksa on 9/7/2564 BE.
//

import Foundation
import UIKit

class PopUpTwoButton: UIView {
    
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var boxView: UIView!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomCon: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var touchCancel: (()->Void)?
    var touchAccept: (()->Void)?
    
    init(imageName: String? = nil, title: String? = nil, message: String, acceptButtonString:String, cancelButtonString:String, touchAccept: (()->Void)? = nil, touchCancel: (()->Void)? = nil) {
        let scene = UIApplication.shared.connectedScenes.first
        let window = (scene?.delegate as? SceneDelegate)?.window!
        
        super.init(frame: window!.frame)
        setup()
        
        if let imageName = imageName {
            self.imageView.image = UIImage(named: imageName)
        } else {
            self.imageViewHeightCon.constant = 0
            self.imageViewBottomCon.constant = 0
        }
        
        if let title = title {
            self.titleLabel.text = title
        } else {
            self.titleLabel.text = ""
        }
        
        self.messageLabel.text = message
        self.acceptButton.setTitle(acceptButtonString, for: .normal)
        self.cancelButton.setTitle(cancelButtonString, for: .normal)
        
        self.touchAccept = touchAccept
        self.touchCancel = touchCancel
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        // init inner view
        var view: UIView!
        view = Bundle.main.loadNibNamed("PopUpTwoButton", owner: self, options: nil)?[0] as! UIView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        // setup auto-layout
        let views = ["contentView": view]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: [], metrics: nil, views: views))
        
        self.overlayView.alpha = 0
        self.boxView.alpha = 0
        self.boxView.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        
    }
    
    func show() {
        
        let scene = UIApplication.shared.connectedScenes.first
        let window = (scene?.delegate as? SceneDelegate)?.window!
        self.backgroundColor = UIColor.clear
        window!.addSubview(self)
        
        // add to showing list
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.overlayView.alpha = 0.3
        }, completion: nil)
        
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseOut, animations: {
            self.boxView.alpha = 1
            self.boxView.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        }) { (complete) in
            UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseOut, animations: {
                self.boxView.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            }, completion: nil)
        }
        
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.overlayView.alpha = 0.0
        }) { (complete) in
            self.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseOut, animations: {
            self.boxView.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        }) { (complete) in
            UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseIn, animations: {
                self.boxView.alpha = 0
                self.boxView.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
            }, completion: nil)
        }
    }
    
    @IBAction func touchAcceptButton(_ sender: Any) {
        self.touchAccept?()
        self.hide()
    }
    
    @IBAction func touchCancelButton(_ sender: Any) {
        self.touchCancel?()
        self.hide()
    }
    
    
}


