//
//  AttachmentViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 22/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachmentViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview1;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
