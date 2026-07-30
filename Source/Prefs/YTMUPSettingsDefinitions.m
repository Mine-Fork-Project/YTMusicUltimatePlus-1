/**
 * YTMUPSettingsDefinitions.m
 * THE SINGLE FILE THAT DEFINES ALL SETTINGS FOR EVERY PAGE.
 *
 * NO macros are used here — all rows are constructed by calling the
 * YTMUPSettingsItem convenience methods directly. This avoids every
 * C-preprocessor comma / line-continuation pitfall.
 *
 * To add a setting: find the right register function, add a row.
 * To add a page:    write a new static void, call it from YTMUPRegisterAllSettings().
 */

#import <UIKit/UIKit.h>
#import "../Headers/Localization.h"
#import "../Headers/YTAssetLoader.h"
#import "../YTMUPKeys.h"
#import "YTMUPSettingsItem.h"
#import "YTMUPSettingsSection.h"
#import "YTMUPSettingsRegistry.h"

// Full imports so [DestClass class] compiles (forward decl is not enough).
#import "PremiumSettingsController.h"
#import "PlayerSettingsController.h"
#import "ThemeSettingsController.h"
#import "NavBarSettingsController.h"
#import "TabBarSettingsController.h"


// =============================================================================
#pragma mark - Data-management helpers (static functions, not blocks)
// =============================================================================

static void ytmupExportSettings(void) {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    for (NSString *k in YTMUPAllKeys()) {
        id val = [[NSUserDefaults standardUserDefaults] objectForKey:k];
        if (val) prefs[k] = val;
    }
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:prefs
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&err];
    if (!data || err) return;
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"YTMUPSettings.json"];
    [data writeToFile:path atomically:YES];
    NSArray *items = @[[NSURL fileURLWithPath:path]];
    UIActivityViewController *avc = [[UIActivityViewController alloc]
        initWithActivityItems:items applicationActivities:nil];
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [root presentViewController:avc animated:YES completion:nil];
}

static void ytmupRestoreDefaults(void) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    for (NSString *k in YTMUPAllKeys()) [ud removeObjectForKey:k];
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
#pragma mark - Main / hub page ("main")
// =============================================================================

