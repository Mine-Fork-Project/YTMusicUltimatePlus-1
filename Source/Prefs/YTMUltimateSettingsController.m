#import "YTMUltimateSettingsController.h"
#import "../YTMUPKeys.h"

@implementation YTMUltimateSettingsController <UIDocumentPickerDelegate>

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Lifecycle
// ─────────────────────────────────────────────────────────────────────────────

- (instancetype)init {
    self = [super init];
    if (self) {
        self.YTMUPPageId = @"main";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // ── Close button (left) ───────────────────────────────────────────────────
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc]
        initWithImage:[UIImage systemImageNamed:@"xmark"]
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(closeButtonTapped:)];

    // ── Apply / restart button (right) ────────────────────────────────────────
    UIBarButtonItem *applyBtn = [[UIBarButtonItem alloc]
        initWithImage:[UIImage systemImageNamed:@"checkmark"]
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(applyButtonTapped:)];

    self.navigationItem.leftBarButtonItem  = closeBtn;
    self.navigationItem.rightBarButtonItem = applyBtn;

    // ── Ensure master-switch default is set on first launch ──────────────────
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:YTMUPKeyEnabled]) {
        [ud setBool:YES forKey:YTMUPKeyEnabled];
    }
}

- (NSString *)title {
    return @"YTMusicUltimate";
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Footer override (version string on the last / links section)
// ─────────────────────────────────────────────────────────────────────────────

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section {

    // Inject the version info into the last visible section (links).
    if (section == (NSInteger)self.YTMUPDisplayedSections.count - 1) {
        NSDictionary *info   = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = info[@"CFBundleShortVersionString"] ?: @"?";
        NSString *tweakVer   = [NSString stringWithUTF8String:OS_STRINGIFY(TWEAK_VERSION)];
        return [NSString stringWithFormat:@"\nYouTubeMusic: v%@\nYTMusicUltimate: v%@",
                appVersion, tweakVer];
    }

    return [super tableView:tableView titleForFooterInSection:section];
}

- (void)tableView:(UITableView *)tableView
willDisplayFooterView:(UIView *)view
       forSection:(NSInteger)section {

    // Centre the version footer.
    if (section == (NSInteger)self.YTMUPDisplayedSections.count - 1) {
        UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
        footer.textLabel.textAlignment = NSTextAlignmentCenter;
    }
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Cache clear override (activity indicator on the cell)
// ─────────────────────────────────────────────────────────────────────────────

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    YTMUPSettingsItem *item = self.YTMUPDisplayedSections[indexPath.section].YTMUPItems[indexPath.row];

    // Intercept the cache-clear action to show an activity indicator on the cell.
    if (item.YTMUPType == YTMUPItemTypeAction &&
        [item.YTMUPDefaultsKey isEqualToString:@"__clearCache"]) {

        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        spinner.color = [UIColor labelColor];
        [spinner startAnimating];
        cell.accessoryView = spinner;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.YTMUPTableView reloadRowsAtIndexPaths:@[indexPath]
                                           withRowAnimation:UITableViewRowAnimationNone];
            });
        });
        return;
    }

    // Intercept Import Settings — need to set self as the picker delegate.
    if (item.YTMUPType == YTMUPItemTypeAction &&
        [item.YTMUPTitle isEqualToString:LOC(@"IMPORT_SETTINGS")]) {

        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
            initWithDocumentTypes:@[@"public.json", @"public.text"]
                           inMode:UIDocumentPickerModeImport];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        return;
    }

    // All other rows (navigation, link actions) handled by the base class.
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Navigation bar actions
// ─────────────────────────────────────────────────────────────────────────────

- (void)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyButtonTapped:(id)sender {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:LOC(@"WARNING")
                         message:LOC(@"APPLY_MESSAGE")
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL")
                                             style:UIAlertActionStyleDefault
                                           handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"YES")
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:1.0];
            exit(0);
        });
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - UIDocumentPickerDelegate (Import Settings)
// ─────────────────────────────────────────────────────────────────────────────

- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (!url) return;

    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return;

    NSDictionary *prefs = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![prefs isKindOfClass:[NSDictionary class]]) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:LOC(@"IMPORT_SETTINGS")
                             message:LOC(@"IMPORT_FAILED")
                      preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:LOC(@"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSSet *validKeys = [NSSet setWithArray:YTMUPAllKeys()];
    for (NSString *key in prefs) {
        if ([validKeys containsObject:key]) {
            [ud setObject:prefs[key] forKey:key];
        }
    }
    [ud synchronize];
    [self YTMUPReloadSections];
}

@end
