//
//  PAPEditPhotoViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//

#import "PMREditPhotoViewController.h"
#import "PMRSkillDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"
#import "PMConstants.h"
#import "PMCache.h"
#import <Parse/Parse.h>

@interface PMREditPhotoViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@end

@implementation PMREditPhotoViewController
@synthesize scrollView;
@synthesize image;
@synthesize commentTextField;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"Memory warning on Edit");
}


#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]];
    self.view = self.scrollView;
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 42.0f, 280.0f, 280.0f)];
    [photoImageView setBackgroundColor:[UIColor blackColor]];
    [photoImageView setImage:self.image];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];

    CALayer *layer = photoImageView.layer;
    layer.masksToBounds = NO;
    layer.shadowRadius = 3.0f;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.5f;
    layer.shouldRasterize = YES;
    
    [self.scrollView addSubview:photoImageView];
    
    CGRect footerRect = [PMRSkillDetailsFooterView rectForView];
    footerRect.origin.y = photoImageView.frame.origin.y + photoImageView.frame.size.height;

    PMRSkillDetailsFooterView *footerView = [[PMRSkillDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = footerView.commentField;
    self.commentTextField.delegate = self;
    [self.scrollView addSubview:footerView];

    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y + photoImageView.frame.size.height + footerView.frame.size.height)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];

    self.navigationItem.title = @"PlayMakr";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self shouldUploadImage:self.image];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doneButtonAction:textField];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentTextField resignFirstResponder];  
}


#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage {    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %lu for Anypic photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Thumbnail uploaded successfully");
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    scrollViewContentOffset.y += keyboardFrameEnd.size.height;
    scrollViewContentOffset.y -= 42.0f;
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)doneButtonAction:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                                  nil];
    }
    
    if (!self.photoFile || !self.thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:kPMSkillClassKey];
    [photo setObject:[PFUser currentUser] forKey:kPMSkillUserKey];
    [photo setObject:self.photoFile forKey:kPMSkillPictureKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];

    // save
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded");
            
            [[PMCache sharedCache] setAttributesForSkill:photo endorsers:[NSArray array] endorsedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    PFObject *comment = [PFObject objectWithClassName:kPMActivityClassKey];
                    [comment setObject:kPMActivityTypeComment forKey:kPMActivityTypeKey];
                    [comment setObject:photo forKey:kPMActivitySkillKey];
                    [comment setObject:[PFUser currentUser] forKey:kPMActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kPMActivityToUserKey];
                    [comment setObject:commentText forKey:kPMActivityContentKey];
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
//                    [[PMCache sharedCache] incrementCommentCountForSkill:photo];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
        } else {
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonAction:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