static void YTMUPRegisterMainSettings(void) {

    // ── Section 0: Master switch ──────────────────────────────────────────────
    YTMUPSettingsItem *master = [YTMUPSettingsItem
        toggleWithTitle:LOC(@"ENABLED")
               subtitle:LOC(@"RESTART_FOOTER")
               sfSymbol:@"power"
                    key:YTMUPKeyEnabled];
    master.YTMUPTintColor = [UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:1.0];

    YTMUPSettingsSection *masterSection = [YTMUPSettingsSection
        sectionWithHeader:nil footer:nil items:@[master]];

    // ── Section 1: Page navigation ────────────────────────────────────────────
    YTMUPSettingsSection *navSection = [YTMUPSettingsSection
        sectionWithHeader:nil footer:nil items:@[
            [YTMUPSettingsItem navigationWithTitle:LOC(@"PREMIUM_SETTINGS") subtitle:@"" sfSymbol:@"flame"           destination:[PremiumSettingsController class]],
            [YTMUPSettingsItem navigationWithTitle:LOC(@"PLAYER_SETTINGS")  subtitle:@"" sfSymbol:@"play.rectangle"  destination:[PlayerSettingsController  class]],
            [YTMUPSettingsItem navigationWithTitle:LOC(@"THEME_SETTINGS")   subtitle:@"" sfSymbol:@"paintbrush"      destination:[ThemeSettingsController   class]],
            [YTMUPSettingsItem navigationWithTitle:LOC(@"NAVBAR_SETTINGS")  subtitle:@"" sfSymbol:@"sidebar.trailing" destination:[NavBarSettingsController  class]],
            [YTMUPSettingsItem navigationWithTitle:LOC(@"TABBAR_SETTINGS")  subtitle:@"" sfSymbol:@"dock.rectangle"  destination:[OtherSettingsController   class]],
        ]];

    // ── Section 2: Data management ────────────────────────────────────────────
    YTMUPSettingsItem *exportItem = [YTMUPSettingsItem
        actionWithTitle:LOC(@"EXPORT_SETTINGS")
               subtitle:LOC(@"EXPORT_SETTINGS_DESC")
               sfSymbol:@"square.and.arrow.up"
                 action:^{ ytmupExportSettings(); }];

    // Import: nil action — hub controller intercepts via __importSettings sentinel.
    YTMUPSettingsItem *importItem = [YTMUPSettingsItem
        actionWithTitle:LOC(@"IMPORT_SETTINGS")
               subtitle:LOC(@"IMPORT_SETTINGS_DESC")
               sfSymbol:@"square.and.arrow.down"
                 action:nil];
    importItem.YTMUPDefaultsKey = @"__importSettings";

    YTMUPSettingsItem *restoreItem = [YTMUPSettingsItem
        actionWithTitle:LOC(@"RESTORE_DEFAULTS")
               subtitle:LOC(@"RESTORE_DEFAULTS_DESC")
               sfSymbol:@"arrow.counterclockwise"
                 action:^{ ytmupRestoreDefaults(); }];
    restoreItem.YTMUPTintColor = [UIColor systemOrangeColor];

    // Clear cache: nil action — hub controller intercepts via __clearCache sentinel.
    YTMUPSettingsItem *clearCache = [YTMUPSettingsItem
        actionWithTitle:LOC(@"CLEAR_CACHE")
               subtitle:@""
               sfSymbol:@"trash"
                 action:nil];
    clearCache.YTMUPDefaultsKey = @"__clearCache";
    clearCache.YTMUPTintColor   = [UIColor systemRedColor];

    YTMUPSettingsSection *dataSection = [YTMUPSettingsSection
        sectionWithHeader:LOC(@"DATA_MANAGEMENT") footer:nil
                    items:@[exportItem, importItem, restoreItem, clearCache]];

    // ── Section 3: Links ──────────────────────────────────────────────────────
    UIColor *blue = [UIColor systemBlueColor];

    void (^applyBundleImage)(YTMUPSettingsItem *, NSString *) = ^(YTMUPSettingsItem *i, NSString *name) {
        NSString *imgPath = [NSBundle.ytmu_defaultBundle pathForResource:name ofType:@"png" inDirectory:@"icons"];
        UIImage *raw = [UIImage imageWithContentsOfFile:imgPath];
        i.YTMUPCustomImage = [raw imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        i.YTMUPTitleColor  = blue;
    };
    void (^openURL)(NSString *) = ^(NSString *url) {
        NSURL *u = [NSURL URLWithString:url];
        if ([[UIApplication sharedApplication] canOpenURL:u])
            [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:nil];
    };

    YTMUPSettingsItem *lGinsu = [YTMUPSettingsItem actionWithTitle:[NSString stringWithFormat:LOC(@"TWITTER"), @"Ginsu"] subtitle:LOC(@"TWITTER_DESC") sfSymbol:@"" action:^{ openURL(@"https://twitter.com/ginsudev"); }];
    YTMUPSettingsItem *lDay   = [YTMUPSettingsItem actionWithTitle:[NSString stringWithFormat:LOC(@"TWITTER"), @"Dayanch96"] subtitle:LOC(@"TWITTER_DESC") sfSymbol:@"" action:^{ openURL(@"https://twitter.com/dayanch96"); }];
    YTMUPSettingsItem *lDisc  = [YTMUPSettingsItem actionWithTitle:LOC(@"DISCORD") subtitle:LOC(@"DISCORD_DESC") sfSymbol:@"" action:^{ openURL(@"https://discord.gg/VN9ZSeMhEW"); }];
    YTMUPSettingsItem *lGit   = [YTMUPSettingsItem actionWithTitle:LOC(@"SOURCE_CODE") subtitle:LOC(@"SOURCE_CODE_DESC") sfSymbol:@"" action:^{ openURL(@"https://github.com/dayanch96/YTMusicUltimate"); }];

    applyBundleImage(lGinsu, @"ginsu-24@2x");
    applyBundleImage(lDay,   @"dayanch96-24@2x");
    applyBundleImage(lDisc,  @"discord-24@2x");
    applyBundleImage(lGit,   @"github-24@2x");

    YTMUPSettingsSection *linksSection = [YTMUPSettingsSection
        sectionWithHeader:LOC(@"LINKS") footer:nil   // version footer injected by hub VC
                    items:@[lGinsu, lDay, lDisc, lGit]];

    [[YTMUPSettingsRegistry sharedRegistry]
        registerSections:@[masterSection, navSection, dataSection, linksSection]
               forPageId:@"main"];
}


// =============================================================================
#pragma mark - Premium page ("premium")
// =============================================================================

static void YTMUPRegisterPremiumSettings(void) {
    YTMUPSettingsSection *s = [YTMUPSettingsSection
        sectionWithHeader:nil footer:nil items:@[
            [YTMUPSettingsItem toggleWithTitle:LOC(@"NO_ADS")             subtitle:LOC(@"NO_ADS_DESC")             sfSymbol:@"nosign"    key:YTMUPKeyNoAds],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"BACKGROUND_PLAYBACK") subtitle:LOC(@"BACKGROUND_PLAYBACK_DESC") sfSymbol:@"play.fill" key:YTMUPKeyBackgroundPlayback],
        ]];
    [[YTMUPSettingsRegistry sharedRegistry] registerSections:@[s] forPageId:@"premium"];
}


