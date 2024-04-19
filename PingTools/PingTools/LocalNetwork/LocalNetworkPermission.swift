//
//  LocalNetworkPermission.swift
//
//  Created by zhujt on 2024/4/18.
//

import UIKit
import Network

@available(iOSApplicationExtension 12.0, *)
public class LocalNetworkPermission: NSObject {
    
    enum LocalNetworkPermissionState {
        ///已授权
        case grant
        ///拒绝或等待授权
        case deniedOrNotDetermined
        ///未知
        case unkonw
    }
    
    static let shared = LocalNetworkPermission()
    private override init() {}
    
    private var connection: NWConnection?
    
    /// 获取本地网络权限
    /// - Parameters:
    ///   - ip: 当前IP地址
    ///   - completed: 权限回调 LocalNetworkPermission.LocalNetworkPermissionState
    func getPermissionState(with ip: String, completed: ((LocalNetworkPermissionState) -> Void)?) {
        self.checkRouterPathStatus(by: ip) {[weak self] status in
            if status == .satisfied {
                completed?(.grant)
            }else if status == .unsatisfied {
                completed?(.deniedOrNotDetermined)
            }else {
                completed?(.unkonw)
            }
            self?.connection?.cancel()
        }
    }
    
    private func checkRouterPathStatus(by ip: String, pathUpdateHandler: ((_ status: NWPath.Status) -> Void)?) {
        let host = NWEndpoint.Host(ip)
        let port = NWEndpoint.Port.any
        connection = NWConnection(host: host, port: port, using: .tcp)
        ///当前路由路径是否可用
        connection?.pathUpdateHandler = { path in
            pathUpdateHandler?(path.status)
        }
        
        // 开始连接
        connection?.start(queue: .global())
    }

}
