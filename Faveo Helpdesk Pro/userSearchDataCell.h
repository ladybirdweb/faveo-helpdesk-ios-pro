//
//  userSearchDataCell.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 10/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userSearchDataCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
-(void)setUserProfileimage:(NSString*)imageUrl;
@end
