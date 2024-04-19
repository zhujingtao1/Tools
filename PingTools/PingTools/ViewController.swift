//
//  ViewController.swift
//  PingTools
//
//  Created by zhujt on 2024/4/11.
//

import UIKit

class ViewController: UIViewController {
    var success = [Int]()
    var failed = [Int]()
    let queue = DispatchQueue(label: "com.aiswei.q", attributes: .concurrent)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func startPing(_ sender: Any) {
//        PingTools.ping(ipPrefix: "192.168.200") { ipAddress, success in
////            print(ipAddress)
//        }
//        PingTools.testPing(ip: "192.168.200.209") { pong, error in
//            print("\(pong)--\(error)")
//        }
        
        LocalNetworkPermission.shared.getPermissionState(with: "192.168.200.127") { state in
            if state == .grant {
                print("已授权本地网络")
            }else if state == .deniedOrNotDetermined {
                print("等待授权或已关闭")
            }else {
                print("未知")
            }
        }
    }
}

