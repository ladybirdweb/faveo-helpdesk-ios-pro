//
//  NotificationTableViewCell.h
//  Faveo Helpdesk Pro
//
//  Created by Narendra on 14/07/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell

/*!
 @property profilePicView
 
 @brief This is an imageView property.
 
 @discussion It is used to show user profile picture.
 */
@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;

/*!
 @property timelbl
 
 @brief This is an label property.
 
 @discussion It is used to show time when notification is created/generated.
 */
@property (weak, nonatomic) IBOutlet UILabel *timelbl;

/*!
 @property msglbl
 
 @brief This is an label property.
 
 @discussion It is used to show/display notification message.
 */
@property (weak, nonatomic) IBOutlet UILabel *msglbl;

/*!
 @property indicationView
 
 @brief This is an view property.
 
 @discussion It is used to show/display/present some ui property.
 */
@property (weak, nonatomic) IBOutlet UIView *indicationView;

/*!
 @property name
 
 @brief This is an label property.
 
 @discussion It is used to show/display user name.
 */
@property (weak, nonatomic) IBOutlet UILabel *name;

/*!
 @property viewMain
 
 @brief This is an view property.
 
 @discussion It is used to show/display/present view.
 */
@property (weak, nonatomic) IBOutlet UIView *viewMain;

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
