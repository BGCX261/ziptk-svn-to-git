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

#import "KeychainPasswordKeeper.h"

#define kKeychainUserName @"KeychainPasswordKeeper";
#define kKeychainServiceName [[NSBundle mainBundle] bundleIdentifier];

@interface KeychainPasswordKeeper (Private_API)
- (NSString *)userName;
- (NSString *)serviceName;
@end

@implementation KeychainPasswordKeeper

@synthesize optionalUserName;
@synthesize optionalServiceName;

- (void)dealloc {
    [optionalUserName release];
    [optionalServiceName release];
    [super dealloc];
}

- (NSString *)userName {
    return self.optionalUserName != nil ? 
            self.optionalUserName :
            kKeychainUserName;
}

- (NSString *)serviceName {
    return self.optionalServiceName != nil ? 
            self.optionalServiceName :
            kKeychainServiceName;
}

- (void)keepPassword:(NSString *)password {

    if ([self isKeepingPassword] == YES) {
        return NO;
    }

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
     self.serviceName,
     self.serviceName,
     self.userName,
     [password dataUsingEncoding:NSUTF8StringEncoding],
     nil];

    NSDictionary *query =
    [[NSDictionary alloc] initWithObjects:queryObjects
                                  forKeys:queryKeys];

    [queryKeys release];
    [queryObjects release];

    SecItemAdd((CFDictionaryRef)query, NULL);

    [query release];
    
    return YES;
}

- (BOOL)isKeepingPassword {

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
     self.serviceName,
     self.serviceName,
     self.userName,
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

- (BOOL)passwordKeptIs:(NSString *)password {

    if (password == nil) {
        return NO;
    }

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
     self.serviceName,
     self.serviceName,
     self.userName,
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

    return [password caseInsensitiveCompare:passwordKept] == NSOrderedSame;
}

- (BOOL)forgetPassword:(NSString *)password {
    
    if ([self passwordKeptIs:password] == NO) {
        return NO;
    }

    NSArray *queryKeys =
    [[NSArray alloc] initWithObjects:
     (NSString *)kSecClass, 
     kSecAttrService, 
     kSecAttrLabel, 
     kSecAttrAccount, 
     kSecValueData, //TODO: This should be optional.
     nil];

    NSArray *queryObjects =
    [[NSArray alloc] initWithObjects:
     (NSString *)kSecClassGenericPassword, 
     self.serviceName,
     self.serviceName,
     self.userName,
     [password dataUsingEncoding:NSUTF8StringEncoding], //TODO: If this was optional.
     nil];

    NSDictionary *query =
    [[NSDictionary alloc] initWithObjects:queryObjects
                                  forKeys:queryKeys];

    [queryKeys release];
    [queryObjects release];

    OSStatus status =
    SecItemDelete((CFDictionaryRef)query);

    [query release];

    return status == errSecSuccess;
}

- (BOOL)changePasswordKept:(NSString *)password with:(NSString *)newPassword {

    if ([self passwordKeptIs:password] == NO) {
        return NO;
    }

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
     self.serviceName,
     self.serviceName,
     self.userName,
     [password dataUsingEncoding:NSUTF8StringEncoding],
     nil];

    NSDictionary *query =
    [[NSDictionary alloc] initWithObjects:queryObjects
                                  forKeys:queryKeys];

    [queryKeys release];
    [queryObjects release];

    NSDictionary *newPasswordDictionary =
    [NSDictionary dictionaryWithObject:[newPassword dataUsingEncoding:NSUTF8StringEncoding]
                                forKey:(NSString *)kSecValueData];

    OSStatus status =
    SecItemUpdate((CFDictionaryRef)query,
                  (CFDictionaryRef)newPasswordDictionary);

    [query release];

    return status == errSecSuccess;
}

@end
