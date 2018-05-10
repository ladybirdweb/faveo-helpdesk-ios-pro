//
//  ViewCCList.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 04/05/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewCCList : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview1;

@property (weak, nonatomic) IBOutlet UIButton *removeCCLabel;

- (IBAction)removeCCButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *removeFinalLabel;

- (IBAction)removeFinalButton:(id)sender;



@end
