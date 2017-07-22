//
//  TicketDetailViewController.m
//  SideMEnuDemo
//
//  Created by Narendra on 07/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "CNPPopupController.h"
#import "Utils.h"
#import "HexColors.h"
#import "AppDelegate.h"
#import "AppConstanst.h"
#import "Reachability.h"
#import "MyWebservices.h"
#import "GlobalVariables.h"
#import "RKDropdownAlert.h"
#import "RMessage.h"
#import "RMessageView.h" 
#import "NotificationViewController.h"

//#import "ReplyViewController.h"

@interface TicketDetailViewController () <CNPPopupControllerDelegate,RMessageProtocol>{
    Utils *utils;
    NSUserDefaults *userDefaults;
    UITextField *textFieldCc;
    UITextView *textViewInternalNote;
    UITextView *textViewReply;
    UILabel *errorMessageReply;
     UILabel *errorMessageNote;
    GlobalVariables *globalVariables;
}

-(void)replyBtnPressed;
-(void)internalNotePressed;
@property (nonatomic, strong) CNPPopupController *popupController;

@end

@implementation TicketDetailViewController

- (void)viewDidLoad {
     [super viewDidLoad];
    self.currentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationVC"];
    self.currentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.currentViewController];
    [self addSubview:self.currentViewController.view toView:self.containerView];
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    self.segmentedControl.tintColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(replyBtnPressed)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(internalNotePressed)], nil] animated:YES];
    
   // _lblTicketNumber.text=globalVariables.ticket_number;
    _lblTicketNumber.text=[NSString stringWithFormat:@"%@ %@",globalVariables.First_name,globalVariables.Last_name];
       // Do any additional setup after loading the view.
}



- (void)addSubview:(UIView *)subView toView:(UIView*)parentView {
    [parentView addSubview:subView];
    
    NSDictionary * views = @{@"subView" : subView,};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                   options:0
                                                                   metrics:0
                                                                     views:views];
    [parentView addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                          options:0
                                                          metrics:0
                                                            views:views];
    [parentView addConstraints:constraints];
}

- (void)cycleFromViewController:(UIViewController*) oldViewController
               toViewController:(UIViewController*) newViewController {
    [oldViewController willMoveToParentViewController:nil];
    [self addChildViewController:newViewController];
    [self addSubview:newViewController.view toView:self.containerView];
    newViewController.view.alpha = 0;
    [newViewController.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         newViewController.view.alpha = 1;
                         oldViewController.view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [oldViewController.view removeFromSuperview];
                         [oldViewController removeFromParentViewController];
                         [newViewController didMoveToParentViewController:self];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)replyBtnPressed{

    NSLog(@"Reply Pressed");

    [self showPopupReply:CNPPopupStyleCentered];
    
    
}

//- (void)dismissPopup {
//if (self.popupViewController != nil) {
 //       [self dismissPopupViewControllerAnimated:YES completion:^{
 //           NSLog(@"popup view dismissed");
 //       }];
 //   }
//}

-(void)internalNotePressed{
     [self showPopupInternalNote:CNPPopupStyleCentered];
    NSLog(@"Internal Pressed");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)indexChanged:(id)sender {
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationVC"];
        newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self cycleFromViewController:self.currentViewController toViewController:newViewController];
        self.currentViewController = newViewController;
         } else {
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailVC"];
        newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self cycleFromViewController:self.currentViewController toViewController:newViewController];
        self.currentViewController = newViewController;
           }
}

