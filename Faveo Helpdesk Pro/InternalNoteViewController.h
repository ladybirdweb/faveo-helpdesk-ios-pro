//
//  InternalNoteViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 06/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class InternalNoteViewController
 
 @brief This class used for adding internal note to the ticket.
 
 @discussion This note is added for internal message which is visible to only agents/admins not to user.
 
 */
@interface InternalNoteViewController : UITableViewController

/*!
 @property tableview1
 
 @brief This is tableView property.
 
 @discussion This property used for some internal purpose while showing/adding into tableView and tableViewCells
 */
@property (strong, nonatomic) IBOutlet UITableView *tableview1;

/*!
 @property contentTextView
 
 @brief This is textView property.
 
 @discussion This property used to take input data (internal message/content) from the agent/admin.
 */
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

/*!
 @property label
 
 @brief This is label property used to show an label.
 */
@property (weak, nonatomic) IBOutlet UILabel *label;

/*!
 @property addButton
 
 @brief This is button property
 */
@property (weak, nonatomic) IBOutlet UIButton *addButton;

/*!
 @property noteTitleLabel
 
 @brief This is label property used to show some label.
 */
@property (weak, nonatomic) IBOutlet UILabel *noteTitleLabel;

/*!
 @property noteContentLabel
 
 @brief This is label property used to show some label.
 */
@property (weak, nonatomic) IBOutlet UILabel *noteContentLabel;


/*!
 @method addButtonAction
 
 @brief This is an button action method.
 
 @discussion After clicking this button add internal note API called.
 
 @code
 
- (IBAction)addButtonAction:(id)sender;
 
 @endcode
  */
- (IBAction)addButtonAction:(id)sender;

@end
