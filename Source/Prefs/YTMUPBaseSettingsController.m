#import "YTMUPBaseSettingsController.h"
#import "../YTMUPKeys.h"
#import <objc/runtime.h>

// Associated-object keys (use address of static char as stable pointer keys)
static const char kYTMUPItemAssocKey;
static const char kYTMUPValueLabelAssocKey;

// Default blue tint used for interactive controls
static UIColor *YTMUPDefaultTintColor(void) {
    return [UIColor colorWithRed:30.0/255.0 green:150.0/255.0 blue:245.0/255.0 alpha:1.0];
}

// ─────────────────────────────────────────────────────────────────────────────
// Private interface
// ─────────────────────────────────────────────────────────────────────────────
@interface YTMUPBaseSettingsController ()
@property (nonatomic, strong) UITableView        *YTMUPTableView;
@property (nonatomic, strong) UISearchController *YTMUPSearchController;
/// Full data, as registered.
@property (nonatomic, strong) NSArray<YTMUPSettingsSection *> *YTMUPAllSections;
/// Filtered view shown in the table; equals YTMUPAllSections when no search text.
/// Redeclared readwrite here; public header exposes it as readonly.
@property (nonatomic, strong) NSArray<YTMUPSettingsSection *> *YTMUPDisplayedSections;
@end

