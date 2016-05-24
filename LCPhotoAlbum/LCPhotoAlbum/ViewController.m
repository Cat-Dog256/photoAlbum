//
//  ViewController.m
//  LCPhotoAlbum
//
//  Created by 李策 on 16/3/21.
//  Copyright © 2016年 李策. All rights reserved.
//

#import "ViewController.h"
#import "LCPhotosViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()
{
    ALAssetsLibrary *_assetsLibrary;
    NSMutableArray *_albumsArray;
    NSMutableArray *_imagesAssetArray;
}
- (IBAction)btsPressAction:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *tipTextWhenNoPhotosAuthorization; // 提示语
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        // 展示提示语
    }
//    _assetsLibrary = [[ALAssetsLibrary alloc] init];
//    _albumsArray = [[NSMutableArray alloc] init];
//    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        if (group) {
//            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//            if (group.numberOfAssets > 0) {
//                [self loadAssetWithAssetsGroup:group];
//                // 把相册储存到数组中，方便后面展示相册时使用
//                [_albumsArray addObject:group];
//            }
//        } else {
//            if ([_albumsArray count] > 0) {
//                // 把所有的相册储存完毕，可以展示相册列表
//            } else {
//                // 没有任何有资源的相册，输出提示
//            }
//        }
//    } failureBlock:^(NSError *error) {
//        NSLog(@"Asset group not found!\n");
//    }];
    
    ALAssetsLibrary *_assetsLibrary = [[ALAssetsLibrary alloc] init];
    
//    photoImages = [[NSMutableArray alloc] init];
//    selectedIndexPaths = [[NSMutableArray alloc]init];
    ///ALAssetsGroupLibrary
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos|ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
//                ALAssetRepresentation *representation = [result defaultRepresentation];
//                // 获取资源图片的 fullScreenImage
//                UIImage *contentImage = [UIImage imageWithCGImage:[representation fullScreenImage]];
//                 UIImage *fullImage = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                UIImage *img = [UIImage imageWithCGImage:result.thumbnail];
               
                if(img)
                {
                    NSLog(@"%@",img);
//                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//                    [dic setObject:img forKey:@"img"];
//                    [dic setObject:@"0" forKey:@"flag"];
//                    [photoImages addObject:dic];
                }
                if(index + 1 == group.numberOfAssets)
                {
                    ///最后一个刷新界面
//                    [self finish];
                }
            }
        }];
    } failureBlock:^(NSError *error) {
        // error
        NSLog(@"error ==> %@",error.localizedDescription);
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}
NSUInteger _targetIndex; // index 目标值，拉取资源直到这个值就手工停止拉取
NSUInteger _currentIndex; // 当前 index，每次拉取资源时从这个值开始

- (void)loadAssetWithAssetsGroup:(ALAssetsGroup *)assetsGroup {
    [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        // 获取资源图片的详细资源信息，其中 imageAsset 是某个资源的 ALAsset 对象
        ALAssetRepresentation *representation = [result defaultRepresentation];
        // 获取资源图片的 fullScreenImage
        UIImage *contentImage = [UIImage imageWithCGImage:[representation fullScreenImage]];
        NSLog(@"%@",contentImage);

    }];

    [assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        [_imagesAssetArray addObject:result];

//        _currentIndex = index;
//        if (index > _targetIndex) {
//            // 拉取资源的索引如果比目标值大，则停止拉取
//            *stop = YES;
//        } else {
//            if (result) {
//                [_imagesAssetArray addObject:result];
//            } else {
//                // result 为 nil，即遍历相片或视频完毕
//            }
//        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btsPressAction:(UIButton *)sender {
    LCPhotosViewController *photosVC = [[LCPhotosViewController alloc]init];
    [self presentViewController:photosVC animated:YES completion:nil];
}
@end