- (void)showPopupInternalNote:(CNPPopupStyle)popupStyle {
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Internal Notes",nil) attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSMutableAttributedString *lineTwo = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Message*",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor hx_colorWithHexRGBAString:@"#00aeef"]}];
    [lineTwo addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7,1)];
    //    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"Message" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
    //    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"Message" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    errorMessageNote=[[UILabel alloc] initWithFrame:CGRectMake(10, 135, 250, 20)];
    errorMessageNote.textColor=[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR];
    errorMessageNote.text=@"Field is mandatory.";
    [errorMessageNote setFont:[UIFont systemFontOfSize:12]];
    errorMessageNote.hidden=YES;
    //    UILabel *lineOneLabel = [[UILabel alloc] init];
    //    lineOneLabel.numberOfLines = 0;
    //    lineOneLabel.attributedText = lineOne;
    //
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    
    UILabel *lineTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
    //    lineTwoLabel.numberOfLines = 0;
    //lineTwoLabel.textColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    lineTwoLabel.attributedText = lineTwo;
    
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 275, 140)];
    //customView.backgroundColor = [UIColor lightGrayColor];
    
    textViewInternalNote = [[UITextView alloc] initWithFrame:CGRectMake(10, 35, 250, 100)];
    
    //[ textViewInternalNote setReturnKeyType:UIReturnKeyDone];
    textViewInternalNote.layer.cornerRadius=4;
     textViewInternalNote.layer.borderWidth=1.0F;
     textViewInternalNote.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    
    [customView addSubview: textViewInternalNote];
    [customView addSubview:lineTwoLabel];
    [customView addSubview:errorMessageNote];
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:NSLocalizedString(@"Done",nil) forState:UIControlStateNormal];
    button.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    button.layer.cornerRadius = 4;
    button.selectionHandler = ^(CNPPopupButton *button){
        NSString *rawString = [textViewInternalNote text];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
        if ([trimmed length] == 0) {
             errorMessageNote.hidden=NO;
            // Text was empty or only whitespace.
        }else if ( textViewInternalNote.text.length > 0 && textViewInternalNote.text != nil && ![textViewInternalNote.text isEqual:@""]) {
            errorMessageNote.hidden=YES;
            [self postInternalNote];
            [self.popupController dismissPopupControllerAnimated:YES];
            NSLog(@"Message of InternalNote: %@",  textViewInternalNote.text);
        }else {
           errorMessageNote.hidden=NO;
        }
    };
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, customView, button]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}

- (void)showPopupReply:(CNPPopupStyle)popupStyle {
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Ticket Reply",nil) attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"Cc" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor hx_colorWithHexRGBAString:@"#00aeef"]}];
    NSMutableAttributedString *lineTwo = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Message*",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor hx_colorWithHexRGBAString:@"#00aeef"]}];
    [lineTwo addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7,1)];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    //    UILabel *lineOneLabel = [[UILabel alloc] init];
    //    lineOneLabel.numberOfLines = 0;
    //    lineOneLabel.attributedText = lineOne;
    //
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 140)];
    //customView.backgroundColor = [UIColor lightGrayColor];
    
    
    UILabel *lineTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
    //    lineTwoLabel.numberOfLines = 0;
    //lineTwoLabel.textColor=[UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    lineTwoLabel.attributedText = lineOne;
    
    textFieldCc=[[UITextField alloc]initWithFrame:CGRectMake(10, 30, 250, 30)];
    [textFieldCc setBorderStyle:UITextBorderStyleNone];
    textFieldCc.layer.cornerRadius=4;
    textFieldCc.layer.borderWidth=1.0F;
    textFieldCc.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    
    errorMessageReply=[[UILabel alloc] initWithFrame:CGRectMake(10, 130, 250, 20)];
     errorMessageReply.textColor=[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR];
    errorMessageReply.text=@"Field is mandatory.";
    [errorMessageReply setFont:[UIFont systemFontOfSize:12]];
     errorMessageReply.hidden=YES;
    
    UILabel *lineTwoLabe2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
    //    lineTwoLabel.numberOfLines = 0;
    //lineTwoLabe2.textColor=[UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    lineTwoLabe2.attributedText = lineTwo;
    
    textViewReply = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, 250, 100)];
    //textViewReply.delegate=self;
   // [textViewReply setReturnKeyType:UIReturnKeyDone];
    textViewReply.layer.cornerRadius=4;
    textViewReply.layer.borderWidth=1.0F;
    textViewReply.layer.borderColor=[[UIColor grayColor] CGColor];
    
    [customView addSubview:textViewReply];
    //[customView addSubview:textFieldCc];
   // [customView addSubview:lineTwoLabel];
    [customView addSubview:lineTwoLabe2];
    [customView addSubview:errorMessageReply];
    
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:NSLocalizedString(@"Done",nil) forState:UIControlStateNormal];
    button.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    button.layer.cornerRadius = 4;
    
    button.selectionHandler = ^(CNPPopupButton *button){
        
        NSString *rawString = [textViewReply text];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
        if ([trimmed length] == 0) {
            errorMessageReply.hidden=NO;
            // Text was empty or only whitespace.
        }else if (textViewReply.text.length > 0 && textViewReply.text != nil && ![textViewReply.text isEqual:@""]) {
            [self postReply];
            errorMessageReply.hidden=YES;
            [self.popupController dismissPopupControllerAnimated:YES];
            NSLog(@"Reply Message: %@, Cc: %@", textViewReply.text,textFieldCc.text);
        }else {
           errorMessageReply.hidden=NO;
        }
    };
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, customView, button]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}



