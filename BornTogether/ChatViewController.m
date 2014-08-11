//
//  ChatViewController.m
//  BornTogether
//
//  Created by Antonio Strickland on 8/6/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    /////////////////////////////////////////////////////////ACCESS USERS INFO///////////////////////////////////////////////////
    
    //use "self.matchedUser" for the persons PFUser object that the user wishes to chat with
    PFUser *currentUser = [PFUser currentUser]; //Use this variable to get the PFUser object of the user who is currently signed in
    
    NSLog(@"User matched with that has same birthday: %@", self.matchedUser);
    NSLog(@"Currently logged in user: %@", currentUser);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
