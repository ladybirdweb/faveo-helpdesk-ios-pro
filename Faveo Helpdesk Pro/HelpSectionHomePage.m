//
//  HelpSectionHomePage.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 14/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "HelpSectionHomePage.h"
#import "SlideNavigationController.h"
#import "HelpSectionHomePageCell.h"
#import "LoadingTableViewCell.h"
#import "AppDelegate.h"
#import "AppConstanst.h"
#import "HexColors.h"
#import "Utils.h"
#import "LeftMenuViewController.h"
#import "LoginListMenuTable.h"
#import "TicketListMenuTable.h"
#import "UserAndAgentMenuList.h"
#import "otherFeatureMenuList.h"
#import "SupportViewController.h"
#import "test.h"

@interface HelpSectionHomePage ()<UITableViewDelegate,UITableViewDataSource>
{

    NSArray *images;
    NSArray *HeadingName;
    NSArray *SubHeadingName;
    
}

@end

@implementation HelpSectionHomePage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"Help Section";
   
    images=[NSArray arrayWithObjects:@"loginHelpSection",@"ticket2",@"userHelpSection",@"otherFeatures", nil];
    HeadingName=[NSArray arrayWithObjects:@"Login",@"Tickets",@"Users & Agents",@"Other Features", nil];
    SubHeadingName=[NSArray arrayWithObjects:@"Logging into the iOS app",@"Managing Tickets in iOS App",@"User Directory Help",@"Guide to use features in iOS app", nil];
    
     _DouHaveQuestionButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return HeadingName.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//        HelpSectionHomePageCell *cell=[tableView dequeueReusableCellWithIdentifier:@"HelpSectionMainPageCell"];
    test *cell=[tableView dequeueReusableCellWithIdentifier:@"testId"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"test" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    
        cell.name.text=[HeadingName objectAtIndex:indexPath.row];
        cell.subName.text=[SubHeadingName objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];

    return cell;
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==0)
    {
       
        LoginListMenuTable *td=[self.storyboard instantiateViewControllerWithIdentifier:@"LoginListMenuTableId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }else  if(indexPath.row==1)
    {
        
        TicketListMenuTable *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketListMenuTableId"];
        [self.navigationController pushViewController:td animated:YES];
        
    } else  if(indexPath.row==2)
    {
        
        UserAndAgentMenuList *td=[self.storyboard instantiateViewControllerWithIdentifier:@"UserAndAgentMenuListId"];
        [self.navigationController pushViewController:td animated:YES];
        
    } if(indexPath.row==3)
    {
        
        otherFeatureMenuList *td=[self.storyboard instantiateViewControllerWithIdentifier:@"otherFeatureMenuListId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }
//    }#import "TicketListMenuTable.h"
//#import "UserAndAgentMenuList.h"
//#import "otherFeatureMenuList.h"
    
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}


- (IBAction)DouHaveQuestionButtonAction:(id)sender {
    
    SupportViewController *support=[self.storyboard instantiateViewControllerWithIdentifier:@"supportViewId"];
    support.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:support animated:YES completion:nil];
    
}
@end
