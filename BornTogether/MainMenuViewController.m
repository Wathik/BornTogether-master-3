//
//  MainMenuViewController.m
//  BornTogether
//
//  Created by Michael Thomas on 7/30/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import "MainMenuViewController.h"
#import "MTConstants.h"
#import "ProfileViewController.h"
#import "MTAppDelegate.h"

@interface MainMenuViewController ()

@property (strong, nonatomic) NSMutableData *imageData;

@property (strong, nonatomic) NSArray *allUsers;

@end

@implementation MainMenuViewController

-(NSArray *)allUsers
{
    if (!_allUsers)
    {
        _allUsers = [[NSArray alloc]init];
    }
    return _allUsers;
}

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
    
    if (![[PFUser currentUser]valueForKey:@"Alias"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter an Alias"
                                                        message:@"Welcome to Born Together \n Please enter a username, this will be the name other users know you by."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Save",nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else
    {
        NSLog(@"There was a user alias found for this user");
    }
    
    if (![[PFUser currentUser] valueForKey:@"profile"])
    {
        FBRequest *request = [FBRequest requestForMe];
        
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (!error){
                NSDictionary *userDictionary = (NSDictionary *)result;
                
                //create URL
                NSString *facebookID = userDictionary[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",facebookID]];
                
                NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
                if (userDictionary[@"name"]){
                    userProfile[kCCUserProfileNameKey] = userDictionary[@"name"];
                }
                if (userDictionary[@"first_name"]){
                    userProfile[kCCUserProfileFirstNameKey] = userDictionary[@"first_name"];
                }
                if (userDictionary[@"location"][@"name"]){
                    userProfile[kCCUserProfileLocationKey] = userDictionary[@"location"][@"name"];
                }
                if (userDictionary[@"gender"]){
                    userProfile[kCCUserProfileGenderKey] = userDictionary[@"gender"];
                }
                if (userDictionary[@"birthday"])
                {
                    userProfile[kCCUserProfileBirthdayKey] = userDictionary[@"birthday"];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateStyle:NSDateFormatterShortStyle];
                    NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                    NSDate *now = [NSDate date];
                    NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                    int age = seconds / 31536000;
                    userProfile[kCCUserProfileAgeKey] = @(age);
                }
                else if(!userDictionary[@"birthday"])
                {
                    // Create alert
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to Born Together" message:@"We could not pull your birthday from Facebook, please enter your birthdate below \n WARNING: you will not be able to change your birthday after this point. " delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    // Show alert (required for sizes to be available)
                    [alert show];
                    // Create date picker (could / should be an ivar)
                    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, alert.bounds.size.height, 320, 216)];
                    picker.datePickerMode = UIDatePickerModeDate;
                    // Add picker to alert
                    [alert addSubview:picker];
                    // Adjust the alerts bounds
                    alert.bounds = CGRectMake(0, 0, 320 + 20, alert.bounds.size.height + 216 + 20);
                    
                    userProfile[kCCUserProfileBirthdayKey] = picker;
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateStyle:NSDateFormatterShortStyle];
                    NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                    NSDate *now = [NSDate date];
                    NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                    int age = seconds / 31536000;
                    userProfile[kCCUserProfileAgeKey] = @(age);
                }
                if (userDictionary[@"interested_in"]){
                    userProfile[kCCUserProfileInterestedInKey] = userDictionary[@"interested_in"];
                }
                if (userDictionary[@"relationship_status"]){
                    userProfile[kCCUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
                }
                if ([pictureURL absoluteString]){
                    userProfile[kCCUserProfilePictureURL] = [pictureURL absoluteString];
                }
                
                self.helloLabel.text = [NSString stringWithFormat:@"Hello, %@ \nWelcome to Born Together!", userProfile[kCCUserProfileNameKey]];
                
                self.bdayAgeLabel.text = [NSString stringWithFormat:@"Interact with other people born on:\n %@", userProfile[kCCUserProfileBirthdayKey]];
                
                [[PFUser currentUser]setObject:@YES forKey:USERYEARSEARCH];
                [[PFUser currentUser] setObject:userProfile forKey:kCCUserProfileKey];
                [[PFUser currentUser] saveInBackground];
                
                [self requestImage];
            }
            else {
                NSLog(@"Error in FB request %@", error);
            }
        }];
    }
    else
    {
        PFUser *user= [PFUser currentUser];
        
        NSDictionary *userDictionary = (NSDictionary *)[user valueForKey:@"profile"];
        self.helloLabel.text = [NSString stringWithFormat:@"Hello, %@ \nWelcome to Born Together!", userDictionary[kCCUserProfileNameKey]];
        
        self.bdayAgeLabel.text = [NSString stringWithFormat:@"Interact with other people born on:\n %@", userDictionary[kCCUserProfileBirthdayKey]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView setHidden:NO];
    [self.noUsersLableHideOrShow setHidden:YES];
    [self.inviteFriendsButtonProperty setHidden:YES];
    
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFUser *currentUser = [PFUser currentUser];
        
        NSMutableArray *addingUsers = [[NSMutableArray alloc]init];
        
        for (PFObject *user in objects)
        {
            NSDictionary *userProfileInfo= [user objectForKey:@"profile"];
            
            NSDictionary *currentProfileInfo = [currentUser objectForKey:@"profile"];
            
            if([userProfileInfo[@"birthday"] isEqual:currentProfileInfo[@"birthday"]] && ![user.objectId isEqualToString:currentUser.objectId])
            {
                [addingUsers addObject:user];
            }
            self.allUsers = addingUsers;
        }
        
        if (self.allUsers.count == 0)
        {
            [self.tableView setHidden:YES];
            [self.noUsersLableHideOrShow setHidden:NO];
            [self.inviteFriendsButtonProperty setHidden:NO];
        }
        [self.tableView reloadData];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField =  [alertView textFieldAtIndex: 0];
    
    if (textField.text && textField.text.length > 0)
    {
        NSLog(@"textfield = %@", textField.text);
        [[PFUser currentUser] setObject:textField.text forKey:@"Alias"];
        [[PFUser currentUser] saveInBackground];
        
        [self viewWillAppear:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter an Alias"
                                                        message:@"A user alias(username) is required to use the application."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Save",nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0)
        {
            PFUser *user = [PFUser currentUser];
            
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kCCUserProfileKey][kCCUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection){
                NSLog(@"Failed to Download Picture");
            }
        }
    }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"connection did recieve data");
    [self.imageData appendData:data];
    [self uploadImage:self.imageData];
}

