
import UIKit

let environment = 1

struct APIServerConstants {
    
    static let imageBaseURL = URL(string: "http://staging.ceem.com/public/storage/")!

    // SERVER URL
    //Demo (staging) : http://bodycloud.strivemindz.com/api
    //uat : http://uat.bodycloud.strivemindz.com/api
    
    static let staggingServerURL = URL(string: "https://staging.ceem.com/API")!
    static let liveServerURL = URL(string: "")!
    
    static let serverBaseURL = staggingServerURL
    
    static let serverKey = ""
    static let serverTimeout = 30.0
    
    // Firebase send custom notification
    static let FCMAPI = URL(string: "https://fcm.googleapis.com/fcm/send")!

}

protocol EndpointType {
    var apiPath: String { get }
    var apiRequestType: String { get }
}

enum APIConstants {
    
    case loginAPI
    case forgotPasswordAPI
    case validateOTP
    case logoutAPI
//    case ChangePasswordAPI
    case VerifyPhoneAPI
    case ResetPasswordAPI(otp: String)
    case uploadPhoto
    case getAllCountries
    case changePassword(userId: Int)
    case updateProfile(userId: Int)
    case validateEmail
    case emailVerification(userId: Int)
    case changeEmail(otp: String)
}

extension APIConstants: EndpointType {
    
    var apiPath: String {
        
        switch self {
            
        case .loginAPI:
            return "/api/Login" // User login
            
        case .forgotPasswordAPI:
            return "/api/ForgetPassword" // Forget Password API
            
        case .validateOTP:
            return "/api/ValidateOTP"
            
        case .logoutAPI:
            return "/api/LogOut"
            
//        case .ChangePasswordAPI:
//            return "/user/change_password"
            
        case .VerifyPhoneAPI:
            return "/verify_phone"
            
        case .ResetPasswordAPI(let otp):
            return "/api/ResetPassword/\(otp)"
            
        case .uploadPhoto:
            return "/api/UploadImage"
            
        case .getAllCountries:
            return "/api/Country"
            
        case .changePassword(let uid):
            return "/api/ChangePassword?id=\(uid)"
            
        case .updateProfile(let uid):
            return "/api/UpdateProfile?id=\(uid)"
            
        case .validateEmail:
            return "/api/ValidateEmail"
            
        case .emailVerification(let uid):
            return "/api/EmailVerification/\(uid)"
            
        case .changeEmail(let uid):
            return "/api/ChangeEmail?OTP=\(uid)"

        }
    }

    var apiRequestType: String {
        
        switch self {

        case .getAllCountries, .emailVerification:
            
            return "GET"

        default:
            return "POST"
        }
    }
}
