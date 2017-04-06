//
//  Image.h
//  Shehzad
//
//  Created by Shehzad Bilal on 05/04/2017.
//  Copyright © 2017 Shehzad Bilal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Image : NSObject

@property(nonatomic, strong) NSString *imageId;
@property(nonatomic, strong) NSString *imageURLRaw;
@property(nonatomic, strong) NSString *imageURLThumb;
@property BOOL imageLoaded;
@end
