//
//  GlobalVariables.h
//  SideMEnuDemo
//
//  Created by Narendra on 30/11/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//



#import <Foundation/Foundation.h>

/*!
 @class GlobalVariables
 
 @brief This class contains Global variable declaration
 
 @discussion It contains variable declaration that are commonly used throughout the app so that accessing and calling is very easy.
       Also it cointans Singleton class that contains global variables and global functions.It’s an extremely powerful way to share data between different parts of code without having to pass the data around manually.
 
 @superclass NSObject
 
 */
@interface GlobalVariables : NSObject

/*!
 @property iD
 
 @brief It is used for defining is id of a ticket.
 */
@property (strong, nonatomic) NSNumber *iD;

/*!
 @property ticket_number
 
 @brief It is used for defining is ticket_number created by user.
 */
@property (strong, nonatomic) NSString *ticket_number;
//@property (strong, nonatomic) NSString *title;

/*!
 @property OpenCount
 
 @brief It shows a count of tickets which are in Open Tickets.
 */
@property (strong, nonatomic) NSString *OpenCount;

/*!
 @property DeletedCount
 
 @brief It shows a count of tickets which are in deleted/trash Tickets.
 */
@property (strong, nonatomic) NSString *DeletedCount;

/*!
 @property ClosedCount
 
 @brief It shows a count of tickets which are in closed Tickets.
 */
@property (strong, nonatomic) NSString *ClosedCount;

/*!
 @property UnassignedCount
 
 @brief It shows a count of tickets which are in Unassigned Tickets.
 */
@property (strong, nonatomic) NSString *UnassignedCount;

/*!
 @property MyticketsCount
 
 @brief It shows a count of tickets which are in my Tickets Tickets i.e the ticket counts those are assigned to Agent.
 */
@property (strong, nonatomic) NSString *MyticketsCount;


@property (strong, nonatomic) NSString *First_name;
@property (strong, nonatomic) NSString *Last_name;
/*!
 @method sharedInstance
 
 @discussion A singleton object provides a global point of access to the resources of its class. Singletons are used in situations where this single point of control is desirable, such as with classes that offer some general service or resource. You obtain the global instance from a singleton class through a factory method.
 */
+ (instancetype)sharedInstance;

@end
