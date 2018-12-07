//
//  ClientFilter.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 27/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class ClientFilter
 
 @brief This class used to filter user list.
 
 @discussion Thsi class provides an feature for filtering the user list like agent, clients, active agents, banned users, deactivate users ..etc so according to your choice you can able to select any option and you will get filered data.
 
 */

@interface ClientFilter : UIViewController<RMessageProtocol,AWNavigationMenuItemDataSource, AWNavigationMenuItemDelegate>{

}

/*!
 @property page
 
 @brief This integer property used to store page number.
 */
@property (nonatomic) NSInteger page;

@end
