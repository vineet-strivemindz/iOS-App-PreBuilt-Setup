
import UIKit
import Alamofire

private let defaultAuthorizedSeperator: String = "Bearer "

private let responseKeySuccess: String = "status"
private let responseKeyData: String = "data"
private let responseAccessToken: String = "accessToken"
private let responseKeyErrorMessage: String = "message"
private let responseKeyreturn_reasons: String = "return_reasons"

private class SingletonAlamofireHelper {
    var parentView: UIViewController?
}

class APIManager: NSObject {
    
    enum HTTPRequestType {
        case get
        case post
        case put
        case delete
    }
    
    //MARK: - Setup
    private static let setup = SingletonAlamofireHelper()
    var isAskedForRefreshToken: Bool = false
    let dictRequests: NSMutableDictionary = [:]
    
    class func setup(parentVC: UIViewController) {
        APIManager.setup.parentView = parentVC
    }
    
    typealias completionDataHandler<T> = (_ status: Bool, _ response: T?, _ errorMessage: APICustomError?) -> Void
    typealias braintreeCompletionHandler = (_ status: Bool, _ responseData: Data?, _ responseString: String?) -> Void

    //MARK: - Accessors
    static let sharedInstance = APIManager()
    var manager: Session?

    //MARK: - Init
    private override init() {
        super.init()
        manager = Alamofire.Session.default
        manager!.session.configuration.timeoutIntervalForRequest = APIServerConstants.serverTimeout
    }
    
