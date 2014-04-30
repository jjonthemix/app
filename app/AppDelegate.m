//
//  AppDelegate.m
//  app
//
//  Created by Joel Oliveira on 16/04/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "MainViewController.h"
#import "RightViewController.h"
#import "LeftViewController.h"
#import "LocationViewController.h"
#import "NSData+Hex.h"
#import "TestFlight.h"
#import "Configuration.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [TestFlight takeOff:[[Configuration shared] getProperty:@"testflight"]];
    
//    [self setApiEngine:[[ApiEngine alloc] initWithHostName:[[Configuration shared] getProperty:@"host"]
//                                        customHeaderFields:nil]];
//    
//    [[self apiEngine] useCache];
//    
//    [UIImageView setDefaultEngine:[self apiEngine]];
    
    //[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor colorWithRed:74.0/255.0 green:134.0/255.0 blue:186.0/255.0 alpha:1.0]];
    

    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Blue"] forBarMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor blackColor]];
    
    [self setBeacons:[NSMutableArray array]];
    [self setRegions:[NSMutableArray array]];
    
    [[NotificarePushLib shared] launch];
    [[NotificarePushLib shared] setDelegate:self];
    [self registerForAPNS];
    
    [[NotificarePushLib shared] handleOptions:[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];

    [[NotificarePushLib shared] handleOptions:[launchOptions objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"]];

    IIViewDeckController* deckController = [self generateControllerStack];
    self.leftController = deckController.leftController;
    self.centerController = deckController.centerController;
    [self.window setRootViewController:deckController];
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (IIViewDeckController*)generateControllerStack {
    
    [self setLeftController:[[LeftViewController alloc] initWithNibName:@"LeftViewController" bundle:nil]];
    [self setRightController:[[RightViewController alloc] initWithNibName:@"RightViewController" bundle:nil]];
    MainViewController * controller = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [controller setViewTitle:LSSTRING(@"menu_item_home")];
    [controller setTargetUrl:[[Configuration shared] getProperty:@"url"]];
    [self setCenterController:[[UINavigationController alloc] initWithRootViewController:controller]];
    [self setDeckController:[[IIViewDeckController alloc] initWithCenterViewController:[self centerController]
                                                                    leftViewController:[self leftController]
                                                                   rightViewController:[self rightController]]];
        //deckController.rightSize = 100;
        
        [[self deckController] disablePanOverViewsOfClass:NSClassFromString(@"_UITableViewHeaderFooterContentView")];
        return [self deckController];

}


-(void)handleNavigation:(NSDictionary *)item{
    
    
    [[self deckController] toggleLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
        
        
        if ([[item objectForKey:@"url"] hasPrefix:@"http://"] || [[item objectForKey:@"url"] hasPrefix:@"https://"]) {
            
            MainViewController * main = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
            
            [main setViewTitle:LSSTRING([item objectForKey:@"label"])];
            [main setTargetUrl:[item objectForKey:@"url"]];
            [self setCenterController:[[UINavigationController alloc] initWithRootViewController:main]];
            
            [[self deckController] setCenterController:[self centerController]];
            
        } else {
            //Check which Native view to use
            
            if ([[item objectForKey:@"url"] hasPrefix:@"IBAction:"]){
                //Call a method in delegate (used for the settings)

                NSString * method = [[item objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"IBAction:" withString:@""];
                SEL mySelector = NSSelectorFromString(method);
                if([self respondsToSelector:mySelector]){
                    Suppressor([self performSelector:mySelector]);
                }
  
            } else if ([[item objectForKey:@"url"] hasPrefix:@"MKMapView:"]){
                
                
                LocationViewController * map = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];

                [self setCenterController:[[UINavigationController alloc] initWithRootViewController:map]];
                [[self deckController] setCenterController:[self centerController]];
                
            }
            
        }
        
        
    }];
    

}


-(void)registerForAPNS{
    [[NotificarePushLib shared] registerForRemoteNotificationsTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}


-(void)openPreferences{
    [[NotificarePushLib shared] openUserPreferences];
}


-(void)openBeacon:(NSDictionary *)info{
    [[NotificarePushLib shared] openBeacon:info];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"userId"]){
        [[NotificarePushLib shared] registerDevice:deviceToken withUserID:[defaults objectForKey:@"userId"] completionHandler:^(NSDictionary *info) {
            [[NotificarePushLib shared] startLocationUpdates];
            [defaults setObject:[deviceToken hexadecimalString] forKey:@"deviceToken"];
            [defaults synchronize];
            [self addTags];
        } errorHandler:^(NSError *error) {
            //
        }];
    } else {
        //If you don't identify users you can just use this
        [[NotificarePushLib shared] registerDevice:deviceToken completionHandler:^(NSDictionary *info) {
            [[NotificarePushLib shared] startLocationUpdates];
            [defaults setObject:[deviceToken hexadecimalString] forKey:@"deviceToken"];
            [defaults synchronize];
            [self addTags];
        } errorHandler:^(NSError *error) {
            //
        }];
    }
    
}


-(void)addTags{
    [[NotificarePushLib shared] addTags:@[@"tag_press",@"tag_events",@"tag_newsletter"] completionHandler:^(NSDictionary *info) {
        //
    } errorHandler:^(NSError *error) {
        //
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"%@",error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [[NotificarePushLib shared] openNotification:userInfo];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    [[NotificarePushLib shared] openNotification:@{@"id":[[notification userInfo] objectForKey:@"notification"]}];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library willOpenNotification:(Notification *)notification{
    NSLog(@"willOpenNotification%@",notification);
}

- (void)notificarePushLib:(NotificarePushLib *)library didOpenNotification:(Notification *)notification{
    NSLog(@"didOpenNotification%@",notification);
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didCloseNotification:(Notification *)notification{
    NSLog(@"didCloseNotification%@",notification);
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToOpenNotification:(Notification *)notification{
    NSLog(@"didFailToOpenNotification%@",notification);
}


- (void)notificarePushLib:(NotificarePushLib *)library willExecuteAction:(Notification *)notification{
    NSLog(@"%@",notification);
}

- (void)notificarePushLib:(NotificarePushLib *)library didExecuteAction:(NSDictionary *)info{
    NSLog(@"%@",info);
}

-(void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelector:(NSString *)selector{
    SEL mySelector = NSSelectorFromString(selector);
    if([self respondsToSelector:mySelector]){
        Suppressor([self performSelector:mySelector]);
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library didNotExecuteAction:(NSDictionary *)info{
    NSLog(@"%@",info);
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToExecuteAction:(NSError *)error{
    NSLog(@"%@",error);
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NSDictionary *)status{
    if ([[status objectForKey:@"status"] isEqualToString:@"Location Services are available"]) {
        [self setIsLocationServicesOn:YES];
    } else {
        [self setIsLocationServicesOn:NO];
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{
    [self setIsLocationServicesOn:NO];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray *)locations{

}

//Use this delegate to know if any region failed to be monitored
- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    NSLog(@"monitoringDidFailForRegion: %@ %@", region, error);
}

//iOS 7 only delegate. When on iOS7 this delegate will give a status of a monitored region
// You can request a state of a region by doing [[[NotificarePushLib shared] locationManager] requestStateForRegion:(CLRegion *) region];

- (void)notificarePushLib:(NotificarePushLib *)library didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
   // NSLog(@"didDetermineState: %i %@", state, region);
    
}

//Use this delegate to know when a user entered a region. Notificare will automatically handle the triggers.
//According to the triggers created through the dashboard or API.
- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(CLRegion *)region{
    NSLog(@"didEnterRegion: %@", region);
    
}

//Use this delegate to know when a user exited a region. Notificare will automatically handle the triggers.
//According to the triggers created through the dashboard or API.
- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(CLRegion *)region{
    
    NSLog(@"didExitRegion: %@", region);
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"didStartMonitoringForRegion: %@", region);
    
    if(![region isKindOfClass:[CLBeaconRegion class]]){
        
        [[self regions] removeAllObjects];
        
        for (NSDictionary * fence in [[NotificarePushLib shared] geofences]) {
            [[self regions] addObject:fence];
        }
        
    }
}


//iOS 7 only delegate. Use this delegate to know when ranging beacons for a CLBeaconRegion failed.
- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    NSLog(@"rangingBeaconsDidFailForRegion: %@ %@", region, error);
}

//iOS 7 only delegate. Use this delegate to know when beacons have been found according to the proximity you set in the dashboard or API.
//When found a beacon it will be included in the array as a NSDictionary with a root property called info
//This will hold all the information of the beacon that is passed by Notificare like settings, content, etc.
//With this object you can alays open the beacon content by doing:
//[[NotificarePushLib shared] openNotification:[beacon objectForKey:@"info"]];

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{

    [self setBeacons:[NSMutableArray arrayWithArray:beacons]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"gotBeacons" object:nil];
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

@end
