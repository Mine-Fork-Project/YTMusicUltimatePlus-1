#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../YTMUPKeys.h"

static BOOL playbackRateButtonEnabled(void) {
    return IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyPlaybackRateButton);
}

@interface YTMPlaybackRateButtonHolder : NSObject
@property (readonly, copy, nonatomic) UIButton *button;
@end

@interface YTMPlayerControlsView : UIView
@property (readonly, nonatomic) NSArray<YTMPlaybackRateButtonHolder *> *playbackRateButtons;
@end

%hook YTMModularNowPlayingViewController
- (BOOL)playbackRateButtonEnabled {
    return playbackRateButtonEnabled() ? YES : %orig;
}
- (void)setPlaybackRateButtonEnabled:(BOOL)enabled {
    playbackRateButtonEnabled() ? %orig(YES) : %orig;
}
%end

%hook YTMPlayerControlsView
- (BOOL)playbackRateButtonEnabled {
    return playbackRateButtonEnabled() ? YES : %orig;
}
- (void)setPlaybackRateButtonEnabled:(BOOL)enabled {
    playbackRateButtonEnabled() ? %orig(YES) : %orig;
}
// Thanks to @danpashin for help
- (void)setupPlaybackRateButtons {
    %orig;
    NSMutableArray *buttonsConstraints = [NSMutableArray arrayWithCapacity:self.playbackRateButtons.count * 2];
    for (YTMPlaybackRateButtonHolder *holder in self.playbackRateButtons) {
        holder.button.translatesAutoresizingMaskIntoConstraints = NO;
        [buttonsConstraints addObject:[holder.button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
        [buttonsConstraints addObject:[holder.button.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
    }
    [NSLayoutConstraint activateConstraints:buttonsConstraints];
}
%end
