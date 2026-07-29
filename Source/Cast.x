#import <Foundation/Foundation.h>
#import "../YTMUPKeys.h"

%hook MDXFeatureFlags
- (BOOL)isCastCloudDiscoveryEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setIsCastCloudDiscoveryEnabled:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)isCastToNativeEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setIsCastToNativeEnabled:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)isCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setIsCastEnabled:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
%end

%hook MDXPlaybackRouteButtonController
- (BOOL)isPersistentCastIconEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end

%hook YTColdConfig
- (BOOL)isCastToNativeEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setIsCastToNativeEnabled:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)isPersistentCastIconEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setIsPersistentCastIconEnabled:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)musicEnableSuggestedCastDevices { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setMusicEnableSuggestedCastDevices:(BOOL)suggest { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)musicClientConfigEnableCastButtonOnPlayerHeader { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setMusicClientConfigEnableCastButtonOnPlayerHeader:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)musicClientConfigEnableAudioOnlyCastingForNonMusicAudio { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setMusicClientConfigEnableAudioOnlyCastingForNonMusicAudio:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
%end

%hook YTMCastSessionController
- (id)premiumUpgradeAction { return IS_ENABLED(YTMUPKeyEnabled) ? nil : %orig; }
- (void)showAudioCastUpsellDialog { if (!IS_ENABLED(YTMUPKeyEnabled)) return %orig; }
- (BOOL)isFreeTierAudioCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? NO : %orig; }
- (void)setIsFreeTierAudioCastEnabled:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(NO) : %orig; }
- (void)openMusicPremiumLandingPage { if (!IS_ENABLED(YTMUPKeyEnabled)) return %orig; }
%end

%hook YTMAudioCastUpsellDialogController
- (void)showAudioCastUpsellDialogWithUpsellParentResponder:(id)arg {
    if (!IS_ENABLED(YTMUPKeyEnabled)) return %orig;
}
%end

%hook YTMCastSessionControllerImpl
- (id)premiumUpgradeAction { return IS_ENABLED(YTMUPKeyEnabled) ? nil : %orig; }
- (void)showAudioCastUpsellDialog { if (!IS_ENABLED(YTMUPKeyEnabled)) return %orig; }
- (void)openMusicPremiumLandingPage { if (!IS_ENABLED(YTMUPKeyEnabled)) return %orig; }
%end

%hook YTMMusicAppMetadata
- (BOOL)isAudioCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setIsAudioCastEnabled:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)isMATScreenedCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (void)setIsMATScreenedCastEnabled:(BOOL)enabled { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
%end

%hook YTMMusicAppMetadataImpl
- (BOOL)isAudioCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (BOOL)isMATScreenedCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end

%hook YTMSettings
- (BOOL)isAudioCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (BOOL)isGcmEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end

%hook YTMSettingsImpl
- (BOOL)isAudioCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (BOOL)isGcmEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end

%hook YTGlobalConfig
- (BOOL)isAudioCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (BOOL)isGcmEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end

%hook YTMQueueConfig
- (BOOL)isMobileAudioTierScreenedCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end

%hook YTMQueueConfigImpl
- (BOOL)isMobileAudioTierScreenedCastEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end

%hook GHCCDeviceCapabilities
- (BOOL)audioSupported { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (BOOL)hasAudioSupported { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (BOOL)hasVideoSupported { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
- (BOOL)videoSupported { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end

%hook YTHotConfig
- (BOOL)isCastCloudDiscoveryEnabled { return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig; }
%end
