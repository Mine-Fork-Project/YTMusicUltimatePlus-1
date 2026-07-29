#import "PlayerSettingsController.h"

@implementation PlayerSettingsController

- (instancetype)init {
    self = [super init];
    if (self) { self.YTMUPPageId = @"player"; }
    return self;
}

- (NSString *)title { return LOC(@"PLAYER_SETTINGS"); }

@end