//
//  TicketTableViewCell.h
//  SideMEnuDemo
//
//  Created by Narendra on 19/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

/*!
 @header TicketTableViewCell.h
 @brief This is the header file contain variable declarations related to tickets.
 @author Mallikarjun
 @copyright 2015 Ladybird Web Solution Pvt Ltd.
 @version 1.6
 */
#import <UIKit/UIKit.h>

@interface TicketTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UIView *indicationView;
@property (weak, nonatomic) IBOutlet UILabel *ticketIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketSubLabel;
@property (weak, nonatomic) IBOutlet UILabel *overDueLabel;
-(void)setUserProfileimage:(NSString*)imageUrl;
@end
