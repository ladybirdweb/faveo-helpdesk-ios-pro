//
//  MyWebservices.m
//  SideMEnuDemo
//
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "MyWebservices.h"
#import "AppConstanst.h"
#import "AppDelegate.h"
#import "GlobalVariables.h"
#import "Utils.h"

@interface MyWebservices(){
    
    NSString *tokenRefreshed;
    GlobalVariables *globalVariables;
    Utils *utils;
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
     globalVariables=[GlobalVariables sharedInstance];
    
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
            
 
        
            NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"Thread--refreshToken--Get your response == %@", replyStr);
            
            if([replyStr hasPrefix:@"<!DOCTYPE html>"] || [replyStr containsString:@"<!DOCTYPE html>"] || [replyStr hasSuffix:@"<!DOCTYPE html>"])
            {
                NSString * msg = @"urlchanged";
                
                [self->_userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
                NSLog(@"Thread--token-Not-Refreshed");
                
            }
            else
            if ([replyStr containsString:@"success"] || [replyStr containsString:@"data"] || [replyStr containsString:@"result"]) {
                
                NSError *error=nil;
                NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (error) {
                    return;
                }
                
                NSLog(@"JSON Data is : %@",jsonData);
                NSLog(@"JSON Data is : %@",jsonData);
                
            
                    if([replyStr containsString:@"result"])
                    {
                        
                        NSDictionary * erroDict = [jsonData objectForKey:@"result"];
                        NSString *errorMessage = [erroDict objectForKey:@"error"];
                        
                        if([errorMessage isEqualToString:@"Methon not allowed"])
                        {
                            NSString *msg =@"Methon not allowed";
                            [self->_userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
                        }
                        
                    }
                    else  if([replyStr containsString:@"message"])
                    {
                        NSString *msg=[jsonData objectForKey:@"message"];
                        
                        
                        if([msg isEqualToString:@"Invalid credentials"])
                        {
                            [self->_userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
                        }
                        
                        else if([msg isEqualToString:@"API disabled"])
                        {
                            [self->_userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
                        }
                        
                    }
                    else{
                        
                        NSDictionary *userDataDict=[jsonData objectForKey:@"data"];
                        
                        
                        NSString *tokenString=[NSString stringWithFormat:@"%@",[userDataDict objectForKey:@"token"]];
                        NSLog(@"Token is : %@",tokenString);
                        
                        [self->_userDefaults setObject:tokenString forKey:@"token"];
                        
                        
                        
                        NSDictionary *userDetailsDict=[userDataDict objectForKey:@"user"];
                        NSLog(@"Data is: %@",userDetailsDict);
                        
                        NSString * userId=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"id"]];
                        
                        NSString *role123=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"role"]];//role
                        NSLog(@"Role from Web Services class : %@",role123);
                        
                        self->globalVariables.roleFromAuthenticateAPI=role123;
                        [self->_userDefaults setObject:role123 forKey:@"msgFromRefreshToken"];
                        
                        [self->_userDefaults setObject:userId forKey:@"user_id"];
                        
                        [self->_userDefaults synchronize];
                        self->globalVariables=[GlobalVariables sharedInstance];
                        
                        result=@"tokenRefreshed";
                        NSLog(@"Thread--refreshToken-tokenRefreshed");
                    }
                
          } //end main if
        
      } // end response class/method
        
        dispatch_semaphore_signal(sem);
    }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return result;
}



-(void)callPATCHAPIWithAPIName:(NSString *)urlString
                     parameter:(id)parameter
               callbackHandler:(callbackHandler)block{
    NSError *err;
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)request] forHTTPHeaderField:@"Content-Length"];
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
    
    [request setHTTPMethod:@"PATCH"];
    
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
//
//+(NSURLSessionTask *)callPATCHAPIWithAPIName:(NSString *)apiName andCompletionHandler:(void(^)(id result, NSInteger responseCode, NSError *error))completionHandler
//{
//    NSString *getURL = apiName;
//    NSURL *url = [NSURL URLWithString:getURL];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    sessionConfiguration.timeoutIntervalForRequest = 45.0f;
//
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//
//    // Create Data from request
//    NSData *requestData = [NSData dataWithBytes: [@"" UTF8String] length:[@"" length]];
//
//    [request setHTTPMethod:@"PATCH"];
//    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
//
//    [request setHTTPBody:requestData];
//
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
//                                            completionHandler:
//                                  ^(NSData *data, NSURLResponse *response, NSError *error)
//                                  {
//                                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//
//                                      NSInteger responseCode = [httpResponse statusCode];
//                                      NSLog(@"response Code : %ld",(long)responseCode);
//                                  }];
//
//    [task resume];
//    return task;
//}

