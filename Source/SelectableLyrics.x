#import <UIKit/UIKit.h>
#import "../YTMUPKeys.h"

static BOOL selectableLyricsEnabled(void) {
    return IS_ENABLED(YTMUPKeyEnabled) && IS_ENABLED(YTMUPKeySelectableLyrics);
}

@interface YTFormattedStringLabel : UILabel @end

@interface YTMLightweightMusicDescriptionShelfCell : UIView
@property (retain, nonatomic) UITextView *lyrics;
@end

%hook YTMLightweightMusicDescriptionShelfCell

%property (retain, nonatomic) UITextView *lyrics;

- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self && selectableLyricsEnabled()) {
        UIView *container = [self valueForKey:@"_descriptionContainer"];
        self.lyrics = [[UITextView alloc] init];
        self.lyrics.backgroundColor          = [UIColor clearColor];
        self.lyrics.editable                 = NO;
        self.lyrics.scrollEnabled            = NO;
        self.lyrics.showsVerticalScrollIndicator = NO;
        [container addSubview:self.lyrics];
    }
    return self;
}

- (void)setRenderer:(id)renderer {
    %orig;
    if (selectableLyricsEnabled()) {
        YTFormattedStringLabel *lbl = [self valueForKey:@"_descriptionLabel"];
        lbl.userInteractionEnabled = YES;
        lbl.hidden = YES;
        self.lyrics.font           = lbl.font;
        self.lyrics.textColor      = lbl.textColor;
        self.lyrics.attributedText = lbl.attributedText;
    }
}

- (void)layoutSubviews {
    %orig;
    if (selectableLyricsEnabled()) {
        YTFormattedStringLabel *lbl = [self valueForKey:@"_descriptionLabel"];
        self.lyrics.frame = lbl.frame;
    }
}

%end
