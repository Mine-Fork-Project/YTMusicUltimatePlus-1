#import "YTMUPSettingsSection.h"

@implementation YTMUPSettingsSection

+ (instancetype)sectionWithHeader:(NSString *)header
                           footer:(NSString *)footer
                            items:(NSArray<YTMUPSettingsItem *> *)items {
    YTMUPSettingsSection *section = [self new];
    section.YTMUPHeader = header;
    section.YTMUPFooter = footer;
    section.YTMUPItems  = [NSMutableArray arrayWithArray:items];
    return section;
}

@end
