//
//  LCPhotoCollectionViewCell.m
//  LCPhotoAlbum
//
//  Created by 李策 on 16/5/12.
//  Copyright © 2016年 李策. All rights reserved.
//

#import "LCPhotoCollectionViewCell.h"

@interface LCPhotoCollectionViewCell ()<LCBigImageScrollViewDelegate>
@property (strong, nonatomic) UIImageView *photoImageView;
@property (nonatomic , strong) LCBigImageScrollView *imageScrollView;
@property (nonatomic , assign) BOOL firstShow;
@end

@implementation LCPhotoCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.firstShow = YES;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.0;

        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        [self addSubview:imageView];
        self.photoImageView = imageView;

        
        self.imageScrollView = [[LCBigImageScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageScrollView.backgroundColor = [UIColor clearColor];
        self.imageScrollView.BigImg_Delegate = self;
        [self addSubview:self.imageScrollView];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}
- (void)setPhotoImage:(UIImage *)photoImage{
    _photoImage = photoImage;
    [self.photoImageView setImage:photoImage];
    self.imageScrollView.hidden = YES;
    self.photoImageView.hidden = NO;
}

- (void)setUpOrientationImage:(UIImage *)image WithFrame:(CGRect)frame andAnimationAtIndex:(NSUInteger)indexRow{
    self.imageScrollView.hidden = NO;
    self.photoImageView.hidden = YES;
    [self.imageScrollView setContentWithFrame:frame];
    [self.imageScrollView setImage:image];
    if (self.cellIndexRow == indexRow) {
        if (self.firstShow) {
            [self performSelector:@selector(setOriginFrame:) withObject:self.imageScrollView afterDelay:0.1];
        }else{
            [self.imageScrollView setAnimationRect];
        }
        
    }else{
        self.alpha = 1.0;
        [self.imageScrollView setAnimationRect];
    }
}
- (void) setOriginFrame:(LCBigImageScrollView *) sender
{
    [UIView animateWithDuration:0.4 animations:^{
        [sender setAnimationRect];
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.firstShow = NO;
    }];
    
}
- (void)tapImageViewTappedWithObject:(LCBigImageScrollView *)sender{ [UIView animateWithDuration:0.4 animations:^{
        [sender rechangeInitRdct];
        self.alpha = 0.0;

        } completion:^(BOOL finished) {
        self.firstShow = YES;
            if ([self.cell_Delegate respondsToSelector:@selector(tapBigImageViewAtCell:)]) {
                [self.cell_Delegate tapBigImageViewAtCell:self];
            }
    }];
}
@end
