#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../YTMUPKeys.h"

@interface YTMNavigationBarView : UIView
- (void)setMusicLogoVisible:(BOOL)arg;
@end

%hook YTMNavigationBarView
- (void)layoutSubviews {
    %orig;
    if (!IS_ENABLED(YTMUPKeyEnabled)) return;
    if (IS_ENABLED(YTMUPKeyHideYTMLogo)) {
        [self setMusicLogoVisible:NO];
    }
    if (IS_ENABLED(YTMUPKeyHideNotiButton)) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:%c(YTMNavbarActivityButton)]) {
                [subview removeFromSuperview];
                break;
            }
        }
    }
}
%end

@interface YTMFlexibleHeaderView : UIView
- (void)setSubheaderViewHidden:(BOOL)arg;
@end

%hook YTMFlexibleHeaderView
- (void)setSubheaderView:(id)arg {
    %orig;
    if (!IS_ENABLED(YTMUPKeyEnabled)) return;
    if (IS_ENABLED(YTMUPKeyHideSubbar)) {
        [self setSubheaderViewHidden:YES];
    }
}