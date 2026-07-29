#import "Headers/YTMNowPlayingViewController.h"
#import "Headers/YTMNowPlayingView.h"
#import "Headers/YTAssetLoader.h"
#import "Headers/Localization.h"
#import "YTMUPKeys.h"

/// Returns the actual seek interval in seconds (0 = use system default).
static NSInteger ytmupSeekTime(void) {
    NSArray<NSNumber *> *seekTimes = @[@0, @10, @20, @30, @60];
    NSInteger index = INTFORVAL(YTMUPKeySeekTime);
    if (index < 0 || index >= (NSInteger)seekTimes.count) index = 0;
    return seekTimes[index].integerValue;
}

%hook YTMNowPlayingViewController
- (void)viewDidLoad {
    %orig;

    if (!IS_ENABLED(YTMUPKeyEnabled) || !IS_ENABLED(YTMUPKeySeekButtons)) return;

    YTMNowPlayingView *nowPlayingView = [self valueForKey:@"_nowPlayingView"];
    if (!nowPlayingView) return;

    YTMPlayerControlsView *controlsView = nowPlayingView.playerControlsView;

    [controlsView.prevButton removeTarget:self action:@selector(didTapPrevButton) forControlEvents:UIControlEventTouchUpInside];
    [controlsView.nextButton removeTarget:self action:@selector(didTapNextButton) forControlEvents:UIControlEventTouchUpInside];

    [controlsView.prevButton addTarget:self action:@selector(didTapSeekBackwardButton) forControlEvents:UIControlEventTouchUpInside];
    [controlsView.nextButton addTarget:self action:@selector(didTapSeekForwardButton)  forControlEvents:UIControlEventTouchUpInside];

    UILongPressGestureRecognizer *longPressPrev = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPrev:)];
    longPressPrev.minimumPressDuration = 0.5;
    [controlsView.prevButton addGestureRecognizer:longPressPrev];

    UILongPressGestureRecognizer *longPressNext = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressNext:)];
    longPressNext.minimumPressDuration = 0.5;
    [controlsView.nextButton addGestureRecognizer:longPressNext];

    NSInteger backValue    = ytmupSeekTime() == 0 ? 10 : ytmupSeekTime();
    NSInteger forwardValue = ytmupSeekTime() == 0 ? 30 : ytmupSeekTime();

    YTAssetLoader *al = [[%c(YTAssetLoader) alloc] initWithBundle:[NSBundle mainBundle]];
    UIImage *backImage    = [al imageNamed:[NSString stringWithFormat:@"ic_seek_back_%ld_40",    (long)backValue]];
    UIImage *forwardImage = [al imageNamed:[NSString stringWithFormat:@"ic_seek_forward_%ld_40", (long)forwardValue]];

    [controlsView.prevButton setImage:backImage    forState:UIControlStateNormal];
    [controlsView.prevButton setImage:backImage    forState:UIControlStateSelected];
    [controlsView.nextButton setImage:forwardImage forState:UIControlStateNormal];
    [controlsView.nextButton setImage:forwardImage forState:UIControlStateSelected];
}

%new
- (void)longPressPrev:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) [self didTapPrevButton];
}

%new
- (void)longPressNext:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) [self didTapNextButton];
}
%end

%hook YTColdConfig
- (NSInteger)iosPlayerClientSharedConfigTransportControlsSeekForwardTime {
    return ytmupSeekTime() == 0 ? %orig : ytmupSeekTime();
}
- (NSInteger)iosPlayerClientSharedConfigTransportControlsSeekBackwardTime {
    return ytmupSeekTime() == 0 ? %orig : ytmupSeekTime();
}
%end