    //MARK: - Request with success response
    func generateAPIRequest<T: Codable>(reqEndpoint: APIConstants, type: T.Type, isAccessToken: Bool = false, reqBodyData: [String:Any]?, completion: @escaping completionDataHandler<T>)  {
        
        var urlString = APIServerConstants.serverBaseURL.appendingPathComponent(reqEndpoint.apiPath).absoluteString.removingPercentEncoding
        if reqBodyData != nil {
            DLog("API Request Data ==> \(reqBodyData!)")
            if reqEndpoint.apiRequestType == "GET"{
                if reqBodyData != nil {
                    urlString = urlString! + "?" + reqBodyData!.queryString
                }
            }
        }
        
        let escapedAddress = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let reqURL = URL(string: escapedAddress ?? "") else {
            return
        }
        DLog("API URL ==> \(reqURL)")
        
        var request = URLRequest(url: reqURL)
        if reqEndpoint.apiRequestType != "GET"{
            if reqBodyData != nil {
                
                var jsonData: Data! = nil
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: reqBodyData!, options: [])
                    request.httpBody = jsonData
                    
                    let requestJSON = String(data: jsonData, encoding: String.Encoding.utf8)
                    DLog("JSON Request ==> \(requestJSON!)")
                }
                catch {
                    DLog("Array to JSON conversion failed: \(error.localizedDescription)")
                }
            }
        }
        
        
        request.httpMethod = reqEndpoint.apiRequestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = getUserSessionHeaders()
        
        self.apiRequestToServer( apiRequest: request, type: type, completion: completion)
    }
    
    private func apiRequestToServer<T: Codable>( apiRequest: URLRequest, type: T.Type, completion: @escaping completionDataHandler<T>) {
        
        
        //Request to Server
        manager!.request(apiRequest)
            .responseJSON { response in
                
                switch response.result {
                case .failure(let error):
                    DLog("Error ==> \(error)")
                    
                case .success(let responseObject):
                    DLog("Request ==> \((apiRequest.url)!)\n Response ==> \(responseObject)")
                }
                
                if let httpError = response.error {
                    
                    //TODO: HTTP ERROR
                    let statusCode = httpError._code
                    
                    //TODO: HTTP - Authentication Required 🤔
                    if statusCode == 401 {
                        
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    else {
                        //TODO: HTTP - Another Error
                        //Callback
                        if statusCode != 15 {
                            let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: (apiRequest.url?.absoluteString)!)
                            completion(false, nil, customError)
                        }
                        return
                    }
                }
                else {
                    //TODO: HTTP Response
                    let statusCode = response.response?.statusCode ?? 0
                    
                    //TODO: Authentication Required 🤔
                    if statusCode == 401 {
                        runOnMainThread {
                            setIntegerValueToUserDefaults(1, "CurrentState")
//                            APP_DELEGATE.navigateApplicationToScreen()
                        }

                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    //TODO: Server Maintainance 😢
                    else if statusCode == 503 {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            //Server Maintainance Prompt
                        })
                        
                        let errorMsg = "Server Under Maintainance"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    
                    //TODO: Valid API Response - Data Parsing 😇
                    //Data Parsing
                    do {
                        if let data = response.data {
                            
                            let dictResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            if let success = (dictResponse?.value(forKey: responseKeySuccess) as? Int), success == 200 {
                                print("Success status - \(success)")
                                if let datadict = (dictResponse?.value(forKey: responseKeyData)) {
                                    
                                    if datadict is NSDictionary || datadict is NSArray
                                    {
                                        //dict
                                        if let dataObj = objectToData(stringArray: datadict){
                                            let resultData = ResponseData(data: dataObj)
                                            let decodedResponse = resultData.decode(type)
                                            print("decodedResponse :- \(decodedResponse)")
                                            guard let decodedData = decodedResponse.decodedData else {
                                                
                                                if let err = decodedResponse.error {
                                                    let error = APICustomError(title: "Data not decoded", desc: err.localizedDescription, code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                                    completion(false, nil, error)
                                                    return
                                                }
                                                completion(false, nil, nil)
                                                return
                                            }
                                            
                                            //MARK: Valid Response
                                            completion(true, decodedData, nil)
                                        }
                                        else{
                                            //error
                                            let error = APICustomError(title: "Data not decoded", desc: "Data not decoded", code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                            completion(false, nil, error)
                                            return
                                        }
                                    }else
                                    {
                                        completion(true, nil, nil)
                                        return
                                    }
                                }
                                else{
                                    //error
                                    var errorMessage = "Something went wrong"
                                    if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? String, !error.isEmpty {
                                        errorMessage = error
                                    }
                                    
                                    //Callback
                                    let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMessage, api: (apiRequest.url?.absoluteString)!)
                                    completion(true, nil, customError)
                                    return
                                }
                                
                            }
                            else {

                                var errorMessage = "Something went wrong"
                                if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? String, !error.isEmpty {
                                    errorMessage = error
                                }
                                
                                //Callback
                                let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMessage, api: (apiRequest.url?.absoluteString)!)
                                completion(false, nil, customError)
                            }
                        }
                        else {
                            //Callback
                            let errorMsg = "Data not found"
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                            completion(false, nil, customError)
                        }
                    }
                    catch {
                        //Callback
                        let errorMsg = "Something went wrong"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                    }
                }
        }
    }
    
    
    //MARK: - Request without success response
    func generateAPIRequestWithDictionary<T: Codable>(reqEndpoint: APIConstants, type: T.Type, isAccessToken: Bool = false, reqBodyData: [String:Any]?, completion: @escaping completionDataHandler<T>)  {
        
        var urlString = APIServerConstants.serverBaseURL.appendingPathComponent(reqEndpoint.apiPath).absoluteString.removingPercentEncoding
        if reqBodyData != nil {
            DLog("API Request Data ==> \(reqBodyData!)")
            if reqEndpoint.apiRequestType == "GET"{
                if reqBodyData != nil {
                    urlString = urlString! + "?" + reqBodyData!.queryString
                }
            }
        }
        
        let escapedAddress = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let reqURL = URL(string: escapedAddress ?? "") else {
            return
        }
        DLog("API URL ==> \(reqURL)")
        
        var request = URLRequest(url: reqURL)
        if reqEndpoint.apiRequestType != "GET"{
            if reqBodyData != nil {
                
                var jsonData: Data! = nil
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: reqBodyData!, options: [])
                    request.httpBody = jsonData
                    
                    let requestJSON = String(data: jsonData, encoding: String.Encoding.utf8)
                    DLog("JSON Request ==> \(requestJSON!)")
                }
                catch {
                    DLog("Array to JSON conversion failed: \(error.localizedDescription)")
                }
            }
        }
        
        
        request.httpMethod = reqEndpoint.apiRequestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = getUserSessionHeaders()
        
        apiRequestToServerWithoutSuccess( apiRequest: request, type: type, completion: completion)
    }
    
    //MARK: - Direct response without success key and all
    private func apiRequestToServerWithoutSuccess<T: Codable>( apiRequest: URLRequest, type: T.Type, completion: @escaping completionDataHandler<T>) {
        
        let manager: Session = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = APIServerConstants.serverTimeout
        
        //Request to Server
        manager.request(apiRequest)
            .responseJSON { response in
                
                switch response.result {
                case .failure(let error):
                    DLog("Error ==> \(error)")
                    //TODO: HTTP ERROR
                    let statusCode = error._code
                    
                    //TODO: HTTP - Authentication Required 🤔
                    if statusCode == 401 {
                        
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    else {
                        //TODO: HTTP - Another Error
                        //Callback
                        let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    
                case .success(let responseObject):
                    DLog("Request ==> \((apiRequest.url)!)\n Response ==> \(responseObject)")
                    //TODO: HTTP Response
                    let statusCode = response.response?.statusCode ?? 0
                    
                    //TODO: Authentication Required 🤔
                    if statusCode == 401 {
                        
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                        //TODO: Server Maintainance 😢
                    else if statusCode == 503 {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            //Server Maintainance Prompt
                        })
                        
                        let errorMsg = "Server Under Maintainance"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                        return
                    }
                    
                    //TODO: Valid API Response - Data Parsing 😇
                    //Data Parsing
                    do {
                        if let data = response.data {
                            
                            let _ = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            
                            let result = ResponseData(data: data)
                            let decodedResponse = result.decode(type)
                            
                            guard let decodedData = decodedResponse.decodedData else {
                                
                                if let err = decodedResponse.error {
                                    let error = APICustomError(title: "Data not decoded", desc: err.localizedDescription, code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                    completion(false, nil, error)
                                    return
                                }
                                completion(false, nil, nil)
                                return
                            }
                            
                            //MARK: Valid Response
                            completion(true, decodedData, nil)
                        }
                        else {
                            //Callback
                            let errorMsg = "Data not found"
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                            completion(false, nil, customError)
                        }
                    }
                    catch {
                        //Callback
                        let errorMsg = "Something went wrong"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: (apiRequest.url?.absoluteString)!)
                        completion(false, nil, customError)
                    }
                }
                
        }
    }
    
    //MARK: - Image Upload
    func uploadImages<T: Codable>(reqEndpoint: APIConstants, type: T.Type, reqBodyData: [String:Any]?, imageArray: [String:[UIImage]], isAccessToken: Bool = false, completion: @escaping completionDataHandler<T>)  {
        
        guard let urlString = APIServerConstants.serverBaseURL.appendingPathComponent(reqEndpoint.apiPath).absoluteString.removingPercentEncoding else {
            return
        }
        
        guard let reqURL = URL(string: urlString) else {
            return
        }
        DLog("API URL ==> \(reqURL)")
        
        let manager: Session = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = APIServerConstants.serverTimeout
        
        var request = URLRequest(url: reqURL)
        
        let accesstoken = getStringValueFromUserDefaults_ForKey("accessToken") ?? ""

        
        request.httpMethod = reqEndpoint.apiRequestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accesstoken, forHTTPHeaderField: "accessToken")
        request.allHTTPHeaderFields = getUserSessionHeaders("multipart/form-data")
        
        manager.upload(multipartFormData: { (multipartFormData) in
            
            // add now
            for (key,value) in imageArray
            {
                DLog("\(key)")
                for i in 0..<value.count
                {
                    let dataImage = value[i].jpegData(compressionQuality: 0.5)
                    multipartFormData.append(dataImage!, withName: key , fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                }
            }
            
            if let parameters = reqBodyData{
                for (key, value) in parameters {
                    var valueStr:String = ""
                    if let intVlaue:Int   = value as? Int{
                        valueStr = String(format:"%d",intVlaue)
                    }else{
                        valueStr = value as? String ?? ""
                    }
                    multipartFormData.append(valueStr.data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }, with: request)
            .uploadProgress(closure: { (progress) in
                DLog("Upload Progress: \(progress.fractionCompleted)")
            })
            .response { (response) in
                switch response.result {
                case .failure(let error):
                    
                    //TODO: HTTP ERROR
                    let statusCode = error._code
                    //TODO: HTTP - Authentication Required 🤔
                    if statusCode == 401 {
                        runOnMainThread {
                            setIntegerValueToUserDefaults(1, "CurrentState")
//                            APP_DELEGATE.navigateApplicationToScreen()
                        }
                        
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }
                    else {
                        //TODO: HTTP - Another Error
                        do {
                            if let data = response.data {
                                
                                let dictResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                                
                                if let errorCode: Int = dictResponse?.value(forKey: responseKeyErrorMessage) as? Int {
                                    
                                    if errorCode > 0 {
                                        
                                        let errorMessage: String = dictResponse?.value(forKey: responseKeyErrorMessage) as? String ?? "Something went wrong"
                                        let customError = APIErrorManager.getServerErrorMessage(status: errorCode, errMsg: errorMessage, api: urlString)
                                        
                                        //Callback
                                        completion(false, nil, customError)
                                        return
                                    }
                                    else {
                                        //Callback
                                        let strErrorMsg: String = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                                        let customError = APIErrorManager.getServerErrorMessage(status: errorCode, errMsg: strErrorMsg, api: urlString)
                                        completion(false, nil, customError)
                                        return
                                    }
                                }
                                else {
                                    //Callback
                                    let strErrorMsg = "API not found"
                                    let customError = APIErrorManager.getServerErrorMessage(status: 404, errMsg: strErrorMsg, api: urlString)
                                    completion(false, nil, customError)
                                    return
                                }
                            }
                            else {
                                //Callback
                                let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                                let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: urlString)
                                completion(false, nil, customError)
                                return
                            }
                        }
                        catch {
                            //Callback
                            let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: urlString)
                            completion(false, nil, customError)
                            return
                        }
                    }
                    
                case .success( _):
                    //TODO: HTTP Response
                    let statusCode = response.response?.statusCode ?? 0
                    
                    DLog("Request ==> \((request.url)!)")
                    
                    //TODO: Authentication Required 🤔
                    if statusCode == 401 {
                        runOnMainThread {
                            setIntegerValueToUserDefaults(1, "CurrentState")
//                            APP_DELEGATE.navigateApplicationToScreen()
                        }
                        
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }
                        //TODO: Server Maintainance 😢
                    else if statusCode == 503 {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            //Server Maintainance Prompt
                        })
                        
                        let errorMsg = "Server Under Maintainance"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }
                    
                    //TODO: Valid API Response - Data Parsing 😇
                    //Data Parsing
                    do {
                        if let data = response.data {
                            
                            let dictResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            if let success = (dictResponse?.value(forKey: responseKeySuccess) as? Int), success == 200 {
                                print("Success status - \(success)")
                                
                                if let atData = (dictResponse?.value(forKey: responseAccessToken)) {
                                    
                                    print(atData)
                                    setStringValueToUserDefaults(atData as! String, "accessToken")
                                    
                                }

                                if let datadict = (dictResponse?.value(forKey: responseKeyData)) {
                                    //dict
                                    if let dataObj = objectToData(stringArray: datadict){
                                        let resultData = ResponseData(data: dataObj)
                                        let decodedResponse = resultData.decode(type)
                                        print("decodedResponse :- \(decodedResponse)")

                                        guard let decodedData = decodedResponse.decodedData else {
                                            
                                            if let err = decodedResponse.error {
                                                let error = APICustomError(title: "Data not decoded", desc: err.localizedDescription, code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                                completion(false, nil, error)
                                                return
                                            }
                                            completion(false, nil, nil)
                                            return
                                        }
                                        
                                        //MARK: Valid Response
                                        completion(true, decodedData, nil)
                                    }
                                    else{
                                        //error
                                        let error = APICustomError(title: "Data not decoded", desc: "Data not decoded", code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                        completion(false, nil, error)
                                        return
                                    }
                                    
                                }
                                else{
                                    //error
                                    var errorMessage = "Something went wrong"
                                    if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? String, !error.isEmpty {
                                        errorMessage = error
                                    }
                                    
                                    //Callback
                                    let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMessage, api: urlString)
                                    completion(true, nil, customError)
                                    return
                                }
                                
                            }
                            else {
                                var errorMessage = "Something went wrong"
                                if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? String, !error.isEmpty {
                                    errorMessage = error
                                }
                                
                                //Callback
                                let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMessage, api: urlString)
                                completion(false, nil, customError)
                            }
                        }
                        else {
                            //Callback
                            let errorMsg = "Data not found"
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                            completion(false, nil, customError)
                        }
                    }
                    catch {
                        //Callback
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: error.localizedDescription, api: urlString)
                        completion(false, nil, customError)
                    }
                }
        }
    }

    //MARK: - Image/Video Upload
    
    
    func uploadImagesVideo<T: Codable>(reqEndpoint: APIConstants, type: T.Type, reqBodyData: [String:Any]?, imageArray: [String:UIImage], videodata: [String:URL], isAccessToken: Bool = false, completion: @escaping completionDataHandler<T>)  {

        guard let urlString = APIServerConstants.serverBaseURL.appendingPathComponent(reqEndpoint.apiPath).absoluteString.removingPercentEncoding else {
            return
        }

        guard let reqURL = URL(string: urlString) else {
            return
        }
        DLog("API URL ==> \(reqURL)")

        let manager: Session = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = APIServerConstants.serverTimeout

        var request = URLRequest(url: reqURL)

        request.httpMethod = reqEndpoint.apiRequestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = getUserSessionHeaders("multipart/form-data")

      
        manager.upload(multipartFormData: { (multipartFormData) in

            // add now
            for (key,value) in imageArray
            {
                DLog("\(key)")
                let dataImage = value.jpegData(compressionQuality: 0.8)
                multipartFormData.append(dataImage!, withName: key , fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            }

            for (key, value) in videodata {
                DLog("\(key)")
                let videoData = try? Data(contentsOf: value)
                let filename = (value).lastPathComponent

                multipartFormData.append(videoData!, withName: key, fileName: filename, mimeType: "video/mp4") //"application/octet-stream"
            }

            if let parameters = reqBodyData{
                for (key, value) in parameters {
                    var valueStr:String = ""
                    if let intVlaue:Int   = value as? Int{
                        valueStr = String(format:"%d",intVlaue)
                    }else{
                        valueStr = value as! String
                    }
                    multipartFormData.append(valueStr.data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }, with: request)
            .uploadProgress(closure: { (progress) in
                DLog("Upload Progress: \(progress.fractionCompleted)")
            })
            .response { (response) in
                switch response.result {
                case .failure(let error):

                    //TODO: HTTP ERROR
                    let statusCode = error._code
                    //TODO: HTTP - Authentication Required �
                    if statusCode == 401 {
                        runOnMainThread {
                            setIntegerValueToUserDefaults(1, "CurrentState")
//                            APP_DELEGATE.navigateApplicationToScreen()
                        }

                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }
                    else {
                        //TODO: HTTP - Another Error
                        do {
                            if let data = response.data {

                                let dictResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary

                                if let errorCode: Int = dictResponse?.value(forKey: responseKeyErrorMessage) as? Int {

                                    if errorCode > 0 {

                                        let errorMessage: String = dictResponse?.value(forKey: responseKeyErrorMessage) as? String ?? "Something went wrong"
                                        let customError = APIErrorManager.getServerErrorMessage(status: errorCode, errMsg: errorMessage, api: urlString)

                                        //Callback
                                        completion(false, nil, customError)
                                        return
                                    }
                                    else {
                                        //Callback
                                        let strErrorMsg: String = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                                        let customError = APIErrorManager.getServerErrorMessage(status: errorCode, errMsg: strErrorMsg, api: urlString)
                                        completion(false, nil, customError)
                                        return
                                    }
                                }
                                else {
                                    //Callback
                                    let strErrorMsg = "API not found"
                                    let customError = APIErrorManager.getServerErrorMessage(status: 404, errMsg: strErrorMsg, api: urlString)
                                    completion(false, nil, customError)
                                    return
                                }
                            }
                            else {
                                //Callback
                                let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                                let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: urlString)
                                completion(false, nil, customError)
                                return
                            }
                        }
                        catch {
                            //Callback
                            let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: urlString)
                            completion(false, nil, customError)
                            return
                        }
                    }

                case .success( _):
                    //TODO: HTTP Response
                    let statusCode = response.response?.statusCode ?? 0

                    DLog("Request ==> \((request.url)!)")

                    //TODO: Authentication Required �
                    if statusCode == 401 {
                        runOnMainThread {
                            setIntegerValueToUserDefaults(1, "CurrentState")
//                            APP_DELEGATE.navigateApplicationToScreen()
                        }

                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }
                        //TODO: Server Maintainance �
                    else if statusCode == 503 {

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            //Server Maintainance Prompt
                        })

                        let errorMsg = "Server Under Maintainance"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }

                    //TODO: Valid API Response - Data Parsing �
                    //Data Parsing
                    do {
                        if let data = response.data {

                            let dictResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            if let success = (dictResponse?.value(forKey: responseKeySuccess) as? Int), success == 200 {
                                print("Success status - \(success)")

                                if let datadict = (dictResponse?.value(forKey: responseKeyData)) {
                                    //dict
                                    if let dataObj = objectToData(stringArray: datadict){
                                        let resultData = ResponseData(data: dataObj)
                                        let decodedResponse = resultData.decode(type)
                                        print("decodedResponse :- \(decodedResponse)")

                                        guard let decodedData = decodedResponse.decodedData else {

                                            if let err = decodedResponse.error {
                                                let error = APICustomError(title: "Data not decoded", desc: err.localizedDescription, code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                                completion(false, nil, error)
                                                return
                                            }
                                            completion(false, nil, nil)
                                            return
                                        }

                                        //MARK: Valid Response
                                        completion(true, decodedData, nil)
                                    }
                                    else{
                                        //error
                                        let error = APICustomError(title: "Data not decoded", desc: "Data not decoded", code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                        completion(false, nil, error)
                                        return
                                    }

                                }
                                else{
                                    //error
                                    var errorMessage = "Something went wrong"
                                    if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? String, !error.isEmpty {
                                        errorMessage = error
                                    }

                                    //Callback
                                    let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMessage, api: urlString)
                                    completion(true, nil, customError)
                                    return
                                }

                            }
                            else {
                                var errorMessage = "Something went wrong"
                                if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? String, !error.isEmpty {
                                    errorMessage = error
                                }

                                //Callback
                                let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMessage, api: urlString)
                                completion(false, nil, customError)
                            }
                        }
                        else {
                            //Callback
                            let errorMsg = "Data not found"
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                            completion(false, nil, customError)
                        }
                    }
                    catch {
                        //Callback
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: error.localizedDescription, api: urlString)
                        completion(false, nil, customError)
                    }
                }
        }
    }
    
    //MARK:- Upload all type of file (jpeg, png, jpg, gif, svg, doc, docx, pdf)
    func uploadFiles<T: Codable>(reqEndpoint: APIConstants, type: T.Type, reqBodyData: [String:Any]?, documentArray: [String:[Data]], isAccessToken: Bool = false, completion: @escaping completionDataHandler<T>)  {
        
        guard let urlString = APIServerConstants.serverBaseURL.appendingPathComponent(reqEndpoint.apiPath).absoluteString.removingPercentEncoding else {
            return
        }
        
        guard let reqURL = URL(string: urlString) else {
            return
        }
        
        DLog("API URL ==> \(reqURL)")
        
        let manager: Session = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = APIServerConstants.serverTimeout
        
        var request = URLRequest(url: reqURL)
        
        request.httpMethod = reqEndpoint.apiRequestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = getUserSessionHeaders("multipart/form-data")
        
        manager.upload(multipartFormData: { (multipartFormData) in
            
            // add now
            for (key,value) in documentArray
            {
                /*
                DLog("\(key)")
                for i in 0..<value.count
                {
                    let dataImage = (value[i] as? UIImage)?.jpegData(compressionQuality: 0.5)
                    multipartFormData.append(dataImage!, withName: key , fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                }
                */
                
                
                for i in 0..<value.count
                {
                    multipartFormData.append(value[i], withName: key , fileName: "\(Date().timeIntervalSince1970)", mimeType: "application/octet-stream")
                }
            }
            
            if let parameters = reqBodyData{
                for (key, value) in parameters {
                    var valueStr:String = ""
                    if let intVlaue:Int   = value as? Int{
                        valueStr = String(format:"%d",intVlaue)
                    }else{
                        valueStr = value as! String
                    }
                    multipartFormData.append(valueStr.data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }, with: request)
            .uploadProgress(closure: { (progress) in
                DLog("Upload Progress: \(progress.fractionCompleted)")
            })
            .response { (response) in
                switch response.result {
                case .failure(let error):
                    
                    //TODO: HTTP ERROR
                    let statusCode = error._code
                    //TODO: HTTP - Authentication Required 🤔
                    if statusCode == 401 {
                        runOnMainThread {
                            setIntegerValueToUserDefaults(1, "CurrentState")
//                            APP_DELEGATE.navigateApplicationToScreen()
                        }
                        
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }
                    else {
                        //TODO: HTTP - Another Error
                        do {
                            if let data = response.data {
                                
                                let dictResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                                
                                if let errorCode: Int = dictResponse?.value(forKey: responseKeyErrorMessage) as? Int {
                                    
                                    if errorCode > 0 {
                                        
                                        let errorMessage: String = dictResponse?.value(forKey: responseKeyErrorMessage) as? String ?? "Something went wrong"
                                        let customError = APIErrorManager.getServerErrorMessage(status: errorCode, errMsg: errorMessage, api: urlString)
                                        
                                        //Callback
                                        completion(false, nil, customError)
                                        return
                                    }
                                    else {
                                        //Callback
                                        let strErrorMsg: String = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                                        let customError = APIErrorManager.getServerErrorMessage(status: errorCode, errMsg: strErrorMsg, api: urlString)
                                        completion(false, nil, customError)
                                        return
                                    }
                                }
                                else {
                                    //Callback
                                    let strErrorMsg = "API not found"
                                    let customError = APIErrorManager.getServerErrorMessage(status: 404, errMsg: strErrorMsg, api: urlString)
                                    completion(false, nil, customError)
                                    return
                                }
                            }
                            else {
                                //Callback
                                let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                                let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: urlString)
                                completion(false, nil, customError)
                                return
                            }
                        }
                        catch {
                            //Callback
                            let strErrorMsg = APIErrorManager.getHTTPErrorMessage(status: statusCode)
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: strErrorMsg, api: urlString)
                            completion(false, nil, customError)
                            return
                        }
                    }
                    
                case .success( _):
                    //TODO: HTTP Response
                    let statusCode = response.response?.statusCode ?? 0
                    
                    DLog("Request ==> \((request.url)!)")
                    
                    //TODO: Authentication Required 🤔
                    if statusCode == 401 {
                        runOnMainThread {
                            setIntegerValueToUserDefaults(1, "CurrentState")
//                            APP_DELEGATE.navigateApplicationToScreen()
                        }
                        
                        let errorMsg = "Authentication Required"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }
                        //TODO: Server Maintainance 😢
                    else if statusCode == 503 {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            //Server Maintainance Prompt
                        })
                        
                        let errorMsg = "Server Under Maintainance"
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                        completion(false, nil, customError)
                        return
                    }
                    
                    //TODO: Valid API Response - Data Parsing 😇
                    //Data Parsing
                    do {
                        if let data = response.data {
                            
                            let dictResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            if let success = (dictResponse?.value(forKey: responseKeySuccess) as? Int), success == 200 {
                                print("Success status - \(success)")

                                if let datadict = (dictResponse?.value(forKey: responseKeyData)) {
                                    //dict
                                    if let dataObj = objectToData(stringArray: datadict){
                                        let resultData = ResponseData(data: dataObj)
                                        let decodedResponse = resultData.decode(type)
                                        print("decodedResponse :- \(decodedResponse)")

                                        guard let decodedData = decodedResponse.decodedData else {
                                            
                                            if let err = decodedResponse.error {
                                                let error = APICustomError(title: "Data not decoded", desc: err.localizedDescription, code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                                completion(false, nil, error)
                                                return
                                            }
                                            completion(false, nil, nil)
                                            return
                                        }
                                        
                                        //MARK: Valid Response
                                        completion(true, decodedData, nil)
                                    }
                                    else{
                                        //error
                                        let error = APICustomError(title: "Data not decoded", desc: "Data not decoded", code: 200, api: "\(response.request?.url?.absoluteString ?? "")")
                                        completion(false, nil, error)
                                        return
                                    }
                                    
                                }
                                else{
                                    //error
                                    var errorMessage = "Something went wrong"
                                    if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? String, !error.isEmpty {
                                        errorMessage = error
                                    }
                                    
                                    //Callback
                                    let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMessage, api: urlString)
                                    completion(true, nil, customError)
                                    return
                                }
                                
                            }
                            else {
                                var errorMessage = "Something went wrong"
                                if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? String, !error.isEmpty {
                                    errorMessage = error
                                }
                                
                                //Callback
                                let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMessage, api: urlString)
                                completion(false, nil, customError)
                            }
                        }
                        else {
                            //Callback
                            let errorMsg = "Data not found"
                            let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: errorMsg, api: urlString)
                            completion(false, nil, customError)
                        }
                    }
                    catch {
                        //Callback
                        let customError = APIErrorManager.getServerErrorMessage(status: statusCode, errMsg: error.localizedDescription, api: urlString)
                        completion(false, nil, customError)
                    }
                }
        }
    }
   
    //MARK: - Cache Request
    private func cacheRequestToLocal<T: Codable>(cacheRequest: URLRequest, responseCallBack: @escaping completionDataHandler<T>) {
        
        //Add to Dictionary
        let dict: NSMutableDictionary = [:]
        dict.setObject(cacheRequest, forKey: "url" as NSCopying)
        dict.setObject(responseCallBack, forKey: "callback" as NSCopying)
        
        dictRequests.setObject(dict, forKey: cacheRequest.url!.absoluteString as NSCopying)
        DLog("Request :: \(cacheRequest.url!.absoluteString)")
    }
    
    //MARK: - User Session Headers
    private func getUserSessionHeaders(_ contentType: String = "application/json") -> [String:String] {
        
        var defaultHeaders = [String:String]()
        defaultHeaders["Content-Type"] = contentType
        defaultHeaders["Accept"] = "application/json"
        //defaultHeaders["Accept-Encoding"] = "gzip"
        
//        if let sessionToken = SessionManager.shared.user?.bearerToken, !sessionToken.isEmpty {
//            defaultHeaders["Authorization"] = "Bearer \(sessionToken)"
//        }
        
        return defaultHeaders
    }
    
    
    //MARK: - braintree methods
    func generateBraintreeRequest(reqURL: String, isAccessToken: Bool = false, reqHTTPMethod: HTTPRequestType, reqBodyData: Any?, responseCallBack: @escaping braintreeCompletionHandler) {
        
        if reqBodyData != nil {
            DLog("API Request Data ==> \(reqBodyData!)")
        }
        
        let apiURL = "\(reqURL)"
        DLog("API URL ==> \(apiURL)")
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = reqHTTPMethod == .post ? "POST" : reqHTTPMethod == .put ? "PUT" : reqHTTPMethod == .delete ? "DELETE" : "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if reqBodyData != nil {
            
            var jsonData: Data! = nil
            do {
                jsonData = try JSONSerialization.data(withJSONObject: reqBodyData!, options: [])
                request.httpBody = jsonData
                
                let requestJSON = String(data: jsonData, encoding: String.Encoding.utf8)
                DLog("JSON Request ==> \(requestJSON!)")
            }
            catch {
                DLog("Array to JSON conversion failed: \(error.localizedDescription)")
            }
        }
        
        request.allHTTPHeaderFields = getUserSessionHeaders()
        self.braintreeRequestToServer(vpnRequest: request, responseCallBack: responseCallBack)
    }
    
    private func braintreeRequestToServer(vpnRequest: URLRequest, responseCallBack: @escaping braintreeCompletionHandler) {
        
        let manager: Session = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = APIServerConstants.serverTimeout

        //Request to Server
        manager.request(vpnRequest)
            .responseJSON { response in
                
                switch response.result {
                case .failure(let error):
                    DLog("Error ==> \(error)")
                    
                case .success(let responseObject):
                    DLog("Request ==> \((vpnRequest.url)!)\n Response ==> \(responseObject)")
                }
                
                if let httpError = response.error {
                    
                    //TODO: HTTP ERROR
                    let statusCode = httpError._code
                    
                    //TODO: HTTP - Authentication Required 🤔
                    if statusCode == 401 {
                        
                        let errorMsg = "Authentication Required"
                        responseCallBack(false, nil, errorMsg)
                        return
                    }
                    else {
                        //TODO: HTTP - Another Error
                        //Callback
                        let errorMsg = "Authentication Required"
                        responseCallBack(false, nil, errorMsg)
                        return
                    }
                }
                else {
                    //TODO: Valid API Response - Data Parsing 😇
                    //Data Parsing
                    do {
                        if let data = response.data {
                            
                            let dictResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            if let success = (dictResponse?.value(forKey: responseKeySuccess) as? Int), success == 200 {
                                print("Success status - \(success)")

                                if let data = dictResponse?.value(forKey: responseKeyData) {
                                    
                                    let dataResponse = try! JSONSerialization.data(withJSONObject: data, options: [])
                                    responseCallBack(true, dataResponse, "Success")
                                }
                                else{
                                    let errorMsg = "Relavant data not found"
                                    responseCallBack(false, nil, errorMsg)
                                }
                            }
                            else {
                                var errorMessage = "Something went wrong"
                                if let error = dictResponse?.value(forKey: responseKeyErrorMessage) as? [String], error.count > 0 {
                                    errorMessage = error[0]
                                }
                                
                                //Callback
                                responseCallBack(false, data, errorMessage)
                            }
                        }
                        else {
                            //Callback
                            let errorMsg = "Data not found"
                            responseCallBack(false, nil, errorMsg)
                        }
                    }
                    catch {
                        //Callback
                        responseCallBack(false, nil, error.localizedDescription)
                    }
                }
        }
    }

}

extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}
