//
//  PreciseCoverage.h
//  PreciseCoverage
//
//  Created by Sash Zats on 11/26/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface PreciseCoverage : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end