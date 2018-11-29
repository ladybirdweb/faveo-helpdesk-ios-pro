//
//  SupportViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 27/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class SupportViewController
 
 @brief This class used to implement/get support from the app.
 
 @discussion It contains some textFields which takes some informations from the user and he can able to raise the ticket/ ask for the support to FaveoHelpdesk.com.
 */
@interface SupportViewController : UITableViewController


/*!
 @property emailTextView
 
 @brief This is an textField property
 
 @discussion This property is used to take email id from the user.
 */
@property (weak, nonatomic) IBOutlet UITextView *emailTextView;

/*!
 @property subjectTextView
 
 @brief This is an textField property
 
 @discussion This property is used to take subject from the user.
 */
@property (weak, nonatomic) IBOutlet UITextView *subjectTextView;

/*!
 @property messageTextView
 
 @brief This is an textField property
 
 @discussion This property is used to take message from the user.
 */
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

/*!
 @property tableView1
 
 @brief This is an tableView property

 */
@property (strong, nonatomic) IBOutlet UITableView *tableView1;

/*!
 @property submitButton
 
 @brief This is an button property
 
 */
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


/*!
 @method ButtonClicked
 
 @brief This is an button action method.
 
 @discussion After clickig this method one api called which takes inputs given by the user and created an ticket to support helpdesk to Faveo.
 
 @code
 
 - (IBAction)ButtonClicked:(id)sender;
 
 @endcode
 */
- (IBAction)ButtonClicked:(id)sender;

@end
