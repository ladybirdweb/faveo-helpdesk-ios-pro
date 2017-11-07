//
//  MyWebservices.m
//  SideMEnuDemo
//
//  Created by Narendra on 16/10/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "MyWebservices.h"
#import "AppConstanst.h"
#import "AppDelegate.h"

@interface MyWebservices(){
    
    NSString *tokenRefreshed;
}

@property (nonatomic,strong) NSUserDefaults *userDefaults;
@end

@implementation MyWebservices

+ (instancetype)sharedInstance
{
    static MyWebservices *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MyWebservices alloc] init];
        NSLog(@"SingleTon-MYwebserves");
    });
    return sharedInstance;
}

-(NSString*)refreshToken{
    NSLog(@"Thread--refreshToken()");
    
    dispatch_semaphore_t sem;
    __block NSString *result=nil;
    sem = dispatch_semaphore_create(0);
    _userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSString *url=[NSString stringWithFormat:@"%@authenticate",[_userDefaults objectForKey:@"companyURL"]];
    
    NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:[_userDefaults objectForKey:@"username"],@"username",[_userDefaults objectForKey:@"password"],@"password",API_KEY,@"api_key",IP,@"ip",nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    
    //[request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:45.0];
    
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil]];
    [request setHTTPMethod:@"POST"];
    
    //    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
    
    NSURLSession *session=[NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Thread--refreshToken error: %@", error);
            return ;
        }
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                NSLog(@"Thread--refreshToken--dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                return ;
            }
            
            NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"Thread--refreshToken--Get your response == %@", replyStr);
            
            if ([replyStr containsString:@"token"]) {
                
                NSError *error=nil;
                NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (error) {
                    return;
                }
                [_userDefaults setObject:[jsonData objectForKey:@"token"] forKey:@"token"];
                NSDictionary *jsonData1=[jsonData objectForKey:@"user_id"];
                [_userDefaults setObject:[jsonData1 objectForKey:@"id"] forKey:@"user_id"];
                [_userDefaults synchronize];
                
                result=@"tokenRefreshed";
                NSLog(@"Thread--refreshToken-tokenRefreshed");
            }
        }
        
        dispatch_semaphore_signal(sem);
    }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return result;
}


-(void)httpResponsePOST:(NSString *)urlString
              parameter:(id)parameter
        callbackHandler:(callbackHandler)block{
    NSError *err;
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Offer-type"];
    [request setTimeoutInterval:45.0];
    
    NSData *postData = nil;
    if ([parameter isKindOfClass:[NSString class]]) {
        postData = [((NSString *)parameter) dataUsingEncoding:NSUTF8StringEncoding];
    } else {
       // postData = [NSJSONSerialization dataWithJSONObject:parameter options:0 error:&err];

        postData = [NSJSONSerialization dataWithJSONObject:parameter options:kNilOptions error:&err];
    }
    [request setHTTPBody:postData];
    //[request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameter options:nil error:&err]];
    
    [request setHTTPMethod:@"POST"];
    //
    NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    NSLog(@"Thread--httpResponsePOST--Request : %@", urlString);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
    
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,nil,nil);
            });
            NSLog(@"dataTaskWithRequest error: %@", [error localizedDescription]);
            
        }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                
                if (statusCode==400) {
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                }else if (statusCode==401)
                {
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }

                    
                }
                else
                       dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, nil,[NSString stringWithFormat:@"Error-%ld",(long)statusCode]);
                    });
                return ;
            }
            
            NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([replyStr containsString:@"token_expired"]) {
                NSLog(@"Thread--httpResponsePOST--token_expired");
                
                if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenRefreshed");
                    });
                    NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenNotRefreshed");
                    });
                    NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                }
                return;
            }
            
            NSError *jsonerror = nil;
            
            id responseData =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonerror];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(jsonerror,responseData,nil);
            });
            
        }
        
    }] resume];
    
}


