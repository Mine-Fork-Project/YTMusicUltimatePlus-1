#import <Foundation/Foundation.h>
#import "YTMUPSettingsItem.h"

NS_ASSUME_NONNULL_BEGIN

/// A single section inside a settings page, containing a header, footer and ordered items.
@interface YTMUPSettingsSection : NSObject

@property (nonatomic, copy,   nullable) NSString                              *YTMUPHeader;
@property (nonatomic, copy,   nullable) NSString                              *YTMUPFooter;
@property (nonatomic, strong)           NSMutableArray<YTMUPSettingsItem *>   *YTMUPItems;

/// Convenience constructor.
+ (instancetype)sectionWithHeader:(nullable NSString *)header
                           footer:(nullable NSString *)footer
                            items:(NSArray<YTMUPSettingsItem *> *)items;

@end

NS_ASSUME_NONNULL_END
