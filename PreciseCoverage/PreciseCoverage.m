//
//  PreciseCoverage.m
//  PreciseCoverage
//
//  Created by Sash Zats on 11/26/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

#import "PreciseCoverage.h"
#import <objc/runtime.h>
#import "Aspects.h"


static PreciseCoverage *sharedPlugin;


@interface PreciseCoverage()
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end


@implementation PreciseCoverage

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.bundle = plugin;
    [self _init];
    return self;
}

- (void)_init {
    Class IDECoverageReportMeterBar = NSClassFromString(@"IDECoverageReportMeterBar");
    [IDECoverageReportMeterBar aspect_hookSelector:@selector(setDoubleValue:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, double newValue){
        NSView *instance = [info instance];
        static const NSInteger labelTag = 124;
        NSTextField *label = [instance viewWithTag:labelTag];
        if (!label) {
            label = [[NSTextField alloc] init];
            label.editable = NO;
            label.bezeled = NO;
            label.drawsBackground = NO;
            label.selectable = NO;
            label.font = [NSFont systemFontOfSize:10];
            label.alignment = NSTextAlignmentCenter;
            [instance addSubview:label];
        }
        label.frame = ({
            CGRect frame = instance.bounds;
            frame.size.width -= 4;
            frame.size.height -= 4;
            frame.origin.y -= 2;
            frame;
        });
        NSString *string = [NSString stringWithFormat:@"%.0f%%", newValue];
        label.alignment = NSTextAlignmentRight;
        label.stringValue = string;
    } error:nil];
    [IDECoverageReportMeterBar aspect_hookSelector:@selector(drawRect:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, CGRect bounds){
        double progress = [[info instance] doubleValue];
        
        NSRect frame = [[info instance] bounds];
        frame = CGRectInset(frame, 4, 6);
        frame.origin.y -= 2;
        frame.size.width -= 35;
        
        const CGFloat radius = 4;
        
        NSBezierPath *background = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
        [[NSColor colorWithDeviceWhite:0.851 alpha:1.000] setFill];
        [background fill];
        
        frame.size.width *= progress / 100;
        NSBezierPath *track = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:radius yRadius:radius];
        if (progress == 100) {
            [[NSColor colorWithDeviceRed:0.191 green:0.638 blue:0.261 alpha:1.000] setFill];
        } else if (progress >= 50) {
            [[NSColor colorWithDeviceRed:0.986 green:0.780 blue:0.000 alpha:1.000] setFill];
        } else {
            [[NSColor colorWithDeviceRed:0.675 green:0.157 blue:0.109 alpha:1.000] setFill];
        }
        [track fill];
        NSLog(@"\n\n\nprogress %f\n\n\n", progress);
    } error:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
