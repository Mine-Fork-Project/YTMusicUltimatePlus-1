#import "YTMUPBaseSettingsController.h"
#import "PremiumSettingsController.h"
#import "PlayerSettingsController.h"
#import "ThemeSettingsController.h"
#import "NavBarSettingsController.h"
#import "TabBarSettingsController.h"

/**
 * YTMUltimateSettingsController
 *
 * The top-level hub settings page. Extends YTMUPBaseSettingsController so it
 * gets the search bar and data-driven table for free, then adds:
 *   • Close / Apply navigation bar buttons
 *   • A live-computed version footer on the last section
 *   • The cache-clear activity-indicator behaviour
 */
@interface YTMUltimateSettingsController : YTMUPBaseSettingsController <UIDocumentPickerDelegate>
@end
