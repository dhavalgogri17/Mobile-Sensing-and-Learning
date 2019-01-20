//
//  AvailablePlayerList.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/6/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import Foundation


// class which stores players information in 2-player amd Tournament mode
public class AvailablePlayerList{
    var gameName: String = ""
    var userName: String = ""
    
    init(gameName: String, userName: String){
        self.gameName = gameName
        self.userName = userName
    }
    
    public func setGameName(gameName: String){
        self.gameName = gameName
    }
    
    public func setUserName(userName: String){
        self.userName = userName
    }
    
    func getGameName() -> (String) {
        return self.gameName
    }
    
    func getUserName() -> (String) {
        return self.userName
    }
    
    
}
