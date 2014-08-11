//
//  MTAppDelegate.h
//  FBAPIPractice
//
//  Created by Michael Thomas on 7/16/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)sendRequest;
- (void)sendRequestToiOSFriends;
- (void)requestFriendsUsingDevice;
- (void)sendRequest:(NSArray *) targeted;

@property (strong, nonatomic) NSMutableArray *deviceFilteredFriends;

@end
