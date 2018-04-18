//
//  FacebookService.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/17/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin

public typealias FacebookCompletion = (FacebookResult) -> Void

public enum FacebookResult {
    
    case success(FacebookProfile)
    case error(Error)
    case missingPermissions
    case unknownError
    case cancelled
    
}

public struct FacebookProfile {
    
    public let facebookId: String
    
    public let facebookToken: String
    
    public let firstName: String
    
    public let lastName: String
    
    public let email: String
    
    public let profilePictureUrl: String
    
    public var fullName: String {
        return firstName + " " + lastName
    }
    
}

struct MyProfileRequest: GraphRequestProtocol {
    struct Response: GraphResponseProtocol {
        
        var name: String?
        var id: String?
        var gender: String?
        var email: String?
        var profilePictureUrl: String?
        
        init(rawResponse: Any?) {
            // Decode JSON from rawResponse into other properties here.
            guard let response = rawResponse as? Dictionary<String, Any> else {
                return
            }
            
            if let name = response["name"] as? String {
                self.name = name
            }
            
            if let id = response["id"] as? String {
                self.id = id
            }
            
            if let gender = response["gender"] as? String {
                self.gender = gender
            }
            
            if let email = response["email"] as? String {
                self.email = email
            }
            
            if let picture = response["picture"] as? Dictionary<String, Any> {
                
                if let data = picture["data"] as? Dictionary<String, Any> {
                    if let url = data["url"] as? String {
                        self.profilePictureUrl = url
                    }
                }
            }
        }
    }
    
    var graphPath = "/me"
    var parameters: [String : Any]? = ["fields": "id, name, email, picture.width(\(400)).height(\(400))"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}

public class FacebookService {
    
    let loginManager: LoginManager = {
        let manager = LoginManager()
        manager.loginBehavior = .web
        return manager
    }()
    
    public func login(from viewController: UIViewController, completion: @escaping FacebookCompletion) {
        loginManager.logIn(readPermissions: [.email, .publicProfile, .userFriends], viewController: viewController) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                completion(.error(error))
            case .cancelled:
                print("User cancelled login.")
                completion(.cancelled)
            case .success(let grantedPermissions, _, let accessToken):
                
                print("FACEBOOK LOGIN: SUCCESS")
                print("PERMISSIONS: \(grantedPermissions)")
                if grantedPermissions.contains("email") && grantedPermissions.contains("public_profile") {
                    print("FACEBOOK LOGIN: PERMISSIONS GRANTED")
                    self.getUserInfo(loginResult: loginResult, token: accessToken, completion: completion)
                } else {
                    print("FACEBOOK LOGIN: MISSING REQUIRED PERMISSIONS")
                    completion(.missingPermissions)
                }
                print("Logged in!")
            }
        }
    }
    
}

private extension FacebookService {
    
    func getUserInfo(loginResult: LoginResult, token: AccessToken, completion: @escaping FacebookCompletion) {
        guard AccessToken.current != nil else {
            print("FACEBOOK: NOT LOGGED IN: ABORTING")
            completion(.unknownError)
            return
        }
        
        let connection = GraphRequestConnection()
        connection.add(MyProfileRequest()) { response, result in
            switch result {
            case .success(let response):
                
                let fullNameArray = response.name?.components(separatedBy: " ")
                guard let firstName = fullNameArray?.first, let lastName = fullNameArray?.last else {
                    print("FACEBOOK: GRAPH REQUEST: MISSING DATA")
                    completion(.unknownError)
                    return
                }
                
                let facebookToken = token.authenticationToken
                
                print("FACEBOOK: GRAPH REQUEST: SUCCESS")
                
                guard let facebookId = response.id, let email = response.email else {
                    completion(.unknownError)
                    return
                }
                let profile = FacebookProfile(facebookId: facebookId,
                                              facebookToken: facebookToken,
                                              firstName: firstName,
                                              lastName: lastName,
                                              email: email,
                                              profilePictureUrl: response.profilePictureUrl ?? "")
                completion(.success(profile))
                
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
}
