//
//  AnswerAncestor.h
//  Feedback
//
//  Created by Andris Konfar on 23/07/14.
//  Copyright (c) 2014 Andris Konfar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SEPARATOR_CHARACTER @"|"

@interface AnswerAncestor : NSObject

@property (nonatomic,strong) NSString* errorMessage;
@property (nonatomic,strong) NSString* value;

- (id)initWithAnswerString:(NSString*) string;

- (BOOL) isError;
- (BOOL) showError;

@end
