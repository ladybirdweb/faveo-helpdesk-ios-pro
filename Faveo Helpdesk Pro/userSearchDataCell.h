//
//  userSearchDataCell.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 10/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class userSearchDataCell
 
 @brief It used show user list/data.
 
 @discussion This tableViewCell class used show an basic information of the user.
 
 @superclass UITableViewCell
 */
@interface userSearchDataCell : UITableViewCell

/*!
 @property userProfileImage
 
 @brief This imageView property used to show user profile picture.
 */
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;

/*!
 @property userNameLabel
 
 @brief This lable property used to show user name.
 */
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

/*!
 @property emalLabel
 
 @brief This lable property used to show user email.
 */
@property (weak, nonatomic) IBOutlet UILabel *emalLabel;


/*!
 @method setUserProfileimage
 
 @param imageUrl This in an url which in string format.
 
 @discussion This method used for displaying a profile picture of a user. It uses a url, and from that url it takes an image and displayed in view.
 
 @code
 [self.profilePicView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
 placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
 */
-(void)setUserProfileimage:(NSString*)imageUrl;

@end
