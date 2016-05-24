


//
//  LCPhotosViewController.m
//  LCPhotoAlbum
//
//  Created by 李策 on 16/5/11.
//  Copyright © 2016年 李策. All rights reserved.
//

#import "LCPhotosViewController.h"
#include <Photos/Photos.h>
#import "LCPhotoCollectionViewCell.h"
#import "LCPhotoKitAsset.h"

@interface LCPhotosViewController ()<UICollectionViewDataSource , UICollectionViewDelegate , LCPhotoCollectionViewCellDelegate>
{
    CGFloat SCREEN_WIDTH;
    CGFloat SCREEN_HEIGHT;
    CGFloat itemWH;
    CGFloat ScreenScale;
    UIView *scrollPanel;
    UIView *markView;
}

@property (nonatomic , strong) NSMutableArray *photosArray;
@property (nonatomic , strong) UICollectionView *myCollectionView;
@property (nonatomic , strong) UICollectionView *bigCollectionView;
@property (nonatomic , strong) LCPhotoKitAsset *photosAsset;
@property (nonatomic , assign) NSUInteger indexRow;
@end

@implementation LCPhotosViewController
- (NSMutableArray *)photosArray{
    if (!_photosArray) {
        _photosArray = [NSMutableArray array];
    }
    return _photosArray;
}
- (LCPhotoKitAsset *)photosAsset{
    if (!_photosAsset) {
        _photosAsset = [LCPhotoKitAsset sharedAsset];
    }
    return _photosAsset;
}
- (UICollectionView *)bigCollectionView{
    if (!_bigCollectionView) {
        //第一步 在创建collectionview之前 先创建它的约束 layout
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        
        //设置collectionview的滚动方向
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //实例化collectionview
        _bigCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,SCREEN_HEIGHT) collectionViewLayout:flowLayout];
        _bigCollectionView.pagingEnabled = YES;
        flowLayout.minimumLineSpacing = CGFLOAT_MIN;//行间距(最小值)
        flowLayout.minimumInteritemSpacing = CGFLOAT_MIN;//item间距(最小值)
        _bigCollectionView.backgroundColor = [UIColor clearColor];
        _bigCollectionView.delegate = self;
        
        _bigCollectionView.dataSource = self;
        
        //在IOS6以后 UICollectionViewCell的创建 都在这里写了
        [_bigCollectionView registerClass: [LCPhotoCollectionViewCell class]forCellWithReuseIdentifier:@"bigID"];
        
    }
    return _bigCollectionView;
}
-(UICollectionView *)myCollectionView{
    if (!_myCollectionView) {
        //第一步 在创建collectionview之前 先创建它的约束 layout
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        
        //设置collectionview的滚动方向
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        //实例化collectionview
        _myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,20, SCREEN_WIDTH,SCREEN_HEIGHT - 20) collectionViewLayout:flowLayout];
        flowLayout.minimumLineSpacing = 10.0;//行间距(最小值)
        flowLayout.minimumInteritemSpacing = 10.0;//item间距(最小值)
        _myCollectionView.backgroundColor = [UIColor clearColor];
        _myCollectionView.delegate = self;
        
        _myCollectionView.dataSource = self;
        
        //在IOS6以后 UICollectionViewCell的创建 都在这里写了
        [_myCollectionView registerClass: [LCPhotoCollectionViewCell class]forCellWithReuseIdentifier:@"ID"];
        
    }
    return _myCollectionView;
}
#pragma mark - 查询相册中的图片按时间排序
- (void)searchAllImagesWithDate{
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 获取所有资源的集合，并按资源的创建时间排序
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
            // 采取同步获取图片（只获得一次图片）
            PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
            imageOptions.synchronous = YES;
            
            for (PHAsset *asset in assetsFetchResults) {
                // 过滤非图片
                if (asset.mediaType != PHAssetMediaTypeImage) continue;
                
                // 图片原尺寸
                CGSize targetSize = CGSizeMake(itemWH * ScreenScale , itemWH * ScreenScale);
                // 请求图片
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    [self.photosArray addObject:result];
                }];
                
            }
            [self.myCollectionView reloadData];
        });
    }];

    
}
#pragma mark - 查询相册中的图片
/**
 * 查询所有的图片
 */
