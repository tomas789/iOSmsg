//
//  RabbitConnector.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation
import RMQClient

class RabbitConnector: NSObject, RMQConnectionDelegate {
    var connection: RMQConnection?
    var connected = false
    var reconnecting = false
    var channel: RMQChannel?
    var modules = [ModuleProtocol]()
    var exchanges = [String: RMQExchange]()
    
    var connectionStatistic = TextStatistics(label: "Connection status", message: "Not connected")
    
    override init() {
        super.init()
        
        let imuModule = ImuModule(connector: self)
        modules.append(imuModule)
        
        let cameraModule = CameraModule(connector: self, cameraPosition: .back)
        modules.append(cameraModule)
    }
    
    func getAllModuleStatistics() -> [StatisticsItem] {
        var statistics = [StatisticsItem]()
        for module in modules {
            statistics.append(contentsOf: module.statistics)
        }
        return statistics
    }
    
    func getAllModuleSettings() -> [ModuleSettingProtocol] {
        var settings = [ModuleSettingProtocol]()
        for module in modules {
            settings.append(contentsOf: module.settings)
        }
        return settings
    }
    
    func connect(host: String, port: Int, username: String, password: String) {
        let connUri = connectionString(host: host, port: port, username: username, password: password)
        connection = RMQConnection(uri: connUri, delegate: self)
        self.connectionStatistic.message = "Connecting"
        connection!.start {
            self.connectionStatistic.message = "Connected"
            self.connected = true
            self.reconnecting = false
            self.channel = self.connection?.createChannel()
            
            for module in self.modules {
                module.start()
            }
        }
    }
    
    func disconnect() {
        for module in modules {
            module.stop()
        }
        connection?.blockingClose()
        connectionStatistic.message = "Disconnected"
        connected = false
        reconnecting = false
        connection = nil
        channel = nil
    }
    
    func sendMessage(exchangeName: String, message: Data) {
        guard let exchange = getExchange(name: exchangeName) else { return }
        exchange.publish(message)
    }
    
    func getExchange(name: String) -> RMQExchange? {
        guard connected == true else { return nil }
        if let exchange = exchanges[name] {
            return exchange;
        } else {
            guard let channel = self.channel else { return nil }
            let exchange = channel.fanout(name)
            exchanges[name] = exchange
            return exchange
        }
    }
    
    private func connectionString(host: String, port: Int, username: String, password: String) -> String {
        return "amqp://\(username):\(password)@\(host):\(port)"
    }
    
    // MARK: RMQConnectionDelegate
    
    /// @brief Called with any channel-level AMQP exception.
    public func channel(_ channel: RMQChannel!, error: Error!) {
        connectionStatistic.message = error.localizedDescription
        disconnect()
    }
    
    /*!
     * @brief Called when <a href="http://www.rabbitmq.com/api-guide.html#recovery">automatic connection recovery</a> has succeeded.
     * @param RMQConnection the connection instance that was recovered.
     */
    public func recoveredConnection(_ connection: RMQConnection!) {
        connected = true
        reconnecting = false
        connectionStatistic.message = "Connected"
    }
    
    /// @brief Called after the configured <a href="http://www.rabbitmq.com/api-guide.html#recovery">automatic connection recovery</a> sleep.
    public func startingRecovery(with connection: RMQConnection!) {
        connected = false
        reconnecting = true
        connectionStatistic.message = "Reconnecting ..."
    }
    
    /// @brief Called before the configured <a href="http://www.rabbitmq.com/api-guide.html#recovery">automatic connection recovery</a> sleep.
    public func willStartRecovery(with connection: RMQConnection!) {
        
    }
    
    /// @brief Called when a socket cannot be opened, or when AMQP handshaking times out for some reason.
    public func connection(_ connection: RMQConnection!, disconnectedWithError error: Error!) {
        connectionStatistic.message = error.localizedDescription
        disconnect()
    }
    
    /// @brief Called when a socket cannot be opened, or when AMQP handshaking times out for some reason.
    public func connection(_ connection: RMQConnection!, failedToConnectWithError error: Error!) {
        connectionStatistic.message = error.localizedDescription
        disconnect()
    }
}
