//
//  ConversationTableViewCell.h
//  SideMEnuDemo
//
//  Created by Narendra on 25/10/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//


#import <UIKit/UIKit.h>
/*!
 @class ConversationTableViewCell
 
 @brief It allows you to develop Graphical User Interface.
 
 @discussion This class used for designing and showing conversation between Agent and clients.It is displayed in table view format.
 A table view uses cell objects to draw its visible rows and then caches those objects as long as the rows are visible. Cells inherit from the UITableViewCell class. The table view’s data source provides the cell objects to the table view by implementing the tableView:cellForRowAtIndexPath: method, a required method of the UITableViewDataSource protocol.
 */
@interface ConversationTableViewCell : UITableViewCell

/*!
 @property profilePicView
 
 @brief It is an view used for showing profile picture of user.
 */
@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;

/*!
 @property clientNameLabel
 
 @brief It is label used for definig name of client.
 */
@property (weak, nonatomic) IBOutlet UILabel *clientNameLabel;

/*!
 @property internalNoteLabel
 
 @brief It is label used for definig name of internal note.
 */
@property (weak, nonatomic) IBOutlet UILabel *internalNoteLabel;

/*!
 @property timeStampLabel
 
 @brief It is label used for definig name of time stamp.
 */
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;

/*!
 @method setUserProfileimage
 
 @param imageUrl This in an url which in string format.
 
 @discussion This method used for displaying a profile picture of a user. It uses a url, and from that url it takes an image and displayed in view.
 
 @code
 [self.profilePicView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
 placeholderImage:[UIImage imageNamed:@"default_pic.png"]];

 */
-(void)setUserProfileimage:(NSString*)imageUrl;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *view1;

@end
