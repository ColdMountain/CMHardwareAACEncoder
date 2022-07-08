//
//  ViewController.m
//  AppleHardwareAACEncoder
//
//  Created by ColdMountain on 2022/3/12.
//

#import "ViewController.h"

#import "AppleHardwareAACEncoder.h"

@interface ViewController ()<NSStreamDelegate>
@property (nonatomic, strong) AppleHardwareAACEncoder *encoder;

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSFileHandle  *auidoHandle;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.encoder = [[AppleHardwareAACEncoder alloc]init];
    
    self.fileManager = [NSFileManager defaultManager];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [path objectAtIndex:0];
    NSString *audio = [documentsDirectory stringByAppendingPathComponent:@"test_aac.aac"];
    [self.fileManager removeItemAtPath:audio error:nil];
    [self.fileManager createFileAtPath:audio contents:nil attributes:nil];
    self.auidoHandle = [NSFileHandle fileHandleForWritingAtPath:audio];
    
    NSString *paths = [[NSBundle mainBundle] pathForResource:@"test_pcm" ofType:@"pcm"];
    NSData *localData = [[NSData alloc] initWithContentsOfFile:paths];
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:localData];
    inputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
}

- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)eventCode {
    
    switch(eventCode) {
        case NSStreamEventOpenCompleted: // 文件打开成功
            NSLog(@"文件打开,准备读取数据");
            break;
        case NSStreamEventHasBytesAvailable: // 读取到数据
        {
            //每次读取2048个字节数据
            //因为AAC编码特性需要1024个采样点的数据一个采样点是2个字节
            //所以每次固定获取2048个字节的数据传入编码器
            uint8_t buf[2048];
            NSInteger readLength = [stream read:buf maxLength:2048];
            NSLog(@"输入的数据长度:%ld",readLength);
            if (readLength > 0) {
                AudioBufferList bufferList;
                bufferList.mBuffers[0].mData = buf;
                bufferList.mBuffers[0].mDataByteSize = (UInt32)readLength;
                bufferList.mBuffers[0].mNumberChannels = 1;
                
                [self.encoder encodeWithBufferList:bufferList completianBlock:^(NSData * _Nonnull encodedData, NSError * _Nonnull error) {
                    [self.auidoHandle writeData:encodedData];
                }];
            }else {
                NSLog(@"未读取到数据");
            }
            break;
        }
        case NSStreamEventEndEncountered: // 文件读取结束
        {
            NSLog(@"数据读取结束");
            [self.auidoHandle closeFile];
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            stream = nil;
            break;
        }
        default:
        break;
    }
    
}

@end
