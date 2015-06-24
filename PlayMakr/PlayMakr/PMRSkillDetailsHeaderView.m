//
//  PAPPhotoDetailsHeaderView.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//

#import "PMRSkillDetailsHeaderView.h"
#import "PMRProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PMConstants.h"
#import "PMUtility.h"
#import "PMCache.h"
#import <ParseUI/ParseUI.h>

#define baseHorizontalOffset 20.0f
#define baseWidth 280.0f

#define horiBorderSpacing 6.0f
#define horiMediumSpacing 8.0f

#define vertBorderSpacing 6.0f
#define vertSmallSpacing 2.0f


#define nameHeaderX baseHorizontalOffset
#define nameHeaderY 0.0f
#define nameHeaderWidth baseWidth
#define nameHeaderHeight 46.0f

#define avatarImageX horiBorderSpacing
#define avatarImageY vertBorderSpacing
#define avatarImageDim 35.0f

#define nameLabelX avatarImageX+avatarImageDim+horiMediumSpacing
#define nameLabelY avatarImageY+vertSmallSpacing
#define nameLabelMaxWidth 280.0f - (horiBorderSpacing+avatarImageDim+horiMediumSpacing+horiBorderSpacing)

#define timeLabelX nameLabelX
#define timeLabelMaxWidth nameLabelMaxWidth

#define mainImageX baseHorizontalOffset
#define mainImageY nameHeaderHeight
#define mainImageWidth baseWidth
#define mainImageHeight 280.0f

#define likeBarX baseHorizontalOffset
#define likeBarY nameHeaderHeight + mainImageHeight
#define likeBarWidth baseWidth
#define likeBarHeight 43.0f

#define likeButtonX 9.0f
#define likeButtonY 7.0f
#define likeButtonDim 28.0f

#define likeProfileXBase 46.0f
#define likeProfileXSpace 3.0f
#define likeProfileY 6.0f
#define likeProfileDim 30.0f

#define viewTotalHeight likeBarY+likeBarHeight
#define numLikePics 7.0f

@interface PMRSkillDetailsHeaderView ()

// View components
@property (nonatomic, strong) UIView *nameHeaderView;
@property (nonatomic, strong) PFImageView *skillImageView;
@property (nonatomic, strong) UIView *endorseBarView;
@property (nonatomic, strong) NSMutableArray *currentEndorseAvatars;

// Redeclare for edit
@property (nonatomic, strong, readwrite) PFUser *creator;
@property (nonatomic, strong, readwrite) PFObject *skill;



// Private methods
- (void)createView;

@end


static TTTTimeIntervalFormatter *timeFormatter;

@implementation PMRSkillDetailsHeaderView

@synthesize skill;
@synthesize creator;
@synthesize endorseUsers;
@synthesize nameHeaderView;
@synthesize skillImageView;
@synthesize endorseBarView;
@synthesize endorseButton;
@synthesize delegate;
@synthesize currentEndorseAvatars;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame skill:(PFObject*)aSkill {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.skill = aSkill;
        self.creator = [self.skill objectForKey:kPMSkillUserKey];
        self.endorseUsers = nil;
        
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame skill:(PFObject *)aSkill creator:(PFUser *)aCreator endorseUsers:(NSArray *)theEndorseUsers {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        self.skill = aSkill;
        self.creator = aCreator;
        self.endorseUsers = theEndorseUsers;
        
        self.backgroundColor = [UIColor clearColor];

        if (self.skill && self.creator && self.endorseUsers) {
            [self createView];
        }
        
    }
    return self;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [PMUtility drawSideDropShadowForRect:self.nameHeaderView.frame inContext:UIGraphicsGetCurrentContext()];
    [PMUtility drawSideDropShadowForRect:self.skillImageView.frame inContext:UIGraphicsGetCurrentContext()];
    [PMUtility drawSideDropShadowForRect:self.endorseBarView.frame inContext:UIGraphicsGetCurrentContext()];
}


#pragma mark - PMSkillDetailsHeaderView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, viewTotalHeight);
}

- (void)setSkill:(PFObject *)aSkill {
    skill = aSkill;

    if (self.skill && self.creator && self.endorseUsers) {
        [self createView];
        [self setNeedsDisplay];
    }
}

