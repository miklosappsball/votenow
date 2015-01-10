//
//  PushData.h
//  Peepapp
//
//  Created by Andris Konfar on 02/10/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushData : NSObject

@property NSString* pushId;
@property NSString* phoneNumber;
@property NSString* name;
@property NSString* msg;
@property BOOL answer;

- (instancetype)initFromDictionary:(NSDictionary*) userInfo;
- (NSDictionary*) dictionaryRepr;

@end
