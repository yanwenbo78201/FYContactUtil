//
//  FYContactUtil.h
//  FYContactUtil_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

/// 通讯录授权状态枚举
typedef NS_ENUM(NSInteger, FYContactsAuthStatus) {
    FYContactsAuthStatusNotDetermined = 0,  // 未决定
    FYContactsAuthStatusRestricted,         // 受限制
    FYContactsAuthStatusDenied,            // 拒绝
    FYContactsAuthStatusAuthorized,        // 已授权
    FYContactsAuthStatusLimited           // 限制访问 (iOS 18+)
} NS_SWIFT_NAME(ContactsAuthStatus);

NS_ASSUME_NONNULL_BEGIN

/// 通讯录工具类，提供通讯录权限管理和联系人数据获取功能
NS_SWIFT_NAME(ContactUtil)
@interface FYContactUtil : NSObject

/// 单例方法
+ (instancetype)sharedInstance NS_SWIFT_NAME(shared());

/// 请求通讯录权限
/// @param required 是否必须获取权限
/// @param completion 完成回调，result: 是否成功，status: 授权状态，shouldShowAlert: 是否需要显示提示框
- (void)requestContactsAuthorization:(BOOL)required 
                          completion:(void(^)(BOOL result, FYContactsAuthStatus status, BOOL shouldShowAlert))completion 
NS_SWIFT_NAME(requestAuthorization(required:completion:));

/// 获取当前通讯录授权状态
- (FYContactsAuthStatus)currentContactsAuthStatus NS_SWIFT_NAME(currentAuthStatus());

/// 获取联系人列表（分页）
/// @param limitCount 最大数量限制
/// @param batchSize 每批数量
/// @return 返回分组后的联系人数组，每个元素是一个包含联系人字典的数组
- (NSArray<NSArray<NSDictionary<NSString *, id> *> *> *)contactListWithLimitCount:(NSInteger)limitCount 
                                                                          batchSize:(NSInteger)batchSize 
NS_SWIFT_NAME(contactList(limitCount:batchSize:));

- (NSArray<NSArray<NSDictionary<NSString *, id> *> *> *)contactListPHWithLimitCount:(NSInteger)limitCount batchSize:(NSInteger)batchSize NS_SWIFT_NAME(contactPHList(limitCount:batchSize:));

@end

NS_ASSUME_NONNULL_END
