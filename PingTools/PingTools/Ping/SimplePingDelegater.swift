//
//  SimplePingDelegater.swift
//  PingTools
//
//  Created by zhujt on 2024/4/11.
//

import UIKit

protocol PingDelegaterDelegate: NSObjectProtocol {
    func didSendPing()
    func didReceivePong()
    func didFailPingWithError(_ error: Error)
}
class SimplePingDelegater: NSObject {
    private let SimplePingErrorDomain = "SimplePing timeout"
    private let SimplePingErrorCode = -999
    private var simplePing: SimplePing?
    ///
    private var pingTimer:Timer?
    /// 超时时间
    private var timeoutDuration:TimeInterval = 3
    var delegate: PingDelegaterDelegate?
}

extension SimplePingDelegater {
    /// 执行ping
    /// hostName: 域名或IP
    func startPing(_ hostName: String, timeout: TimeInterval) {
        timeoutDuration = timeout
        
        simplePing = SimplePing(hostName: hostName)
        simplePing?.delegate = self
        simplePing?.start()
    }
    
    /// 停止ping
    func stopPinging() {
        if let simplePing = simplePing {
            simplePing.stop()
        }
        
        if pingTimer != nil {
            pingTimer?.invalidate()
            pingTimer = nil
        }
    }
    /// 超时
    @objc private func sendPing() {
        timeoutDuration -= 1
        if timeoutDuration < 0 {
            delegate?.didFailPingWithError(NSError(domain: SimplePingErrorDomain, code: SimplePingErrorCode))
            stopPinging()
        }else {
            simplePing?.send(with: nil)
        }
    }
}

extension SimplePingDelegater: SimplePingDelegate {
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        pingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendPing), userInfo: nil, repeats: true)
    }
    
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        delegate?.didSendPing()
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        delegate?.didReceivePong()
        stopPinging()
    }
    
    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        // waiting timeout
    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        delegate?.didFailPingWithError(error)
        stopPinging()
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        delegate?.didFailPingWithError(error)
        stopPinging()
    }
}