// ─────────────────────────────────────────────────────────────────────────────
@implementation YTMUPBaseSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    // ── Load sections from registry ──────────────────────────────────────────
    [self YTMUPReloadSections];

    // ── Search controller ────────────────────────────────────────────────────
    self.YTMUPSearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.YTMUPSearchController.searchResultsUpdater = self;
    self.YTMUPSearchController.obscuresBackgroundDuringPresentation = NO;
    self.YTMUPSearchController.searchBar.placeholder = @"Search";
    self.navigationItem.searchController = self.YTMUPSearchController;
    self.navigationItem.hidesSearchBarWhenScrolling = YES;
    self.definesPresentationContext = YES;

    // ── Table view ───────────────────────────────────────────────────────────
    self.YTMUPTableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                        style:UITableViewStyleInsetGrouped];
    self.YTMUPTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.YTMUPTableView.dataSource      = self;
    self.YTMUPTableView.delegate        = self;
    self.YTMUPTableView.rowHeight       = UITableViewAutomaticDimension;
    self.YTMUPTableView.estimatedRowHeight = 60;
    [self.view addSubview:self.YTMUPTableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.YTMUPTableView.topAnchor    constraintEqualToAnchor:self.view.topAnchor],
        [self.YTMUPTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.YTMUPTableView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.YTMUPTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Public helpers
// ─────────────────────────────────────────────────────────────────────────────

- (void)YTMUPReloadSections {
    self.YTMUPAllSections       = [[YTMUPSettingsRegistry sharedRegistry] sectionsForPageId:self.YTMUPPageId];
    self.YTMUPDisplayedSections = self.YTMUPAllSections;
    [self.YTMUPTableView reloadData];
}

- (void)YTMUPSaveValue:(id)value forKey:(NSString *)key {
    if (!key) return;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - UISearchResultsUpdating
// ─────────────────────────────────────────────────────────────────────────────

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *query = searchController.searchBar.text;

    if (!query.length) {
        self.YTMUPDisplayedSections = self.YTMUPAllSections;
        [self.YTMUPTableView reloadData];
        return;
    }

    NSMutableArray *filtered = [NSMutableArray array];
    for (YTMUPSettingsSection *section in self.YTMUPAllSections) {
        NSMutableArray<YTMUPSettingsItem *> *matchingItems = [NSMutableArray array];
        for (YTMUPSettingsItem *item in section.YTMUPItems) {
            BOOL titleMatch    = [item.YTMUPTitle    localizedCaseInsensitiveContainsString:query];
            BOOL subtitleMatch = [item.YTMUPSubtitle localizedCaseInsensitiveContainsString:query];
            if (titleMatch || subtitleMatch) {
                [matchingItems addObject:item];
            }
        }
        if (matchingItems.count > 0) {
            YTMUPSettingsSection *fs = [YTMUPSettingsSection sectionWithHeader:section.YTMUPHeader
                                                                        footer:nil
                                                                         items:matchingItems];
            [filtered addObject:fs];
        }
    }
    self.YTMUPDisplayedSections = filtered;
    [self.YTMUPTableView reloadData];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - UITableViewDataSource
// ─────────────────────────────────────────────────────────────────────────────

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)self.YTMUPDisplayedSections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.YTMUPDisplayedSections[section].YTMUPHeader;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.YTMUPDisplayedSections[section].YTMUPFooter;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.YTMUPDisplayedSections[section].YTMUPItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    YTMUPSettingsItem *item = self.YTMUPDisplayedSections[indexPath.section].YTMUPItems[indexPath.row];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    switch (item.YTMUPType) {

        // ── Toggle ────────────────────────────────────────────────────────────
        case YTMUPItemTypeToggle: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                           reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self YTMUPApplyCommonCell:cell item:item];

            // Prefer ABCSwitch (YouTube Music styled); fall back to stock UISwitch
            UISwitch *sw = nil;
            Class abcClass = NSClassFromString(@"ABCSwitch");
            if (abcClass) sw = [[abcClass alloc] init];
            else          sw = [[UISwitch alloc] init];

            sw.onTintColor = item.YTMUPTintColor ?: YTMUPDefaultTintColor();
            sw.on          = IS_ENABLED(item.YTMUPDefaultsKey);
            objc_setAssociatedObject(sw, &kYTMUPItemAssocKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [sw addTarget:self action:@selector(YTMUPToggleChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            return cell;
        }

        // ── Slider (discrete, NSArray-backed) ─────────────────────────────────
        case YTMUPItemTypeSlider: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            NSArray<NSNumber *> *opts = item.YTMUPSliderOptions;
            NSUInteger optCount = opts.count;

            // ── Title label (top-left) ───────────────────────────────────────
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.text                    = item.YTMUPTitle;
            titleLabel.font                    = [UIFont systemFontOfSize:16];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

            // ── Value label (top-right) ──────────────────────────────────────
            UILabel *valueLabel = [[UILabel alloc] init];
            // Find the index whose value is closest to the stored one
            float stored = FLOAT_FOR_KEY(item.YTMUPDefaultsKey);
            NSInteger currentIndex = [self YTMUPIndexClosestToValue:stored inOptions:opts];
            valueLabel.text       = [NSString stringWithFormat:@"%@", optCount ? opts[currentIndex] : @""];
            valueLabel.font       = [UIFont systemFontOfSize:14];
            valueLabel.textColor  = [UIColor secondaryLabelColor];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.translatesAutoresizingMaskIntoConstraints = NO;

            // ── Slider ───────────────────────────────────────────────────────
            UISlider *slider = [[UISlider alloc] init];
            slider.minimumValue = 0;
            slider.maximumValue = optCount > 0 ? (float)(optCount - 1) : 0;
            slider.value        = (float)currentIndex;
            slider.tintColor    = item.YTMUPTintColor ?: YTMUPDefaultTintColor();
            slider.translatesAutoresizingMaskIntoConstraints = NO;

            // Attach item + value label to slider via associated objects
            objc_setAssociatedObject(slider, &kYTMUPItemAssocKey,       item,       OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(slider, &kYTMUPValueLabelAssocKey, valueLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

            [slider addTarget:self action:@selector(YTMUPSliderDragged:)  forControlEvents:UIControlEventValueChanged];
            [slider addTarget:self action:@selector(YTMUPSliderReleased:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];

            [cell.contentView addSubview:titleLabel];
            [cell.contentView addSubview:valueLabel];
            [cell.contentView addSubview:slider];

            const CGFloat pad = 16;
            [NSLayoutConstraint activateConstraints:@[
                // Title — top left
                [titleLabel.topAnchor     constraintEqualToAnchor:cell.contentView.topAnchor    constant:10],
                [titleLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:pad],
                [titleLabel.trailingAnchor constraintEqualToAnchor:valueLabel.leadingAnchor      constant:-8],

                // Value — top right
                [valueLabel.topAnchor      constraintEqualToAnchor:cell.contentView.topAnchor     constant:10],
                [valueLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-pad],
                [valueLabel.widthAnchor    constraintGreaterThanOrEqualToConstant:44],

                // Slider — spans full width below the labels
                [slider.topAnchor      constraintEqualToAnchor:titleLabel.bottomAnchor      constant:6],
                [slider.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor constant:pad],
                [slider.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-pad],
                [slider.bottomAnchor   constraintEqualToAnchor:cell.contentView.bottomAnchor  constant:-10],
            ]];

            return cell;
        }

        // ── Segment ───────────────────────────────────────────────────────────
        case YTMUPItemTypeSegment: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            if (item.YTMUPTitle.length) {
                cell.textLabel.text = item.YTMUPTitle;
                if (item.YTMUPTitleColor) cell.textLabel.textColor = item.YTMUPTitleColor;
            }

            // Resolve items — provider block wins over static array
            NSArray *segItems = item.YTMUPSegmentItemsProvider
                ? item.YTMUPSegmentItemsProvider()
                : item.YTMUPSegmentItems;

            UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:segItems];
            seg.selectedSegmentIndex = INTFORVAL(item.YTMUPDefaultsKey);
            objc_setAssociatedObject(seg, &kYTMUPItemAssocKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [seg addTarget:self action:@selector(YTMUPSegmentChanged:) forControlEvents:UIControlEventValueChanged];

            // If there is no title, center the segment spanning the full width
            if (!item.YTMUPTitle.length) {
                seg.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:seg];
                [NSLayoutConstraint activateConstraints:@[
                    [seg.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                    [seg.leadingAnchor  constraintEqualToAnchor:cell.contentView.leadingAnchor  constant:12],
                    [seg.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-12],
                ]];
            } else {
                cell.accessoryView = seg;
            }
            return cell;
        }

        // ── TextField ─────────────────────────────────────────────────────────
        case YTMUPItemTypeTextField: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self YTMUPApplyCommonCell:cell item:item];

            UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
            tf.text          = [ud stringForKey:item.YTMUPDefaultsKey] ?: @"";
            tf.placeholder   = item.YTMUPTextFieldPlaceholder;
            tf.keyboardType  = item.YTMUPKeyboardType;
            tf.textAlignment = NSTextAlignmentRight;
            tf.font          = [UIFont systemFontOfSize:14];
            tf.textColor     = [UIColor secondaryLabelColor];
            tf.delegate      = self;
            tf.returnKeyType = UIReturnKeyDone;
            // Toolbar with Done button for dismissing keyboard
            tf.inputAccessoryView = [self YTMUPKeyboardToolbar:tf];
            objc_setAssociatedObject(tf, &kYTMUPItemAssocKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            cell.accessoryView = tf;
            return cell;
        }

        // ── Navigation ────────────────────────────────────────────────────────
        case YTMUPItemTypeNavigation: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                           reuseIdentifier:nil];
            [self YTMUPApplyCommonCell:cell item:item];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }

        // ── Action ────────────────────────────────────────────────────────────
        case YTMUPItemTypeAction: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                           reuseIdentifier:nil];
            [self YTMUPApplyCommonCell:cell item:item];

            // Special case: cache-clear row shows the current cache size on the right.
            if ([item.YTMUPDefaultsKey isEqualToString:@"__clearCache"]) {
                UILabel *sizeLabel = [[UILabel alloc] init];
                sizeLabel.text      = [self YTMUPCurrentCacheSize];
                sizeLabel.font      = [UIFont systemFontOfSize:16];
                sizeLabel.textColor = [UIColor secondaryLabelColor];
                sizeLabel.textAlignment = NSTextAlignmentRight;
                [sizeLabel sizeToFit];
                cell.accessoryView = sizeLabel;
            }
            return cell;
        }
    }

    return [[UITableViewCell alloc] init];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - UITableViewDelegate
