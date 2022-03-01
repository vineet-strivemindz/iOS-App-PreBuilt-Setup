//
//  Constants.swift
//  OrderToSeat
//
//  Created by Vineet on 16/08/21.
//

import Foundation
import UIKit
import Alamofire


let appDel = UIApplication.shared.delegate as! AppDelegate

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

let loadingString = "Loading..."
let messageSomethingWrong = "Something went wrong"
let noRecordsFound = "No record found..."

let verificationCodeSent = "Verification code has been sent on your register mail."
let verificationCodeMatch = "Verification code has been match. Please change your password."
let verifyEmailDone = "Your email has been verified."
let passwordChanged = "Your password has been changed."

struct kCell {
    static let HomeTop_CVCell                        = "HomeTop_CVCell"
    static let HomeSecond_CVCell                    = "HomeSecond_CVCell"
    static let HomeThird_CVCell                        = "HomeThird_CVCell"
    static let HomeForth_CVCell                        = "HomeForth_CVCell"
}

struct kColor {
    static let theme_color = "51B748"
    static let borderColor = "EBF0FF"
    static let titleColor =  "1F508B"      //"223263"
    static let rbtnColor = "51B748"
    static let greyCustom = "9098B1"
    
    static let blueTheme = "638DDB"
    static let orangeTheme = "EE8B43"
    static let pinkTheme = "F29EEF"
}

struct kUIStrings {
    
    //Dummy Values
    static let active                                    = "active"
    static let RegexEmail                        = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
    static let RegexMobile                        = "^[0-9]{6,15}$"
    static let RegexName                        = "^[a-zA-Z]+$"
    static let AcceptableChars                = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-,.'"
    static let WhiteSpace                        = " "
    static let NoText                                = ""
    static let Dot                                        = "."
    static let Comma                                = ","
    
    static let ContentType                        = "Content-Type"
    static let Authorization                        = "Authorization"
    static let Message                                = "Message"
    
    static let addressLine1                        = "Address Line 1"
    static let addressLine2                        = "Address Line 2"
    static let City                                        = "City"
    static let State                                    = "State"
    static let Country                                = "Country"
    static let PinCode                                = "Pin Code"
    
    static let iosvalue                             = "X-Plateform"
    static let securekey                            = "X-Signature"

}

struct kConstants {
    static let kView_WIDTH:CGFloat         = CGFloat(UIWindow().frame.size.width)
    static let kView_HEIGHT:CGFloat         = CGFloat(UIWindow().frame.size.height)
    
    static let ZEROInt: Int                        = 0
    static let ONEInt: Int                            = 1
    static let TWOInt: Int                            = 2
    static let THREEInt: Int                        = 3
    static let FOURInt: Int                        = 4
    static let SIX: Int                                 = 6
    static let OZO: Int                                 = 101
    static let OZT: Int                                 = 102
    static let OZTT: Int                                 = 103
    static let OZF: Int                                 = 104
    static let OZFF: Int                             = 105
    static let OZZO: Int                             = 1001
    static let OZZT: Int                             = 1002
    static let OZZTT: Int                             = 1003
    static let OZZF: Int                             = 1004
    static let OZZFF: Int                             = 1005
    
    static let ZERO: CGFloat                     = 0.0
    static let ONE: CGFloat                     = 1.0
    static let TWO: CGFloat                     = 2.0
    static let EIGHTEEN: CGFloat            = 18.0 //half of Alert button height
    static let kView_PADDING:CGFloat     = 20.0
    static var kTab_HEIGHT:CGFloat         = 49.0
    static var kBar_HEIGHT:CGFloat         = 64.0
    static var kStatusBar_HEIGHT:CGFloat            = 20.0
    static let kCropped_HEIGHT:CGFloat         = 435.0

    static let kColor_Seperator: UIColor     = UIColor(red: 53.0/255.0, green: 126.0/255.0, blue: 167.0/255.0, alpha: 1.0)
    
    static let Version    = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
}

struct kFontNames {//not used yet
//    static let MINNOGOPI01             = "MINNO-GOPI-01"
    static let Poppins_Light                    = "Poppins-Light"
    //LanguageManger.shared.currentLanguage != .hi ? "Eczar-Regular" : "NotoSans"
    static let Poppins_Bold            = "Poppins-Bold"
    static let Poppins_Regular    = "Poppins-Regular"
    
    //LanguageManger.shared.currentLanguage != .hi ? "Eczar-SemiBold" : "NotoSans-Bold"
//    static let Eczar_Medium            = "NotoSans-Bold"//LanguageManger.shared.currentLanguage != .hi ? "Eczar-Medium" : "NotoSans-Bold"
//    static let Eczar_Bold                 = "NotoSans-Bold"//LanguageManger.shared.currentLanguage != .hi ? "Eczar-Bold" : "NotoSans-Bold"
//    static let Eczar_ExtraBold        = "NotoSans-Bold"//LanguageManger.shared.currentLanguage != .hi ? "Eczar-ExtraBold" : "NotoSans-Bold"

    
    static let Montserrat_Bold            = "Montserrat-Bold"
    static let Montserrat_Light        = "Montserrat-Light"
//    static let Chanakya        = "chanakyaunin"

//    static let Eczar_Regular            = "NotoSans-Regular"     ChanakyaUnii
//    static let Eczar_SemiBold        = "NotoSans-Bold"
//    static let Eczar_Medium            = "NotoSans-Bold"
//    static let Eczar_Bold                 = "NotoSans-Bold"
//    static let Eczar_ExtraBold        = "NotoSans-Bold"
    
}
