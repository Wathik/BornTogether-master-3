//
//  MTAppDelegate.m
//  FBAPIPractice
//
//  Created by Michael Thomas on 7/16/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import "MTAppDelegate.h"

@implementation MTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"A8N5t7LhL3JfgYVoBD2AdH7YvZ3mCnWfvBDkxedU"
                  clientKey:@"YcjsowWXb5NLUvB4isNMpkFgsHwBCzUK22LfCebT"];
    [PFFacebookUtils initializeFacebook]; 
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
//    //[defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [PFFacebookUtils handleOpenURL:url];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

/*
 * Send a user to user request, with a targeted list
 */
- (void)sendRequest:(NSArray *) targeted {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:@{
                                             @"social_karma": @"%i",
                                             }
                        options:0
                        error:&error];
    if (error) {
        NSLog(@"JSON error: %@", error);
        return;
    }
    
    NSString *giftStr = [[NSString alloc]
                         initWithData:jsonData
                         encoding:NSUTF8StringEncoding];
    NSMutableDictionary* params = [@{@"data" : giftStr} mutableCopy];
    
    // Filter and only show targeted friends
    if (targeted != nil && [targeted count] > 0) {
        NSString *selectIDsStr = [targeted componentsJoinedByString:@","];
        params[@"suggestions"] = selectIDsStr;
    }
    
    // Display the requests dialog
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Learn how to make your iOS apps social."
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }];
    
    
}


/*
 * Get iOS device users and send targeted requests.
 */
- (void) requestFriendsUsingDevice:(NSString *)device {
    _deviceFilteredFriends = [[NSMutableArray alloc] init];
    [FBRequestConnection startWithGraphPath:@"me/friends"parameters: @{ @"fields" : @"id,devices"}
                                 HTTPMethod:nil completionHandler:^(FBRequestConnection *connection,
                                                                    id result,
                                                                    NSError *error) {
                                     if (!error) {
                                         
                                         NSArray *resultData = result[@"data"];
                                         if ([resultData count] > 0) {
                                             // Loop through the friends returned
                                             for (NSDictionary *friendObject in resultData) {
                                                 // Check if devices info available
                                                 if (friendObject[@"devices"]) {
                                                     NSArray *deviceData = friendObject[@"devices"];
                                                     // Loop through list of devices
                                                     for (NSDictionary *deviceObject in deviceData) {
                                                         
                                                         if ([device isEqualToString:deviceObject[@"os"]]) {
                                                             
                                                             [_deviceFilteredFriends addObject:friendObject[@"id"]];
                                                             break;
                                                         }
                                                     }
                                                 }
                                             }
                                         }
                                     }
                                     // Send request
                                     [self sendRequest:_deviceFilteredFriends];
                                 }];
}



//Send request to iOS device users.

- (void)sendRequestToiOSFriends {
    // Filter and only show friends using iOS
    [self requestFriendsUsingDevice:@"iOS"];
}


//Helper function to get the request data

- (void) notificationGet:(NSString *)requestid {
    [FBRequestConnection startWithGraphPath:requestid completionHandler:^(FBRequestConnection *connection,
                                                                          id result,
                                                                          NSError *error) {
        if (!error) {
            NSString *title;
            NSString *message;
            if (result[@"data"]) {
                title = [NSString
                         stringWithFormat:@"%@ sent you a request",
                         result[@"from"][@"name"]];
                NSString *jsonString = result[@"data"];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                if (!jsonData) {
                    NSLog(@"JSON decode error: %@", error);
                    return;
                }
                NSError *jsonError = nil;
                NSDictionary *requestData =
                [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:0
                                                  error:&jsonError];
                if (jsonError) {
                    NSLog(@"JSON decode error: %@", error);
                    return;
                }
                message =
                [NSString stringWithFormat:@" %@, %@",
                 requestData[@"%@"],
                 requestData[@"Born_Together"]];
            } else {
                title = [NSString
                         stringWithFormat:@"%@ sent you a request",
                         result[@"from"][@"name"]];
                message = result[@"message"];
            }
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil,
                                  nil];
            [alert show];
            
            // Delete the request notification
            [self notificationClear:result[@"id"]];
        }
    }];
}

/*
 * Helper function to delete the request notification
 */
- (void) notificationClear:(NSString *)requestid {
    // Delete the request notification
    [FBRequestConnection startWithGraphPath:requestid
                                 parameters:nil
                                 HTTPMethod:@"DELETE"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (!error) {
                                  NSLog(@"Request deleted");
                              }
                          }];
}

- (void)showInvite
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Invite Friends"
                          message:@"If you enjoy using this app, would you mind taking a moment to invite a few friends that you think will also like it?"
                          delegate:self
                          cancelButtonTitle:@"No Thanks"
                          otherButtonTitles:@"Tell Friends!", @"Remind Me Later", nil];
    [alert show];
}


@end
