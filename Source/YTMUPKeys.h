/**
 * YTMUPKeys.h
 * ─────────────────────────────────────────────────────────────────────────────
 * Single source of truth for every NSUserDefaults key used by YTMusicUltimatePlus,
 * plus the read-access macros.
 *
 * ALL keys are stored directly in [NSUserDefaults standardUserDefaults] (no
 * wrapping dictionary) and carry the "YTMUP" prefix so they are namespaced and
 * will never collide with system or app keys.
 *
 * ── Read macros ──────────────────────────────────────────────────────────────
 *   IS_ENABLED(k)      → BOOL   (boolForKey:)
 *   INTFORVAL(k)       → NSInteger (integerForKey:)
 *   FLOAT_FOR_KEY(k)   → float  (floatForKey:)
 *   STRING_FOR_KEY(k)  → NSString * nullable (stringForKey:)
 *
 * Usage example:
 *   if (IS_ENABLED(YTMUPKeyNoAds)) { … }
 *   NSInteger mode = INTFORVAL(YTMUPKeyAudioVideoMode);
 */

#pragma once
#import <Foundation/Foundation.h>

// ─────────────────────────────────────────────────────────────────────────────
// Read-access macros
// ─────────────────────────────────────────────────────────────────────────────

/// Reads a BOOL value directly from NSUserDefaults.
#define IS_ENABLED(k)       [[NSUserDefaults standardUserDefaults] boolForKey:(k)]

/// Reads an NSInteger value directly from NSUserDefaults.
#define INTFORVAL(k)        [[NSUserDefaults standardUserDefaults] integerForKey:(k)]

/// Reads a float value directly from NSUserDefaults.
#define FLOAT_FOR_KEY(k)    [[NSUserDefaults standardUserDefaults] floatForKey:(k)]

/// Reads an NSString value directly from NSUserDefaults (may be nil).
#define STRING_FOR_KEY(k)   [[NSUserDefaults standardUserDefaults] stringForKey:(k)]


// ─────────────────────────────────────────────────────────────────────────────
// Key constants — General
// ─────────────────────────────────────────────────────────────────────────────

/// Master on/off switch for the entire tweak.
#define YTMUPKeyEnabled                 @"YTMUPEnabled"


// ─────────────────────────────────────────────────────────────────────────────
// Key constants — Premium / Ad-block
// ─────────────────────────────────────────────────────────────────────────────

/// Block all ads.
#define YTMUPKeyNoAds                   @"YTMUPNoAds"

/// Enable background audio playback.
#define YTMUPKeyBackgroundPlayback      @"YTMUPBackgroundPlayback"


// ─────────────────────────────────────────────────────────────────────────────
// Key constants — Player
// ─────────────────────────────────────────────────────────────────────────────

/// Enable audio download button.
#define YTMUPKeyDownloadAudio           @"YTMUPDownloadAudio"

/// Enable cover-image download button.
#define YTMUPKeyDownloadCover           @"YTMUPDownloadCover"

/// Show the playback-rate button in the player.
#define YTMUPKeyPlaybackRateButton      @"YTMUPPlaybackRateButton"

/// Make lyrics text selectable.
#define YTMUPKeySelectableLyrics        @"YTMUPSelectableLyrics"

/// Show the volume slider bar.
#define YTMUPKeyVolBar                  @"YTMUPVolBar"

/// Disable auto-radio / autoplay.
#define YTMUPKeyDisableAutoRadio        @"YTMUPDisableAutoRadio"

/// Skip explicit-content warning screens automatically.
#define YTMUPKeySkipWarning             @"YTMUPSkipWarning"

/// Default audio/video mode. 0 = audio, 1 = video (NSInteger).
#define YTMUPKeyAudioVideoMode          @"YTMUPAudioVideoMode"


// ─────────────────────────────────────────────────────────────────────────────
// Key constants — SponsorBlock
// ─────────────────────────────────────────────────────────────────────────────

/// Enable SponsorBlock segment skipping.
#define YTMUPKeySponsorBlock            @"YTMUPSponsorBlock"

/// Skip behaviour. 0 = auto-skip, 1 = ask (NSInteger).
#define YTMUPKeySBSkipMode              @"YTMUPSBSkipMode"

/// SponsorBlock notification banner duration in seconds (float).
#define YTMUPKeySBDuration              @"YTMUPSBDuration"


