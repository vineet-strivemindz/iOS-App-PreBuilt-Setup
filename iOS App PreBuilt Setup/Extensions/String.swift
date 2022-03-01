//
//  StringExtension.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/22/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import Foundation
import UIKit

let ACCEPTABLE_CHARACTERS = kUIStrings.AcceptableChars

extension String {
	
	func trim() -> String {
		return trimmingCharacters(in: CharacterSet.whitespaces)
	}
	
	func range(from nsRange: NSRange) -> Range<String.Index>? {
		guard
			let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
			let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
			let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self)
			else { return nil }
		return from ..< to
	}
	
    func exReplace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: .literal, range: nil)
    }
    
    func exRremoveWhitespace() -> String {
        return self.exReplace(string: kUIStrings.WhiteSpace, replacement: kUIStrings.NoText)
    }
	
	func exRemoveLeadingAndTrailingWhiteSpaces () -> String {
		return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

	}
    
    func exKeepDigitsOnly() -> String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: kUIStrings.NoText)
    }
    
    //To check text field or String is blank or not
    var exIsBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    static func exClassName(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: kUIStrings.Dot).last!
    }
    
	func capFirstLetter() -> String {
		let first = String(self.prefix(1)).capitalized
		let other = String(self.dropFirst())
		return first + other
	}
	
	mutating func capFirstLetter() {
		self = self.capFirstLetter()
	}
    
    func exIsFullName() -> Bool {
        
        //Full Name - First Name and Last Name -^([a-zA-Z]{2,}\\s[a-zA-z]{1,}'?-?[a-zA-Z]{2,}\\s?([a-zA-Z]{1,})?)
        //Allow a name without last name -[a-zA-z]+([ '-][a-zA-Z]+)*$
        
        //            let regExp = try! NSRegularExpression(pattern: "[a-zA-z]+([ '-][a-zA-Z]+)*$", options: .caseInsensitive)
        //            let matchResult = regExp.rangeOfFirstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count))
        //        return matchResult.length > 0 ? true : false
        
        let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered: String = (self.components(separatedBy: cs) as NSArray).componentsJoined(by: kUIStrings.NoText)
        return (self == filtered)
		
    }
    
    func exIsSixDigit () -> Bool {
        if self.exLength >= kConstants.SIX {
            return true
        }
        return false
    }
	
	public func getFirstCharacter () -> String {
		return String(self.first!)
	}
	
	var html2Att: NSMutableAttributedString? {
		let htmlData = NSString(string: self).data(using: String.Encoding.unicode.rawValue)
		let options = [NSMutableAttributedString.DocumentReadingOptionKey.documentType: NSMutableAttributedString.DocumentType.html]
		let attributedString = try! NSMutableAttributedString(data: htmlData!, options: options, documentAttributes: nil)
		
		return attributedString
	}
    
