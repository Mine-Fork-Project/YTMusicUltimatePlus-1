#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../YTMUPKeys.h"

// ── AV switching / audio-only mode ───────────────────────────────────────────

// Remove popup reminder
%hook YTMPlayerHeaderViewController
- (BOOL)shouldDisplayHintForAudioVideoSwitch {
    return IS_ENABLED(YTMUPKeyEnabled) ? NO : %orig;
}
%end

%hook YTIPlayerResponse
- (id)ytm_audioOnlyUpsell {
    return IS_ENABLED(YTMUPKeyEnabled) ? nil : %orig;
}
- (BOOL)ytm_isAudioOnlyPlayable {
    return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig;
}
- (BOOL)isAudioOnlyAvailabilityBlocked {
    return IS_ENABLED(YTMUPKeyEnabled) ? NO : %orig;
}
- (void)setIsAudioOnlyAvailabilityBlocked:(BOOL)blocked {
    IS_ENABLED(YTMUPKeyEnabled) ? %orig(NO) : %orig;
}
- (void)setYtm_isAudioOnlyPlayable:(BOOL)playable {
    IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig;
}
%end

%hook YTMAudioVideoModeController
- (BOOL)isAudioOnlyBlocked {
    return IS_ENABLED(YTMUPKeyEnabled) ? NO : %orig;
}
- (void)setIsAudioOnlyBlocked:(BOOL)blocked {
    IS_ENABLED(YTMUPKeyEnabled) ? %orig(NO) : %orig;
}
- (void)setSwitchAvailability:(NSInteger)arg1 {
    IS_ENABLED(YTMUPKeyEnabled) ? %orig(1) : %orig;
}
%end

%hook YTMQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return IS_ENABLED(YTMUPKeyEnabled) ? YES : %orig;
}
- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig;
}
// Audio-only / video default mode (0 = audio, 1 = video)
- (BOOL)noVideoModeEnabledForMusic {
    return INTFORVAL(YTMUPKeyAudioVideoMode) == 0 ? YES : %orig;
}
- (BOOL)noVideoModeEnabledForPodcasts {
    return INTFORVAL(YTMUPKeyAudioVideoMode) == 0 ? YES : %orig;
}
%end

%hook YTMAudioVideoModeControllerInternalImpl
- (void)setSwitchAvailability:(NSInteger)arg1 { IS_ENABLED(YTMUPKeyEnabled) ? %orig(1) : %orig; }
- (NSInteger)switchAvailability { return IS_ENABLED(YTMUPKeyEnabled) ? 1 : %orig; }
- (BOOL)isAudioOnlyBlocked { return IS_ENABLED(YTMUPKeyEnabled) ? NO : %orig; }
%end

%hook YTVideoQualitySwitchRedesignedController
- (void)setAllowAudioOnlyManualQualitySelection:(BOOL)arg1 { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)allowAudioOnlyManualQualitySelection { return IS_ENABLED(YTMUPKeyEnabled) ?: %orig; }
%end

%hook YTVideoQualitySwitchOriginalController
- (void)setAllowAudioOnlyManualQualitySelection:(BOOL)arg1 { IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig; }
- (BOOL)allowAudioOnlyManualQualitySelection { return IS_ENABLED(YTMUPKeyEnabled) ?: %orig; }
%end

%hook YTDefaultQueueConfig
- (BOOL)isAudioVideoModeSupportedForNonPodcasts {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
- (BOOL)isAudioVideoModeSupported {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig;
}
%end

%hook YTMSettings
- (BOOL)allowAudioOnlyManualQualitySelection {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
%end

%hook YTMSettingsImpl
- (BOOL)allowAudioOnlyManualQualitySelection {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
%end

%hook YTIAudioOnlyPlayabilityRenderer
- (BOOL)audioOnlyPlayability {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
- (int)audioOnlyAvailability {
    return IS_ENABLED(YTMUPKeyEnabled) ? 1 : %orig;
}
- (void)setAudioOnlyPlayability:(BOOL)playability {
    IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig;
}
- (id)infoRenderer {
    return IS_ENABLED(YTMUPKeyEnabled) ? nil : %orig;
}
- (BOOL)hasInfoRenderer {
    return IS_ENABLED(YTMUPKeyEnabled) ? NO : %orig;
}
%end

%hook YTIAudioOnlyPlayabilityRenderer_AudioOnlyPlayabilityInfoSupportedRenderers
- (id)upsellDialogRenderer {
    return IS_ENABLED(YTMUPKeyEnabled) ? nil : %orig;
}
- (void)setUpsellDialogRenderer:(id)renderer {
    if (!IS_ENABLED(YTMUPKeyEnabled)) return %orig;
}
%end

%hook YTQueueItem
- (BOOL)supportsAudioVideoSwitching {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
- (void)setSupportsAudioVideoSwitching:(BOOL)arg1 {
    IS_ENABLED(YTMUPKeyEnabled) ? %orig(YES) : %orig;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)isAudioOnlyButtonVisible {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
%end

%hook YTMMusicAppMetadataImpl
- (BOOL)isAudioOnlyButtonVisible {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
%end

%hook YTMQueueConfigImpl
- (BOOL)isAudioVideoModeSupportedForNonPodcasts {
    return IS_ENABLED(YTMUPKeyEnabled) ?: %orig;
}
- (BOOL)noVideoModeEnabledForMusic {
    return INTFORVAL(YTMUPKeyAudioVideoMode) == 0 ? YES : %orig;
}
- (BOOL)noVideoModeEnabledForPodcasts {
    return INTFORVAL(YTMUPKeyAudioVideoMode) == 0 ? YES : %orig;
}
%end

%hook YTQueueController
- (BOOL)noVideoModeEnabled:(id)arg1 {
    return INTFORVAL(YTMUPKeyAudioVideoMode) == 0 ? YES : %orig;
}
- (BOOL)isAudioVideoModeSupportedForVideo:(id)video { return IS_ENABLED(YTMUPKeyEnabled) ?: %orig; }
%end

%hook YTColdConfig
- (BOOL)iosEnableHighQualityAudioAppSettingsPremiumUpsell {
    return IS_ENABLED(YTMUPKeyEnabled) ? NO : %orig;
}
%end
