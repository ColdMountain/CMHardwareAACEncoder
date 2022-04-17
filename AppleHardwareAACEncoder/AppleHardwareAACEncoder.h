//
//  AppleHardwareAACEncoder.h
//  AppleHardwareAACEncoder
//
//  Created by ColdMountain on 2022/3/12.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppleHardwareAACEncoder : NSObject

- (void)encodeWithBufferList:(AudioBufferList)bufferList completianBlock:(void (^)(NSData *encodedData, NSError *error))completionBlock;

@end

NS_ASSUME_NONNULL_END