-(void)httpResponsePOST:(NSString *)urlString
              parameter:(id)parameter
        callbackHandler:(callbackHandler)block{
    NSError *err;
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    //    urlString = [urlString stringByReplacingOccurrencesOfString:@"%5B%5D"
    //                                         withString:@"[]"];
    //    NSLog(@"String 11111 is : %@",urlString);
    
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
                    
                    
                }else
                    if (statusCode==429)
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
            NSLog(@"Status code is : %ld",(long)statusCode);
            
            
            
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

// url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=DESC"];


-(void)getNextPageURLInbox:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    NSLog(@"page isssss : %@",pageInt);
    
    if([globalVariables.filterId isEqualToString:@"INBOXFilter"])
    {
        NSString *urlAAA= [url stringByAppendingString:@"&page="];
        NSString *urlBBB= [urlAAA stringByAppendingString:pageInt];
        
        [self httpResponseGET:urlBBB parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    } else if([globalVariables.sortCondition isEqualToString:@"INBOX"])
    {
        
        NSString * apiValue=[NSString stringWithFormat:@"%i",1];
        NSString * showInbox = @"inbox";
        NSString * Alldeparatments=@"All";
        
        
        NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,pageInt];
        
        NSLog(@"urlssss i sssss : %@",url222);
        
        
        NSString *sortContiionValue= [NSString stringWithFormat:@"%@",globalVariables.sortCondtionValueToSendWebServices];
        
        NSString*appendedURL;
        appendedURL = [url222 stringByAppendingString:sortContiionValue];
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
    }
    else{
        
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
    
}

-(void)getNextPageURLInboxSearchResults:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block
{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    NSLog(@"page isssss : %@",pageInt);
    
    NSString *urlAAA= [url stringByAppendingString:@"&page="];
    NSString *urlBBB= [urlAAA stringByAppendingString:pageInt];
    
    [self httpResponseGET:urlBBB parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
    
}

-(void)getNextPageURLInboxSearchResults:(NSString*)url searchString:(NSString*)searchData pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block;
{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    
    NSLog(@"Search data is : %@",searchData);
    //    _userDefaults=[NSUserDefaults standardUserDefaults];
    //   // NSString *urll=[NSString stringWithFormat:@"%@&api_key=%@&ip=%@&token=%@",url,API_KEY,IP,[_userDefaults objectForKey:@"token"]];
    NSLog(@"page isssss : %@",pageInt);
    
    NSString *urlAAA= [url stringByAppendingString:@"?page="];
    NSString *urlBBB= [urlAAA stringByAppendingString:pageInt];
    NSString *urlccc= [urlBBB stringByAppendingString:[NSString stringWithFormat:@"&search=%@",searchData]];
    // NSLog(@"url of search next view is 11 : %@",urlccc);
    
    NSString *finalUrl=[NSString stringWithFormat:@"%@&token=%@",urlccc,[_userDefaults objectForKey:@"token"]];
    NSLog(@"FInal 111111111 url : %@",finalUrl);
    
    [self httpResponseGET:finalUrl parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error,json,msg);
        });
        
    }];
    
    
}

