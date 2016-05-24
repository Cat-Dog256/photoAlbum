//
//  LCPhotoCollectionViewCell.h
//  LCPhotoAlbum
//
//  Created by 李策 on 16/5/12.
//  Copyright © 2016年 李策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCBigImageScrollView.h"
@class LCPhotoCollectionViewCell;
@protocol LCPhotoCollectionViewCellDelegate <NSObject>

- (void)tapBigImageViewAtCell:(LCPhotoCollectionViewCell *)bigCell;

@end

@interface LCPhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic , strong) id<LCPhotoCollectionViewCellDelegate>cell_Delegate;
@property (nonatomic , assign) NSUInteger cellIndexRow;
@property (nonatomic , strong) UIImage *photoImage;
- (void)setUpOrientationImage:(UIImage *)image WithFrame:(CGRect)frame andAnimationAtIndex:(NSUInteger)indexRow;
@end
