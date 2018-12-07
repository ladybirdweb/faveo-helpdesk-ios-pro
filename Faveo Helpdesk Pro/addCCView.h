//
//  addCCView.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 06/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class addCCView
 
 @brief This class used to add cc to the particular ticket.
 
 @discussion Here user can able to search the cc that he wants to add to the ticket. After giving some input it will show some dropdown menu which contains list of user, once user selected any one of the cc then it will be added to the ticket after clickinng on add button on same view.
 
 */
@interface addCCView : UITableViewController

/*!
 @property tablview
 
 @brief This is tableView property used for some internal implementation purpose.
 */
@property (strong, nonatomic) IBOutlet UITableView *tablview;

/*!
 @property userSearchTextField
 
 @brief This is textField property used to type some data.
 */
@property (weak, nonatomic) IBOutlet UITextField *userSearchTextField;

/*!
 @property addButton
 
 @brief This is button property used to perform some action after adding/selecting an cc it will add cc to the ticket.
 */
@property (weak, nonatomic) IBOutlet UIButton *addButton;

/*!
 @property searchLabel
 
 @brief This is label property used show an label name call Search CC.
 */
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;

/*!
 @method addCCMethod
 
 @brief This is an button action.
 
 @discussion After clicking this button add cc API will call.
 @code
 
 - (IBAction)addCCMethod:(id)sender;
 
 @endcode
  */
- (IBAction)addCCMethod:(id)sender;

@end

