//
//  UIViewController.swift
//  Permnt
//
//  Created by Harry on 15/07/19.
//  Copyright © 2019 Permnt. All rights reserved.
//

import UIKit

extension UIViewController
{
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func pushViewController(Storyboard:String,ViewController:String, animation:Bool)
    {
        let storyBoard = UIStoryboard(name: Storyboard, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: ViewController)
        self.navigationController?.pushViewController(vc, animated: animation)
    }
    
    //MARK:- Activity
    func showIndicator(view: UIView) {
        let container: UIView = UIView()
        container.tag = 555
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        
        container.frame = view.bounds
        container.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3022527825)
        
        activityIndicator.frame = CGRect (x: 0, y: 0, width: 80, height: 80)
        activityIndicator.style = .whiteLarge
        activityIndicator.center = container.center
        activityIndicator.hidesWhenStopped = true
        
        DispatchQueue.main.async {
            container.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            view.addSubview(container)
        }
    }
    
    func hideIndicator(view: UIView) {
        DispatchQueue.main.async {
            view.viewWithTag(555)?.removeFromSuperview()
        }
    }
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        present(viewControllerToPresent, animated: false)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false)
    }
}

public func loadViewController(Storyboard:String,ViewController:String) -> UIViewController
{
    let storyBoard = UIStoryboard(name: Storyboard, bundle: nil)
    let vc = storyBoard.instantiateViewController(withIdentifier: ViewController)
    return vc
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
