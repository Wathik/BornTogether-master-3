//
//  MTLoginViewController.m
//  FBAPIPractice
//
//  Created by Michael Thomas on 7/16/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import "MTLoginViewController.h"

@interface MTLoginViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITextField *Username;
@property (strong, nonatomic) IBOutlet UITextField *UserName;

@end

@implementation MTLoginViewController

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
    self.activityIndicator.hidden = YES;
    // Do any additional setup after loading the view.
    
}

-(void)viewDidAppear:(BOOL)animated
{
    //[super viewDidAppear:<#animated#>];
    PFLogInViewController *login = [[PFLogInViewController alloc]init];
    login.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsFacebook | PFLogInFieldsTwitter | PFLogInFieldsSignUpButton |PFLogInFieldsPasswordForgotten;
           login.delegate = self;
             login.signUpController.delegate = self;
    
    
    [self presentModalViewController:login animated:YES];
    
    
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
       //[self updateUserInformation];
 
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
    }
    //[login release];
   
    
    
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

-(void)getUserData
{
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    FBSession *session;
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error)
    {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        if (!user){
            if (!error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"The Facebook Login was Canceled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
        }
        else
        {
            //[self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
        }
    }];
    NSLog(@"%@", permissionsArray);
}
- (IBAction)loginButtonPressed:(UIButton *)sender
{
    [self getUserData];
}
- (IBAction)userlinkdedin:(UIButton *)sender {
}
- (IBAction)Twitterlogin:(UIButton *)sender {
}

@end
