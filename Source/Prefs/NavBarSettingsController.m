#import "NavBarSettingsController.h"

@implementation NavBarSettingsController

- (instancetype)init {
    self = [super init];
    if (self) { self.YTMUPPageId = @"navbar"; }
    return self;
}

- (NSString *)title { return LOC(@"NAVBAR_SETTINGS"); }

@end