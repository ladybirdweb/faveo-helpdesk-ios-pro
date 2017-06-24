//
//  ConversationTableViewCell.h
//  SideMEnuDemo
//
//  Created by Narendra on 25/10/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

/*!
 @header ClientListTableViewCell.h
 @brief This is the header file contain conversation deatils.
 @author Mallikarjun
 @copyright 2015 Ladybird Web Solution Pvt Ltd.
 @version 1.6
 */

#import <UIKit/UIKit.h>

@interface ConversationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UILabel *clientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *internalNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
-(void)setUserProfileimage:(NSString*)imageUrl;
@end
