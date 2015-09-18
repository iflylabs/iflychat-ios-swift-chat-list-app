//
//  ApplicationSettings.swift
//  iFlyChatGlobalListSwiftView
//
//  Created by Prateek Grover on 16/09/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

import UIKit

class ApplicationSettings {
    
    var usersTabTopBarTitle:String!
    var roomsTabTopBarTitle:String!
    
    static let sharedInstance = ApplicationSettings()
    
    private init()
    {
        usersTabTopBarTitle = "Chats";
        roomsTabTopBarTitle = "Chats"
    }
    
    func setUsersTabTopBarTitle(usersTabTopBarTitleText:String)
    {
        usersTabTopBarTitle = usersTabTopBarTitleText;
    }
    
    func getUsersTabTopBarTitle()->String
    {
        return usersTabTopBarTitle;
    }
    
    func setRoomsTabTopBarTitle(roomsTabTopBarTitleText:String)
    {
        roomsTabTopBarTitle = roomsTabTopBarTitleText;
    }
    
    func getRoomsTabTopBarTitle()->String
    {
        return roomsTabTopBarTitle;
    }
}