// =============================================================================
#pragma mark - Player page ("player")
// =============================================================================

static void YTMUPRegisterPlayerSettings(void) {

    // Section 0 — General
    YTMUPSettingsSection *general = [YTMUPSettingsSection
        sectionWithHeader:nil footer:nil items:@[
            [YTMUPSettingsItem toggleWithTitle:LOC(@"DOWNLOAD_AUDIO")       subtitle:LOC(@"DOWNLOAD_AUDIO_DESC")       sfSymbol:@"square.and.arrow.down"  key:YTMUPKeyDownloadAudio],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"DOWNLOAD_COVER")       subtitle:LOC(@"DOWNLOAD_COVER_DESC")       sfSymbol:@"photo"                  key:YTMUPKeyDownloadCover],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"PLAYBACK_RATE_BUTTON") subtitle:LOC(@"PLAYBACK_RATE_BUTTON_DESC") sfSymbol:@"gauge"                  key:YTMUPKeyPlaybackRateButton],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"SELECTABLE_LYRICS")    subtitle:LOC(@"SELECTABLE_LYRICS_DESC")    sfSymbol:@"text.quote"             key:YTMUPKeySelectableLyrics],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"VOLBAR")               subtitle:LOC(@"VOLBAR_DESC")               sfSymbol:@"slider.vertical.3"      key:YTMUPKeyVolBar],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"NO_AUTORADIO")         subtitle:LOC(@"NO_AUTORADIO_DESC")         sfSymbol:@"shuffle"                key:YTMUPKeyDisableAutoRadio],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"SKIP_CONTENT_WARNING") subtitle:LOC(@"SKIP_CONTENT_WARNING_DESC") sfSymbol:@"exclamationmark.shield" key:YTMUPKeySkipWarning],
        ]];

    // Section 1 — Audio/Video mode (0 = audio, 1 = video)
    NSArray *avItems = @[[UIImage systemImageNamed:@"music.note"], [UIImage systemImageNamed:@"film"]];
    YTMUPSettingsSection *avSection = [YTMUPSettingsSection
        sectionWithHeader:nil footer:nil items:@[
            [YTMUPSettingsItem segmentWithTitle:LOC(@"AV_DEFAULT_MODE") sfSymbol:@"music.note.and.tv" key:YTMUPKeyAudioVideoMode items:avItems],
        ]];

    // Section 2 — SponsorBlock
    NSArray *sbBehaviourItems = @[LOC(@"SB_SKIP"), LOC(@"SB_ASK")];
    NSArray *sbDurationOpts   = @[@1, @3, @5, @10, @15, @20, @30];
    YTMUPSettingsSection *sbSection = [YTMUPSettingsSection
        sectionWithHeader:@"SponsorBlock" footer:nil items:@[
            [YTMUPSettingsItem toggleWithTitle:LOC(@"SKIP_NONMUSIC_PARTS") subtitle:LOC(@"SKIP_NONMUSIC_PARTS_DESC") sfSymbol:@"scissors"         key:YTMUPKeySponsorBlock],
            [YTMUPSettingsItem segmentWithTitle:LOC(@"SB_BEHAVIOR")        sfSymbol:@"waveform.path.ecg"             key:YTMUPKeySBSkipMode      items:sbBehaviourItems],
            [YTMUPSettingsItem sliderWithTitle:LOC(@"SB_NOTIF_DURATION")   subtitle:@""                              sfSymbol:@"timer"           key:YTMUPKeySBDuration  options:sbDurationOpts],
        ]];

    // Section 3 — Seek buttons
    NSArray *seekItems = @[LOC(@"DEFAULT"), @"10", @"20", @"30", @"60"];
    YTMUPSettingsSection *seekSection = [YTMUPSettingsSection
        sectionWithHeader:nil footer:LOC(@"SEEK_TIME_FOOTER") items:@[
            [YTMUPSettingsItem toggleWithTitle:LOC(@"SEEK_BUTTONS") subtitle:@"" sfSymbol:@"goforward" key:YTMUPKeySeekButtons],
            [YTMUPSettingsItem segmentWithTitle:LOC(@"DEFAULT")     sfSymbol:@""                       key:YTMUPKeySeekTime  items:seekItems],
        ]];

    [[YTMUPSettingsRegistry sharedRegistry]
        registerSections:@[general, avSection, sbSection, seekSection]
               forPageId:@"player"];
}


// =============================================================================
#pragma mark - Theme page ("theme")
// =============================================================================

