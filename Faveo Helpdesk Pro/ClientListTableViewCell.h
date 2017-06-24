//
//  ClientListTableViewCell.h
//  SideMEnuDemo
//
//  Created by Narendra on 02/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

/*!
 @header ClientListTableViewCell
 @brief This is the header file contain variable declarations related Client.
 @author Mallikarjun
 @copyright 2015 Ladybird Web Solution Pvt Ltd.
 @version 1.6
 */

#import <UIKit/UIKit.h>

@interface ClientListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *clientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;
-(void)setUserProfileimage:(NSString*)imageUrl;
@end
