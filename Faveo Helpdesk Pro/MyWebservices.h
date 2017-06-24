//
//  MyWebservices.h
//  SideMEnuDemo
//
//  Created by Narendra on 16/10/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//



#import <Foundation/Foundation.h>


typedef void (^NetworkResponce)(id responce);
typedef void (^callbackHandler) (NSError *, id,NSString*);
typedef void (^routebackHandler) (NSError *, id, NSHTTPURLResponse*);
typedef void (^ApiResponse)(NSError* , id);

/**
 @class MyWebservices
 
 @brief This class provide web-based APIs to support machine-to-machine communication over networks. Because these APIs are web-based, they inherently support interaction between devices running on different architectures and speaking different native languages
 
 @discussion A server with a database responds to remote queries for data, where the client specifies a particular city, stock symbol, or book title, for example. The client application sends queries to the server, parses the response, and processes the returned data.
 
     All web service schemes utilize a web-based transport mode, such as HTTP, HTTPS, or SMTP, and a method for packaging the queries and responses, typically some sort of XML schema.
 
 @superclass NSObject
 
 @helper AppDelegate,AppConstanst
 */
@interface MyWebservices : NSObject

@property(nonatomic,strong)NSURLSession *session;

+ (instancetype)sharedInstance;

-(void)httpResponsePOST:(NSString *)urlString
              parameter:(id)parameter
        callbackHandler:(callbackHandler)block;

-(void)httpResponseGET:(NSString *)urlString
             parameter:(id)parameter
       callbackHandler:(callbackHandler)block;

-(NSString*)refreshToken;

-(void)getNextPageURL:(NSString*)url callbackHandler:(callbackHandler)block;
-(void)getNextPageURL:(NSString*)url user_id:(NSString*)uid callbackHandler:(callbackHandler)block;
@end
