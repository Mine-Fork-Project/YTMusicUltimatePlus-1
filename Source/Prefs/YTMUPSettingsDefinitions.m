/**
 * YTMUPSettingsDefinitions.m
 * THE SINGLE FILE THAT DEFINES ALL SETTINGS FOR EVERY PAGE.
 *
 * To add a new setting:
 *   1. Find (or create) the appropriate static void register function below.
 *   2. Add a YTMUPSettingsItem to the desired section using the convenience
 *      constructors or the helper macros at the top.
 *   3. That's it — the base controller and search bar handle everything else.
 *
 * To add a new page:
 *   1. Write a new static void YTMUPRegisterXxxSettings(void) function.
 *   2. Call it inside YTMUPRegisterAllSettings().
 *   3. Create a thin YTMUPBaseSettingsController subclass that sets YTMUPPageId.
 */

#import <UIKit/UIKit.h>
#import "../Headers/Localization.h"
#import "../Headers/YTAssetLoader.h"
#import "../YTMUPKeys.h"
#import "YTMUPSettingsItem.h"
#import "YTMUPSettingsSection.h"
#import "YTMUPSettingsRegistry.h"

// Full imports (not @class) so [DestClass class] compiles.
#import "PremiumSettingsController.h"
#import "PlayerSettingsController.h"
#import "ThemeSettingsController.h"
#import "NavBarSettingsController.h"
#import "TabBarSettingsController.h"

// ─────────────────────────────────────────────────────────────────────────────
// Convenience macros — single-line to avoid CRLF / line-continuation issues.
// ─────────────────────────────────────────────────────────────────────────────

/// Toggle row.
#define YTMUP_TOGGLE(titleKey, subtitleKey, sfSym, pKey) [YTMUPSettingsItem toggleWithTitle:LOC(titleKey) subtitle:LOC(subtitleKey) sfSymbol:sfSym key:pKey]

/// Slider row (discrete NSNumber options via variadic).
#define YTMUP_SLIDER(titleKey, subtitleKey, sfSym, pKey, ...) [YTMUPSettingsItem sliderWithTitle:LOC(titleKey) subtitle:LOC(subtitleKey) sfSymbol:sfSym key:pKey options:@[__VA_ARGS__]]

/// Segment row — static items.
#define YTMUP_SEGMENT(titleKey, sfSym, pKey, ...) [YTMUPSettingsItem segmentWithTitle:LOC(titleKey) sfSymbol:sfSym key:pKey items:@[__VA_ARGS__]]

/// Segment row — lazy items provider block.
#define YTMUP_SEGMENT_LAZY(titleKey, sfSym, pKey, block) [YTMUPSettingsItem segmentWithTitle:LOC(titleKey) sfSymbol:sfSym key:pKey itemsProvider:block]

/// TextField row.
#define YTMUP_TEXTFIELD(titleKey, sfSym, pKey, kbType, placeholder) [YTMUPSettingsItem textFieldWithTitle:LOC(titleKey) sfSymbol:sfSym key:pKey keyboardType:kbType placeholder:placeholder]

/// Navigation row.
#define YTMUP_NAV(titleKey, subtitleKey, sfSym, destClass) [YTMUPSettingsItem navigationWithTitle:LOC(titleKey) subtitle:LOC(subtitleKey) sfSymbol:sfSym destination:[destClass class]]

/// Action row.
#define YTMUP_ACTION(titleKey, subtitleKey, sfSym, block) [YTMUPSettingsItem actionWithTitle:LOC(titleKey) subtitle:LOC(subtitleKey) sfSymbol:sfSym action:block]


// ─────────────────────────────────────────────────────────────────────────────
// Helpers for Data Management actions (broken out of blocks to avoid
// comma-in-array-literal macro-argument parsing issues).
// ─────────────────────────────────────────────────────────────────────────────

static void ytmupExportSettings(void) {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    for (NSString *key in YTMUPAllKeys()) {
        id val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (val) prefs[key] = val;
    }
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:prefs
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&err];
    if (!data || err) return;
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"YTMUPSettings.json"];
    [data writeToFile:tmpPath atomically:YES];
    NSURL *fileURL = [NSURL fileURLWithPath:tmpPath];
    NSArray *items = @[fileURL];
    UIActivityViewController *avc = [[UIActivityViewController alloc]
        initWithActivityItems:items applicationActivities:nil];
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [root presentViewController:avc animated:YES completion:nil];
}

