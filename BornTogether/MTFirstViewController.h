//
//  SecureViewController.h
//  Login
//
//  Created by Wathik Almayali on 8/7/14.
//  Copyright (c) 2014 Wathik Almayali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTFirstViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate>

//@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;



@property (strong, nonatomic) UIImage *profileImage;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextView *aboutMeTextField;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UIButton *imageButtonLabel;

@property (strong, nonatomic) IBOutlet UIButton *updateInfoButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteAccountButton;

@property (strong, nonatomic) IBOutlet UILabel *includeInSearchLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthYearLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthLabelStatic;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatiorView;

@property (strong, nonatomic) IBOutlet UISwitch *yearSwitchProp;

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)updateInfoButtonPressed:(UIButton *)sender;
- (IBAction)deleteButtonPressed:(UIButton *)sender;
- (IBAction)logoutButtonPressed:(UIButton *)sender;
- (IBAction)imageButtonPressed:(UIButton *)sender;



@end
