//
//  AttachmentViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 22/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class AttachmentViewController
 
 @brief This class used show attachments.
 
 @discussion This class contains a tableView and webView. If tickets contains an attachment then in this class it show its list. When user clicks on any attachment row (if it contains more than 1 attachments) then below tableView that attachment will open in webView, depening upon attachment type it will open/show/play on webView.
 
 */
@interface AttachmentViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

/*!
 @property tableview1
 
 @brief This is an tableView property
 
 @discussion This property used to show attachments list.
 */
@property (weak, nonatomic) IBOutlet UITableView *tableview1;

/*!
 @property webView
 
 @brief This is an webView property
 
 @discussion This property used to show/open attachments.
 */
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
