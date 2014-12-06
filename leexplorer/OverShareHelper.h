//
//  ShareManager.h
//  leexplorer
//
//  Created by Hector Monserrate  on 12/6/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSDictionary.h>
#import "OverShareKit.h"

@interface OverShareHelper: NSObject <OSKActivityCustomizations>

+ (instancetype)sharedInstance;

- (void)presentActivitySheetForContent:(OSKShareableContent *)content
presentingViewController:(UIViewController *)presentingViewController;

@end
