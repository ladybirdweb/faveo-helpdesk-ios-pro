//
//  ReplyTicketViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 06/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "ReplyTicketViewController.h"
#import "AddRequester.h"
#import "LeftMenuViewController.h"
#import "ActionSheetStringPicker.h"
#import "HexColors.h"
#import "Utils.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "AppDelegate.h"
#import "RKDropdownAlert.h"
#import "IQKeyboardManager.h"
#import "Dat.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "AddRequester.h"
#import "GlobalVariables.h"
#import "BDCustomAlertView.h"
#import "addCCView.h"
#import "BIZPopupViewController.h"
#import "NotificationViewController.h"
#import <HSAttachmentPicker/HSAttachmentPicker.h>
#import "TicketDetailViewController.h"


@interface ReplyTicketViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,HSAttachmentPickerDelegate>
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    // NSString * count1;
    NSMutableArray *usersArray;
    
    NSArray  * ccListArray;
    
    HSAttachmentPicker *_menu;
    
    NSData *attachNSData;
    NSString *file123;
    NSString *base64Encoded;
    NSString *typeMime;
    
    
}

@end

@implementation ReplyTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Reply Ticket";
    
    
    self.tableview1.separatorColor=[UIColor clearColor];
    
    
    UIButton *attachmentButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [attachmentButton setImage:[UIImage imageNamed:@"attach1"] forState:UIControlStateNormal];
    [attachmentButton addTarget:self action:@selector(addAttachmentPickerButton) forControlEvents:UIControlEventTouchUpInside];
    [attachmentButton setFrame:CGRectMake(12, 7, 22, 22)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    // [rightBarButtonItems addSubview:addBtn];
    [rightBarButtonItems addSubview:attachmentButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    utils=[[Utils alloc]init];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
    _addCCLabelButton.userInteractionEnabled=YES;
    _viewCCandRemoveCCLabel.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedOnCCSubButton)];
    _addCCLabelButton.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewCCorRemoceCCButton)];
    
    [_addCCLabelButton addGestureRecognizer:tapGesture];
    [_viewCCandRemoveCCLabel addGestureRecognizer:tapGesture2];
    
    
    if(globalVariables.ccCount==0)
    {
        _addCCLabelButton.text=@"Add cc";
    }else
    {
        _addCCLabelButton.text=[NSString stringWithFormat:@"Add cc (%@ Recipients)",globalVariables.ccCount];
    }
    
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    [self.messageTextView setInputAccessoryView:toolBar];
    
    _submitButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];

   
}

-(void)removeKeyBoard
{
    
    [_messageTextView resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self viewDidLoad];
    [self FetchCollaboratorAssociatedwithTicket];

    
}
-(void)clickedOnCCSubButton
{
    addCCView *cc1=[self.storyboard instantiateViewControllerWithIdentifier:@"addCCViewId"];
    [self.navigationController pushViewController:cc1 animated:YES];
    
}

-(void)viewCCorRemoceCCButton
{
    
    NSLog(@"Clicked");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *smallViewController = [storyboard instantiateViewControllerWithIdentifier:@"SampleTableCellTableViewCellId"];
    
    BIZPopupViewController *popupViewController = [[BIZPopupViewController alloc] initWithContentViewController:smallViewController contentSize:CGSizeMake(250, 300)];
    [self presentViewController:popupViewController animated:NO completion:nil];
}

