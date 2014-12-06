//
//  ShareManager.m
//  leexplorer
//
//  Created by Hector Monserrate  on 12/6/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

#import "OverShareHelper.h"


@implementation OverShareHelper

+ (id)sharedInstance {
    static dispatch_once_t once;
    static OverShareHelper * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

#pragma mark - Public Methods

- (void)presentActivitySheetForContent:(OSKShareableContent *)content
              presentingViewController:(UIViewController *)presentingViewController {
    
    OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    OSKPresentationEndingHandler dismissalHandler = [self dismissalHandler];
    
    NSDictionary *options = @{    OSKActivityOption_ExcludedTypes : @[OSKActivityType_API_AppDotNet, OSKActivityType_API_GooglePlus],
                                  OSKPresentationOption_ActivityCompletionHandler : completionHandler,
                                  OSKPresentationOption_PresentationEndingHandler : dismissalHandler};
    
    [OSKActivitiesManager sharedInstance].customizationsDelegate = self;
    
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                   presentingViewController:presentingViewController
                                                                    options:options];
}

- (OSKApplicationCredential *)applicationCredentialForActivityType:(NSString *)activityType {
    return [[OSKApplicationCredential alloc] initWithOvershareApplicationKey:@"760381750702853" applicationSecret:@"" appName:@"Facebook"];
}



#pragma mark - Convenience

- (OSKActivityCompletionHandler)activityCompletionHandler {
    OSKActivityCompletionHandler activityCompletionHandler = ^(OSKActivity *activity, BOOL successful, NSError *error){
        OSKLog(@"Sheet completed.");
    };
    return activityCompletionHandler;
}

- (OSKPresentationEndingHandler)dismissalHandler {
    OSKPresentationEndingHandler dismissalHandler = ^(OSKPresentationEnding ending, OSKActivity *activityOrNil){
        OSKLog(@"Sheet dismissed.");
    };
    return dismissalHandler;
}

@end