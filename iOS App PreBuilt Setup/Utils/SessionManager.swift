//
//  SessionManager.swift
//  BodyCloud
//
//  Created by iMac on 21/09/21.
//

import Foundation

class SessionManager: NSObject {
    
    public static let shared = SessionManager()

    private let kSESSION_DEVICETOKEN_KEY = "kSessionDeviceTokenKey"
    private let kSESSION_HOSPITAL_KEY = "kSessionHospitalKey"

    
    //  MARK: - Save Device Token
    public var setDeviceTokenValue: String? {
        set {
            guard newValue != nil else {
                UserDefaults.standard.removeObject(forKey: kSESSION_DEVICETOKEN_KEY);
                return;
            }
            UserDefaults.standard.set(newValue, forKey: kSESSION_DEVICETOKEN_KEY)
            UserDefaults.standard.synchronize()
        }
        get {
            if let string = UserDefaults.standard.value(forKey: kSESSION_DEVICETOKEN_KEY) as? String {
                return string
            }
            return nil
        }
    }
    
   
}

