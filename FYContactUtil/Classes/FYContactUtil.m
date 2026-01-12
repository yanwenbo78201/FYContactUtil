//
//  FYContactUtil.m
//  FYContactUtil_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import "FYContactUtil.h"
#import <AddressBook/AddressBook.h>

@implementation FYContactUtil

+ (instancetype)sharedInstance {
    static FYContactUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FYContactUtil alloc] init];
    });
    return instance;
}
- (void)requestContactsAuthorization:(BOOL)required completion:(void(^)(BOOL result, FYContactsAuthStatus status, BOOL shouldShowAlert))completion {
    
    FYContactsAuthStatus currentStatus = [self currentContactsAuthStatus];
    switch (currentStatus) {
        case FYContactsAuthStatusNotDetermined: {
            // 首次获取权限
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  
                    if (granted) {
                        // 首次获取，如果是同意
                        FYContactsAuthStatus newStatus = [self currentContactsAuthStatus];
                        
                        if (@available(iOS 18.0, *)) {
                            if (newStatus == FYContactsAuthStatusLimited) {
                                
                                // 查看当前状态在iOS18下是否是.limited
                                if (required) {
                                    completion(NO, newStatus, NO);
                                } else {
                                    // 不是必须获取通讯录，回调成功，将对应状态返回，不调用二次弹框方法
                                    completion(YES, newStatus, NO);
                                }
                            } else {
                                completion(YES, newStatus, NO);
                            }
                        } else {
                            // iOS 18以下，如果不是.limited，回调成功，将对应状态返回，不调用二次弹框方法
                            completion(YES, newStatus, NO);
                        }
                    } else {
                       
                        // 首次获取，如果是不同意
                        FYContactsAuthStatus newStatus = [self currentContactsAuthStatus];
                        if (required) {
                            completion(NO, newStatus, NO);
                        } else {
                            // 如果是非必须获取，回调成功，将对应状态返回，不调用二次弹框方法
                            completion(YES, newStatus, NO);
                        }
                    }
                });
            }];
            break;
        }
        case FYContactsAuthStatusRestricted:
        case FYContactsAuthStatusDenied:
        case FYContactsAuthStatusLimited: {
            if (required) {
                // 如果是必须获取通讯录，回调失败，将对应状态返回，调用二次弹框方法
                completion(NO, currentStatus, YES);
            } else {
                completion(YES, currentStatus, NO);
            }
            break;
        }
        case FYContactsAuthStatusAuthorized: {
            completion(YES, currentStatus, NO);
            break;
        }
    }
}

- (FYContactsAuthStatus)currentContactsAuthStatus {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    switch (status) {
        case CNAuthorizationStatusNotDetermined:
            return FYContactsAuthStatusNotDetermined;
        case CNAuthorizationStatusRestricted:
            return FYContactsAuthStatusRestricted;
        case CNAuthorizationStatusDenied:
            return FYContactsAuthStatusDenied;
        case CNAuthorizationStatusAuthorized:
            return FYContactsAuthStatusAuthorized;
        default:
            if (@available(iOS 18.0, *)) {
                // iOS 18+ 可能有Limited状态
                if (status == CNAuthorizationStatusLimited) { // CNAuthorizationStatusLimited value is 4
                    return FYContactsAuthStatusLimited;
                }
            }
            return FYContactsAuthStatusNotDetermined;
    }
}

- (NSArray<NSArray<NSDictionary<NSString *, id> *> *> *)contactListWithLimitCount:(NSInteger)limitCount batchSize:(NSInteger)batchSize {
    NSArray<NSDictionary<NSString *, id> *> *allContacts = [self validContacts];
    // 如果联系人数据长度超过limitCount，进行截取
    if (allContacts.count > limitCount) {
        allContacts = [allContacts subarrayWithRange:NSMakeRange(0, limitCount)];
    }
    
    // 根据batchSize分组
    NSMutableArray<NSArray<NSDictionary<NSString *, id> *> *> *groupedArray = [NSMutableArray array];
    NSInteger totalCount = allContacts.count;
    
    for (NSInteger i = 0; i < totalCount; i += batchSize) {
        NSInteger endIndex = MIN(i + batchSize, totalCount);
        NSArray<NSDictionary<NSString *, id> *> *subArray = [allContacts subarrayWithRange:NSMakeRange(i, endIndex - i)];
        [groupedArray addObject:subArray];
    }
    
    return groupedArray;
}

