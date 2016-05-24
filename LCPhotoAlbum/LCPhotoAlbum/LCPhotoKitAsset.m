//
//  LCPhotoKitAsset.m
//  LCPhotoAlbum
//
//  Created by 李策 on 16/5/12.
//  Copyright © 2016年 李策. All rights reserved.
//

#import "LCPhotoKitAsset.h"

@interface LCPhotoKitAsset ()
{   CGFloat SCREEN_WIDTH;
    CGFloat SCREEN_HEIGHT;
    CGFloat ScreenScale;
    NSUInteger _currentIndex;
}
@property (nonatomic , strong) NSMutableArray *assetsArray;
@property (nonatomic , copy) void(^assetsFetchResultsBlock)(PHFetchResult *assetsFetchResults);
@end
/**
 *  - (UIImage *)thumbnailWithSize:(CGSize)size {
 if (_thumbnailImage) {
 return _thumbnailImage;
 }
 __block UIImage *resultImage;
 if (_usePhotoKit) {
 PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
 phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
 // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
 [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
 targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale)
 contentMode:PHImageContentModeAspectFill options:phImageRequestOptions
 resultHandler:^(UIImage *result, NSDictionary *info) {
 resultImage = result;
 }];
 } else {
 CGImageRef thumbnailImageRef = [_alAsset thumbnail];
 if (thumbnailImageRef) {
 resultImage = [UIImage imageWithCGImage:thumbnailImageRef];
 }
 }
 _thumbnailImage = resultImage;
 return resultImage;
 }
 
 - (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *))completion {
 if (_usePhotoKit) {
 if (_thumbnailImage) {
 if (completion) {
 completion(_thumbnailImage, nil);
 }
 return 0;
 } else {
 PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
 imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
 // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
 return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
 // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _thumbnailImage 中
 BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
 if (downloadFinined) {
 _thumbnailImage = result;
 }
 if (completion) {
 completion(result, info);
 }
 }];
 }
 } else {
 if (completion) {
 completion([self thumbnailWithSize:size], nil);
 }
 return 0;
 }
 }
 */
