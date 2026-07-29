#import <UIKit/UIKit.h>
#import "../YTMUPKeys.h"

static BOOL isOLEDTheme(void)    { return IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyOledTheme); }
static BOOL isOLEDKeyboard(void) { return IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyOledKeyboard); }
static BOOL isLowContrast(void)  { return IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeyLowContrast); }

@interface YTMPlayerPageColorScheme : NSObject
- (void)setPlayButtonColor:(UIColor *)color;
@end
@interface UIKeyboardDockView : UIView @end
@interface UIKeyboardLayoutStar : UIView @end
@interface YTPivotBarView : UIView @end
@interface YTMMusicMenuTitleView : UIView @end
@interface MDCSnackbarMessageView : UIView @end
@interface UIPredictionViewController : UIViewController @end
@interface UICandidateViewController : UIViewController @end

#pragma mark - OLED Dark mode
@interface YTColor : UIColor
+ (UIColor *)blackPure;
@end

%hook YTColor
+ (UIColor *)black0 { return isOLEDTheme() ? [self blackPure] : %orig; }
+ (UIColor *)black1 { return isOLEDTheme() ? [self blackPure] : %orig; }
+ (UIColor *)black2 { return isOLEDTheme() ? [self blackPure] : %orig; }
+ (UIColor *)black3 { return isOLEDTheme() ? [self blackPure] : %orig; }
+ (UIColor *)black4 { return isOLEDTheme() ? [self blackPure] : %orig; }
%end

%hook YTMPlayerPageColorScheme
- (UIColor *)backgroundColor { return isOLEDTheme() ? [UIColor blackColor] : %orig; }
- (UIColor *)expandedTabsBackgroundColor { return isOLEDTheme() ? [UIColor blackColor] : %orig; }
- (UIColor *)miniPlayerColor { return isOLEDTheme() ? [UIColor blackColor] : %orig; }
- (UIColor *)expandedTabViewColor { return isOLEDTheme() ? [UIColor blackColor] : %orig; }
- (UIColor *)overlayButtonColor { return isOLEDTheme() ? [UIColor blackColor] : %orig; }
- (UIColor *)overlayErrorBackgroundColor { return isOLEDTheme() ? [UIColor blackColor] : %orig; }
- (UIColor *)AVSwitchBackgroundColor { return isOLEDTheme() ? [UIColor blackColor] : %orig; }
- (UIColor *)AVSwitchActiveModeColor { return isOLEDTheme() ? [[UIColor whiteColor] colorWithAlphaComponent:0.1] : %orig; }
- (UIColor *)queueBackgroundColor { return isOLEDTheme() ? [UIColor blackColor] : %orig; }
- (UIColor *)queueCurrentlyPlayingColor { return isOLEDTheme() ? [[UIColor whiteColor] colorWithAlphaComponent:0.1] : %orig; }
- (BOOL)gradientBackgroundEnabled { return isOLEDTheme() ? NO : %orig; }
%end

%hook YTPivotBarView
- (UIView *)contentView {
    UIView *orig = %orig;
    if (isOLEDTheme()) orig.backgroundColor = [UIColor blackColor];
    return orig;
}
%end

@interface YTLightweightBrowseBackgroundView : UIView @end
%hook YTLightweightBrowseBackgroundView
- (UIImageView *)imageView {
    if (!isOLEDTheme()) return %orig;
    self.backgroundColor = [UIColor blackColor];
    return nil;
}
%end

#pragma mark - OLED Dark Keyboard
%hook UIPredictionViewController
- (void)loadView { %orig; if (isOLEDKeyboard()) [self.view setBackgroundColor:[UIColor blackColor]]; }
%end

%hook UICandidateViewController
- (void)loadView { %orig; if (isOLEDKeyboard()) [self.view setBackgroundColor:[UIColor blackColor]]; }
%end

%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)arg1 { isOLEDKeyboard() ? %orig(NO) : %orig; }
%end

%hook UIKeyboardDockView
- (void)didMoveToWindow { if (isOLEDKeyboard()) self.backgroundColor = [UIColor blackColor]; %orig; }
%end

%hook UIKeyboardLayoutStar
- (void)didMoveToWindow { if (isOLEDKeyboard()) self.backgroundColor = [UIColor blackColor]; %orig; }
%end

#pragma mark - Low contrast mode
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
    return isLowContrast() ? [UIColor colorWithWhite:0.565 alpha:1] : %orig;
}
- (UIColor *)textSecondary {
    return isLowContrast() ? [UIColor colorWithWhite:0.565 alpha:1] : %orig;
}
%end

%hook UIColor
+ (UIColor *)whiteColor {
    return isLowContrast() ? [UIColor colorWithWhite:0.565 alpha:1] : %orig;
}
%end
