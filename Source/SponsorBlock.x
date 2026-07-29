#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Headers/Localization.h"
#import "Headers/YTMToastController.h"
#import "Headers/YTPlayerViewController.h"
#import "YTMUPKeys.h"

%hook YTPlayerViewController
%property (nonatomic, strong) NSMutableDictionary *sponsorBlockValues;

- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    %orig;

    if (!IS_ENABLED(YTMUPKeySponsorBlock)) return;

    self.sponsorBlockValues = [NSMutableDictionary dictionary];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:
        [NSString stringWithFormat:@"https://sponsor.ajay.app/api/skipSegments?videoID=%@&categories=%@",
         self.currentVideoID, @"%5B%22music_offtopic%22%5D"]]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([NSJSONSerialization isValidJSONObject:jsonResponse]) {
                NSMutableDictionary *segments = [NSMutableDictionary dictionary];
                for (NSDictionary *segmentDict in jsonResponse) {
                    segments[segmentDict[@"UUID"]] = @(1);
                }
                self.sponsorBlockValues[self.currentVideoID] = jsonResponse;
                self.sponsorBlockValues[@"segments"] = segments;
            }
        }
    }] resume];
}

- (void)singleVideo:(id)video currentVideoTimeDidChange:(id)time {
    %orig;
    [self skipSegment];
}

- (void)potentiallyMutatedSingleVideo:(id)video currentVideoTimeDidChange:(id)time {
    %orig;
    [self skipSegment];
}

%new
- (void)skipSegment {
    if (!IS_ENABLED(YTMUPKeySponsorBlock)) return;
    if (![NSJSONSerialization isValidJSONObject:self.sponsorBlockValues]) return;

    NSArray      *sponsorValues  = self.sponsorBlockValues[self.currentVideoID];
    NSMutableDictionary *skipMap = self.sponsorBlockValues[@"segments"];
    NSInteger    skipMode        = INTFORVAL(YTMUPKeySBSkipMode);
    NSInteger    duration        = INTFORVAL(YTMUPKeySBDuration);

    for (NSDictionary *seg in sponsorValues) {
        NSString *uuid = seg[@"UUID"];
        if (![skipMap[uuid] isEqual:@(1)]) continue;
        if (![seg[@"category"] isEqual:@"music_offtopic"]) continue;
        if (self.currentVideoMediaTime < [seg[@"segment"][0] floatValue]) continue;
        if (self.currentVideoMediaTime > ([seg[@"segment"][1] floatValue] - 1)) continue;

        skipMap[uuid] = @(0);
        self.sponsorBlockValues[@"segments"] = skipMap;

        GOOHUDMessageAction *unskipAction = [[%c(GOOHUDMessageAction) alloc] init];
        unskipAction.title = LOC(@"UNSKIP");
        [unskipAction setHandler:^{ [self seekToTime:[seg[@"segment"][0] floatValue]]; }];

        GOOHUDMessageAction *skipAction = [[%c(GOOHUDMessageAction) alloc] init];
        skipAction.title = LOC(@"SKIP");
        [skipAction setHandler:^{
            [self seekToTime:[seg[@"segment"][1] floatValue]];
            [[%c(YTMToastController) alloc] showMessage:LOC(@"SEGMENT_SKIPPED")
                                       HUDMessageAction:unskipAction
                                               infoType:0
                                               duration:duration];
        }];

        if (skipMode == 0) {
            [self seekToTime:[seg[@"segment"][1] floatValue]];
            [[%c(YTMToastController) alloc] showMessage:LOC(@"SEGMENT_SKIPPED")
                                       HUDMessageAction:unskipAction
                                               infoType:0
                                               duration:duration];
        } else {
            [[%c(YTMToastController) alloc] showMessage:LOC(@"FOUND_SEGMENT")
                                       HUDMessageAction:skipAction
                                               infoType:0
                                               duration:duration];
        }
    }
}
%end