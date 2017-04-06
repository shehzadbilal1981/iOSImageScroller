//
//  ImageGalleryController.m
//  Shehzad
//
//  Created by Shehzad Bilal on 05/04/2017.
//  Copyright © 2017 Shehzad Bilal. All rights reserved.
//

#import "ImageGalleryController.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "Image.h"
#import "ImageCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"

#define CLIENT_ID @"5016533-e83d4fa58ef5fcafc46b14aa1"

@interface ImageGalleryController () {
    int pageNumber;
    BOOL isLoading;
    NSMutableArray<Image *> *images;
}

@end

@implementation ImageGalleryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pageNumber = 0;
    isLoading = NO;
    images = [[NSMutableArray<Image*> alloc] init];
    [self loadImages];
}


-(void)loadImages {
    if(isLoading) {
        return;
    } else {
        isLoading = YES;
        pageNumber++;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [manager GET:[NSString stringWithFormat:@"https://pixabay.com/api/?key=%@&page=%d",CLIENT_ID,pageNumber] parameters:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        isLoading = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSArray *hits = [responseObject valueForKey:@"hits"];
        for(NSDictionary *imgData in hits) {
            Image *img = [Image new];
            /*
             if we will use unsplash API
            img.imageId = [imgData valueForKey:@"id"];
            img.imageURLRaw = [[imgData valueForKey:@"urls"] valueForKey:@"raw"];
            img.imageURLThumb = [[imgData valueForKey:@"urls"] valueForKey:@"thumb"];
             */
            img.imageId = [imgData valueForKey:@"id"];
            img.imageURLRaw = [imgData valueForKey:@"previewURL"];
            img.imageURLThumb = [imgData valueForKey:@"webformatURL"];
            [images addObject:img];
        }
        [_ImageCollectionView reloadData];
        //NSLog(@"%@",images);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        isLoading = NO;
        pageNumber--;
        NSLog(@"Error: %@", error);
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageCollectionViewCell *cell = (ImageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    
    Image *img = [images objectAtIndex:indexPath.row];
    __weak typeof(img) weakImg = img;
    __weak typeof(cell) weakCell = cell;
    NSURL *imgURL = [NSURL URLWithString:img.imageURLThumb];
    if(img.imageLoaded == YES) {
        [cell.imgView setImageWithURL:imgURL];
    } else {
        [cell.imgView setImageWithURLRequest:[NSURLRequest requestWithURL:imgURL] placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            weakImg.imageLoaded = YES;
            [UIView transitionWithView:weakCell.imgView
                              duration:0.4
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                weakCell.imgView.image = image;
                            } completion:nil];
            
        } failure:nil];
    }
    if(indexPath.row == images.count - 1) {
        [self loadImages];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Image *img = [images objectAtIndex:indexPath.row];
    UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.imageURL = [NSURL URLWithString:img.imageURLRaw];
    imageInfo.referenceRect = attributes.frame;
    imageInfo.referenceView = self.view;
    // Setup view controller
    JTSImageViewController *imgViewer = [[JTSImageViewController alloc]
                                         initWithImageInfo:imageInfo
                                         mode:JTSImageViewControllerMode_Image
                                         backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imgViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
}

@end