-(void)uploadImage:(NSData *)imageData
{
    PFFile *imageFile = [PFFile fileWithName:@"ProfileImage.jpg" data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            // Create a PFObject around a PFFile and associate it with the current user
            [[PFUser currentUser] setObject:imageFile forKey:USERPROFILEIMAGE];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    //[self refresh:nil];
                }
                else
                {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    self.profileImage = [UIImage imageWithData:self.imageData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allUsers count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Born Together";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%lu", (unsigned long)[self.allUsers count]]);
    
    PFObject *user = self.allUsers[indexPath.row];
    
    NSDictionary *userDict = [user objectForKey:@"profile"];
    
    cell.detailTextLabel.text = userDict[@"gender"];
    
    cell.textLabel.text = user[@"Alias"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"toMatchedProfile" sender:indexPath];
}

-(void)invite
{
    MTAppDelegate *appDelegate =
    (MTAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (FBSession.activeSession.isOpen) {
        [appDelegate sendRequest:appDelegate.deviceFilteredFriends];
    }
}

- (IBAction)inviteFriendsButtonPressed:(UIButton *)sender
{
    [self invite];
}

- (IBAction)inviteButtonPressed:(UIBarButtonItem *)sender
{
    [self invite];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]])
    {
        NSIndexPath *path = sender;
        PFUser *matchedUser = [self.allUsers objectAtIndex:path.row];
        ProfileViewController *pvc = segue.destinationViewController;
        pvc.matchedUser =  matchedUser;
    }
}
@end