-(void)postInternalNote{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        [[AppDelegate sharedAppdelegate] showProgressView];
        
//        NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:API_KEY,@"api_key",IP,@"ip",[userDefaults objectForKey:@"token"],@"token",[userDefaults objectForKey:@"user_id"],@"userid",textViewInternalNote.text,@"body",globalVariables.iD,@"ticketid",nil];
//        NSLog(@"Dic %@",param);
//        
//        NSString *url=[NSString stringWithFormat:@"%@helpdesk/internal-note",[userDefaults objectForKey:@"companyURL"]];
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/internal-note?api_key=%@&ip=%@&token=%@&user_id=%@&body=%@&ticket_id=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],[userDefaults objectForKey:@"user_id"],textViewInternalNote.text,globalVariables.iD];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self postInternalNote];
                NSLog(@"Thread--NO4-call-postCreateTicket");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-CreateTicket-%@",json);
                if ([json objectForKey:@"thread"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [RKDropdownAlert title:APP_NAME message:@"Posted your note!"backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
                       // [utils showAlertWithMessage:@"Kindly Refresh!!" sendViewController:self];
                    });
                }
            }
            NSLog(@"Thread-NO5-postCreateTicket-closed");
            
        }];
    }
}


-(void)postReply{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];        
    }else{
        
        [[AppDelegate sharedAppdelegate] showProgressView];
        
//        NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:API_KEY,@"api_key",IP,@"ip",[userDefaults objectForKey:@"token"],@"token",textViewReply.text,@"reply_content",textFieldCc.text,@"cc",globalVariables.iD,@"ticket_ID",nil];
//        NSLog(@"Dic %@",param);
//        
//        NSString *url=[NSString stringWithFormat:@"%@helpdesk/reply",[userDefaults objectForKey:@"companyURL"]];
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/reply?api_key=%@&ip=%@&token=%@&reply_content=%@&ticket_id=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],textViewReply.text,globalVariables.iD];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self postReply];
                NSLog(@"Thread--NO4-call-postCreateTicket");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-CreateTicket-%@",json);
                if ([json objectForKey:@"result"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [RKDropdownAlert title:APP_NAME message:@"Posted your reply!"backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
                       // [utils showAlertWithMessage:@"Kindly Refresh!" sendViewController:self];
                    });
                }
                
            }
            NSLog(@"Thread-NO5-postCreateTicket-closed");
            
        }];
    }
}

//- (NSString *)removeEndSpaceFrom:(NSString *)strtoremove{
//    NSUInteger location = 0;
//    unichar charBuffer[[strtoremove length]];
//    [strtoremove getCharacters:charBuffer];
//    int i = 0;
//    for(i = [strtoremove length]; i >0; i--) {
//        NSCharacterSet* charSet = [NSCharacterSet whitespaceCharacterSet];
//        if(![charSet characterIsMember:charBuffer[i - 1]]) {
//            break;
//        }
//    }
//    return [strtoremove substringWithRange:NSMakeRange(location, i  - location)];
//}


- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)aTextField
//{
//    return [self validate:aTextField.text];
//}
//
//- (BOOL) validate: (NSString *) candidate {
//    NSString *emailRegex = @"[a-zA-Z]*";
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    
//    return [emailTest evaluateWithObject:candidate];
//}

@end
