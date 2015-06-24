//
//  PAPActivityCell.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/14/12.
//

#import "PMRActivityCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PMRProfileImageView.h"
#import "PMRActivityFeedViewController.h"
#import "PMConstants.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface PMRActivityCell ()

/*! Private view components */
@property (nonatomic, strong) PMRProfileImageView *activityImageView;
@property (nonatomic, strong) UIButton *activityImageButton;

/*! Flag to remove the right-hand side image if not necessary */
@property (nonatomic) BOOL hasActivityImage;

/*! Private setter for the right-hand side image */
- (void)setActivityImageFile:(PFFile *)image;

/*! Button touch handler for activity image button overlay */
- (void)didTapActivityButton:(id)sender;

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end


@implementation PMRActivityCell

@synthesize activityImageButton,activityImageView;
@synthesize activity = _activity;
@synthesize hasActivityImage;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        horizontalTextSpace = [PMRActivityCell horizontalTextSpaceForInsetWidth:0];
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        // Create subviews and set cell properties
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.hasActivityImage = NO; //No until one is set
        
        self.activityImageView = [[PMRProfileImageView alloc] init];
        [self.activityImageView setBackgroundColor:[UIColor clearColor]];
        [self.activityImageView setOpaque:YES];
        [self.mainView addSubview:self.activityImageView];
        
        self.activityImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activityImageButton setBackgroundColor:[UIColor clearColor]];
        [self.activityImageButton addTarget:self action:@selector(didTapActivityButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.activityImageButton];
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
       
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    [self.activityImageView setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 8.0f, 33.0f, 33.0f)];
    [self.activityImageButton setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 8.0f, 33.0f, 33.0f)];

    // Add activity image if one was set
    if (self.hasActivityImage) {
        [self.activityImageView setHidden:NO];
        [self.activityImageButton setHidden:NO];
    } else {
        [self.activityImageView setHidden:YES];
        [self.activityImageButton setHidden:YES];
    }

    // Change frame of the content text so it doesn't go through the right-hand side picture
    
    CGRect contentRect = [self.contentLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil];
    CGSize contentSize = contentRect.size;
    CGFloat contentHeight = ceilf(contentSize.height);
    CGFloat contentWidth = ceilf(contentSize.width);
    
    [self.contentLabel setFrame:CGRectMake( 46.0f, 10.0f, contentWidth, contentHeight)];
    
    // Layout the timestamp label given new vertical
    
    CGRect timeRect = [self.timeLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]} context:nil];
    CGSize timeSize = timeRect.size;
    CGFloat timeHeight = ceilf(timeSize.height);
    CGFloat timeWidth = ceilf(timeSize.width);
    

    [self.timeLabel setFrame:CGRectMake( 46.0f, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 2.0f, timeWidth, timeHeight)];
}


#pragma mark - PMRActivityCell

- (void)setIsNew:(BOOL)isNew {
    if (isNew) {
        [self.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundNewActivity.png"]]];
    } else {
        [self.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
    }
}


- (void)setActivity:(PFObject *)activity {
    // Set the activity property
    _activity = activity;
    if ([[activity objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeFollow] || [[activity objectForKey:kPMActivityTypeKey] isEqualToString:kPMActivityTypeJoined]) {
        [self setActivityImageFile:nil];
    } else {
        [self setActivityImageFile:(PFFile*)[[activity objectForKey:kPMActivitySkillKey] objectForKey:kPAPPhotoThumbnailKey]];
    }
    
    NSString *activityString = [PMRActivityFeedViewController stringForActivityType:(NSString*)[activity objectForKey:kPMActivityTypeKey]];
    self.user = [activity objectForKey:kPMActivityFromUserKey];
    
    // Set name button properties and avatar image
    [self.avatarImageView setFile:[self.user objectForKey:kPMUserProfilePicSmallKey]];
    [self.nameButton setTitle:[self.user objectForKey:kPMUserDisplayNameKey] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:kPMUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }

    if (self.user) {
        CGRect nameRect = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]} context:nil];
        CGSize nameSize = nameRect.size;
        CGFloat nameWidth = ceilf(nameSize.width);

        NSString *paddedString = [PMRBaseTextCell padString:activityString withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameWidth];
        [self.contentLabel setText:paddedString];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.contentLabel setText:activityString];
    }

    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[activity createdAt]]];

    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    [super setCellInsetWidth:insetWidth];
    horizontalTextSpace = [PMRActivityCell horizontalTextSpaceForInsetWidth:insetWidth];
}

// Since we remove the compile-time check for the delegate conforming to the protocol
// in order to allow inheritance, we add run-time checks.
- (id<PMRActivityCellDelegate>)delegate {
    return (id<PMRActivityCellDelegate>)_delegate;
}

- (void)setDelegate:(id<PMRActivityCellDelegate>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
    }
}


#pragma mark - ()

+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return ([UIScreen mainScreen].bounds.size.width - (insetWidth * 2.0f)) - 72.0f - 46.0f;
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [self heightForCellWithName:name contentString:content cellInsetWidth:0.0f];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    
    CGRect nameRect = [name boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]} context:nil];
    CGSize nameSize = nameRect.size;
    CGFloat nameWidth = ceilf(nameSize.width);
    
    NSString *paddedString = [PMRBaseTextCell padString:content withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameWidth];

    CGFloat horizontalTextSpace = [PMRActivityCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGRect contentRect = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]} context:nil];
    CGSize contentSize = contentRect.size;
    CGFloat contentHeight = ceilf(contentSize.height);
//    CGFloat contentWidth = ceilf(contentSize.width);
    
    CGFloat singleLineHeight = [@"Test" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}].height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = contentHeight - singleLineHeight;

    return 48.0f + fmax(0.0f, multilineHeightAddition);
}

- (void)setActivityImageFile:(PFFile *)imageFile {
    if (imageFile) {
        [self.activityImageView setFile:imageFile];
        [self setHasActivityImage:YES];
    } else {
        [self setHasActivityImage:NO];
    }
}

- (void)didTapActivityButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapActivityButton:)]) {
        [self.delegate cell:self didTapActivityButton:self.activity];
    }    
}

@end