// ─────────────────────────────────────────────────────────────────────────────

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    YTMUPSettingsItem *item = self.YTMUPDisplayedSections[indexPath.section].YTMUPItems[indexPath.row];
    return (item.YTMUPType == YTMUPItemTypeNavigation ||
            item.YTMUPType == YTMUPItemTypeAction);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    YTMUPSettingsItem *item = self.YTMUPDisplayedSections[indexPath.section].YTMUPItems[indexPath.row];

    if (item.YTMUPType == YTMUPItemTypeNavigation && item.YTMUPDestinationClass) {
        UIViewController *vc = [[item.YTMUPDestinationClass alloc] init];
        [self.navigationController pushViewController:vc animated:YES];

    } else if (item.YTMUPType == YTMUPItemTypeAction && item.YTMUPActionBlock) {
        item.YTMUPActionBlock();
    }
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Control callbacks
// ─────────────────────────────────────────────────────────────────────────────

- (void)YTMUPToggleChanged:(UISwitch *)sender {
    YTMUPSettingsItem *item = objc_getAssociatedObject(sender, &kYTMUPItemAssocKey);
    [self YTMUPSaveValue:@(sender.isOn) forKey:item.YTMUPDefaultsKey];
}

/// Called continuously as the user drags — snaps to grid and updates value label.
- (void)YTMUPSliderDragged:(UISlider *)sender {
    YTMUPSettingsItem *item       = objc_getAssociatedObject(sender, &kYTMUPItemAssocKey);
    UILabel           *valueLabel = objc_getAssociatedObject(sender, &kYTMUPValueLabelAssocKey);
    NSArray<NSNumber *> *opts     = item.YTMUPSliderOptions;

    NSInteger index = (NSInteger)roundf(sender.value);
    index = MAX(0, MIN(index, (NSInteger)opts.count - 1));

    // Snap the thumb to the nearest discrete position
    sender.value = (float)index;
    valueLabel.text = [NSString stringWithFormat:@"%@", opts[index]];
}

