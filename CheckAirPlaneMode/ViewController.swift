//
//  ViewController.swift
//  CheckAirPlaneMode
//
//  Created by Wataru Miyakoshi on 2024/04/15.
//

import UIKit
import Network

class ViewController: UIViewController {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    private let connectionStatusLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let interfaceTypeLabel:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setUpNetworkPathMonitoring()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        stopNetworkPathMonitoring()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(connectionStatusLabel)
        NSLayoutConstraint.activate([
            connectionStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectionStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        view.addSubview(interfaceTypeLabel)
        NSLayoutConstraint.activate([
            interfaceTypeLabel.topAnchor.constraint(equalTo: connectionStatusLabel.bottomAnchor),
            interfaceTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setUpNetworkPathMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                Task { @MainActor [weak self] in
                    self?.connectionStatusLabel.text = "接続中"
                }
            } else {
                Task { @MainActor [weak self] in
                    self?.connectionStatusLabel.text = "接続解除"
                    self?.interfaceTypeLabel.text = "NOT CONNECTED"
                }
                return
            }
            
            if path.usesInterfaceType(.wifi) {
                Task { @MainActor [weak self] in
                    self?.interfaceTypeLabel.text = "Wi-Fi"
                }
            } else if path.usesInterfaceType(.cellular) {
                Task { @MainActor [weak self] in
                    self?.interfaceTypeLabel.text = "Cellular"
                }
            } else if path.usesInterfaceType(.wiredEthernet) {
                Task { @MainActor [weak self] in
                    self?.interfaceTypeLabel.text = "Wired Ethrenet"
                }
            } else if path.usesInterfaceType(.loopback) {
                Task { @MainActor [weak self] in
                    self?.interfaceTypeLabel.text = "local loopback"
                }
            } else if path.usesInterfaceType(.other) {
                Task { @MainActor [weak self] in
                    self?.interfaceTypeLabel.text = "virtual networks or networks or unknown types"
                }
            }
        }
    }
    
    private func stopNetworkPathMonitoring() {
        monitor.cancel()
    }
}

