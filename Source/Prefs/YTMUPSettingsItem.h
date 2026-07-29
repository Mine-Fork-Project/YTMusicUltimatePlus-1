#import <UIKit/UIKit.h>

/// Describes what kind of control a settings row displays.
typedef NS_ENUM(NSUInteger, YTMUPSettingsItemType) {
    YTMUPItemTypeToggle,      // ABCSwitch / UISwitch — saves BOOL to defaultsKey
    YTMUPItemTypeSlider,      // UISlider snapping to discrete YTMUPSliderOptions — saves actual NSNumber value
    YTMUPItemTypeSegment,     // UISegmentedControl — saves selectedSegmentIndex as NSInteger to defaultsKey
    YTMUPItemTypeTextField,   // Right-aligned UITextField — saves NSString to defaultsKey on dismiss
    YTMUPItemTypeNavigation,  // Disclosure indicator — pushes YTMUPDestinationClass
    YTMUPItemTypeAction,      // Tappable row — calls YTMUPActionBlock
};

@interface YTMUPSettingsItem : NSObject

// ─── Common ───────────────────────────────────────────────────────────────────
@property (nonatomic, copy)   NSString              *YTMUPTitle;
@property (nonatomic, copy)   NSString              *YTMUPSubtitle;       // shown as detail text
@property (nonatomic, copy)   NSString              *YTMUPSfSymbol;       // SF Symbol name
@property (nonatomic, strong) UIImage               *YTMUPCustomImage;    // overrides sfSymbol
@property (nonatomic, strong) UIColor               *YTMUPTintColor;      // switch / icon tint
@property (nonatomic, strong) UIColor               *YTMUPTitleColor;     // custom label colour
@property (nonatomic, assign) YTMUPSettingsItemType  YTMUPType;
@property (nonatomic, copy)   NSString              *YTMUPDefaultsKey;    // NSUserDefaults key

// ─── Slider ───────────────────────────────────────────────────────────────────
// Provide an ordered NSArray of NSNumber values.
// The slider snaps to one of those positions; the actual value is saved to defaults.
@property (nonatomic, copy) NSArray<NSNumber *> *YTMUPSliderOptions;

// ─── Segment ──────────────────────────────────────────────────────────────────
// Static array of NSString or UIImage items.
@property (nonatomic, copy) NSArray *YTMUPSegmentItems;
// Lazy provider block — evaluated when the cell is built (use for images from YTAssetLoader).
// Overrides YTMUPSegmentItems when non-nil.
@property (nonatomic, copy) NSArray *(^YTMUPSegmentItemsProvider)(void);

// ─── TextField ────────────────────────────────────────────────────────────────
@property (nonatomic, assign) UIKeyboardType  YTMUPKeyboardType;
@property (nonatomic, copy)   NSString       *YTMUPTextFieldPlaceholder;

// ─── Navigation ───────────────────────────────────────────────────────────────
@property (nonatomic, assign) Class YTMUPDestinationClass;

// ─── Action ───────────────────────────────────────────────────────────────────
@property (nonatomic, copy) void (^YTMUPActionBlock)(void);

// ─── Convenience constructors ─────────────────────────────────────────────────

+ (instancetype)toggleWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                       sfSymbol:(NSString *)sf
                            key:(NSString *)key;

+ (instancetype)sliderWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                       sfSymbol:(NSString *)sf
                            key:(NSString *)key
                        options:(NSArray<NSNumber *> *)options;

+ (instancetype)segmentWithTitle:(NSString *)title
                        sfSymbol:(NSString *)sf
                             key:(NSString *)key
                           items:(NSArray *)items;

+ (instancetype)segmentWithTitle:(NSString *)title
                        sfSymbol:(NSString *)sf
                             key:(NSString *)key
                   itemsProvider:(NSArray *(^)(void))provider;

+ (instancetype)textFieldWithTitle:(NSString *)title
                          sfSymbol:(NSString *)sf
                               key:(NSString *)key
                      keyboardType:(UIKeyboardType)kbType
                       placeholder:(NSString *)placeholder;

+ (instancetype)navigationWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                           sfSymbol:(NSString *)sf
                        destination:(Class)destClass;

+ (instancetype)actionWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                       sfSymbol:(NSString *)sf
                         action:(void (^)(void))block;

@end
