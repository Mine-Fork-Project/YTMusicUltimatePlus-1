#import "PremiumSettingsController.h"

@implementation PremiumSettingsController

- (instancetype)init {
    self = [super init];
    if (self) { self.YTMUPPageId = @"premium"; }
    return self;
}

- (NSString *)title { return LOC(@"PREMIUM_SETTINGS"); }

@end