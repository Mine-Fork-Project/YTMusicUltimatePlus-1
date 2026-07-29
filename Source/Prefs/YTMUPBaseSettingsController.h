#import <UIKit/UIKit.h>
#import "YTMUPSettingsRegistry.h"
#import "YTMUPSettingsSection.h"
#import "YTMUPSettingsItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Shared base view controller for all YTMusicUltimatePlus settings pages.
 *
 * Set YTMUPPageId before the view loads (e.g., in -init of the subclass)
 * and the controller will automatically:
 *   • Load sections from YTMUPSettingsRegistry
 *   • Embed a UISearchController that filters rows live
 *   • Build and manage cells for every YTMUPSettingsItemType
 *   • Persist all changes to NSUserDefaults under the "YTMUltimate" dictionary
 */
@interface YTMUPBaseSettingsController : UIViewController
    <UITableViewDataSource,
     UITableViewDelegate,
     UISearchResultsUpdating,
     UITextFieldDelegate>

/// Must be set before viewDidLoad — typically in -init of the concrete subclass.
@property (nonatomic, copy) NSString *YTMUPPageId;

/// The underlying table view (accessible to subclasses for custom reload / decoration).
@property (nonatomic, strong, readonly) UITableView *YTMUPTableView;

/// The currently displayed sections (filtered when a search is active).
/// Subclasses may read this in overridden delegate/datasource methods.
@property (nonatomic, strong, readonly) NSArray<YTMUPSettingsSection *> *YTMUPDisplayedSections;

/// Save an arbitrary value for a key into the shared "YTMUltimate" NSUserDefaults dictionary.
- (void)YTMUPSaveValue:(id)value forKey:(NSString *)key;

/// Reload all sections from the registry and refresh the table view.
- (void)YTMUPReloadSections;

@end

NS_ASSUME_NONNULL_END
