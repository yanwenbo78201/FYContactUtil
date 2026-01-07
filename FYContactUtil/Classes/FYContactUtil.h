//
//  FYContactUtil.h
//  FYContactUtil_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
typedef NS_ENUM(NSInteger, FYContactsAuthStatus) {
    FYContactsAuthStatusNotDetermined = 0,  // 未决定
    FYContactsAuthStatusRestricted,         // 受限制
    FYContactsAuthStatusDenied,            // 拒绝
    FYContactsAuthStatusAuthorized,        // 已授权
    FYContactsAuthStatusLimited           // 限制访问 (iOS 18+)
};

NS_ASSUME_NONNULL_BEGIN

@interface FYContactUtil : NSObject

/// 请求通讯录权限
/// @param required 是否必须获取权限
/// @param completion 完成回调，result: 是否成功，status: 授权状态，shouldShowAlert: 是否需要显示提示框
- (void)requestContactsAuthorization:(BOOL)required completion:(void(^)(BOOL result, FYContactsAuthStatus status, BOOL shouldShowAlert))completion;

/// 获取当前通讯录授权状态
- (FYContactsAuthStatus)currentContactsAuthStatus;

/// 获取联系人列表（分页）
/// @param limitCount 最大数量限制
/// @param batchSize 每批数量
- (NSArray *)contactListWithLimitCount:(NSInteger)limitCount batchSize:(NSInteger)batchSize;

@end

NS_ASSUME_NONNULL_END