//    var html2Att2: NSMutableAttributedString? {
//        let htmlData = NSString(string: self).data(using: String.Encoding.unicode.rawValue)
//        let options = [NSMutableAttributedString.DocumentReadingOptionKey.documentType: NSMutableAttributedString.DocumentType.html]
//        let attributedString = try! NSMutableAttributedString(data: htmlData!, options: options, documentAttributes: nil)
//        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: kFontNames.ChanakyaUni_Regular, size: 22.0) as Any, range: NSRange(location: 0, length: attributedString.length))
//        return attributedString
//    }
	
	var html2AttributedString: NSMutableAttributedString? {
		
//		let htmlData = NSString(string: self).data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true)
//		let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
//		let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
		let htmlData = NSString(string: self).data(using: String.Encoding.unicode.rawValue)
		let options = [NSMutableAttributedString.DocumentReadingOptionKey.documentType: NSMutableAttributedString.DocumentType.html]
		let attributedString = try! NSMutableAttributedString(data: htmlData!, options: options, documentAttributes: nil)
		
//		let myAttribute = [ NSAttributedStringKey.font: UIFont(name: kFontNames.ChanakyaUni_Regular, size: 24.0)! ]
//
//		attributedString = NSMutableAttributedString(string: attributedString.string, attributes: myAttribute)
//		print(attributedString)
		
		return attributedString
		
//		guard let data = data(using: .utf8) else { return NSAttributedString() }          ChanakyaUni-Regular.otf
//		do {
//			return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//		} catch {
//			return NSAttributedString()
//		}
		
//		let font = UIFont.init(name: kFontNames.Helvetica_Neue_Regular, size: 15.0)
//
//		let stringAttributes = [
//			NSAttributedStringKey.font : font!,
////			NSAttributedStringKey.underlineStyle : 1,
//			NSAttributedStringKey.foregroundColor : UIColor.darkGray,
//			.documentType: NSAttributedString.DocumentType.html,
//			.characterEncoding:String.Encoding.utf8.rawValue
////			NSAttributedStringKey.textEffect : NSAttributedString.TextEffectStyle.letterpressStyle,
////			NSAttributedStringKey.strokeWidth : 2.0
//			] as [NSAttributedStringKey : Any]
//
//		let atrributedString = NSAttributedString(string: self, attributes: stringAttributes)
//
//		return atrributedString
		
		
//			return try NSAttributedString(data: Data(utf8),
//										  options: [.documentType: NSAttributedString.DocumentType.html,
//													.characterEncoding: String.Encoding.utf8.rawValue],
//										  object: font!,
//										  documentAttributes: nil)

		
//		} catch {
//			print("error: ", error)
//			return nil
//		}
	}
	
	func localized(lang:String) ->String {
		
		let path = Bundle.main.path(forResource: lang, ofType: "lproj")
		let bundle = Bundle(path: path!)
		
		return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
	}
	

	
	var html2String: String {
		return html2AttributedString?.string ?? ""
	}
	
    
    // Validate Email
    func isValidEmail() -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
		
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
	
    
    
    //***************************************** Condition limited to UK users only
    //    func isPhoneNumber() -> (valid: Bool, number: String) {
    //        guard self.length >= 10 else {
    //            return (false, "Less than 10 digit number")
    //        }
    //
    //        if self.hasPrefix("0") == true{
    //            if self.characters.count < 11 {
    //                    return (false, "shoule be 11 digit number")
    //                }else {
    //                    let gotNumber = (self.substring(1))
    //                    return (true, gotNumber)
    //                }
    //        }else{
    //            return (true, self)
    //        }
    //    }
    //***************************************** Condition limited to UK users only
    
    var exIsPhoneNumberValid: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    
    //    var isAlphanumeric: Bool {
    //        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    //    }
    
    //validate Password
    //    var isValidPassword: Bool {
    //        do {
    //            let regex = try NSRegularExpression(pattern: "^[a-zA-Z_0-9\\-_,;.:#+*?=!§$%&/()@]+$", options: .caseInsensitive)
    //            if(regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil){
    //
    //                if(self.characters.count>=6 && self.characters.count<=20){
    //                    return true
    //                }else{
    //                    return false
    //                }
    //            }else{
    //                return false
    //            }
    //        } catch {
    //            return false
    //        }
    //    }
    
    

    func exMakeUrl(apiName: String) -> String {
        return self + apiName
    }
    
    var exLength: Int {
        return self.count
    }
    
    func exSafelyLimitedTo(length n: Int)->String {
        let c = self.exKeepDigitsOnly()
        if (c.count <= n) { return self }
        return String( Array(c).prefix(upTo: n) )
    }
	

	func versionToInt() -> [Int] {
		return self.components(separatedBy: ".")
				.map { Int.init($0) ?? 0 }
	}
	
	var firstUppercased: String {
		guard let first = first else { return "" }
		return String(first).uppercased() + dropFirst()
	}
    
    var encodeEmoji: String{
        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue){
            return encodeStr as String
        }
        return self
    }
    
    var decodeEmoji: String{
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr{
            return str as String
        }
        return self
    }
	
}
