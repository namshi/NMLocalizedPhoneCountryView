//
//  NMExtensions.swift
//  NMLocalizedPhoneCountryView
//
//  Updated by Mobile Team of Namshi on 03/10/2018.
//  Originally created as CountryPickerView by Kizito Nwose on 18/09/2017.
//  Copyright © 2018 NAMSHI. All rights reserved.
//

import UIKit

extension UIWindow {
    var topViewController: UIViewController? {
        guard var top = rootViewController else {

            return nil
        }
        while let next = top.presentedViewController {
            top = next
        }

        return top
    }
}

extension UINavigationController {
    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
