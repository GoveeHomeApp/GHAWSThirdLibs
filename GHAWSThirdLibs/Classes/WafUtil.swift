//
//  WafUtil.swift
//  WafUtil
//
//  Created by abiaoyo on 2024/4/18.
//

import Foundation
import WafMobileSdk

@objcMembers
public class WafUtil: NSObject {
    
    public static let shared = WafUtil()
    
    private let domain_name = "dev-app2.govee.com"
    private let acl_url_string = "https://a984f4f6448a.us-east-1.sdk.awswaf.com/a984f4f6448a/0b7c5b5291f0/"
    
    private(set) lazy var acl_url:URL = URL(string: acl_url_string)!
    
    private(set) var tokenProvider:WAFTokenProvider?
    
    public var onRefreshToken:((_ aws_waf_token:String) -> Void)?
    
    public func startup() {
        guard tokenProvider == nil else {
            print("WAFUtil.startup(): tokenProvider 不能重复创建")
            return
        }
        guard let configuration = WAFConfiguration(applicationIntegrationUrl: acl_url, domainName: domain_name, setTokenCookie: false) else {
            print("WAFUtil.startup(): configuration 初始化失败")
            return
        }
        tokenProvider = WAFTokenProvider(configuration)
        tokenProvider?.onTokenReady { [weak self] token, error in
            guard let tokenValue:String = token?.value else {
                print("WafUtil: -> onTokenReady -> failure .token:\(String(describing: token))  error:\(String(describing: error))")
                return
            }
            print("WafUtil: -> onTokenReady -> success .token:\(tokenValue)")
            self?.onRefreshToken?(tokenValue)
        }
    }
    public func getToken() -> String? {
        tokenProvider?.getToken()?.value
    }
}