static void ytmupRestoreDefaults(void) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    for (NSString *key in YTMUPAllKeys()) {
        [ud removeObjectForKey:key];
    }
    [ud synchronize];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:LOC(@"RESTORE_DEFAULTS")
                         message:LOC(@"RESTORE_DONE")
                  preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"OK")
                                             style:UIAlertActionStyleDefault
                                           handler:nil]];
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [root presentViewController:alert animated:YES completion:nil];
}


// =============================================================================
#pragma mark - Main / hub settings page ("main")
// =============================================================================

static void YTMUPRegisterMainSettings(void) {

    // ── Section 0 — Master switch ─────────────────────────────────────────────
    YTMUPSettingsItem *masterToggle = YTMUP_TOGGLE(@"ENABLED", @"RESTART_FOOTER", @"power", YTMUPKeyEnabled);
    masterToggle.YTMUPTintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:1.0];

    YTMUPSettingsSection *masterSection = [YTMUPSettingsSection
        sectionWithHeader:nil footer:nil items:@[masterToggle]];

    // ── Section 1 — Settings pages ────────────────────────────────────────────
    YTMUPSettingsSection *navSection = [YTMUPSettingsSection
        sectionWithHeader:nil
                   footer:nil
                    items:@[
        YTMUP_NAV(@"PREMIUM_SETTINGS", @"", @"flame",            PremiumSettingsController),
        YTMUP_NAV(@"PLAYER_SETTINGS",  @"", @"play.rectangle",   PlayerSettingsController),
        YTMUP_NAV(@"THEME_SETTINGS",   @"", @"paintbrush",       ThemeSettingsController),
        YTMUP_NAV(@"NAVBAR_SETTINGS",  @"", @"sidebar.trailing", NavBarSettingsController),
        YTMUP_NAV(@"TABBAR_SETTINGS",  @"", @"dock.rectangle",   OtherSettingsController),
    ]];

    // ── Section 2 — Data Management ───────────────────────────────────────────
    // Export
    YTMUPSettingsItem *exportItem = YTMUP_ACTION(@"EXPORT_SETTINGS", @"EXPORT_SETTINGS_DESC", @"square.and.arrow.up", ^{ ytmupExportSettings(); });

    // Import — actual picker is shown by YTMUltimateSettingsController (needs delegate).
    // The action block is nil; the hub controller intercepts via the __importSettings sentinel key.
    YTMUPSettingsItem *importItem = YTMUP_ACTION(@"IMPORT_SETTINGS", @"IMPORT_SETTINGS_DESC", @"square.and.arrow.down", nil);
    importItem.YTMUPDefaultsKey = @"__importSettings";

    // Restore defaults
    YTMUPSettingsItem *restoreItem = YTMUP_ACTION(@"RESTORE_DEFAULTS", @"RESTORE_DEFAULTS_DESC", @"arrow.counterclockwise", ^{ ytmupRestoreDefaults(); });
    restoreItem.YTMUPTintColor = [UIColor systemOrangeColor];

    // Clear cache — sentinel key; hub controller intercepts taps.
    YTMUPSettingsItem *clearCache = YTMUP_ACTION(@"CLEAR_CACHE", @"", @"trash", nil);
    clearCache.YTMUPDefaultsKey = @"__clearCache";
    clearCache.YTMUPTintColor   = [UIColor systemRedColor];

    YTMUPSettingsSection *dataSection = [YTMUPSettingsSection
        sectionWithHeader:LOC(@"DATA_MANAGEMENT")
                   footer:nil
                    items:@[exportItem, importItem, restoreItem, clearCache]];

    // ── Section 3 — Links ─────────────────────────────────────────────────────
    UIColor *blue = [UIColor systemBlueColor];

    void (^loadBundleImage)(YTMUPSettingsItem *, NSString *) = ^(YTMUPSettingsItem *i, NSString *name) {
        UIImage *raw = [UIImage imageWithContentsOfFile:
            [NSBundle.ytmu_defaultBundle pathForResource:name ofType:@"png" inDirectory:@"icons"]];
        i.YTMUPCustomImage = [raw imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        i.YTMUPTitleColor  = blue;
    };

    void (^openURL)(NSString *) = ^(NSString *urlStr) {
        NSURL *url = [NSURL URLWithString:urlStr];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    };

    YTMUPSettingsItem *linkGinsu     = YTMUP_ACTION(@"TWITTER",     @"TWITTER_DESC",     @"", ^{ openURL(@"https://twitter.com/ginsudev"); });
    YTMUPSettingsItem *linkDayanch96 = YTMUP_ACTION(@"TWITTER",     @"TWITTER_DESC",     @"", ^{ openURL(@"https://twitter.com/dayanch96"); });
    YTMUPSettingsItem *linkDiscord   = YTMUP_ACTION(@"DISCORD",     @"DISCORD_DESC",     @"", ^{ openURL(@"https://discord.gg/VN9ZSeMhEW"); });
    YTMUPSettingsItem *linkGithub    = YTMUP_ACTION(@"SOURCE_CODE", @"SOURCE_CODE_DESC", @"", ^{ openURL(@"https://github.com/dayanch96/YTMusicUltimate"); });

    linkGinsu.YTMUPTitle     = [NSString stringWithFormat:LOC(@"TWITTER"), @"Ginsu"];
    linkDayanch96.YTMUPTitle = [NSString stringWithFormat:LOC(@"TWITTER"), @"Dayanch96"];

    loadBundleImage(linkGinsu,     @"ginsu-24@2x");
    loadBundleImage(linkDayanch96, @"dayanch96-24@2x");
    loadBundleImage(linkDiscord,   @"discord-24@2x");
    loadBundleImage(linkGithub,    @"github-24@2x");

    YTMUPSettingsSection *linksSection = [YTMUPSettingsSection
        sectionWithHeader:LOC(@"LINKS")
                   footer:nil  // version footer injected by hub VC
                    items:@[linkGinsu, linkDayanch96, linkDiscord, linkGithub]];

    [[YTMUPSettingsRegistry sharedRegistry]
        registerSections:@[masterSection, navSection, dataSection, linksSection]
               forPageId:@"main"];
}


