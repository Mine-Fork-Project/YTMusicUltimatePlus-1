#import "ThemeSettingsController.h"

@implementation ThemeSettingsController

- (instancetype)init {
    self = [super init];
    if (self) { self.YTMUPPageId = @"theme"; }
    return self;
}

- (NSString *)title { return LOC(@"THEME_SETTINGS"); }

@end