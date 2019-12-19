//
//  RNDynamicCropper.m
//  camtest
//
//  Created by Robert Sherling on 2018/05/05.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNDynamicCropper.h"
#import <React/RCTConvert.h>
#import "React/RCTLog.h"

#if __has_include("TOCropViewController.h")
#import "TOCropViewController.h"
#elif __has_include(<TOCropViewControllerController/TOCropViewControllerController.h>)
#import <TOCropViewControllerController/TOCropViewControllerController.h>
#else
#import "TOCropViewController/TOCropViewController.h"
#endif

@interface RNDynamicCropper()
@property(nonatomic, strong) RCTPromiseResolveBlock resolver;
@property(nonatomic, strong) RCTPromiseRejectBlock reject;
@end

NSString *someString = @"front";


@implementation RNDynamicCropper

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(cropImage:(NSString *)path details:(NSDictionary *)details resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
  self.resolver = resolve;
  self.reject = reject;
    NSString *title = [RCTConvert NSString:details[@"title"]];
    NSString *type_image = [RCTConvert NSString:details[@"type"]];
    someString = type_image;
    NSString *cancelButtonTitle = [RCTConvert NSString:details[@"cancelText"]];
    NSString *doneButtonTitle = [RCTConvert NSString:details[@"confirmText"]];
    // NSString *locale = [RCTConvert NSString:details[@"locale"]];
  dispatch_async(dispatch_get_main_queue(), ^{
    // This code pretty much never chages. Take the path command that we passed from JS.
    // Read that data into an image. Open the image in the cropper.
    // Profit.
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
      // Locale set here
      if([title length] != 0){
          cropViewController.title = title;
      }
      if([doneButtonTitle length] != 0){
          cropViewController.doneButtonTitle = doneButtonTitle;
      }
      if([cancelButtonTitle length] != 0){
          cropViewController.cancelButtonTitle = cancelButtonTitle;
      }
    cropViewController.delegate = self;
    UINavigationController* contactNavigator = [[UINavigationController alloc] initWithRootViewController:cropViewController];
     [[self getRootVC] presentViewController:contactNavigator animated:NO completion:nil];
  });
}

// Copied from https://github.com/ivpusic/react-native-image-crop-picker/blob/master/ios/src/ImageCropPicker.m
// Actually, pretty much this whole thing was like 5 tutorials and looking at this for reference, and help from an amazing freelancer.
- (UIViewController*) getRootVC {
  UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  while (root.presentedViewController != nil) {
    root = root.presentedViewController;
  }
  
  return root;
}

-(void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
  // Just a way to get file paths
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *string2 = @".jpg";
  NSString *tmpPathFull = [someString stringByAppendingString:string2];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:tmpPathFull];
  // Write our image data to the above specified path (wherever + temp)
  [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
  // Close the UIView
  [cropViewController dismissViewControllerAnimated:YES completion:nil];
  // Return the path so it can be manipulated elsewhere.
  self.resolver(filePath);
}

- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled
{
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
    self.resolver(@"");
}

@end