// =============================================================================
#pragma mark - Premium settings page ("premium")
// =============================================================================

static void YTMUPRegisterPremiumSettings(void) {

    YTMUPSettingsSection *section = [YTMUPSettingsSection
        sectionWithHeader:nil
                   footer:nil
                    items:@[
        YTMUP_TOGGLE(@"NO_ADS",             @"NO_ADS_DESC",            @"nosign",    YTMUPKeyNoAds),
        YTMUP_TOGGLE(@"BACKGROUND_PLAYBACK", @"BACKGROUND_PLAYBACK_DESC", @"play.fill", YTMUPKeyBackgroundPlayback),
    ]];

    [[YTMUPSettingsRegistry sharedRegistry]
        registerSections:@[section]
               forPageId:@"premium"];
}


// =============================================================================
#pragma mark - Player settings page ("player")
// =============================================================================

static void YTMUPRegisterPlayerSettings(void) {

    // ── Section 0 — General player options ───────────────────────────────────
    YTMUPSettingsSection *general = [YTMUPSettingsSection
        sectionWithHeader:nil
                   footer:nil
                    items:@[
        YTMUP_TOGGLE(@"DOWNLOAD_AUDIO",       @"DOWNLOAD_AUDIO_DESC",       @"square.and.arrow.down",  YTMUPKeyDownloadAudio),
        YTMUP_TOGGLE(@"DOWNLOAD_COVER",       @"DOWNLOAD_COVER_DESC",       @"photo",                  YTMUPKeyDownloadCover),
        YTMUP_TOGGLE(@"PLAYBACK_RATE_BUTTON", @"PLAYBACK_RATE_BUTTON_DESC", @"gauge",                  YTMUPKeyPlaybackRateButton),
        YTMUP_TOGGLE(@"SELECTABLE_LYRICS",    @"SELECTABLE_LYRICS_DESC",    @"text.quote",             YTMUPKeySelectableLyrics),
        YTMUP_TOGGLE(@"VOLBAR",               @"VOLBAR_DESC",               @"slider.vertical.3",      YTMUPKeyVolBar),
        YTMUP_TOGGLE(@"NO_AUTORADIO",         @"NO_AUTORADIO_DESC",         @"shuffle",                YTMUPKeyDisableAutoRadio),
        YTMUP_TOGGLE(@"SKIP_CONTENT_WARNING", @"SKIP_CONTENT_WARNING_DESC", @"exclamationmark.shield", YTMUPKeySkipWarning),
    ]];

    // ── Section 1 — Audio / Video default mode ────────────────────────────────
    // Segment: index 0 = audio, 1 = video. Saves selectedSegmentIndex as NSInteger.
    YTMUPSettingsSection *avSection = [YTMUPSettingsSection
        sectionWithHeader:nil
                   footer:nil
                    items:@[
        YTMUP_SEGMENT(@"AV_DEFAULT_MODE", @"music.note.and.tv", YTMUPKeyAudioVideoMode,
                      [UIImage systemImageNamed:@"music.note"],
                      [UIImage systemImageNamed:@"film"]),
    ]];

    // ── Section 2 — SponsorBlock ──────────────────────────────────────────────
    YTMUPSettingsSection *sbSection = [YTMUPSettingsSection
        sectionWithHeader:@"SponsorBlock"
                   footer:nil
                    items:@[
        YTMUP_TOGGLE(@"SKIP_NONMUSIC_PARTS", @"SKIP_NONMUSIC_PARTS_DESC", @"scissors", YTMUPKeySponsorBlock),
        YTMUP_SEGMENT(@"SB_BEHAVIOR", @"waveform.path.ecg", YTMUPKeySBSkipMode, LOC(@"SB_SKIP"), LOC(@"SB_ASK")),
        YTMUP_SLIDER(@"SB_NOTIF_DURATION", @"", @"timer", YTMUPKeySBDuration, @1, @3, @5, @10, @15, @20, @30),
    ]];

    // ── Section 3 — Seek buttons ──────────────────────────────────────────────
    // Index 0 = default, 1 = 10 s, 2 = 20 s, 3 = 30 s, 4 = 60 s.
    YTMUPSettingsSection *seekSection = [YTMUPSettingsSection
        sectionWithHeader:nil
                   footer:LOC(@"SEEK_TIME_FOOTER")
                    items:@[
        YTMUP_TOGGLE(@"SEEK_BUTTONS", @"", @"goforward", YTMUPKeySeekButtons),
        YTMUP_SEGMENT(@"DEFAULT", @"", YTMUPKeySeekTime, LOC(@"DEFAULT"), @"10", @"20", @"30", @"60"),
    ]];

    [[YTMUPSettingsRegistry sharedRegistry]
        registerSections:@[general, avSection, sbSection, seekSection]
               forPageId:@"player"];
}


