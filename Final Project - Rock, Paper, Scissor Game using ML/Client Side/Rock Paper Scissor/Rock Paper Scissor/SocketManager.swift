//
//  SocketManager.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/6/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import Foundation
import Starscream

// Socket Manager Protocol so that other classes can access all important messages from server via socket
protocol SocketManagerDelegate {
    func getData(data: Data)
    func getmessage(message: String)
    func connectionSuccessful(isConnected: Bool)
    func connectionDisconnected(isDisConnected: Bool)
}

// Socket Manager to manage the socket connection with the client
public class SocketManager{

    static var sharedInstance: SocketManager! = nil
    var socket = WebSocket(url: URL(string: "\(SERVER_URL)/ws")!)
    var delegate: SocketManagerDelegate! = nil
    
    
    public static func getSharedInstanceSocket() -> SocketManager{
        if(sharedInstance == nil){
            return SocketManager()
        }
        return sharedInstance!
    }
    
    init(){
        self.connectToSocket()
        self.disconnectFromSocket()
        self.receiveDataFromSocket()
        self.receiveMessageFromSocket()
        
    }
    
    // Call back for socket connection
    public func connectToSocket(){
        socket.onConnect = {
            //websocketDidConnect
            print("\(String(describing: self.delegate))")
            self.delegate?.connectionSuccessful(isConnected: true)
            print("websocket is connected")
        }
    }
    
    public func disconnectFromSocket(){
        //websocketDidDisconnect
        socket.disconnect()
        socket.onDisconnect = { (error: Error?) in
            self.delegate?.connectionDisconnected(isDisConnected: true)
            print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
        }
    }
    
    
    public func receiveMessageFromSocket(){
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
            print("got some text: \(text)")
            self.delegate?.getmessage(message: text)
        }
    }
    
    public func receiveDataFromSocket(){
        //websocketDidReceiveData
        socket.onData = { (data: Data) in
            self.delegate?.getData(data: data)
            print("got some data: \(data.count)")
        }
    }
    
    

    
}