/// Called on touch-up — saves the snapped value (actual NSNumber) to NSUserDefaults.
- (void)YTMUPSliderReleased:(UISlider *)sender {
    YTMUPSettingsItem *item   = objc_getAssociatedObject(sender, &kYTMUPItemAssocKey);
    NSArray<NSNumber *> *opts = item.YTMUPSliderOptions;

    NSInteger index = (NSInteger)roundf(sender.value);
    index = MAX(0, MIN(index, (NSInteger)opts.count - 1));
    sender.value = (float)index;

    [self YTMUPSaveValue:opts[index] forKey:item.YTMUPDefaultsKey];
}

/// Saves selectedSegmentIndex as NSInteger.
- (void)YTMUPSegmentChanged:(UISegmentedControl *)sender {
    YTMUPSettingsItem *item = objc_getAssociatedObject(sender, &kYTMUPItemAssocKey);
    [self YTMUPSaveValue:@(sender.selectedSegmentIndex) forKey:item.YTMUPDefaultsKey];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - UITextFieldDelegate
// ─────────────────────────────────────────────────────────────────────────────

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    YTMUPSettingsItem *item = objc_getAssociatedObject(textField, &kYTMUPItemAssocKey);
    if (item) {
        [self YTMUPSaveValue:textField.text forKey:item.YTMUPDefaultsKey];
    }
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Private helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Populates the common cell properties (title, subtitle, image) shared by several types.
- (void)YTMUPApplyCommonCell:(UITableViewCell *)cell item:(YTMUPSettingsItem *)item {
    cell.textLabel.text = item.YTMUPTitle;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    if (item.YTMUPTitleColor) cell.textLabel.textColor = item.YTMUPTitleColor;

    if (item.YTMUPSubtitle.length) {
        cell.detailTextLabel.text          = item.YTMUPSubtitle;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor     = [UIColor secondaryLabelColor];
    }

    if (item.YTMUPCustomImage) {
        cell.imageView.image = item.YTMUPCustomImage;
    } else if (item.YTMUPSfSymbol.length) {
        UIImage *img = [UIImage systemImageNamed:item.YTMUPSfSymbol];
        if (item.YTMUPTintColor) {
            img = [img imageWithTintColor:item.YTMUPTintColor
                    renderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        cell.imageView.image = img;
    }
}

/// Returns the index in opts whose float value is closest to storedValue.
- (NSInteger)YTMUPIndexClosestToValue:(float)storedValue
                             inOptions:(NSArray<NSNumber *> *)opts {
    if (!opts.count) return 0;
    NSInteger bestIndex = 0;
    float     bestDiff  = FLT_MAX;
    for (NSInteger i = 0; i < (NSInteger)opts.count; i++) {
        float diff = fabsf(opts[i].floatValue - storedValue);
        if (diff < bestDiff) { bestDiff = diff; bestIndex = i; }
    }
    return bestIndex;
}

/// Computes and returns the formatted size of the app's caches directory.
- (NSString *)YTMUPCurrentCacheSize {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSArray  *files     = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];
    unsigned long long folderSize = 0;
    for (NSString *fileName in files) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        folderSize += [attrs fileSize];
    }
    NSByteCountFormatter *fmt = [[NSByteCountFormatter alloc] init];
    fmt.countStyle = NSByteCountFormatterCountStyleFile;
    return [fmt stringFromByteCount:(long long)folderSize];
}

/// Builds a UIToolbar with a Done button for dismissing the keyboard over a text field.
- (UIView *)YTMUPKeyboardToolbar:(UITextField *)textField {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0,
                          CGRectGetWidth(self.view.frame), 44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self action:@selector(YTMUPDismissKeyboard)];
    toolbar.items = @[flex, done];
    return toolbar;
}

- (void)YTMUPDismissKeyboard {
    [self.view endEditing:YES];
}

@end
