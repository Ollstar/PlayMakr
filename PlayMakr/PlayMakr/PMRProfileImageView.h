
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class PFImageView;
@interface PMRProfileImageView : UIView

@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) PFImageView *profileImageView;

- (void)setFile:(PFFile *)file;

@end