- (IBAction)submitButtonClicked:(id)sender {
    
    UIActivityIndicatorView *activityIndicator1 =
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(145, 100, 100, 100)];
    activityIndicator1.color=[UIColor blueColor];
    
    [self.view addSubview:activityIndicator1];

     [activityIndicator1 startAnimating];
  
    if([_messageTextView.text isEqualToString:@""] || [_messageTextView.text length]==0)
    {
        [utils showAlertWithMessage:@"Enter the reply content.It can not be empty." sendViewController:self];
        [activityIndicator1 stopAnimating]; //working
        
    }else
    {
      //  [self replyTicketMethodCall];
       
        [self performSelector:@selector(replyTicketMethodCall) withObject:self afterDelay:5.0];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)FetchCollaboratorAssociatedwithTicket
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        NSString *url =[NSString stringWithFormat:@"%@helpdesk/collaborator/get-ticket?token=%@&ticket_id=%@&user_id=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],globalVariables.iD,globalVariables.userIdFromInbox];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    if([msg isEqualToString:@"Error-401"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again."] sendViewController:self];
                    }
                    else
                        
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                        }
                        else if([msg isEqualToString:@"Error-402"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                        }else if([msg isEqualToString:@"Error-422"]){
                            
                            NSLog(@"Message is : %@",msg);
                        }else{
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                            NSLog(@"Error is11 : %@",msg);
                        }
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-CollaboratorFetch-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self FetchCollaboratorAssociatedwithTicket];
                NSLog(@"Thread--NO4-call-CollaboratorFetch");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-CollaboratorWithTicket-%@",json);
                //  NSDictionary * dict1=[json objectForKey:@"collaborator"];
                
                self->ccListArray=[json objectForKey:@"collaborator"];
                self->globalVariables.ccCount=[NSString stringWithFormat:@"%lu",(unsigned long)self->ccListArray.count];//array1.count;
                //NSLog(@"Array count is : %lu",(unsigned long)array1.count);
                NSLog(@"Array count is : %@",self->globalVariables.ccCount);
                [self viewDidLoad];
            }
            
        }];
    }
    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if(textView == _messageTextView)
    {
        
        if([text isEqualToString:@" "])
        {
            if(!textView.text.length)
            {
                return NO;
            }
        }
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length < textView.text.length)
        {
            
            return  YES;
        }
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length >500)
        {
            return NO;
        }
        
        NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890,.1234567890!@#$^&*()--=+/?:;{}[]| "];
        
        
        if([text rangeOfCharacterFromSet:set].location == NSNotFound)
        {
            return NO;
        }
    }
    
    
    return YES;
}


-(void)addAttachmentPickerButton
{
    _menu = [[HSAttachmentPicker alloc] init];
    _menu.delegate = self;
    [_menu showAttachmentMenu];
    
}
- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu showController:(UIViewController * _Nonnull)controller completion:(void (^ _Nullable)(void))completion {
    UIPopoverPresentationController *popover = controller.popoverPresentationController;
    if (popover != nil) {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        //  popover.sourceView = self.openPickerButton;
    }
    [self presentViewController:controller animated:true completion:completion];
}

- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu showErrorMessage:(NSString * _Nonnull)errorMessage {
    NSLog(@"%@", errorMessage);
}

- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu upload:(NSData * _Nonnull)data filename:(NSString * _Nonnull)filename image:(UIImage * _Nullable)image {
    
    NSLog(@"File Name : %@", filename);
    NSLog(@"File name : %@",filename);
    
    file123=filename;
    attachNSData=data;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_fileSize123.text=[NSString stringWithFormat:@" %.2f MB",(float)data.length/1024.0f/1024.0f];
    
    
    
    //  base64Encoded = [data base64EncodedStringWithOptions:0];
    // printf("NSDATA Attachemnt : %s\n", [base64Encoded UTF8String]);
        
    
        self->_fileName123.text=filename;
    
    if([filename hasSuffix:@".doc"] || [filename hasSuffix:@".DOC"])
    {
        self->typeMime=@"application/msword";
        self->_fileImage.image=[UIImage imageNamed:@"doc"];
    }
    else if([filename hasSuffix:@".pdf"] || [filename hasSuffix:@".PDF"])
    {
        self->typeMime=@"application/pdf";
        self->_fileImage.image=[UIImage imageNamed:@"pdf"];
    }
    else if([filename hasSuffix:@".css"] || [filename hasSuffix:@".CSS"])
    {
        self->typeMime=@"text/css";
        self->_fileImage.image=[UIImage imageNamed:@"css"];
    }
    else if([filename hasSuffix:@".csv"] || [filename hasSuffix:@".CSV"])
    {
        self->typeMime=@"text/csv";
        self->_fileImage.image=[UIImage imageNamed:@"csv"];
    }
    else if([filename hasSuffix:@".xls"] || [filename hasSuffix:@".XLS"])
    {
        self->typeMime=@"application/vnd.ms-excel";
        self->_fileImage.image=[UIImage imageNamed:@"xls"];
    }
    
    else if([filename hasSuffix:@".rtf"] || [filename hasSuffix:@".RTF"])
    {
        self->typeMime=@"text/richtext";
        self->_fileImage.image=[UIImage imageNamed:@"rtf"];
    }
    else if([filename hasSuffix:@".sql"] || [filename hasSuffix:@".SQL"])
    {
        self->typeMime=@"text/sql";
        self->_fileImage.image=[UIImage imageNamed:@"sql"];
    }
    else if([filename hasSuffix:@".gif"] || [filename hasSuffix:@".GIF"])
    {
        self->typeMime=@"image/gif";
        self->_fileImage.image=[UIImage imageNamed:@"gif2"];
    }
    else if([filename hasSuffix:@".ppt"] || [filename hasSuffix:@".PPT"])
    {
        self->typeMime=@"application/mspowerpoint";
        self->_fileImage.image=[UIImage imageNamed:@"ppt"];
    }
    else if([filename hasSuffix:@".jpeg"] || [filename hasSuffix:@".JPEG"])
    {
        self->typeMime=@"image/jpeg";
        self->_fileImage.image=[UIImage imageNamed:@"jpg"];
    }
    else if([filename hasSuffix:@".docx"] || [filename hasSuffix:@".DOCX"])
    {
        self->typeMime=@"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        self->_fileImage.image=[UIImage imageNamed:@"doc"];
    }
    else if([filename hasSuffix:@".pps"] || [filename hasSuffix:@".PPS"])
    {
        self->typeMime=@"application/vnd.ms-powerpoint";
        self->_fileImage.image=[UIImage imageNamed:@"ppt"];
    }
    else if([filename hasSuffix:@".pptx"] || [filename hasSuffix:@".PPTX"])
    {
        self->typeMime=@"application/vnd.openxmlformats-officedocument.presentationml.presentation";
        self->_fileImage.image=[UIImage imageNamed:@"ppt"];
    }
    else if([filename hasSuffix:@".jpg"] || [filename hasSuffix:@".JPG"])
    {
        self->typeMime=@"image/jpg";
        self->_fileImage.image=[UIImage imageNamed:@"jpg"];
    }
    else if([filename hasSuffix:@".png"] || [filename hasSuffix:@".PNG"])
    {
        self->typeMime=@"image/png";
        self->_fileImage.image=[UIImage imageNamed:@"png"];
    }
    else if([filename hasSuffix:@".ico"] || [filename hasSuffix:@".ICO"])
    {
        self->typeMime=@"image/x-icon";
        self->_fileImage.image=[UIImage imageNamed:@"ico"];
    }
    else if([filename hasSuffix:@".txt"] || [filename hasSuffix:@".text"] || [filename hasSuffix:@".TEXT"] || [filename hasSuffix:@".com"] || [filename hasSuffix:@".f"] || [filename hasSuffix:@".hh"]  || [filename hasSuffix:@".conf"]  || [filename hasSuffix:@".f90"]  || [filename hasSuffix:@".idc"] || [filename hasSuffix:@".cxx"] || [filename hasSuffix:@".h"] || [filename hasSuffix:@".java"] || [filename hasSuffix:@".def"] || [filename hasSuffix:@".g"] || [filename hasSuffix:@".c"] || [filename hasSuffix:@".c++"] || [filename hasSuffix:@".cc"] || [filename hasSuffix:@".list"]|| [filename hasSuffix:@".log"]|| [filename hasSuffix:@".lst"] || [filename hasSuffix:@".m"] || [filename hasSuffix:@".mar"] || [filename hasSuffix:@".pl"] || [filename hasSuffix:@".sdml"])
    {
        self->typeMime=@"text/plain";
        self->_fileImage.image=[UIImage imageNamed:@"txt"];
    }
    else if([filename hasPrefix:@".bmp"])
    {
        self->typeMime=@"image/bmp";
        self->_fileImage.image=[UIImage imageNamed:@"commonImage"];
    }
    else if([filename hasPrefix:@".java"])
    {
        self->typeMime=@"application/java";
        self->_fileImage.image=[UIImage imageNamed:@"commonImage"];
    }
    else if([filename hasSuffix:@".html"] || [filename hasSuffix:@".htm"] || [filename hasSuffix:@".htmls"] || [filename hasSuffix:@".HTML"] || [filename hasSuffix:@".HTM"])
    {
        self->typeMime=@"text/html";
        self->_fileImage.image=[UIImage imageNamed:@"html"];
    }
    else  if([filename hasSuffix:@".mp3"])
    {
        self->typeMime=@"audio/mp3";
        self->_fileImage.image=[UIImage imageNamed:@"mp3"];
    }
    else  if([filename hasSuffix:@".wav"])
    {
        self->typeMime=@"audio/wav";
        self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
    }
    else  if([filename hasSuffix:@".aac"])
    {
        self->typeMime=@"audio/aac";
        self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
    }
    else  if([filename hasSuffix:@".aiff"] || [filename hasSuffix:@".aif"])
    {
        self->typeMime=@"audio/aiff";
        self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
    }
    else  if([filename hasSuffix:@".m4p"])
    {
        self->typeMime=@"audio/m4p";
        self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
    }
    else  if([filename hasSuffix:@".mp4"])
    {
        self->typeMime=@"video/mp4";
        self->_fileImage.image=[UIImage imageNamed:@"mp4"];
    }
    else if([filename hasSuffix:@".mov"])
    {
        self->typeMime=@"video/quicktime";
        self->_fileImage.image=[UIImage imageNamed:@"audioCommon"];
    }
    
    else  if([filename hasSuffix:@".wmv"])
    {
        self->typeMime=@"video/x-ms-wmv";
        self->_fileImage.image=[UIImage imageNamed:@"wmv"];
    }
    else if([filename hasSuffix:@".flv"])
    {
        self->typeMime=@"video/x-msvideo";
        self->_fileImage.image=[UIImage imageNamed:@"flv"];
    }
    else if([filename hasSuffix:@".mkv"])
    {
        self->typeMime=@"video/mkv";
        self->_fileImage.image=[UIImage imageNamed:@"mkv"];
    }
    else if([filename hasSuffix:@".avi"])
    {
        self->typeMime=@"video/avi";
        self->_fileImage.image=[UIImage imageNamed:@"avi"];
    }
    else if([filename hasSuffix:@".zip"])
    {
        self->typeMime=@"application/zip";
        self->_fileImage.image=[UIImage imageNamed:@"zip"];
    }
    else if([filename hasSuffix:@".rar"])
    {
        self->typeMime=@"application/x-rar-compressed";
        self->_fileImage.image=[UIImage imageNamed:@"commonImage"];
    }
    else
    {
        self->_fileImage.image=[UIImage imageNamed:@"commonImage"];
    }
    
    });
}