- (void)searchAllImages {
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 遍历所有的自定义相册
            PHFetchResult<PHAssetCollection *> *collectionResult0 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *collection in collectionResult0) {
                [self searchAllImagesInCollection:collection];
            }
            
            // 获得相机胶卷的图片
            PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *collection in collectionResult1) {
                if (![collection.localizedTitle isEqualToString:@"Camera Roll"]) continue;
                [self searchAllImagesInCollection:collection];
                break;
            }
        });
    }];
}

/**
 * 查询某个相册里面的所有图片
 */
- (void)searchAllImagesInCollection:(PHAssetCollection *)collection
{
    // 采取同步获取图片（只获得一次图片）
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    
    NSLog(@"相册名字：%@", collection.localizedTitle);
    
    // 遍历这个相册中的所有图片
    PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    for (PHAsset *asset in assetResult) {
        // 过滤非图片
        if (asset.mediaType != PHAssetMediaTypeImage) continue;
        
        // 图片原尺寸
        CGSize targetSize = CGSizeMake(itemWH * ScreenScale , itemWH * ScreenScale);
        // 请求图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"图片：%@ %@", result, [NSThread currentThread]);
            [self.photosArray addObject:result];
        }];
    }
    [self.myCollectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;;
    itemWH = (SCREEN_WIDTH - 50) /3;
    ScreenScale = [UIScreen mainScreen].scale;
    scrollPanel = [[UIView alloc]initWithFrame:self.view.frame];
    scrollPanel.backgroundColor = [UIColor clearColor];
    scrollPanel.alpha = 0.0;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:scrollPanel];
    
    
    markView = [[UIView alloc] initWithFrame:scrollPanel.bounds];
    markView.backgroundColor = [UIColor blackColor];
    markView.alpha = 0.0;
    [scrollPanel addSubview:markView];
    [scrollPanel addSubview:self.bigCollectionView];
    
    
    [self.view addSubview:self.myCollectionView];
    // 图片原尺寸
    CGSize targetSize = CGSizeMake(100 , 100);
    [self.photosAsset searchAllThumbnailsImagesSortByCreationDateWithSize:targetSize completion:^(NSArray *thumbnailsImages) {
        [self.photosArray addObjectsFromArray:thumbnailsImages];
        [self.myCollectionView reloadData];
    }];
//    [self searchAllImagesWithDate];
    //    // 列出所有相册智能相册
//    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//    
//    // 列出所有用户创建的相册
//    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
//    
    // Do any additional setup after loading the view.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.myCollectionView]) {
        LCPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ID" forIndexPath:indexPath];
        cell.photoImage = self.photosArray[indexPath.row];
        return cell;
    }else{
        LCPhotoCollectionViewCell *bigcell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bigID" forIndexPath:indexPath];
        bigcell.cellIndexRow = indexPath.row;
        bigcell.cell_Delegate = self;
        LCPhotoCollectionViewCell *cell1 = (LCPhotoCollectionViewCell *)[self.myCollectionView cellForItemAtIndexPath:indexPath];
        CGRect rect = [cell1 convertRect:cell1.bounds toView:self.view.window];
        [bigcell setUpOrientationImage:[self.photosAsset objectAtIndex:indexPath.row imageType:PreviewImage] WithFrame:rect andAnimationAtIndex:self.indexRow];

        return bigcell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(LCPhotoCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.bigCollectionView]) {
        
    }
}
//设置每个Item的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.myCollectionView]) {
        return CGSizeMake(itemWH, itemWH);
    }else{
        return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    }
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ([collectionView isEqual:self.myCollectionView]) {
        return UIEdgeInsetsMake(10, 10, 10,10);
    }else{
        return UIEdgeInsetsMake(0, 0, 0,0);
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.myCollectionView]) {
        [self.view bringSubviewToFront:scrollPanel];
        scrollPanel.alpha = 1.0;
        self.bigCollectionView.contentOffset = CGPointMake(SCREEN_WIDTH * indexPath.row, 0);
        self.indexRow = indexPath.row;
        [self.bigCollectionView reloadData];
}
    //    [self.photosAsset objectAtIndex:indexPath.row imageType:OrientationImage];
}
- (void)tapBigImageViewAtCell:(LCPhotoCollectionViewCell *)bigCell{
    scrollPanel.alpha = 0.0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
