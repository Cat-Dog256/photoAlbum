//
//  LCPhotoKitAsset.h
//  LCPhotoAlbum
//
//  Created by 李策 on 16/5/12.
//  Copyright © 2016年 李策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
typedef enum  {
    PreviewImage,
    OrientationImage,
} LCPhotoImageSizeType;
@interface LCPhotoKitAsset : NSObject

+ (instancetype)sharedAsset;
/**
 *  按相片创建时间顺序读取缩略图
 *
 *  @param targetSize 图片尺寸
 *  @param completion 读取完成时调用,携带thumbnailsImages返回
 */
- (void)searchAllThumbnailsImagesSortByCreationDateWithSize:(CGSize)targetSize completion:(void (^)(NSArray *thumbnailsImages))completion;
- (UIImage *)objectAtIndex:(NSUInteger)index imageType:(LCPhotoImageSizeType)imageType;
@end
