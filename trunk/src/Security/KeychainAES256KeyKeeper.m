//
//  Copyright 2010 Zerously.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  

#import "KeychainAES256KeyKeeper.h"

#define kKeychainUserName @"KeychainAES256KeyKeeper"
#define kKeychainServiceName [[NSBundle mainBundle] bundleIdentifier]

@interface KeychainAES256KeyKeeper (Private_API)
+ (BOOL)hasKey;
+ (NSString *)getKey;
+ (void)keepKey:(NSString *)key;
+ (NSString *)generateKey;
@end

@implementation KeychainAES256KeyKeeper

#pragma mark -
#pragma mark KeychainAES256KeyKeeper Private_API
+ (BOOL)hasKey {
    NSArray *queryKeys =
    [[NSArray alloc] initWithObjects:
     (NSString *)kSecClass, 
     kSecAttrService, 
     kSecAttrLabel, 
     kSecAttrAccount, 
     nil];

    NSArray *queryObjects =
    [[NSArray alloc] initWithObjects:
     (NSString *)kSecClassGenericPassword, 
     kKeychainServiceName,
     kKeychainServiceName,
     kKeychainUserName,
     nil];

    NSDictionary *query =
    [[NSDictionary alloc] initWithObjects:queryObjects
                                  forKeys:queryKeys];

    [queryKeys release];
    [queryObjects release];

    OSStatus status =
    SecItemCopyMatching((CFDictionaryRef)query, NULL);

    [query release];

    return status == errSecSuccess;
}

+ (NSString *)getKey {
    NSArray *queryKeys =
    [[NSArray alloc] initWithObjects:
     (NSString *)kSecClass, 
     kSecAttrService, 
     kSecAttrLabel, 
     kSecAttrAccount,
     kSecReturnData,
     nil];

    NSArray *queryObjects =
    [[NSArray alloc] initWithObjects:
     (NSString *)kSecClassGenericPassword, 
     kKeychainServiceName,
     kKeychainServiceName,
     kKeychainUserName,
     kCFBooleanTrue,
     nil];

    NSDictionary *query =
    [[NSDictionary alloc] initWithObjects:queryObjects
                                  forKeys:queryKeys];

    [queryKeys release];
    [queryObjects release];

    NSData *passwordData = NULL;
    SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&passwordData);
    
    [query release];

    NSString *passwordKept =
    [[[NSString alloc] initWithBytes:[passwordData bytes]
                              length:[passwordData length] 
                            encoding:NSUTF8StringEncoding] autorelease];

    return passwordKept;
}

+ (void)keepKey:(NSString *)key {
    NSArray *queryKeys =
    [[NSArray alloc] initWithObjects:
     (NSString *)kSecClass, 
     kSecAttrService, 
     kSecAttrLabel, 
     kSecAttrAccount, 
     kSecValueData, 
     nil];

    NSArray *queryObjects =
    [[NSArray alloc] initWithObjects:
     (NSString *)kSecClassGenericPassword, 
     kKeychainServiceName,
     kKeychainServiceName,
     kKeychainUserName,
     [key dataUsingEncoding:NSUTF8StringEncoding],
     nil];

    NSDictionary *query =
    [[NSDictionary alloc] initWithObjects:queryObjects
                                  forKeys:queryKeys];

    [queryKeys release];
    [queryObjects release];

    SecItemAdd((CFDictionaryRef)query, NULL);

    [query release];
}

+ (NSString *)generateKey {

    unichar bytes[32];

    for (int i = 0; i < 32; i++) {
        bytes[i] = random() % 256;
    }

    return [NSString stringWithCharacters:bytes length:32];
}

#pragma mark KeychainAES256KeyKeeper
+ (NSString *)getAES256Key {
    if ([KeychainAES256KeyKeeper hasKey] == YES) {
        return [KeychainAES256KeyKeeper getKey];
    } else {
        NSString *generatedKey =
        [KeychainAES256KeyKeeper generateKey];

        [KeychainAES256KeyKeeper keepKey:generatedKey];

        return generatedKey;
    }
}

@end
