//
//  PingTools.swift
//  PingTools
//
//  Created by zhujt on 2024/4/11.
//

import UIKit

class PingTools: NSObject {
    static var IP_Prefix = ""
    static let IP_Start_HostID = 2
    static let IP_End_HostID = 254
    private static var ConcurrentCount = 30
    /// ping 成功的地址
    private static var completedClourse: ((_ ipAddress: String, _ success: Bool) -> Void)?
    ///ping 结果
    typealias PingResultClourse = (_ pong: Bool, _ error: Error?) -> Void
    private var resultClourse: PingResultClourse?
    private var pingDelegater: SimplePingDelegater?
    private var concurrentCount: Int = 30
    
    class func ping(ipPrefix: String, concurrentCount: Int = 30, success: ((_ ipAddress: String, _ success: Bool) -> Void)?) {
        ConcurrentCount = concurrentCount
        IP_Prefix = ipPrefix
        completedClourse = success
        concurrentPings(start: IP_Start_HostID)
    }
    
    class func testPing(ip: String, completed: PingResultClourse?) {
        let pingTools = PingTools()
        pingTools.pingDelegater = SimplePingDelegater()
        pingTools.pingDelegater?.delegate = pingTools
        pingTools.resultClourse = completed
        pingTools.pingDelegater?.startPing(ip, timeout: 3)
    }
    
    private class func concurrentPings(start: Int) {
        guard start <= IP_End_HostID else {
            return
        }

        let end = min(start + ConcurrentCount, IP_End_HostID + 1)
        let group = DispatchGroup()

        for i in start..<end {
            group.enter()
            let pingTools = PingTools()
            pingTools.ping("\(IP_Prefix).\(i)") { pong, error in
                if let error = error as? NSError {
                    if error.code == -999 {
                        print("超时-----\(IP_Prefix).\(i)")
                    }else {
                        print("找不到-----\(IP_Prefix).\(i)")
                    }
                }
                if pong {
                    print("成功-----\(IP_Prefix).\(i)")
                }
                completedClourse?("\(IP_Prefix).\(i)", pong)
                group.leave()
            }
            
        }

        group.notify(queue: .main) {
            concurrentPings(start: end)
        }
    }

    
    func ping(_ hostName: String, withTimeout timeout: TimeInterval = 3, completed: PingResultClourse?) {
        pingDelegater = SimplePingDelegater()
        pingDelegater?.delegate = self
        resultClourse = completed
        pingDelegater?.startPing(hostName, timeout: timeout)
    }
    
    deinit {
//        print("PingTools释放了")
    }
}

extension PingTools: PingDelegaterDelegate {
    func didSendPing() {
        // do something
    }
    
    func didReceivePong() {
        self.resultClourse?(true, nil)
        // 解除循环引用链，释放PingTools
        pingDelegater?.delegate = nil
        pingDelegater = nil
    }
    
    func didFailPingWithError(_ error: Error) {
        self.resultClourse?(false, error)
        // 解除循环引用链，释放PingTools
        pingDelegater?.delegate = nil
        pingDelegater = nil
    }
}
