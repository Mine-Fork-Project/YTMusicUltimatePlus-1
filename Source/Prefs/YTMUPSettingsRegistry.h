#import <Foundation/Foundation.h>
#import "YTMUPSettingsSection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Singleton that maps a page identifier string to an ordered array of
 * YTMUPSettingsSection objects.
 *
 * Call -registerSections:forPageId: from static void registration functions
 * (defined in YTMUPSettingsDefinitions.m) before any settings page is presented.
 */
@interface YTMUPSettingsRegistry : NSObject

+ (instancetype)sharedRegistry;

/**
 * Register the complete section list for a page.
 * Calling this again with the same pageId replaces the previous registration.
 */
- (void)registerSections:(NSArray<YTMUPSettingsSection *> *)sections
               forPageId:(NSString *)pageId;

/// Returns the registered sections for pageId, or an empty array if none.
- (NSArray<YTMUPSettingsSection *> *)sectionsForPageId:(NSString *)pageId;

@end

NS_ASSUME_NONNULL_END
