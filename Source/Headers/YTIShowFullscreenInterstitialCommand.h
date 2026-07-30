#import "YTIModalClientThrottlingRules.h"

@interface YTIShowFullscreenInterstitialCommand : NSObject
@property (nonatomic, readwrite, assign) BOOL hasModalClientThrottlingRules;
@property (nonatomic, readwrite, strong) YTIModalClientThrottlingRules *modalClientThrottlingRules;
@end