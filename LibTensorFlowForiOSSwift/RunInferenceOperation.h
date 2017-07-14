//
//  RunInferenceOperation.h
//  LibTensorFlowForiOSSwift
//
//  Created by 邵伟男 on 2017/7/13.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static const NSString* WarningString = @"WARNING";


@interface EmojiValue : NSObject

@property (nonatomic, copy) NSString *emoji;
@property (nonatomic, assign) float confidence;

- (instancetype)initWithEmojiString:(NSString *)emoji
                         confidence:(float)confidence;

+ (instancetype)emojiValueWithEmojiString:(NSString *)emoji
                               confidence:(float)confidence;

@end


@interface RunInferenceOperation : NSObject

+ (instancetype)sharedInstance;

- (void)initModel;

- (nullable NSArray<EmojiValue *> *)runModelWith:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

