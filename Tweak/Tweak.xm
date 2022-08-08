#import "Tweak.h"

%hook _UIStatusBarStringView
- (id)initWithFrame:(CGRect)frame {
   id orig = %orig;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateWeather) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    return orig;
}

%new
- (void)updateWeather {
    if ([[self _viewControllerForAncestor] isKindOfClass:objc_getClass("CCUIModularControlCenterOverlayViewController")]) return;

    CATransition *animation = [CATransition animation];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.type = kCATransitionPush;
	animation.subtype = kCATransitionFromTop;
	animation.duration = 0.3;
	[self.layer addAnimation:animation forKey:@"kCATransitionPush"];

    if ([self.text containsString:@":"]) {
        [[Togachan sharedInstance] refreshWeatherData];
        NSString *weatherString = [NSString stringWithFormat:@"%@", [[Togachan sharedInstance] currentTemperature]];
        UIImage *conditionsImage = [[Togachan sharedInstance] currentConditionsImage];
        conditionsImage = [conditionsImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        NSMutableAttributedString *weatherAttributedString = [self attributedStringWithValue:weatherString image:conditionsImage];
        self.attributedText = weatherAttributedString;
    } else if ([self.text containsString:@"°"]) {
        [[Togachan sharedInstance] refreshWeatherData];
        NSString *locationString = [NSString stringWithFormat:@"%@", [[Togachan sharedInstance] currentLocation]];
        UIImage *locationImage = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/Application Support/Tosaka/gps.png"];
        locationImage = [locationImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        NSMutableAttributedString *locationAttributedString = [self attributedStringWithValue:locationString image:locationImage];
        self.attributedText = locationAttributedString;
    } else { // weatherground #Tr1Fecta-7 https://github.com/Tr1Fecta-7/WeatherGround
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSRange amRange = [[formatter stringFromDate:[NSDate now]] rangeOfString:[formatter AMSymbol]];
        NSRange pmRange = [[formatter stringFromDate:[NSDate now]] rangeOfString:[formatter PMSymbol]];
        BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
        [formatter setDateFormat:is24h ? @"H:mm" : @"h:mm"];
        NSString *currentStatusTime = [formatter stringFromDate:[NSDate now]];
        self.text = currentStatusTime;
    }
}

%new
- (NSMutableAttributedString *)attributedStringWithValue:(NSString *)string image:(UIImage *)image { //Reddit #blazejmar https://stackoverflow.com/questions/29041458/how-to-set-color-of-templated-image-in-nstextattachment
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, -self.frame.size.height/4, self.frame.size.height, self.frame.size.height);
    attachment.image = image;

    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "]];
    [mutableAttributedString appendAttributedString:attachmentString];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:0] range:NSMakeRange(0, mutableAttributedString.length)]; // Put font size 0 to prevent offset
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor labelColor] range:NSMakeRange(0, mutableAttributedString.length)];
    [mutableAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "]];

    NSMutableAttributedString *ratingText = [[NSMutableAttributedString alloc] initWithString:string];
    [mutableAttributedString appendAttributedString:ratingText];
    return mutableAttributedString;
}
%end

%hook _UIStatusBarDisplayItem
- (void)setEnabled:(BOOL)arg1 {
	if ([[self item] isKindOfClass:objc_getClass("_UIStatusBarIndicatorLocationItem")]) return %orig(NO);
	else return %orig;
}
%end
