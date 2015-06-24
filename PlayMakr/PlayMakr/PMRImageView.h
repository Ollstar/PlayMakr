//
//  PMImageView.h
//  PlayMakr
//
//  Created by Ollstar.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface PMRImageView : UIImageView

@property (nonatomic, strong) UIImage *placeholderImage;

- (void) setFile:(PFFile *)file;

@end
