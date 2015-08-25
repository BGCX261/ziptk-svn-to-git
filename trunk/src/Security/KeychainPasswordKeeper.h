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

#import <Foundation/Foundation.h>


@interface KeychainPasswordKeeper : NSObject {
    NSString *optionalUserName;
    NSString *optionalServiceName;
}

@property (nonatomic, retain) NSString *optionalUserName;
@property (nonatomic, retain) NSString *optionalServiceName;

- (BOOL)keepPassword:(NSString *)password;          //Returns NO if keeper was previously keeping password.
- (BOOL)isKeepingPassword;
- (BOOL)passwordKeptIs:(NSString *)password;
- (BOOL)forgetPassword:(NSString *)password;        //Returns NO if password is not the one being kept.
- (BOOL)changePasswordKept:(NSString *)password
                      with:(NSString *)newPassword; //Returns NO if password is not the one being kept.

@end
