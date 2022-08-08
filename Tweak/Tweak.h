#import <UIKit/UIKit.h>
#import <libTogachan/libtogachan.h>

@interface _UIStatusBarStringView : UILabel
- (id)_viewControllerForAncestor;
- (void)updateWeather;
- (NSMutableAttributedString *)attributedStringWithValue:(NSString *)string image:(UIImage *)image;
@end

@interface _UIStatusBarDisplayItem : NSObject
@property (nonatomic, weak, readonly) id item;
@end