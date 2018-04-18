//
//  InstantiateViewController.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/17/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import Foundation



func instantiateMainTabBarViewController() -> NewTabBarViewController{
    
    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: NewTabBarViewController.identifier) as? NewTabBarViewController{
        return viewController
        
    }
    return UIViewController() as! NewTabBarViewController
}

func instantiateSignUpViewController() -> SignUpViewController{
    
    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: SignUpViewController.identifier) as? SignUpViewController{
        return viewController
        
    }
    return UIViewController() as! SignUpViewController
}

func instantiateLoginViewController() -> LoginViewController{
    
    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: LoginViewController.identifier) as? LoginViewController{
        return viewController
        
    }
    return UIViewController() as! LoginViewController
}

func instantiatePreferencesViewController() -> PreferencesViewController{
    
    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PreferencesViewController.identifier) as? PreferencesViewController{
        return viewController
        
    }
    return UIViewController() as! PreferencesViewController
}