@implementation LCPhotoKitAsset
#pragma  mark - 设置单例
static id _instance;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedAsset
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}
- (NSMutableArray *)assetsArray{
    if (!_assetsArray) {
        _assetsArray = [NSMutableArray array];
    }
    return _assetsArray;
}
- (instancetype)init{
    if (self = [super init]) {
        ScreenScale = [UIScreen mainScreen].scale;
        SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
        SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
        // 判断授权状态
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                // 获取所有资源的集合，并按资源的创建时间排序
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
              PHFetchResult *Results = [PHAsset fetchAssetsWithOptions:options];
                for (PHAsset *asset in Results) {
                    // 过滤非图片
                    if (asset.mediaType != PHAssetMediaTypeImage) continue;
                    [self.assetsArray addObject:asset];
                }
                self.assetsFetchResultsBlock(Results);
                dispatch_async(dispatch_get_main_queue(), ^{
                // 采取同步获取图片（只获得一次图片）
                PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
                /**
                 *   PHImageRequestOptions 的 synchronous 属性，让 requestImage... 系列的方法变成同步操作。注意：当synchronous 设为 true 时，deliveryMode 属性就会被忽略，并被当作 .HighQualityFormat 来处理。
                 */
                        imageOptions.synchronous = YES;
                /**
                 *  在设置这些参数时，一定要考虑到你的一些用户有可能开启了 iCloud 照片库，这点非常重要。PhotoKit 的 API 不一定会对设备的照片和 iCloud 上照片进行区分 —— 它们都用同一个 requestImage 方法来加载。这意味着任意一个图像请求都有可能是一个通过蜂窝网络来进行的非常缓慢的网络请求。当你要用 .HighQualityFormat 或者做一个同步请求的时候，要牢记这个。注意：如果你想要确保请求不经过网络，可以将 networkAccessAllowed 设为 false
                 */
                imageOptions.networkAccessAllowed = NO;
                /**
                 *  默认情况下，如果图像管理器决定要用最优策略，那么它会在将图像的高质量版本递送给你之前，先传递一个较低质量的版本。你可以通过 deliveryMode 属性来控制这个行为；上面所描述的默认行为的值为 .Opportunistic。如果你只想要高质量的图像，并且可以接受更长的加载时间，那么将属性设置为 .HighQualityFormat。如果你想要更快的加载速度，且可以牺牲一点图像质量，那么将属性设置为 .FastFormat。
                 */
                imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
                
               
                });
            });
        }];

    }
    return self;
}
- (void)searchAllThumbnailsImagesSortByCreationDateWithSize:(CGSize)targetSize completion:(void (^)(NSArray * thumbnailsImages))completion{
        [self setAssetsFetchResultsBlock:^(PHFetchResult *assetsFetchResults) {
            NSMutableArray *thumbnailsImages = [NSMutableArray array];
            // 采取同步获取图片（只获得一次图片）
            PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
            /**
             *   PHImageRequestOptions 的 synchronous 属性，让 requestImage... 系列的方法变成同步操作。注意：当synchronous 设为 true 时，deliveryMode 属性就会被忽略，并被当作 .HighQualityFormat 来处理。
             */
            imageOptions.synchronous = YES;
            /**
             *  在设置这些参数时，一定要考虑到你的一些用户有可能开启了 iCloud 照片库，这点非常重要。PhotoKit 的 API 不一定会对设备的照片和 iCloud 上照片进行区分 —— 它们都用同一个 requestImage 方法来加载。这意味着任意一个图像请求都有可能是一个通过蜂窝网络来进行的非常缓慢的网络请求。当你要用 .HighQualityFormat 或者做一个同步请求的时候，要牢记这个。注意：如果你想要确保请求不经过网络，可以将 networkAccessAllowed 设为 false
             */
            imageOptions.networkAccessAllowed = NO;
            /**
             *  默认情况下，如果图像管理器决定要用最优策略，那么它会在将图像的高质量版本递送给你之前，先传递一个较低质量的版本。你可以通过 deliveryMode 属性来控制这个行为；上面所描述的默认行为的值为 .Opportunistic。如果你只想要高质量的图像，并且可以接受更长的加载时间，那么将属性设置为 .HighQualityFormat。如果你想要更快的加载速度，且可以牺牲一点图像质量，那么将属性设置为 .FastFormat。
             */
            imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            imageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;

        for (PHAsset *asset in assetsFetchResults) {
            // 过滤非图片
            if (asset.mediaType != PHAssetMediaTypeImage) continue;
            CGSize size = CGSizeMake(125 , 125 );
//            NSLog(@"%@",NSStringFromCGSize(size));
            // 请求图片
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [thumbnailsImages addObject:result];
            }];
        }
        completion(thumbnailsImages);
    }];
    
}
static     UIImage *image;
static UIImage *prior_Image = nil;
static UIImage *current_Image = nil;
static UIImage *after_Image = nil;
//NSUInteger _targetIndex; // index 目标值，拉取资源直到这个值就手工停止拉取
//NSUInteger _currentIndex; // 当前 index，每次拉取资源时从这个值开始

- (UIImage *)objectAtIndex:(NSUInteger)index imageType:(LCPhotoImageSizeType)imageType{
    
   
    
    return [self imageAtIndex:index imageType:PreviewImage];
   
}
- (UIImage *)imageAtIndex:(NSUInteger)index imageType:(LCPhotoImageSizeType)imageType{
    PHAsset *asset = self.assetsArray[index];
    CGSize targetSize = CGSizeZero;
    if (imageType == PreviewImage) {
        targetSize = CGSizeMake( SCREEN_WIDTH * ScreenScale, SCREEN_HEIGHT * ScreenScale);
    }else{
        targetSize = PHImageManagerMaximumSize;
    }
    // 采取同步获取图片（只获得一次图片）
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    imageOptions.synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = result;
    }];
    NSData *pngdata = UIImagePNGRepresentation(image);
    CGFloat pngData = pngdata.length/1024.00;
    if (pngData > 1024) {
        pngData = pngData/10240.00;
    }
    NSLog(@"%@ -- %f",image , pngData);
    
    return image;

}
@end