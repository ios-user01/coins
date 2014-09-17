//
//  BTCAppDelegate.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCAppDelegate.h"
#import "BTCValueViewController.h"
#import "LocalyticsUtilities.h"

#import "HockeySDK.h"
#import "UIColor+Coins.h"

@implementation BTCAppDelegate

#pragma mark - Accessors

@synthesize window = _window;


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"d0d82a50debc14c4fde0cb3430893bd6"];
	[[BITHockeyManager sharedHockeyManager] startManager];
	[[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

	LLStartSession(@"987380b36bedad08c8468c1-1e2d6372-7443-11e3-1898-004a77f8b47f");

	application.statusBarStyle = UIStatusBarStyleLightContent;

	[application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

	UINavigationBar *navigationBar = [UINavigationBar appearance];
	navigationBar.barTintColor = [UIColor btc_blueColor];
	navigationBar.tintColor = [UIColor colorWithWhite:1.0 alpha:0.5f];
	navigationBar.titleTextAttributes = @{
		NSForegroundColorAttributeName: [UIColor whiteColor],
		NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0]
	};

	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	[standardDefaults registerDefaults:@{
		kBTCAutomaticallyRefreshKey: @YES,
		kBTCDisableSleepKey: @NO,
		@"BTCMigrated": @NO
	}];

	NSUserDefaults *sharedDefaults = [NSUserDefaults btc_sharedDefaults];
	[sharedDefaults registerDefaults:@{
		kBTCSelectedCurrencyKey: @"USD",
		kBTCNumberOfCoinsKey: @0,
		kBTCControlsHiddenKey: @NO
	}];

	if (![standardDefaults boolForKey:@"BTCMigrated"]) {
		NSArray *keys = @[kBTCSelectedCurrencyKey, kBTCNumberOfCoinsKey, kBTCControlsHiddenKey];
		for (NSString *key in keys) {
			[sharedDefaults setObject:[standardDefaults objectForKey:key] forKey:key];
		}
		[sharedDefaults synchronize];

		[standardDefaults setBool:YES forKey:@"BTCMigrated"];
		[standardDefaults synchronize];
	}

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BTCValueViewController alloc] init]];

    [self.window makeKeyAndVisible];

	dispatch_async(dispatch_get_main_queue(), ^{
		NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
		NSString *versionString = [NSString stringWithFormat:@"%@ (%@)",
								   info[@"CFBundleShortVersionString"],
								   info[@"CFBundleVersion"]];
		[standardDefaults setObject:versionString forKey:@"BTCVersion"];
		[standardDefaults synchronize];
	});

    return YES;
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	if (!completionHandler) {
		return;
	}

	[[BTCConversionProvider sharedProvider] getConversionRates:^(NSDictionary *conversionRates, UIBackgroundFetchResult result) {
		completionHandler(result);
	}];
}

@end
