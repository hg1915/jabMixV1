//
//  LoginCoordinator.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/17/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

protocol FBTwitterCredentials: class{
    var fbToken: String? { get }
    var twitterToken: String? { get }
}

protocol UserInformation{
    var email: String? { get }
    var uid: String? { get }
    var ref: DatabaseReference? { get }
    var location: String? { get}
    var photoURL: String? { get }
    var biography: String? { get }
    var key: String? { get }
    var firstLastName: String? { get }
    var interests: String? { get }
    var password: String? { get }
}

open class LoginCoordinator: FBTwitterCredentials {
    
    
    // MARK: - Properties
    
    public let window: UIWindow?
    
    public let rootViewController: UIViewController?
    
    public var fbToken: String?
    public var twitterToken: String?
    
    // MARK: Private
    
    fileprivate static let bundle = Bundle(for: InitialViewController.self)
    
    // MARK: View Controller's
    
    fileprivate var navigationController: UINavigationController {
        if _navigationController == nil {
            _navigationController = UINavigationController(rootViewController: self.initialViewController)
        }
        return _navigationController!
    }
    
    private var _navigationController: UINavigationController?
    
    fileprivate var initialViewController: SignUpViewController {
        if _initialViewController == nil {
            let viewController = instantiateSignUpViewController()
            viewController.delegate = self
            
            _initialViewController = viewController
        }
        return _initialViewController!
    }
    
    fileprivate var _initialViewController: SignUpViewController?
    
    
    fileprivate var loginViewController: LoginViewController {
        if _loginViewController == nil {
            let viewController = instantiateLoginViewController()
            viewController.delegate = self
            _loginViewController = viewController
        }
        return _loginViewController!
    }
    
    fileprivate var _loginViewController: LoginViewController?
    
    
    fileprivate var preferencesViewController: PreferencesViewController {
        if _preferencesViewController == nil {
            let viewController = instantiatePreferencesViewController()
            viewController.delegate = self
            _preferencesViewController = viewController
        }
        return _preferencesViewController!
    }
    
    fileprivate var _preferencesViewController: PreferencesViewController?
    
    
    // MARK: Services
    
    public lazy var facebookService = FacebookService()
    
    // MARK: - LoginCoordinator
    
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.window = nil
    }
    
    public init(window: UIWindow) {
        self.window = window
        self.rootViewController = nil
    }
    
    open func start() {
        if let rootViewController = rootViewController {
            rootViewController.present(navigationController, animated: true, completion: nil)
        } else if let window = window {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
    
    open func noUsername(){
        start()
        //        goToSignup()
    }
    
    open func finish() {
        if let rootViewController = rootViewController {
            rootViewController.dismiss(animated: true, completion: nil)
        }
        
        _navigationController = nil
        _initialViewController = nil
        _loginViewController = nil
        _preferencesViewController = nil
        
    }
    
    public func visibleViewController() -> UIViewController? {
        return navigationController.topViewController
    }
    
    // MARK: - Callbacks, Meant to be subclassed
    
    open func login(email: String, password: String) {
        print("Implement this method in your subclass to handle login.")
    }
    
    open func signup(name: String, email: String, password: String) {
        print("Implement this method in your subclass to handle signup.")
        
    }
    
    open func fbSignUp(token: FacebookProfile){
        
    }
    
    open func recoverPassword(email: String) {
        print("Implement this method in your subclass to handle password recovery.")
    }
    
    //MARK: Navigation
    func toPreferences(_ viewController: UIViewController, user: UserPass){
        visibleViewController()?.navigationController?.popViewController(animated: true)
        _preferencesViewController?.user = user
        guard let prefVC = _preferencesViewController else {
            fatalError("Trying to present a viewcontroller that is nil(_preferencesViewController)")}
        visibleViewController()?.navigationController?.pushViewController(prefVC, animated: true)
    }
    
    func toLogin(_ viewController: UIViewController){
        visibleViewController()?.navigationController?.popViewController(animated: true)
        visibleViewController()?.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    
}

extension LoginCoordinator: SignUpViewControllerDelegate{
    func loginButtonPressed(_ viewcontroller: UIViewController) {
        toLogin(viewcontroller)
    }
    
    func signUpButtonPressed(_ viewcontroller: UIViewController, user: UserPass) {
        toPreferences(viewcontroller, user: user)
    }
    
    
}

extension LoginCoordinator: PreferencesViewControllerDelegate{
    
}

extension LoginCoordinator: LoginViewControllerDelegate{
    
}