#pragma mark - Contacts Data Processing Methods

- (NSArray<NSDictionary<NSString *, id> *> *)validContacts {
    NSArray<NSDictionary<NSString *, id> *> *allContacts = [self allContacts];
    NSMutableArray<NSDictionary<NSString *, id> *> *validContacts = [NSMutableArray array];
    NSMutableArray<NSString *> *processedPhones = [[NSMutableArray alloc] init];
    
    for (NSDictionary<NSString *, id> *contactDict in allContacts) {
        NSString *contactName = [self extractContactNameFromDict:contactDict];
        
        if (contactName.length == 0) {
            continue;
        }
        
        NSArray<NSString *> *phoneArray = [contactDict objectForKey:@"phoneArray"];
        [self processContactPhones:phoneArray
                        contactName:contactName
                        contactDict:contactDict
                      validContacts:validContacts
                    processedPhones:processedPhones];
    }
    
    return validContacts;
}

- (NSArray<NSDictionary<NSString *, id> *> *)allContacts {
    if (![self isContactsAccessAuthorized]) {
        return @[];
    }
    
    NSMutableArray<NSDictionary<NSString *, id> *> *allContacts = [NSMutableArray array];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef contactsArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    long contactsCount = CFArrayGetCount(contactsArray);
    
    for (int i = 0; i < contactsCount; i++) {
        ABRecordRef personRecord = CFArrayGetValueAtIndex(contactsArray, i);
        NSDictionary<NSString *, id> *contactDict = [self extractContactInfoFromRecord:personRecord];
        [allContacts addObject:contactDict];
    }
    
    CFRelease(contactsArray);
    CFRelease(addressBook);
    return allContacts;
}

#pragma mark - Contacts Helper Methods

- (BOOL)isContactsAccessAuthorized {
    CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if (@available(iOS 18.0, *)) {
        return (authStatus == CNAuthorizationStatusAuthorized || authStatus == CNAuthorizationStatusLimited);
    } else {
        return (authStatus == CNAuthorizationStatusAuthorized);
    }
}

