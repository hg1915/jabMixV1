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
import FirebaseAuth
import SVProgressHUD
import MessageUI
import TwitterKit

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
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
    
    open func fbLogIn(_ viewController: UIViewController, token: FacebookProfile){
        let credential = FacebookAuthProvider.credential(withAccessToken: token.facebookToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else
                if let user = user {
                    print("\(user.displayName!) has been signed in with Facebook!")
                    
                    SVProgressHUD.dismiss()
                    
                    self.finish()
                    
                    viewController.present(instantiateMainTabBarViewController(), animated: true, completion: nil)
                    
                }
            
            
        }
    }
    
    open func twitterLogIn(_ viewController: UIViewController, token: String, secret: String, session: TWTRSession){
        let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else
                if let user = user {
                    print("\(user.displayName!) has been signed in with Twitter!")
                    
                    SVProgressHUD.dismiss()
                    
                    self.finish()
                    
                    updateUserSingleProperty(user: user, type: UserUpdate.firstLastName, stringValue: session.userName, imageValue: nil)
       
                    viewController.present(instantiateMainTabBarViewController(), animated: true, completion: nil)
                    
            }
         
        }
        
    }
    
    
    open func recoverPassword(email: String) {
        print("Implement this method in your subclass to handle password recovery.")
    }
    
    //MARK: Navigation
    func toPreferences(_ viewController: UIViewController, user: UserPass){
        navigationController.navigationController?.popViewController(animated: true)
        
        preferencesViewController.user = user
        guard let prefVC = _preferencesViewController else {
            fatalError("Trying to present a viewcontroller that is nil(_preferencesViewController)")}
        visibleViewController()?.navigationController?.pushViewController(prefVC, animated: true)
    }
    
    func toLogin(_ viewController: UIViewController){
        navigationController.navigationController?.popViewController(animated: true)
        navigationController.pushViewController(loginViewController, animated: true)
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
    
    func loginEmailPressed(_ viewController: UIViewController, email: String, pass: String) {
        
        guard let viewController = viewController as? LoginViewController else { return }
        
        if email.isEmpty || pass.isEmpty {
            
            let alertController = UIAlertController(title: "Error!", message: "Please fill in all the fields.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            viewController.present(alertController, animated: true, completion: nil)
            
        }else {
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
                
                if error == nil {
                    if let user = user {
                        print("\(user.displayName!) has been signed in")
                        
                        SVProgressHUD.dismiss()
                        
                        viewController.present(instantiateMainTabBarViewController(), animated: true, completion: nil)
                        
                    }else{
                        SVProgressHUD.dismiss()
                        print("error")
                        
                        
                        
                        print(error?.localizedDescription as Any)
                    }
                }
                else {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Low Blow!", message: "Incorrect Credentials", preferredStyle: .alert)
                    
                    
                    let action1 = UIAlertAction(title: "Contact Support", style: .default, handler: { (action) -> Void in
                        
                        let mailComposeViewController = viewController.configuredMailComposeViewController()
                        if MFMailComposeViewController.canSendMail() {
                            viewController.present(mailComposeViewController, animated: true, completion: nil)
                        } else {
                            viewController.showSendMailErrorAlert()
                        }
                        
                        print("ACTION 1 selected!")
                    })
                    
                    
                    
                    // Cancel button
                    let cancel = UIAlertAction(title: "Try Again", style: .default , handler: { (action) -> Void in })
                    
                    
                    // Add action buttons and present the Alert
                    alert.addAction(action1)
                    alert.addAction(cancel)
                    viewController.present(alert, animated: true, completion: nil)
                    
                    
                }
            }
        }
    }
    
    func facebookLoginPressed(_ viewController: UIViewController) {
        facebookService.login(from: viewController) { (result) in
            switch result {
            case .success(let profile):
                self.fbLogIn(viewController, token: profile)
            case .error(let err):
                viewController.createAlert(title: "Error", message: err.localizedDescription)
            case .missingPermissions:
                print("Missing permissions!")
            case .unknownError:
                viewController.createAlert(title: "Error", message: "Could not log you in!")
            case .cancelled:
                print("Cancelled")
            }
        }
    }
    
    func twitterLoginPressed(_ viewContoller: UIViewController) {
        
        TWTRTwitter.sharedInstance().logIn(completion: { session, error in
           
            if let session = session {
                // Successful log in with Twitter
                let authToken = session.authToken
                let authTokenSecret = session.authTokenSecret
                
                print("signed in as \(session.userName)");
                let info = "Username: \(session.userName) \n User ID: \(session.userID)"
                self.twitterLogIn(viewContoller, token: authToken, secret: authTokenSecret, session: session)
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
    }
    
    
    
    
}