-(void)getNextPageURLUnassigned:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    NSLog(@"page isssss : %@",pageInt);
    
    if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"])
    {
        NSString *urlAAA= [url stringByAppendingString:@"&page="];
        NSString *urlBBB= [urlAAA stringByAppendingString:pageInt];
        
        [self httpResponseGET:urlBBB parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    }else if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"])
    {
        
        NSString * apiValue=[NSString stringWithFormat:@"%i",1];
        NSString * showInbox = @"inbox";
        NSString * Alldeparatments=@"All";
        NSString * assigned = [NSString stringWithFormat:@"%i",0];
        
        NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@&assigned=%@",url,[_userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,pageInt,assigned];
        
        NSLog(@"urlssss i sssss : %@",url222);
        
        NSString *sortContiionValue= [NSString stringWithFormat:@"%@",globalVariables.sortCondtionValueToSendWebServices];
        
        NSString*appendedURL;
        appendedURL = [url222 stringByAppendingString:sortContiionValue];
        NSLog(@"Append url is : %@",appendedURL);
        NSLog(@"Append url is : %@",appendedURL);
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
    }
    else{
        
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
    
    
    
    
    
    
}


-(void)getNextPageURLMyTickets:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    NSLog(@"page isssss : %@",pageInt);
    
    if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"])
    {
        NSString *urlAAA= [url stringByAppendingString:@"&page="];
        NSString *urlBBB= [urlAAA stringByAppendingString:pageInt];
        
        [self httpResponseGET:urlBBB parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    } else if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"])
    {
        
        NSString * apiValue=[NSString stringWithFormat:@"%i",1];
        NSString * MyTickets = @"mytickets";
        NSString * Alldeparatments=@"All";
        
        NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,MyTickets,Alldeparatments,pageInt];
        
        NSLog(@"urlssss i sssss : %@",url222);
        
        
        NSString *sortContiionValue= [NSString stringWithFormat:@"%@",globalVariables.sortCondtionValueToSendWebServices];
        
        NSString*appendedURL;
        appendedURL = [url222 stringByAppendingString:sortContiionValue];
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
    }
    else{
        
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
    
    
    
    
    
}

-(void)getNextPageURLClosed:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    NSLog(@"page isssss : %@",pageInt);
    
    if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"])
    {
        NSString *urlAAA= [url stringByAppendingString:@"&page="];
        NSString *urlBBB= [urlAAA stringByAppendingString:pageInt];
        
        [self httpResponseGET:urlBBB parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    } else  if([globalVariables.sortCondition isEqualToString:@"CLOSED"])
    {
        
        NSString * apiValue=[NSString stringWithFormat:@"%i",1];
        NSString * closedTickets = @"closed";
        NSString * Alldeparatments=@"All";
        
        NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,closedTickets,Alldeparatments,pageInt];
        
        NSLog(@"urlssss i sssss : %@",url222);
        
        
        NSString *sortContiionValue= [NSString stringWithFormat:@"%@",globalVariables.sortCondtionValueToSendWebServices];
        
        NSString*appendedURL;
        appendedURL = [url222 stringByAppendingString:sortContiionValue];
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
    }
    else{
        
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
    
    
    
    
}


-(void)getNextPageURLTrash:(NSString*)url pageNo:(NSString*)pageInt callbackHandler:(callbackHandler)block{
    _userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
    NSLog(@"page isssss : %@",pageInt);
    
    if([globalVariables.filterId isEqualToString:@"TRASHFilter"])
    {
        NSString *urlAAA= [url stringByAppendingString:@"&page="];
        NSString *urlBBB= [urlAAA stringByAppendingString:pageInt];
        
        [self httpResponseGET:urlBBB parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    } else if([globalVariables.sortCondition isEqualToString:@"TRASH"])
    {
        
        NSString * apiValue=[NSString stringWithFormat:@"%i",1];
        NSString * TrashTickets = @"trash";
        NSString * Alldeparatments=@"All";
        
        NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,TrashTickets,Alldeparatments,pageInt];
        
        NSString *sortContiionValue= [NSString stringWithFormat:@"%@",globalVariables.sortCondtionValueToSendWebServices];
        
        NSString*appendedURL;
        appendedURL = [url222 stringByAppendingString:sortContiionValue];
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
    }else{
        
        NSString * apiValue=[NSString stringWithFormat:@"%i",1];
        NSString * TrashTickets = @"trash";
        NSString * Alldeparatments=@"All";
        
        NSString *url222= [NSString stringWithFormat:@"%@?token=%@&api=%@&show=%@&departments=%@&page=%@",url,[_userDefaults objectForKey:@"token"],apiValue,TrashTickets,Alldeparatments,pageInt];
        
        
        [self httpResponseGET:url222 parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
    }
    
    
} // getNextPageURLTrash



-(void)getNextPageUSERFilter:(NSString*)url callbackHandler:(callbackHandler)block{
    
    globalVariables=[GlobalVariables sharedInstance];
    _userDefaults=[NSUserDefaults standardUserDefaults];
    
    
    
    NSString *urll=[NSString stringWithFormat:@"%@&api_key=%@&ip=%@&token=%@",url,API_KEY,IP,[_userDefaults objectForKey:@"token"]];
    
    NSLog(@"Old url is : %@",urll);
    
    
    if([globalVariables.userFilterId isEqualToString:@"AGENTUSERS"])
        
    {
        
        //    NSString *appendedURL;
        //  appendedURL = [urll stringByAppendingString:@"&active=1"];
        
        [self httpResponseGET:urll parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    }else if([globalVariables.userFilterId isEqualToString:@"ACTIVEUSERS"])
        
    {
        NSString *appendedURL;
        
        appendedURL = [urll stringByAppendingString:@"&active=1&role=user"];
        
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    }else if([globalVariables.userFilterId isEqualToString:@"CLIENTUSERS"])
        
    {
        
        [self httpResponseGET:urll parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    }else if([globalVariables.userFilterId isEqualToString:@"BANNEDUSERS"])
        
    {
        
        NSString *appendedURL;
        appendedURL = [urll stringByAppendingString:@"&ban=1"];
        
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
        
    }else if([globalVariables.userFilterId isEqualToString:@"INACTIVEUSERS"])
        
    {
        
        NSString *appendedURL;
        appendedURL = [urll stringByAppendingString:@"&active=0"];
        
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    }else if([globalVariables.userFilterId isEqualToString:@"DEACTIVEUSERS"])
        
    {  // deleted=%@
        
        NSString *appendedURL;
        appendedURL = [urll stringByAppendingString:@"&deleted=1"];
        
        [self httpResponseGET:appendedURL parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error,json,msg);
            });
            
        }];
        
    }
    
    
    
    
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

