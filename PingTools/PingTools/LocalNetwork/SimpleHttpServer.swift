//
//  SimpleHttpServer.swift
//  PingTools
//
//  Created by zhujt on 2024/4/18.
//

import UIKit
import Swifter

class SimpleHttpServer: NSObject {
    static let PORT: in_port_t = 8484
    static let shared = SimpleHttpServer()
    
    private let server = HttpServer()
    
    private override init() {}
    
    func start(_ result: ((Bool) -> Void)?) {
        do {
            // 开启本地HTTP服务
            try server.start(SimpleHttpServer.PORT, forceIPv4: true)
            server["/"] = { _ in
                return .ok(.text("Local Server"))
            }
            print("开启本地HTTP服务--port: \(SimpleHttpServer.PORT).")
            result?(true)
        } catch {
            result?(false)
        }
    }
    
    func stop() {
        server.stop()
        print("关闭本地HTTP服务")
    }
}
