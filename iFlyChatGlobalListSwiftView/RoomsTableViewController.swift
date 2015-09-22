//
//  RoomsTableViewController.swift
//  iFlyChatGlobalListSwiftView
//
//  Created by iFlyLabs on 04/08/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

import UIKit


class RoomsTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate
{
    var resultsArray: NSArray!
    var roomArray: iFlyChatOrderedDictionary!
    var dtclass: DataClass!
    var appSettings: ApplicationSettings!
    var fetchImage: dispatch_queue_t!
    var roomImageCache: NSCache!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dtclass = DataClass.sharedInstance
        appSettings = ApplicationSettings.sharedInstance
        
        appSettings.setRoomsTabTopBarTitle("Chats")
        
        resultsArray = []
        roomArray = iFlyChatOrderedDictionary()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero);
        
        self.tableView.tableHeaderView = self.searchDisplayController!.searchBar;
        
        
        var nib: UINib = UINib(nibName: "GlobalListTableViewCell", bundle:nil)
        
        self.tableView.registerNib(nib, forCellReuseIdentifier: "GlobalListCell")
        
        self.searchDisplayController?.searchResultsTableView.registerNib(nib, forCellReuseIdentifier: "GlobalListCell")
                
        fetchImage = dispatch_queue_create("fetchImage", DISPATCH_QUEUE_SERIAL);
        
        roomImageCache = NSCache()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationItem.title = appSettings.getRoomsTabTopBarTitle()
        
        self.refreshRoomList()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "refreshRoomList",
            name: "onUpdatedGlobalList",
            object: nil)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: "onUpdatedGlobalList",
            object: nil
        )
    }
    
    func refreshRoomList()
    {
        if(dtclass.updatedRoomList == true && resultsArray.count == 0)
        {
            roomArray = dtclass.getUpdatedRoomList()
            dtclass.setUpdatedRoomListBool(false)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if (resultsArray.count != 0)
        {
            return resultsArray.count
        }
        
        return roomArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.separatorInset.bottom = 0
        tableView.separatorInset.left = 70
        tableView.separatorInset.right = 0
        tableView.separatorInset.top = 0
        
        
        var cell = tableView.dequeueReusableCellWithIdentifier("GlobalListCell") as? GlobalListTableViewCell

        var currentRoom: iFlyChatRoom
        
        if(resultsArray.count != 0 && tableView.isEqual(self.searchDisplayController?.searchResultsTableView))
        {
            currentRoom = resultsArray.objectAtIndex(indexPath.row) as! iFlyChatRoom
        }
        else
        {
            currentRoom = roomArray.objectAtIndex(UInt(indexPath.row)) as! iFlyChatRoom
        }
        
        cell!.nameLabel.text = currentRoom.getName();
        cell!.timeLabel.text = "5 pm";
        
        if roomImageCache.objectForKey(currentRoom.getId()) == nil
        {
            if(!currentRoom.getAvatarUrl().isEmpty)
            {
                dispatch_async(fetchImage, { () -> Void in
                self.loadImagesWithURL("http:"+currentRoom.getAvatarUrl(), indexPath: indexPath, activeTableView:tableView, roomId:currentRoom.getId())
                })
            }
        
            cell!.avatarImage.image = UIImage(named: "defaultRoom.png")
        }
        else
        {
            cell!.avatarImage.image = (roomImageCache.objectForKey(currentRoom.getId()) as! UIImage)
        }
        
        cell!.messageLabel.text = "No message"
        
        return cell!
    }
    
    
    func loadImagesWithURL(imageURL:NSString,indexPath:NSIndexPath, activeTableView:UITableView, roomId:NSString)
    {
        var url:NSURL = NSURL(string: imageURL as String)!
        
        var data:NSData = NSData(contentsOfURL: url)!
        
        var img:UIImage = UIImage(data: data)!
        
        roomImageCache.setObject(img, forKey: roomId)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if let cell = activeTableView.cellForRowAtIndexPath(indexPath) as? GlobalListTableViewCell
            {
                cell.avatarImage.image = img
            }
        })
        
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 60
    }
    
    func filterContentForSearchText(searchText:String)
    {
        resultsArray = NSArray()
        
        var resultPredicate:NSPredicate = NSPredicate(format: "SELF.getName contains[c] %@", searchText)
        
        resultsArray = roomArray.filteredArrayUsingPredicate(resultPredicate)
    }
    
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool
    {
        self.filterContentForSearchText(searchString)
        
        return true;
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.text = ""
        
        if(dtclass.updatedRoomList == true)
        {
            roomArray = dtclass.getUpdatedRoomList()
            dtclass.setUpdatedRoomListBool(false)
            self.tableView.reloadData()
        }
    }
    
    
}

