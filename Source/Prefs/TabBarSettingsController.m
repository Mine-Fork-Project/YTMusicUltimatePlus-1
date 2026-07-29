#import "TabBarSettingsController.h"

@implementation OtherSettingsController

- (instancetype)init {
    self = [super init];
    if (self) { self.YTMUPPageId = @"tabbar"; }
    return self;
}

- (NSString *)title { return LOC(@"TABBAR_SETTINGS"); }

@end