// =============================================================================
#pragma mark - Theme settings page ("theme")
// =============================================================================

static void YTMUPRegisterThemeSettings(void) {

    YTMUPSettingsSection *section = [YTMUPSettingsSection
        sectionWithHeader:nil
                   footer:nil
                    items:@[
        YTMUP_TOGGLE(@"OLED_DARK_THEME",    @"OLED_DARK_THEME_DESC",    @"moon.fill",              YTMUPKeyOledTheme),
        YTMUP_TOGGLE(@"OLED_DARK_KEYBOARD", @"OLED_DARK_KEYBOARD_DESC", @"keyboard",               YTMUPKeyOledKeyboard),
        YTMUP_TOGGLE(@"LOW_CONTRAST",       @"LOW_CONTRAST_DESC",       @"circle.lefthalf.filled", YTMUPKeyLowContrast),
    ]];

    [[YTMUPSettingsRegistry sharedRegistry]
        registerSections:@[section]
               forPageId:@"theme"];
}


// =============================================================================
#pragma mark - NavBar settings page ("navbar")
// =============================================================================

static void YTMUPRegisterNavBarSettings(void) {

    YTMUPSettingsSection *section = [YTMUPSettingsSection
        sectionWithHeader:nil
                   footer:nil
                    items:@[
        YTMUP_TOGGLE(@"DONT_STICK_HEADERS",  @"DONT_STICK_HEADERS_DESC",  @"pin.slash",                         YTMUPKeyNoStickyHeaders),
        YTMUP_TOGGLE(@"HIDE_HISTORY_BUTTON", @"HIDE_HISTORY_BUTTON_DESC", @"clock.arrow.circlepath",            YTMUPKeyHideHistoryButton),
        YTMUP_TOGGLE(@"HIDE_CAST_BUTTON",    @"HIDE_CAST_BUTTON_DESC",    @"airplayaudio",                      YTMUPKeyHideCastButton),
        YTMUP_TOGGLE(@"HIDE_FILTER_BUTTON",  @"HIDE_FILTER_BUTTON_DESC",  @"line.3.horizontal.decrease.circle", YTMUPKeyHideFilterButton),
    ]];

    [[YTMUPSettingsRegistry sharedRegistry]
        registerSections:@[section]
               forPageId:@"navbar"];
}


