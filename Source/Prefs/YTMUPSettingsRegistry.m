#import "YTMUPSettingsRegistry.h"

@interface YTMUPSettingsRegistry ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<YTMUPSettingsSection *> *> *registry;
@end

@implementation YTMUPSettingsRegistry

+ (instancetype)sharedRegistry {
    static YTMUPSettingsRegistry *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
        instance.registry = [NSMutableDictionary dictionary];
    });
    return instance;
}

- (void)registerSections:(NSArray<YTMUPSettingsSection *> *)sections
               forPageId:(NSString *)pageId {
    self.registry[pageId] = [sections copy];
}

- (NSArray<YTMUPSettingsSection *> *)sectionsForPageId:(NSString *)pageId {
    return self.registry[pageId] ?: @[];
}

@end