- (NSString *)extractContactNameFromDict:(NSDictionary<NSString *, id> *)contactDict {
    NSString *firstName = [contactDict objectForKey:@"firstName"] ?: @"";
    NSString *lastName = [contactDict objectForKey:@"lastName"] ?: @"";
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
    return [fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)processContactPhones:(NSArray<NSString *> *)phoneArray
                 contactName:(NSString *)contactName
                 contactDict:(NSDictionary<NSString *, id> *)contactDict
               validContacts:(NSMutableArray<NSDictionary<NSString *, id> *> *)validContacts
             processedPhones:(NSMutableArray<NSString *> *)processedPhones {
    
    for (NSString *phoneStr in phoneArray) {
        NSString *cleanedPhone = [self cleanPhoneNumber:phoneStr];
        
        if ([self isValidPhoneNumber:cleanedPhone]) {
            NSString *formattedPhone = [self formatPhoneNumber:cleanedPhone];
            
            if (![processedPhones containsObject:formattedPhone]) {
                [processedPhones addObject:formattedPhone];
                
                NSDictionary<NSString *, id> *contactInfo = [self createContactInfo:contactName
                                                         phoneNumber:formattedPhone
                                                         contactDict:contactDict];
                [validContacts addObject:contactInfo];
            }
        }
    }
}

- (NSString *)cleanPhoneNumber:(NSString *)phoneNumber {
    if (!phoneNumber) {
        return @"";
    }
    
    NSString *trimmedPhone = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSCharacterSet *digitsOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSArray *digitComponents = [trimmedPhone componentsSeparatedByCharactersInSet:[digitsOnly invertedSet]];
    return [digitComponents componentsJoinedByString:@""];
}

- (BOOL)isValidPhoneNumber:(NSString *)phoneNumber {
    NSPredicate *phonePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(91[6-9]\\d{9}|910[6-9]\\d{9}|[6-9]\\d{9}|0[6-9]\\d{9})$"];
    return [phonePredicate evaluateWithObject:phoneNumber];
}

- (NSString *)formatPhoneNumber:(NSString *)phoneNumber {
    NSString *formattedPhone = phoneNumber;
    
    if (formattedPhone.length == 13 && [formattedPhone hasPrefix:@"910"]) {
        formattedPhone = [formattedPhone substringFromIndex:3];
    } else if (formattedPhone.length == 12 && [formattedPhone hasPrefix:@"91"]) {
        formattedPhone = [formattedPhone substringFromIndex:2];
    } else if (formattedPhone.length == 11 && [formattedPhone hasPrefix:@"0"]) {
        formattedPhone = [formattedPhone substringFromIndex:1];
    }
    
    return formattedPhone;
}

- (NSDictionary<NSString *, id> *)createContactInfo:(NSString *)contactName
                        phoneNumber:(NSString *)phoneNumber
                        contactDict:(NSDictionary<NSString *, id> *)contactDict {
    
    NSDate *contactDate = [contactDict objectForKey:@"alterTime"];
    NSString *contactUpdateTime = @"";
    
    if (contactDate) {
        long long timestamp = (long long)([contactDate timeIntervalSince1970] * 1000);
        contactUpdateTime = [NSString stringWithFormat:@"%lld", timestamp];
    }
    
    return @{
        @"contactName": contactName,
        @"centre": phoneNumber,
        @"history": contactUpdateTime,
        @"contactStorage": @"1",
        @"condense": @"-99",
        @"zone": @""
    };
}

- (NSDictionary<NSString *, id> *)extractContactInfoFromRecord:(ABRecordRef)personRecord {
    NSMutableDictionary<NSString *, id> *contactDict = [NSMutableDictionary new];
    
    // 提取姓名
    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(personRecord, kABPersonFirstNameProperty));
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(personRecord, kABPersonLastNameProperty));
    [contactDict setValue:firstName forKey:@"firstName"];
    [contactDict setValue:lastName forKey:@"lastName"];
    
    // 提取电话号码
    NSMutableArray<NSString *> *phoneList = [self extractPhoneNumbersFromRecord:personRecord];
    [contactDict setValue:phoneList forKey:@"phoneArray"];
    
    // 提取时间信息
    NSDate *createTime = (__bridge NSDate *)(ABRecordCopyValue(personRecord, kABPersonCreationDateProperty));
    NSDate *modifyTime = (__bridge NSDate *)(ABRecordCopyValue(personRecord, kABPersonModificationDateProperty));
    [contactDict setValue:createTime forKey:@"creatTime"];
    [contactDict setValue:modifyTime forKey:@"alterTime"];
    
    return contactDict;
}

- (NSMutableArray<NSString *> *)extractPhoneNumbersFromRecord:(ABRecordRef)personRecord {
    NSMutableArray<NSString *> *phoneList = [[NSMutableArray alloc] init];
    ABMultiValueRef phones = ABRecordCopyValue(personRecord, kABPersonPhoneProperty);
    
    for (NSInteger j = 0; j < ABMultiValueGetCount(phones); j++) {
        NSString *phoneNumber = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
        if (phoneNumber) {
            [phoneList addObject:phoneNumber];
        }
    }
    
    CFRelease(phones);
    return phoneList;
}


@end
