#import "YTMUPSettingsItem.h"

@implementation YTMUPSettingsItem

#pragma mark - Toggle

+ (instancetype)toggleWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                       sfSymbol:(NSString *)sf
                            key:(NSString *)key {
    YTMUPSettingsItem *item = [self new];
    item.YTMUPTitle        = title;
    item.YTMUPSubtitle     = subtitle;
    item.YTMUPSfSymbol     = sf;
    item.YTMUPType         = YTMUPItemTypeToggle;
    item.YTMUPDefaultsKey  = key;
    return item;
}

#pragma mark - Slider

+ (instancetype)sliderWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                       sfSymbol:(NSString *)sf
                            key:(NSString *)key
                        options:(NSArray<NSNumber *> *)options {
    YTMUPSettingsItem *item = [self new];
    item.YTMUPTitle         = title;
    item.YTMUPSubtitle      = subtitle;
    item.YTMUPSfSymbol      = sf;
    item.YTMUPType          = YTMUPItemTypeSlider;
    item.YTMUPDefaultsKey   = key;
    item.YTMUPSliderOptions = options;
    return item;
}

#pragma mark - Segment

+ (instancetype)segmentWithTitle:(NSString *)title
                        sfSymbol:(NSString *)sf
                             key:(NSString *)key
                           items:(NSArray *)items {
    YTMUPSettingsItem *item = [self new];
    item.YTMUPTitle        = title;
    item.YTMUPSfSymbol     = sf;
    item.YTMUPType         = YTMUPItemTypeSegment;
    item.YTMUPDefaultsKey  = key;
    item.YTMUPSegmentItems = items;
    return item;
}

+ (instancetype)segmentWithTitle:(NSString *)title
                        sfSymbol:(NSString *)sf
                             key:(NSString *)key
                   itemsProvider:(NSArray *(^)(void))provider {
    YTMUPSettingsItem *item = [self new];
    item.YTMUPTitle                 = title;
    item.YTMUPSfSymbol              = sf;
    item.YTMUPType                  = YTMUPItemTypeSegment;
    item.YTMUPDefaultsKey           = key;
    item.YTMUPSegmentItemsProvider  = provider;
    return item;
}

#pragma mark - TextField

+ (instancetype)textFieldWithTitle:(NSString *)title
                          sfSymbol:(NSString *)sf
                               key:(NSString *)key
                      keyboardType:(UIKeyboardType)kbType
                       placeholder:(NSString *)placeholder {
    YTMUPSettingsItem *item = [self new];
    item.YTMUPTitle                  = title;
    item.YTMUPSfSymbol               = sf;
    item.YTMUPType                   = YTMUPItemTypeTextField;
    item.YTMUPDefaultsKey            = key;
    item.YTMUPKeyboardType           = kbType;
    item.YTMUPTextFieldPlaceholder   = placeholder;
    return item;
}

#pragma mark - Navigation

+ (instancetype)navigationWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                           sfSymbol:(NSString *)sf
                        destination:(Class)destClass {
    YTMUPSettingsItem *item = [self new];
    item.YTMUPTitle            = title;
    item.YTMUPSubtitle         = subtitle;
    item.YTMUPSfSymbol         = sf;
    item.YTMUPType             = YTMUPItemTypeNavigation;
    item.YTMUPDestinationClass = destClass;
    return item;
}

#pragma mark - Action

+ (instancetype)actionWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                       sfSymbol:(NSString *)sf
                         action:(void (^)(void))block {
    YTMUPSettingsItem *item = [self new];
    item.YTMUPTitle       = title;
    item.YTMUPSubtitle    = subtitle;
    item.YTMUPSfSymbol    = sf;
    item.YTMUPType        = YTMUPItemTypeAction;
    item.YTMUPActionBlock = block;
    return item;
}

@end
