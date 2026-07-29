#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../YTMUPKeys.h"

@interface YTMNavigationBarView : UIView @end
@interface QTMButton : UIButton
@property (nonatomic, copy, readwrite) NSString *accessibilityIdentifier;
@end
@interface YTMSortFilterButton : UIButton @end

%hook QTMButton
- (void)layoutSubviews {
    %orig;
    if (IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyHideHistoryButton)) {
        if ([self.accessibilityIdentifier isEqualToString:@"id.navigation.history.button"])
            self.hidden = YES;
    }
    if (IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyHideCastButton)) {
        if ([self.accessibilityIdentifier isEqualToString:@"id.mdx.playbackroute.button"])
            self.hidden = YES;
    }
}
%end

%hook YTMNavigationBarView
- (void)layoutSubviews {
    %orig;
    if (!IS_ENABLED(YTMUPKeyEnabled) || !IS_ENABLED(YTMUPKeyHideFilterButton)) return;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"YTMSortFilterButton")]) {
            [subview removeFromSuperview];
            break;
        }
    }
}
%end
