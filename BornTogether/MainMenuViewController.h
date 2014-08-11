//
//  MainMenuViewController.h
//  BornTogether
//
//  Created by Michael Thomas on 7/30/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSIndexPath *cellIndex;

@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *helloLabel;
@property (strong, nonatomic) IBOutlet UILabel *bdayAgeLabel;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *inviteFriendsButtonProperty;
@property (strong, nonatomic) IBOutlet UILabel *noUsersLableHideOrShow;


- (IBAction)inviteFriendsButtonPressed:(UIButton *)sender;
- (IBAction)inviteButtonPressed:(UIBarButtonItem *)sender;


@end