static void YTMUPRegisterThemeSettings(void) {
    YTMUPSettingsSection *s = [YTMUPSettingsSection
        sectionWithHeader:nil footer:nil items:@[
            [YTMUPSettingsItem toggleWithTitle:LOC(@"OLED_DARK_THEME")    subtitle:LOC(@"OLED_DARK_THEME_DESC")    sfSymbol:@"moon.fill"              key:YTMUPKeyOledTheme],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"OLED_DARK_KEYBOARD") subtitle:LOC(@"OLED_DARK_KEYBOARD_DESC") sfSymbol:@"keyboard"               key:YTMUPKeyOledKeyboard],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"LOW_CONTRAST")       subtitle:LOC(@"LOW_CONTRAST_DESC")       sfSymbol:@"circle.lefthalf.filled" key:YTMUPKeyLowContrast],
        ]];
    [[YTMUPSettingsRegistry sharedRegistry] registerSections:@[s] forPageId:@"theme"];
}


// =============================================================================
#pragma mark - NavBar page ("navbar")
// =============================================================================

static void YTMUPRegisterNavBarSettings(void) {
    YTMUPSettingsSection *s = [YTMUPSettingsSection
        sectionWithHeader:nil footer:nil items:@[
            [YTMUPSettingsItem toggleWithTitle:LOC(@"DONT_STICK_HEADERS")  subtitle:LOC(@"DONT_STICK_HEADERS_DESC")  sfSymbol:@"pin.slash"                         key:YTMUPKeyNoStickyHeaders],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"HIDE_HISTORY_BUTTON") subtitle:LOC(@"HIDE_HISTORY_BUTTON_DESC") sfSymbol:@"clock.arrow.circlepath"            key:YTMUPKeyHideHistoryButton],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"HIDE_CAST_BUTTON")    subtitle:LOC(@"HIDE_CAST_BUTTON_DESC")    sfSymbol:@"airplayaudio"                      key:YTMUPKeyHideCastButton],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"HIDE_FILTER_BUTTON")  subtitle:LOC(@"HIDE_FILTER_BUTTON_DESC")  sfSymbol:@"line.3.horizontal.decrease.circle" key:YTMUPKeyHideFilterButton],
        ]];
    [[YTMUPSettingsRegistry sharedRegistry] registerSections:@[s] forPageId:@"navbar"];
}


// =============================================================================
#pragma mark - TabBar page ("tabbar")
// =============================================================================

static void YTMUPRegisterTabBarSettings(void) {

    // Section 0 — Startup tab
    // itemsProvider block is stored and called lazily when the cell builds,
    // so YTAssetLoader is ready by then.
    NSArray *(^startupProvider)(void) = ^NSArray *(void) {
        YTAssetLoader *appAL = [[NSClassFromString(@"YTAssetLoader") alloc] initWithBundle:[NSBundle mainBundle]];
        YTAssetLoader *dlAL  = [[NSClassFromString(@"YTAssetLoader") alloc] initWithBundle:NSBundle.ytmu_defaultBundle];
        UIImage *home     = [appAL imageNamed:@"yt_outline_home_24pt"];
        UIImage *samples  = [appAL imageNamed:@"youtube_outline/samples_24pt"];
        UIImage *explore  = [appAL imageNamed:@"yt_outline_compass_24pt"];
        UIImage *library  = [appAL imageNamed:@"yt_outline_library_music_24pt"];
        UIImage *downloads = [dlAL imageNamed:@"icons/downloads"];
        return @[home, samples, explore, library, downloads];
    };
    YTMUPSettingsItem *startupSeg = [YTMUPSettingsItem
        segmentWithTitle:LOC(@"STARTUP_TAB") sfSymbol:nil key:YTMUPKeyStartupPage itemsProvider:startupProvider];

    YTMUPSettingsSection *startupSection = [YTMUPSettingsSection
        sectionWithHeader:LOC(@"STARTUP_TAB") footer:nil items:@[startupSeg]];

    // Section 1 — Tab visibility
    YTMUPSettingsSection *tabsSection = [YTMUPSettingsSection
        sectionWithHeader:LOC(@"TAB_SETTINGS") footer:nil items:@[
            [YTMUPSettingsItem toggleWithTitle:LOC(@"REMOVE_TABBAR_LABELS") subtitle:@"" sfSymbol:@"textformat.size"   key:YTMUPKeyNoTabBarLabels],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"HIDE_HOME")            subtitle:@"" sfSymbol:@"house"             key:YTMUPKeyHideHomeTab],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"HIDE_SAMPLES")         subtitle:@"" sfSymbol:@"waveform"          key:YTMUPKeyHideSamplesTab],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"HIDE_EXPLORE")         subtitle:@"" sfSymbol:@"safari"            key:YTMUPKeyHideExploreTab],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"HIDE_LIBRARY")         subtitle:@"" sfSymbol:@"books.vertical"    key:YTMUPKeyHideLibraryTab],
            [YTMUPSettingsItem toggleWithTitle:LOC(@"HIDE_DOWNLOADS")       subtitle:@"" sfSymbol:@"arrow.down.circle" key:YTMUPKeyHideDownloadsTab],
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
