//
//  ImageGalleryController.h
//  Shehzad
//
//  Created by Shehzad Bilal on 05/04/2017.
//  Copyright © 2017 Shehzad Bilal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGalleryController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic,strong) IBOutlet UICollectionView *ImageCollectionView;

@end
