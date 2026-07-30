#import <Foundation/Foundation.h>
#import "Headers/YTIShowFullscreenInterstitialCommand.h"

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { 
    id temp = nil;
    %orig(temp);
}
%end

%hook YTAccountScopedAdsInnerTubeContextDecorator
- (void)decorateContext:(id)context { 
    id temp = nil;
    %orig(temp);
}
%end

%hook YTAdShieldUtils
+ (id)spamSignalsDictionary { return @{}; }
+ (id)spamSignalsDictionaryWithoutIDFA { return @{}; }
%end

%hook YTDataUtils
+ (id)spamSignalsDictionary { return @{ @"ms": @"" }; }
+ (id)spamSignalsDictionaryWithoutIDFA { return @{}; }
%end

%hook YTIPlayerResponse
- (BOOL)isMonetized { return NO; }
- (id)paidContentOverlayElementRendererOptions { return nil; }
- (BOOL)isCuepointAdsEnabled { return NO; }
- (id)adIntroRenderer { return nil; }
- (BOOL)isDAIEnabledPlayback { return YES; }
%end

%hook YTIClientMdxGlobalConfig
%new(B@:)
- (BOOL)enableSkippableAd { return YES; }
%end

%hook YTLocalPlaybackController
- (id)createAdsPlaybackCoordinator { return nil; }
%end

%hook MDXSession
- (void)adPlaying:(id)ad {}
%end

%hook MDXSessionImpl
- (void)adPlaying:(id)ad {}
%end

%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)arg1 { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCaps:(id)arg1 { return NO; }
%end

%hook YTPromoThrottleControllerImpl
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)arg1 { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCaps:(id)arg1 { return NO; }
%end

/*
%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial {
    if (self.hasModalClientThrottlingRules)
        self.modalClientThrottlingRules.oncePerTimeWindow = YES;
    return %orig;
}
%end
*/

// Survey
%hook YTSurveyController
- (void)showSurveyWithRenderer:(id)arg1 surveyParentResponder:(id)arg2 {}
%end

%hook YTPromosheetController
- (void)presentPromosheetWithEvent:(id)arg {}
%end