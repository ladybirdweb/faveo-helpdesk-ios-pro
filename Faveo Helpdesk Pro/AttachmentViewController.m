//
//  AttachmentViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 22/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "AttachmentViewController.h"
#import "attachmentListShowTableCell.h"
#import "Utils.h"
#import "GlobalVariables.h"
#import "AppDelegate.h"
#import "NSData+Base64.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AttachmentViewController ()
{
    NSMutableArray *selectedArray;
    GlobalVariables *globalvariable;
     NSUserDefaults *userDefaults;
    NSMutableArray *fileAttachmentArray;
    NSString *fileName;
    AVPlayer *playr;
    
}
@end

@implementation AttachmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppDelegate sharedAppdelegate] hideProgressView];
    
    globalvariable=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    fileAttachmentArray=[[NSMutableArray alloc]init];
    
    fileAttachmentArray=globalvariable.attachArrayFromConversation;
   // NSLog(@"Array is : %@",globalvariable.attachArrayFromConversation);
    

 //   selectedArray=[[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil];
    

}
-(void)viewWillAppear:(BOOL)animated
{
    globalvariable=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return fileAttachmentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     attachmentListShowTableCell *cell=[tableView dequeueReusableCellWithIdentifier:@"attachListShowId"];

    if (cell == nil)
     {
          NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"attachmentListShowTableCell" owner:self options:nil];
         cell = [nib objectAtIndex:0];
    }

  //  for (int i = 0; i < fileAttachmentArray.count; i++) {
        
        NSDictionary *attachDictionary=[fileAttachmentArray objectAtIndex:indexPath.row];
        
        
    //    NSString *numStr = [NSString stringWithFormat:@"%@", [attachDictionary objectForKey:@"file"]];
        
        fileName=[attachDictionary objectForKey:@"name"];
        cell.attachmentName.text=fileName;
        
    
        NSString *fileSize=[NSString stringWithFormat:@"%@",[attachDictionary objectForKey:@"size"]];
    cell.sizeLabel.text=[NSString stringWithFormat:@"%@ KB",fileSize];
    
        NSString *fileType=[attachDictionary objectForKey:@"type"];
        
        NSLog(@"File Name : %@",fileName);
        NSLog(@"File size : %@",fileSize);
        NSLog(@"File Type : %@",fileType);
        
      //  printf("File Attachemnt(base64 String) : %s\n", [numStr UTF8String]);
        
  //  }
    
    return cell;

    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_webView reload];
    
    NSDictionary *attachDictionary=[fileAttachmentArray objectAtIndex:indexPath.row];
    NSString *numStr = [NSString stringWithFormat:@"%@", [attachDictionary objectForKey:@"file"]];
    NSString *fileName=[attachDictionary objectForKey:@"name"];
  //  NSString *fileType=[attachDictionary objectForKey:@"type"];
    
     NSString *typeMime;
    
    if([fileName hasSuffix:@".doc"])
    {
        typeMime=@"application/msword";
    }
    else if([fileName hasSuffix:@".pdf"] || [fileName hasSuffix:@".PDF"])
        {
           typeMime=@"application/pdf";
        }
    else if([fileName hasSuffix:@".css"])
    {
        typeMime=@"text/css";
    }
    else if([fileName hasSuffix:@".csv"])
    {
        typeMime=@"text/csv";
    }
    else if([fileName hasSuffix:@".xls"])
    {
        typeMime=@"application/vnd.ms-excel";
    }
    else if([fileName hasSuffix:@".xls"])
    {
        typeMime=@"application/vnd.ms-excel";
    }
    else if([fileName hasSuffix:@".rtf"])
    {
        typeMime=@"text/richtext";
    }
    else if([fileName hasSuffix:@".sql"])
    {
        typeMime=@"text/sql";
    }
    else if([fileName hasSuffix:@".gif"])
    {
        typeMime=@"image/gif";
    }
    else if([fileName hasSuffix:@".ppt"] || [fileName hasSuffix:@".PPT"])
    {
        typeMime=@"application/mspowerpoint";
    }
    else if([fileName hasSuffix:@".jpeg"])
    {
        typeMime=@"image/jpeg";
    }
    else if([fileName hasSuffix:@".png"])
    {
        typeMime=@"image/png";
    }
    else if([fileName hasSuffix:@".ico"])
    {
        typeMime=@"image/x-icon";
    }
    else if([fileName hasSuffix:@".txt"] || [fileName hasSuffix:@".text"])
    {
        typeMime=@"text/plain";
    }
    else if([fileName hasSuffix:@".html"] || [fileName hasSuffix:@".htm"] || [fileName hasSuffix:@".htmls"])
    {
        typeMime=@"text/html";
    }
//    else if([fileName hasSuffix:@".mp3"])
//    {
//
//        // NSData from the Base64 encoded str
//        NSData *nsdataFromBase64String = [[NSData alloc]
//                                          initWithBase64EncodedString:numStr options:0];
//
//        // Decoded NSString from the NSData
//        NSString *base64Decoded = [[NSString alloc]
//                                   initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
//        NSLog(@"Decoded: %@", base64Decoded);
//
////        //typeMime=@"audio/x-mpeg-3";
////        NSString *str=@"data:application/pdf;base64,";
////        NSString *str2=[str stringByAppendingString:numStr];
////
////         NSURL *url = [NSURL URLWithString:str2];
////        // NSData *imageData = [NSData dataWithContentsOfURL:url];
////
////        AVPlayerItem *item=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
////        playr=[AVPlayer playerWithPlayerItem:item];
////        [playr play];
//    }
    else
    {
        typeMime=@"audio/mp3";
        
    }
    
    // dataFromBase64String from NSData+Base64.h file
    NSData* myData = [NSData dataFromBase64String: numStr];
    
    
    [_webView loadData:myData
             //MIMEType:@"application/pdf"
              MIMEType:typeMime
     textEncodingName:@"NSUTF8StringEncoding"
              baseURL:[NSURL URLWithString:@"https://www.google.co.in/"]];
    
    // zoom karnya sathi
    _webView.scalesPageToFit = YES;
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview:_webView];
    _webView.mediaPlaybackRequiresUserAction = NO;
    
    
}






@end
