//
//  UsersTableViewController.swift
//  iFlyChatGlobalListSwiftView
//
//  Created by Prateek Grover on 04/08/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

import UIKit


class UsersTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate
 {
    var resultsArray: NSArray!
    var userArray: iFlyChatOrderedDictionary!
    var dtclass: DataClass!
    var appSettings: ApplicationSettings!
    var fetchImage: dispatch_queue_t!
    var userImageCache: NSCache!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Getting singleton instances of DataClass and ApplicationSettings
        dtclass = DataClass.sharedInstance
        appSettings = ApplicationSettings.sharedInstance
        
        //Setting the Top bar title for Users Tab
        appSettings.setUsersTabTopBarTitle("Chats")
        
        //Instantiating resultsArray and userArray
        self.resultsArray = []
        self.userArray = iFlyChatOrderedDictionary()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero);
        
        //Adding a search bar on top of table view
        self.tableView.tableHeaderView = self.searchDisplayController!.searchBar;
        
        //Registering custom UITableViewCell for table view and search results table view
        var nib: UINib = UINib(nibName: "GlobalListTableViewCell", bundle:nil)
        
        self.tableView.registerNib(nib, forCellReuseIdentifier: "GlobalListCell")
        
        self.searchDisplayController?.searchResultsTableView.registerNib(nib, forCellReuseIdentifier: "GlobalListCell")
        
        //Initializing iFlyChat
        dtclass.initiFlyChatLibrary()
        
        //Instantiating a queue for image downloads
        fetchImage = dispatch_queue_create("fetchImage", DISPATCH_QUEUE_SERIAL);
        
        //Instantiating cache to store downloaded images
        userImageCache = NSCache()
    }

    override func viewWillAppear(animated: Bool)
    {
        //Setting the top bar title
        self.navigationItem.title = appSettings.getUsersTabTopBarTitle()
        
        //Putting the data inside the table view
        self.refreshUserList()
        
        //Registering for the notification that will come from DataClass after library sends the updated Global List
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "refreshUserList",
            name: "onUpdatedUserList",
            object: nil)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        //Removing the observer
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: "onUpdatedUserList",
            object: nil
        )
    }
    
    func refreshUserList()
    {
        //Checking if the userlist is updated or not and user is not searching anything
        if(dtclass.updatedUserList == true && resultsArray.count == 0)
        {
            self.userArray = dtclass.getUpdatedUserList()
            dtclass.setUpdatedUserListBool(false)
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //If the user is searching something, number of rows is equal to search results
        if (resultsArray.count != 0)
        {
            return resultsArray.count
        }
        
        return userArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.separatorInset.bottom = 0
        tableView.separatorInset.left = 70
        tableView.separatorInset.right = 0
        tableView.separatorInset.top = 0
        
                
        var cell = tableView.dequeueReusableCellWithIdentifier("GlobalListCell") as? GlobalListTableViewCell
        
        var currentUser: iFlyChatUser

        //If the user is searching something, take the data from resultsArray otherwise from userArray
        if(resultsArray.count != 0 && tableView.isEqual(self.searchDisplayController?.searchResultsTableView))
        {
            currentUser = resultsArray.objectAtIndex(indexPath.row) as! iFlyChatUser
        }
        else
        {
            currentUser = userArray.objectAtIndex(UInt(indexPath.row)) as! iFlyChatUser
        }
        
        cell!.nameLabel.text = currentUser.getName()
        cell!.timeLabel.text = "5 pm"
        
        //Checking if the image is already downloaded for the user id
        if userImageCache.objectForKey(currentUser.getId()) == nil
        {
            if(!currentUser.getAvatarUrl().isEmpty)
            {
                dispatch_async(fetchImage, { () -> Void in
                
                    //Downloading images asynchronously 
                    self.loadImagesWithURL("http:"+currentUser.getAvatarUrl(), indexPath: indexPath, activeTableView:tableView, userId:currentUser.getId())
                
                })
            }
    
            //If avatar url is empty, set the default image
            cell!.avatarImage.image = UIImage(named: "defaultUser.png")
        }
        else
        {
            //If the image is already downloaded, get it from cache and set it
            cell!.avatarImage.image = (userImageCache.objectForKey(currentUser.getId()) as! UIImage)
        }
        cell!.messageLabel.text = "No message"

        return cell!
    }
    
    
    func loadImagesWithURL(imageURL:NSString,indexPath:NSIndexPath, activeTableView:UITableView, userId:NSString)
    {
        var url:NSURL = NSURL(string: imageURL as String)!
        
        var data:NSData = NSData(contentsOfURL: url)!
        
        var img:UIImage = UIImage(data: data)!
        
        //Inserting downloaded image in cache
        userImageCache.setObject(img, forKey: userId)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            //Setting the image in the correct tableview and in the correct row
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
        
        //Creating a predicate to be used for search
        var resultPredicate:NSPredicate = NSPredicate(format: "SELF.getName contains[c] %@", searchText)
        
        resultsArray = userArray.filteredArrayUsingPredicate(resultPredicate)
    }

    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool
    {
        self.filterContentForSearchText(searchString)
        
        return true;
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.text = ""
        
        //After cancel button for search is pressed, check if user list is updated behind the scene or not. If yes, update it in the view.
        if(dtclass.updatedUserList == true)
        {
            userArray = dtclass.getUpdatedUserList()
            dtclass.setUpdatedUserListBool(false)
            self.tableView.reloadData()
        }
    }


}