-(void)replyTicketMethodCall
{
   
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        //[utils showAlertWithMessage:NO_INTERNET sendViewController:self];
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        
        @try{
            
            NSString *urlString=[NSString stringWithFormat:@"%@helpdesk/reply?token=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"POST"];
            
            NSMutableData *body = [NSMutableData data];
            
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
            
            // attachment parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media_attachment[]\"; filename=\"%@\"\r\n", file123] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", typeMime] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:attachNSData]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            // reply content parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"reply_content\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[_messageTextView.text dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            NSString * tickerId=[NSString stringWithFormat:@"%@",globalVariables.iD];
            // ticket id parameter
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ticket_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[tickerId dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // set request body
            [request setHTTPBody:body];
            
            NSLog(@"Request is : %@",request);
            
            //return and test
            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            
            NSLog(@"ReturnString : %@", returnString);
            
            NSError *error=nil;
            NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
            if (error) {
                return;
            }
            
            NSLog(@"Dictionary is : %@",jsonData);
            // "message": "Successfully replied"
            
           
            
            if ([jsonData objectForKey:@"message"]){
                
                NSString * msg=[jsonData objectForKey:@"message"];
                
                
                if([msg isEqualToString:@"Successfully replied"])
                {
                    
                    [RKDropdownAlert title:NSLocalizedString(@"success", nil) message:NSLocalizedString(@"Posted your reply.", nil)backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
                    
                  //  [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
                    
//                    TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
//                    [self.navigationController pushViewController:td animated:YES];
                    
                     [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else if ([jsonData objectForKey:@"message"])
                {
                    
                    NSString *str=[jsonData objectForKey:@"message"];
                    
                    if([str isEqualToString:@"Token expired"])
                    {
                        MyWebservices *web=[[MyWebservices alloc]init];
                        [web refreshToken];
                        [self replyTicketMethodCall];
                        
                    }
                }
                else
                {
                    [self->utils showAlertWithMessage:@"Something went wrong. Please try again." sendViewController:self];
                }
                NSLog(@"Thread-Ticket-Reply-closed");
                
                
            }
            
        }@catch (NSException *exception)
        {
            [utils showAlertWithMessage:exception.name sendViewController:self];
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        @finally
        {
            NSLog( @" I am in replytTicket method in TicketDetail ViewController" );
            
        }
        
    }
}




@end

