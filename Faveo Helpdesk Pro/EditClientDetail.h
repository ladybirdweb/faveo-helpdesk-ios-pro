//
//  EditClientDetail.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 21/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class EditClientDetail
 
 @brief This class used for edit user profile/data.
 
 @discussion This class contains number of textFields like name, email, username...etc so you can able to modify/update its contents.
 
 */
@interface EditClientDetail : UITableViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

/*!
 @property userNameTextField
 
 @brief This is an textField property
 
 @discussion This property is used to show user name or take new username from the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

/*!
 @property firstNameTextField
 
 @brief This is an textField property
 
 @discussion This property is used to show first name or take new first from the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;

/*!
 @property lastNameTextField
 
 @brief This is an textField property
 
 @discussion This property is used to show last name or take new last name from the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

/*!
 @property emailTextField
 
 @brief This is an textField property
 
 @discussion This property is used to show user email id or take new email id from the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

/*!
 @property phoneTextField
 
 @brief This is an textField property
 
 @discussion This property is used to show user phone number or take new phone number from the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

/*!
 @property mobileTextField
 
 @brief This is an textField property
 
 @discussion This property is used to show user mobile number or take new mobile number from the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;

/*!
 @property userStateChangeView
 
 @brief This is an view property
 
 @discussion This property used show user state.
 */
@property (weak, nonatomic) IBOutlet UIView *userStateChangeView;

/*!
 @property submitButton
 
 @brief This button property used to perform some actions.
 */
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end
