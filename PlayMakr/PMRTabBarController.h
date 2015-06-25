//
//  PAPTabBarController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//

#import <UIKit/UIKit.h>

@protocol PMRTabBarControllerDelegate;

@interface PMRTabBarController : UITabBarController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

- (BOOL)shouldPresentPhotoCaptureController;

@end

@protocol PMRTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;

@end