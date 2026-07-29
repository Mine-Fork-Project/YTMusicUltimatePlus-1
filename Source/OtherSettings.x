#import "Headers/YTPivotBarItemView.h"
#import "Headers/YTIPivotBarRenderer.h"
#import "Headers/YTMWatchViewController.h"
#import "Headers/YTPivotBarViewController.h"
#import "Headers/YTPlayabilityResolutionUserActionUIController.h"
#import "YTMUPKeys.h"

@interface YTPlayabilityResolutionUserActionUIControllerImpl : NSObject
- (void)confirmAlertDidPressConfirm;
@end

// ── Sticky headers ────────────────────────────────────────────────────────────
%hook YTLightweightCollectionController
- (void)setUseStickyHeaders:(BOOL)arg1 {
    IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyNoStickyHeaders) ? %orig(NO) : %orig;
}
%end

%hook YTMSearchTabViewController
- (BOOL)shouldUseStickyHeaders {
    return IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyNoStickyHeaders) ? NO : %orig;
}
%end

%hook YTMTabViewController
- (BOOL)shouldUseStickyHeaders {
    return IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyNoStickyHeaders) ? NO : %orig;
}
%end

%hook YTMChipCloudView
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyNoStickyHeaders) ? %orig([UIColor clearColor]) : %orig;
}
%end

// ── Tab bar labels ────────────────────────────────────────────────────────────
%hook YTPivotBarItemView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    %orig;
    if (IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyNoTabBarLabels)) {
        [self.navigationButton setTitle:@"" forState:UIControlStateNormal];
        [self.navigationButton setSizeWithPaddingAndInsets:NO];
    }
}
%end

// ── Remove tabs ───────────────────────────────────────────────────────────────
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray<YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];
    NSDictionary *identifiersToRemove = @{
        @"FEmusic_home":            @(IS_ENABLED(YTMUPKeyHideHomeTab)),
        @"FEmusic_immersive":       @(IS_ENABLED(YTMUPKeyHideSamplesTab)),
        @"FEmusic_explore":         @(IS_ENABLED(YTMUPKeyHideExploreTab)),
        @"FEmusic_library_landing": @(IS_ENABLED(YTMUPKeyHideLibraryTab)),
    };
    for (NSString *identifier in identifiersToRemove) {
        BOOL shouldRemove = [identifiersToRemove[identifier] boolValue];
        NSUInteger idx = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *r, NSUInteger i, BOOL *stop) {
            return shouldRemove && [[r.pivotBarItemRenderer pivotIdentifier] isEqualToString:identifier];
        }];
        if (idx != NSNotFound) [items removeObjectAtIndex:idx];
    }
    %orig;
}
%end

// ── Startup tab ───────────────────────────────────────────────────────────────
static BOOL isTabSelected = NO;

%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (!isTabSelected) {
        NSArray *pivotIdentifiers = @[
            @"FEmusic_home",
            @"FEmusic_immersive",
            @"FEmusic_explore",
            @"FEmusic_library_landing",
            @"BHdownloadsVC",
        ];
        NSInteger index = INTFORVAL(YTMUPKeyStartupPage);
        if (index >= 0 && index < (NSInteger)pivotIdentifiers.count) {
            [self selectItemWithPivotIdentifier:pivotIdentifiers[index]];
        }
        isTabSelected = YES;
    }
}
%end

// ── Skip content warning ──────────────────────────────────────────────────────
%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert {
    IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeySkipWarning) ? [self confirmAlertDidPressConfirm] : %orig;
}
%end

%hook YTPlayabilityResolutionUserActionUIControllerImpl
- (void)showConfirmAlert {
    IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeySkipWarning) ? [self confirmAlertDidPressConfirm] : %orig;
}
%end

// ── Miniplayer fixes ──────────────────────────────────────────────────────────
%hook YTMWatchViewController
- (void)playbackControllerStateDidChange {
    %orig;
    if ([self respondsToSelector:@selector(resetMiniplayerRestrictions)])
        [self resetMiniplayerRestrictions];
    [self setValue:@(NO) forKey:@"_pauseOnMinimize"];
}
%end

// ── Network fixes ─────────────────────────────────────────────────────────────
%hook YTColdConfig
- (BOOL)cxClientEnableIosLocalNetworkPermissionWifiFixes        { return YES; }
- (BOOL)cxClientEnableIosLocalNetworkPermissionUsingSockets     { return NO;  }
- (BOOL)cxClientEnableIosLocalNetworkPermissionReliabilityFixes { return YES; }
- (BOOL)cxClientEnableIosLocalNetworkPermissionPageDelayFix     { return YES; }
%end

%hook YTHotConfig
- (BOOL)isPromptForLocalNetworkPermissionsEnabled { return NO; }
%end

%hook YTMLightweightOfflineTrackingSectionController
%new
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}
%end