// =============================================================================
#pragma mark - TabBar settings page ("tabbar")
// =============================================================================

static void YTMUPRegisterTabBarSettings(void) {

    // ── Section 0 — Startup tab ───────────────────────────────────────────────
    // Items loaded lazily so YTAssetLoader is ready when the cell builds.
    YTMUPSettingsItem *startupSeg = YTMUP_SEGMENT_LAZY(@"STARTUP_TAB", nil, YTMUPKeyStartupPage, ^NSArray * {
        YTAssetLoader *appAL = [[NSClassFromString(@"YTAssetLoader") alloc] initWithBundle:[NSBundle mainBundle]];
        YTAssetLoader *dlAL  = [[NSClassFromString(@"YTAssetLoader") alloc] initWithBundle:NSBundle.ytmu_defaultBundle];
        return @[
            [appAL imageNamed:@"yt_outline_home_24pt"],
            [appAL imageNamed:@"youtube_outline/samples_24pt"],
            [appAL imageNamed:@"yt_outline_compass_24pt"],
            [appAL imageNamed:@"yt_outline_library_music_24pt"],
            [dlAL  imageNamed:@"icons/downloads"],
        ];
    });

    YTMUPSettingsSection *startupSection = [YTMUPSettingsSection
        sectionWithHeader:LOC(@"STARTUP_TAB")
                   footer:nil
                    items:@[startupSeg]];

    // ── Section 1 — Tab visibility toggles ───────────────────────────────────
    YTMUPSettingsSection *tabsSection = [YTMUPSettingsSection
        sectionWithHeader:LOC(@"TAB_SETTINGS")
                   footer:nil
                    items:@[
        YTMUP_TOGGLE(@"REMOVE_TABBAR_LABELS", @"", @"textformat.size",   YTMUPKeyNoTabBarLabels),
        YTMUP_TOGGLE(@"HIDE_HOME",            @"", @"house",             YTMUPKeyHideHomeTab),
        YTMUP_TOGGLE(@"HIDE_SAMPLES",         @"", @"waveform",          YTMUPKeyHideSamplesTab),
        YTMUP_TOGGLE(@"HIDE_EXPLORE",         @"", @"safari",            YTMUPKeyHideExploreTab),
        YTMUP_TOGGLE(@"HIDE_LIBRARY",         @"", @"books.vertical",    YTMUPKeyHideLibraryTab),
        YTMUP_TOGGLE(@"HIDE_DOWNLOADS",       @"", @"arrow.down.circle", YTMUPKeyHideDownloadsTab),
    ]];

    [[YTMUPSettingsRegistry sharedRegistry]
        registerSections:@[startupSection, tabsSection]
               forPageId:@"tabbar"];
}


// =============================================================================
#pragma mark - Entry point — call from %ctor in Settings.x
// =============================================================================

void YTMUPRegisterAllSettings(void) {
    YTMUPRegisterMainSettings();
    YTMUPRegisterPremiumSettings();
    YTMUPRegisterPlayerSettings();
    YTMUPRegisterThemeSettings();
    YTMUPRegisterNavBarSettings();
    YTMUPRegisterTabBarSettings();
}