- (void)setEndorseUsers:(NSMutableArray *)anArray {
    endorseUsers = [anArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *endorser1, PFUser *endorser2) {
        NSString *displayName1 = [endorser1 objectForKey:kPMUserDisplayNameKey];
        NSString *displayName2 = [endorser2 objectForKey:kPMUserDisplayNameKey];
        
        if ([[endorser1 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedAscending;
        } else if ([[endorser2 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedDescending;
        }
        
        return [displayName1 compare:displayName2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    }];;
    
    for (PMRProfileImageView *image in currentEndorseAvatars) {
        [image removeFromSuperview];
    }

    [endorseButton setTitle:[NSString stringWithFormat:@"%d", self.endorseUsers.count] forState:UIControlStateNormal];

    self.currentEndorseAvatars = [[NSMutableArray alloc] initWithCapacity:endorseUsers.count];
    int i;
    int numOfPics = numLikePics > self.endorseUsers.count ? self.endorseUsers.count : numLikePics;

    for (i = 0; i < numOfPics; i++) {
        PMRProfileImageView *profilePic = [[PMRProfileImageView alloc] init];
        [profilePic setFrame:CGRectMake(likeProfileXBase + i * (likeProfileXSpace + likeProfileDim), likeProfileY, likeProfileDim, likeProfileDim)];
        [profilePic.profileButton addTarget:self action:@selector(didTapEndorserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        profilePic.profileButton.tag = i;
        [profilePic setFile:[[self.endorseUsers objectAtIndex:i] objectForKey:kPMUserProfilePicSmallKey]];
        [endorseBarView addSubview:profilePic];
        [currentEndorseAvatars addObject:profilePic];
    }
    
    [self setNeedsDisplay];
}

- (void)setEndorseButtonState:(BOOL)selected {
    if (selected) {
        [endorseButton setTitleEdgeInsets:UIEdgeInsetsMake( -1.0f, 0.0f, 0.0f, 0.0f)];
        [[endorseButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
    } else {
        [endorseButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
        [[endorseButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    }
    [endorseButton setSelected:selected];
}

- (void)reloadEndorseBar {
    self.endorseUsers = [[PMCache sharedCache] endorsersForSkill:self.skill];
    [self setEndorseButtonState:[[PMCache sharedCache] isSkillEndorsedByCurrentUser:self.skill]];
    [endorseButton addTarget:self action:@selector(didTapEndorseSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setNeedsDisplay];
}


#pragma mark - ()

- (void)createView {    
    /*
     Create middle section of the header view; the image
     */
    self.skillImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageX, mainImageY, mainImageWidth, mainImageHeight)];
    self.skillImageView.image = [UIImage imageNamed:@"PlaceholderPhoto.png"];
    self.skillImageView.backgroundColor = [UIColor blackColor];
    self.skillImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFFile *imageFile = [self.skill objectForKey:kPMSkillPictureKey];

    if (imageFile) {
        self.skillImageView.file = imageFile;
        [self.skillImageView loadInBackground];
    }
    
    [self addSubview:self.skillImageView];
    
    /*
     Create top of header view with name and avatar
     */
    self.nameHeaderView = [[UIView alloc] initWithFrame:CGRectMake(nameHeaderX, nameHeaderY, nameHeaderWidth, nameHeaderHeight)];
    self.nameHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]];
    [self addSubview:self.nameHeaderView];
    
    CALayer *layer = self.nameHeaderView.layer;
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.masksToBounds = NO;
    layer.shadowRadius = 1.0f;
    layer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
    layer.shadowOpacity = 0.5f;
    layer.shouldRasterize = YES;
    
    layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, self.nameHeaderView.frame.size.height - 4.0f, self.nameHeaderView.frame.size.width, 4.0f)].CGPath;

    // Load data for header
    [self.creator fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        // Create avatar view
        PMRProfileImageView *avatarImageView = [[PMRProfileImageView alloc] initWithFrame:CGRectMake(avatarImageX, avatarImageY, avatarImageDim, avatarImageDim)];
        [avatarImageView setFile:[self.creator objectForKey:kPMUserProfilePicSmallKey]];
        [avatarImageView setBackgroundColor:[UIColor clearColor]];
        [avatarImageView setOpaque:NO];
        [avatarImageView.profileButton addTarget:self action:@selector(didTapUserNameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //[avatarImageView load:^(UIImage *image, NSError *error) {}];
        [nameHeaderView addSubview:avatarImageView];
        
        // Create name label
        NSString *nameString = [self.creator objectForKey:kPMUserDisplayNameKey];
        UIButton *userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nameHeaderView addSubview:userButton];
        [userButton setBackgroundColor:[UIColor clearColor]];
        [[userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [userButton setTitle:nameString forState:UIControlStateNormal];
        [userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [[userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[userButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [userButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
        [userButton addTarget:self action:@selector(didTapUserNameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // we resize the button to fit the user's name to avoid having a huge touch area
        CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
        CGFloat constrainWidth = self.nameHeaderView.bounds.size.width - (avatarImageView.bounds.origin.x + avatarImageView.bounds.size.width);
        CGSize constrainSize = CGSizeMake(constrainWidth, self.nameHeaderView.bounds.size.height - userButtonPoint.y*2.0f);
        CGRect userButtonBoundingRect = [userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                options:NSStringDrawingTruncatesLastVisibleLine
                                                             attributes:@{NSFontAttributeName:userButton.titleLabel.font}
                                                                context:nil];
        CGSize userButtonSize = userButtonBoundingRect.size;
        CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
        [userButton setFrame:userButtonFrame];
        
        // Create time label
        NSString *timeString = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[self.skill createdAt]];
        CGRect timeLabelBoundingRect = [timeString boundingRectWithSize:CGSizeMake(nameLabelMaxWidth, CGFLOAT_MAX)
                                                                                 options:NSStringDrawingTruncatesLastVisibleLine
                                                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}
                                                                                 context:nil];
        CGSize timeLabelSize = timeLabelBoundingRect.size;

        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, nameLabelY+userButtonSize.height, timeLabelSize.width, timeLabelSize.height)];
        [timeLabel setText:timeString];
        [timeLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [timeLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        [timeLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        [timeLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.nameHeaderView addSubview:timeLabel];
        
        [self setNeedsDisplay];
    }];
    
    /*
     Create bottom section fo the header view; the endorsements
     */
    endorseBarView = [[UIView alloc] initWithFrame:CGRectMake(likeBarX, likeBarY, likeBarWidth, likeBarHeight)];
    [endorseBarView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
    [self addSubview:endorseBarView];
    
    // Create the heart-shaped endorse button
    endorseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [endorseButton setFrame:CGRectMake(likeButtonX, likeButtonY, likeButtonDim, likeButtonDim)];
    [endorseButton setBackgroundColor:[UIColor clearColor]];
    [endorseButton setTitleColor:[UIColor colorWithRed:0.369f green:0.271f blue:0.176f alpha:1.0f] forState:UIControlStateNormal];
    [endorseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [endorseButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
    [endorseButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.750f] forState:UIControlStateSelected];
    [endorseButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[endorseButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[endorseButton titleLabel] setMinimumScaleFactor:11.0f];
    [[endorseButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[endorseButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [endorseButton setAdjustsImageWhenDisabled:NO];
    [endorseButton setAdjustsImageWhenHighlighted:NO];
    [endorseButton setBackgroundImage:[UIImage imageNamed:@"ButtonLike.png"] forState:UIControlStateNormal];
    [endorseButton setBackgroundImage:[UIImage imageNamed:@"ButtonLikeSelected.png"] forState:UIControlStateSelected];
    [endorseButton addTarget:self action:@selector(didTapEndorseSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [endorseBarView addSubview:endorseButton];
    
    [self reloadEndorseBar];
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)]];
    [separator setFrame:CGRectMake(0.0f, endorseBarView.frame.size.height - 2.0f, endorseBarView.frame.size.width, 2.0f)];
    [endorseBarView addSubview:separator];
}

- (void)didTapEndorseSkillButtonAction:(UIButton *)button {
    BOOL endorsed = !button.selected;
    [button removeTarget:self action:@selector(didTapEndorseSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setEndorseButtonState:endorsed];

    NSArray *originalEndorseUsersArray = [NSArray arrayWithArray:self.endorseUsers];
    NSMutableSet *newEndorseUsersSet = [NSMutableSet setWithCapacity:[self.endorseUsers count]];
    
    for (PFUser *endorseUser in self.endorseUsers) {
        // add all current likeUsers BUT currentUser
        if (![[endorseUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [newEndorseUsersSet addObject:endorseUser];
        }
    }
    
    if (endorsed) {
        [[PMCache sharedCache] incrementEndorserCountForSkill:self.skill];
        [newEndorseUsersSet addObject:[PFUser currentUser]];
    } else {
        [[PMCache sharedCache] decrementEndorserCountForSkill:self.skill];
    }
    
    [[PMCache sharedCache] setSkillIsEndorsedByCurrentUser:self.skill endorsed:endorsed];

    [self setEndorseUsers:[newEndorseUsersSet allObjects]];

    if (endorsed) {
        [PMUtility endorseSkillInBackground:self.skill block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapEndorseSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setEndorseUsers:originalEndorseUsersArray];
                [self setEndorseButtonState:NO];
            }
        }];
    } else {
        [PMUtility removeEndorsementForSkillInBackground:self.skill block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapEndorseSkillButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setEndorseUsers:originalEndorseUsersArray];
                [self setEndorseButtonState:YES];
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotification object:self.skill userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:endorsed] forKey:PMSkillDetailsViewControllerUserEndorsedUnendorsedSkillNotificationUserInfoEndorsedKey]];
}

- (void)didTapEndorserButtonAction:(UIButton *)button {
    PFUser *user = [self.endorseUsers objectAtIndex:button.tag];
    if (delegate && [delegate respondsToSelector:@selector(skillDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate skillDetailsHeaderView:self didTapUserButton:button user:user];
    }    
}

- (void)didTapUserNameButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(skillDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate skillDetailsHeaderView:self didTapUserButton:button user:self.creator];
    }    
}

@end