// ─────────────────────────────────────────────────────────────────────────────
// Key constants — Seek Buttons
// ─────────────────────────────────────────────────────────────────────────────

/// Show seek forward/backward buttons in the player.
#define YTMUPKeySeekButtons             @"YTMUPSeekButtons"

/// Seek interval index. 0 = default, 1 = 10 s, 2 = 20 s, 3 = 30 s, 4 = 60 s (NSInteger).
#define YTMUPKeySeekTime                @"YTMUPSeekTime"


// ─────────────────────────────────────────────────────────────────────────────
// Key constants — Theme
// ─────────────────────────────────────────────────────────────────────────────

/// Force true-black OLED dark theme.
#define YTMUPKeyOledTheme               @"YTMUPOledTheme"

/// Force true-black OLED keyboard.
#define YTMUPKeyOledKeyboard            @"YTMUPOledKeyboard"

/// Enable low-contrast mode.
#define YTMUPKeyLowContrast             @"YTMUPLowContrast"


// ─────────────────────────────────────────────────────────────────────────────
// Key constants — NavBar
// ─────────────────────────────────────────────────────────────────────────────

/// Disable sticky section headers.
#define YTMUPKeyNoStickyHeaders         @"YTMUPNoStickyHeaders"

/// Hide the history button from the navigation bar.
#define YTMUPKeyHideHistoryButton       @"YTMUPHideHistoryButton"

/// Hide the cast/AirPlay button from the navigation bar.
#define YTMUPKeyHideCastButton          @"YTMUPHideCastButton"

/// Hide the filter chips button from the navigation bar.
#define YTMUPKeyHideFilterButton        @"YTMUPHideFilterButton"


// ─────────────────────────────────────────────────────────────────────────────
// Key constants — Tab Bar
// ─────────────────────────────────────────────────────────────────────────────

/// Starting tab index on launch (NSInteger).
#define YTMUPKeyStartupPage             @"YTMUPStartupPage"

/// Remove tab bar labels (icon-only mode).
#define YTMUPKeyNoTabBarLabels          @"YTMUPNoTabBarLabels"

/// Hide the Home tab.
#define YTMUPKeyHideHomeTab             @"YTMUPHideHomeTab"

/// Hide the Samples tab.
#define YTMUPKeyHideSamplesTab          @"YTMUPHideSamplesTab"

/// Hide the Explore tab.
#define YTMUPKeyHideExploreTab          @"YTMUPHideExploreTab"

/// Hide the Library tab.
#define YTMUPKeyHideLibraryTab          @"YTMUPHideLibraryTab"

/// Hide the Downloads tab.
#define YTMUPKeyHideDownloadsTab        @"YTMUPHideDownloadsTab"


// ─────────────────────────────────────────────────────────────────────────────
// Convenience: ordered array of every YTMUP key — used for export/import/reset.
// ─────────────────────────────────────────────────────────────────────────────

static inline NSArray<NSString *> *YTMUPAllKeys(void) {
    return @[
        YTMUPKeyEnabled,
        YTMUPKeyNoAds,
        YTMUPKeyBackgroundPlayback,
        YTMUPKeyDownloadAudio,
        YTMUPKeyDownloadCover,
        YTMUPKeyPlaybackRateButton,
        YTMUPKeySelectableLyrics,
        YTMUPKeyVolBar,
        YTMUPKeyDisableAutoRadio,
        YTMUPKeySkipWarning,
        YTMUPKeyAudioVideoMode,
        YTMUPKeySponsorBlock,
        YTMUPKeySBSkipMode,
        YTMUPKeySBDuration,
        YTMUPKeySeekButtons,
        YTMUPKeySeekTime,
        YTMUPKeyOledTheme,
        YTMUPKeyOledKeyboard,
        YTMUPKeyLowContrast,
        YTMUPKeyNoStickyHeaders,
        YTMUPKeyHideHistoryButton,
        YTMUPKeyHideCastButton,
        YTMUPKeyHideFilterButton,
        YTMUPKeyStartupPage,
        YTMUPKeyNoTabBarLabels,
        YTMUPKeyHideHomeTab,
        YTMUPKeyHideSamplesTab,
        YTMUPKeyHideExploreTab,
        YTMUPKeyHideLibraryTab,
        YTMUPKeyHideDownloadsTab,
    ];
}
