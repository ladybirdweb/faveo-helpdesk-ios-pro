//
//  ReplyTicketViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 06/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class ReplyTicketViewController
 
 @brief This class used to give reply to the ticket.
 
 @discussion In this reply view user can able to see existing cc names and can able to add new cc to the ticket while giving an reply to the ticket.
 
 */
@interface ReplyTicketViewController : UITableViewController


/*!
 @property ccTextField
 
 @brief This textField used to show/update cc data
 */
@property (weak, nonatomic) IBOutlet UITextField *ccTextField;

/*!
 @property messageTextView
 
 @brief This textView used add an message for the ticket.
 */
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

/*!
 @property tableview1
 
 @brief This is tableView instance used for internal purpose.
 */
@property (strong, nonatomic) IBOutlet UITableView *tableview1;

/*!
 @property addCCLabelButton
 
 @brief This is label property and used as an button. After clicking this button it will navigate to the add cc view.
 */
@property (weak, nonatomic) IBOutlet UILabel *addCCLabelButton;

/*!
 @property submitButton
 
 @brief This is button property.
 */
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

/*!
 @property viewCCandRemoveCCLabel
 
 @brief This is label property used as a button and when user clicks on it, it will show a list of cc users.
 */
@property (weak, nonatomic) IBOutlet UILabel *viewCCandRemoveCCLabel;


/*!
 @property fileImage
 
 @brief This is imageView property used to show and icon for the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;

/*!
 @property fileName123
 
 @brief This is label property used to show file name for the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *fileName123;

/*!
 @property fileSize123
 
 @brief This is label property used to show file size for the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *fileSize123;


/*!
 @property viewCCLabel
 
 @brief This is label property used as an button. When user clicks on this label, it will show an list of cc users which are belonging with the tickets.
 */
@property (weak, nonatomic) IBOutlet UILabel *viewCCLabel;

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;


/*!
 @method viewDidLoad
 
 @brief This method used to update the internal methods which are used/called from this methods in order to update and get other details.
 
 @code
 
 -(void)viewDidLoad;
 
 @endcode
 
 */
-(void)viewDidLoad;



/*!
 @method FetchCollaboratorAssociatedwithTicket
 
 @brief This method is called to get data of cc which is attached to the particular ticket.
 
 @code
 
-(void)FetchCollaboratorAssociatedwithTicket;
 
 @endcode
 
 */
-(void)FetchCollaboratorAssociatedwithTicket;


/*!
 @method submitButtonClicked
 
 @brief This method is called when after adding an message to the ticket and adding cc this will add an reply to the ticket.
 
 @code
 
 -(IBAction)submitButtonClicked:(id)sender;

 @endcode
 
 */
-(IBAction)submitButtonClicked:(id)sender;


@end

