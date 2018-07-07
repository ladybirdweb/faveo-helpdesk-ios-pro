//
//  AboutViewController.m
//  SideMEnuDemo
//
//  Created on 07/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "AboutViewController.h"
#import "HexColors.h"
#import "RKDropdownAlert.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

#pragma mark - SlideNavigationController Methods -

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _versionNumberLabel.text=@"version: 1.8.9";
    _textview.editable=NO;
      [self setTitle:NSLocalizedString(@"About",nil)];
    _websiteButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
  
}

//Sent to the view controller when the app receives a memory warning.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// After clicking this method, it will navigate to notification view controller
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

// after clcking on button, it will redirect to Faveo Helpdesk website
- (IBAction)btnClicked:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://www.faveohelpdesk.com/"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }else {
        
    }
}
@end