-(void)httpResponseGET:(NSString *)urlString
             parameter:(id)parameter
       callbackHandler:(callbackHandler)block{
    
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    //[request addValue:@"text/html" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:45.0];
    
    NSData *postData = nil;
    if ([parameter isKindOfClass:[NSString class]]) {
        postData = [((NSString *)parameter) dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        postData = [NSJSONSerialization dataWithJSONObject:parameter options:0 error:&error];
    }
    [request setHTTPBody:postData];
    
    [request setHTTPMethod:@"GET"];
    
    NSLog(@"Thread--httpResponseGET--Request : %@", urlString);
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        NSLog(@"Response is required : %@",(NSHTTPURLResponse *) response);
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,nil,nil);
            });
            NSLog(@"Thread--httpResponseGET--dataTaskWithRequest error: %@", [error localizedDescription]);
            
        }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                
                if (statusCode==400) {
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                }else if (statusCode==401){
                    
                    if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenRefreshed");
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(nil,nil,@"tokenNotRefreshed");
                        });
                        NSLog(@"Thread--httpResponsePOST--tokenNotRefreshed");
                    }
                } else
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, nil,[NSString stringWithFormat:@"Error-%ld",(long)statusCode]);
                    });
                return ;
            }
            
            NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([replyStr containsString:@"token_expired"]) {
                NSLog(@"Thread--httpResponseGET--token_expired");
                
                if ([[self refreshToken] isEqualToString:@"tokenRefreshed"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenRefreshed");
                    });
                    NSLog(@"Thread--httpResponseGET--tokenRefreshed");
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,nil,@"tokenNotRefreshed");
                    });
                    NSLog(@"Thread--httpResponseGET--tokenNotRefreshed");
                }
                return;
            }
            
            NSError *jsonerror = nil;
            id responseData =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(jsonerror,responseData,nil);
            });
            
        }
    }] resume];
    
}

-(void)getNextPageURL:(NSString*)url callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"URL from inbox : %@",url);
    
    NSString *urll=[NSString stringWithFormat:@"%@&api_key=%@&ip=%@&token=%@",url,API_KEY,IP,[_userDefaults objectForKey:@"token"]];
   
    NSLog(@"URL 11111 is : %@",urll);

    [self httpResponseGET:urll parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });

    }];

}

//-(void)getNextPageURL:(NSString*)url callbackHandler:(callbackHandler)block{
//    _userDefaults=[NSUserDefaults standardUserDefaults];
//   // NSString *urll=[NSString stringWithFormat:@"%@&api_key=%@&ip=%@&token=%@",url,API_KEY,IP,[_userDefaults objectForKey:@"token"]];
//    NSString * urll=url;
//    NSLog(@"url12345 : %@",urll);
//    [self httpResponseGET:urll parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            block(error,json,msg);
//        });
//
//    }];
//
//}


-(void)getNextPageURLInbox:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"page isssss : %@",pageInt);
  
    NSString * apiValue=[NSString stringWithFormat:@"%i",1];
    NSString * showInbox = @"inbox";
    NSString * Alldeparatments=@"All";
    
     NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,pageInt];
    
    NSLog(@"urlssss i sssss : %@",url222);
    
    
    [self httpResponseGET:url222 parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
}


-(void)getNextPageURLUnassigned:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"page isssss : %@",pageInt);
    
    NSString * apiValue=[NSString stringWithFormat:@"%i",1];
    NSString * showInbox = @"inbox";
    NSString * Alldeparatments=@"All";
    NSString * assigned = [NSString stringWithFormat:@"%i",0];
    
    NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@&assigned=%@",url,[_userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,pageInt,assigned];
    
    NSLog(@"urlssss i sssss : %@",url222);
    
    
    [self httpResponseGET:url222 parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
}


-(void)getNextPageURLMyTickets:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"page isssss : %@",pageInt);
    
    NSString * apiValue=[NSString stringWithFormat:@"%i",1];
    NSString * MyTickets = @"mytickets";
    NSString * Alldeparatments=@"All";
    
    NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,MyTickets,Alldeparatments,pageInt];
    
    NSLog(@"urlssss i sssss : %@",url222);
    
    
    [self httpResponseGET:url222 parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
}

-(void)getNextPageURLClosed:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"page isssss : %@",pageInt);
    
    NSString * apiValue=[NSString stringWithFormat:@"%i",1];
    NSString * closedTickets = @"closed";
    NSString * Alldeparatments=@"All";
    
    NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,closedTickets,Alldeparatments,pageInt];
    
    NSLog(@"urlssss i sssss : %@",url222);
    
    
    [self httpResponseGET:url222 parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
}


-(void)getNextPageURLTrash:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"page isssss : %@",pageInt);
    
    NSString * apiValue=[NSString stringWithFormat:@"%i",1];
    NSString * TrashTickets = @"trash";
    NSString * Alldeparatments=@"All";
    
    NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,TrashTickets,Alldeparatments,pageInt];
    
    NSLog(@"urlssss i sssss : %@",url222);
    
    
    [self httpResponseGET:url222 parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
} // getNextPageURLTrash




-(void)getNextPageURL:(NSString*)url user_id:(NSString*)uid callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *urll=[NSString stringWithFormat:@"%@&api_key=%@&ip=%@&token=%@&user_id=%@",url,API_KEY,IP,[_userDefaults objectForKey:@"token"],uid];
    
    [self httpResponseGET:urll parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
}

@end
