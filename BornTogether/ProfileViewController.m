//
//  ProfileViewController.m
//  BornTogether
//
//  Created by Michael Thomas on 8/5/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import "ProfileViewController.h"
#import "ChatViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    //NSLog(@"user from home, %@", self.matchedUser);
    
    NSDictionary *profileDict = self.matchedUser[@"profile"];
    
    self.usernameLabel.text = self.matchedUser[@"Alias"];
    self.birthdayLabel.text = profileDict[@"birthday"];
    self.aboutmeLabel.text = self.matchedUser[@"aboutMe"];
    
    PFFile *theImage = [self.matchedUser objectForKey:USERPROFILEIMAGE];
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        self.profilePicImageView.image = image;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chatButtonClicked:(UIBarButtonItem *)sender
{
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toChat"])
    {
        if ([segue.destinationViewController isKindOfClass:[ChatViewController class]])
        {
            ChatViewController *cvc = segue.destinationViewController;
            cvc.matchedUser =  self.matchedUser;
        }
    }
    
}



@end
