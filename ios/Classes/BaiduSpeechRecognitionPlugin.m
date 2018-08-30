#import "BaiduSpeechRecognitionPlugin.h"


//#error "请在官网新建应用，配置包名，并在此填写应用的 api key, secret key, appid(即appcode)"
const NSString* API_KEY = @"Ge2kYvna0IymBqcupFwq5fAV";
const NSString* SECRET_KEY = @"skMQOIKKmqLI2brAceEkadz9VgjO3KfR";
const NSString* APP_ID = @"11719380";

@interface BaiduSpeechRecognitionPlugin () <FlutterStreamHandler>

@property (strong, nonatomic) BDSEventManager *asrEventManager;
@property (nonatomic, assign) BOOL longSpeechFlag;
@property (nonatomic, strong) NSFileHandle *fileHandler;

@property (strong, nonatomic) FlutterResult flutterResult;
@property (copy, nonatomic) FlutterEventSink flutterEventSink;

@end

@implementation BaiduSpeechRecognitionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"baidu_speech_channel"
            binaryMessenger:[registrar messenger]];
    
    FlutterEventChannel* callback = [FlutterEventChannel eventChannelWithName:@"baidu_speech_callback"
             binaryMessenger:[registrar messenger]];
    
    BaiduSpeechRecognitionPlugin* instance = [[BaiduSpeechRecognitionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    [callback setStreamHandler:instance];
}

/**
 **  BDS Plugin 初始化
 **/
- (instancetype) init {
    
    NSLog(@"plugin init");
    self.asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
    [self.asrEventManager setDelegate:self];
    return self;
}

// Plugin 方法调用
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

    if ([@"speechInit" isEqualToString:call.method]) {
        
        [self configVoiceRecognitionClient];
        result(@"speech.init call");
        
    } else if ([@"speechStart" isEqualToString:call.method]) {
        
        [self start];
        result(@"speech.start call");

    } else if ([@"speechStop" isEqualToString:call.method]) {
        
        [self stop];
        result(@"speech.stop call");
        
    } else if ([@"speechCancel" isEqualToString:call.method]) {

        [self cancel];
        result(@"speech.cancel call");
        
    } else if ([@"speechStartLong" isEqualToString:call.method]) {
        
        [self longSpeechRecognition];
        result(@"speech.long call");
        
    } else {
        
        result(FlutterMethodNotImplemented);

    }
}

// 语音识别 配置
- (void)configVoiceRecognitionClient {
    //设置DEBUG_LOG的级别
    [self.asrEventManager setParameter:@(EVRDebugLogLevelError) forKey:BDS_ASR_DEBUG_LOG_LEVEL];
    //配置API_KEY 和 SECRET_KEY 和 APP_ID
    [self.asrEventManager setParameter:@[API_KEY, SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
    //配置端点检测（二选一）
    [self configModelVAD];
    //      [self configDNNMFE];
    
    //     [self.asrEventManager setParameter:@"15361" forKey:BDS_ASR_PRODUCT_ID];
    // ---- 语义与标点 -----
    [self enableNLU];
    //    [self enablePunctuation];
    // ------------------------
}

- (void)configModelVAD {
    NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    [self.asrEventManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
}

- (void) enableNLU {
    // ---- 开启语义理解 -----
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_NLU];
    [self.asrEventManager setParameter:@"1536" forKey:BDS_ASR_PRODUCT_ID];
}

// 开启 长语音识别
- (void)longSpeechRecognition
{
    self.longSpeechFlag = YES;
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    // 长语音请务必开启本地VAD
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
    [self start];
}

// 开启 语音 识别
- (void)start
{
    self.longSpeechFlag = NO;
    //[self configFileHandler];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
    //[self onInitializing];
}

// 结束 语音 识别
- (void) stop
{
    [self.asrEventManager sendCommand:BDS_ASR_CMD_STOP];
}

// 取消 语音 识别
- (void) cancel
{
    [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
}

// 录音 文件 保存
- (void)configFileHandler {
    self.fileHandler = [self createFileHandleWithName:@"recoder.pcm" isAppend:NO];
}

- (NSFileHandle *)createFileHandleWithName:(NSString *)aFileName isAppend:(BOOL)isAppend {
    NSFileHandle *fileHandle = nil;
    NSString *fileName = [self getFilePath:aFileName];
    
    int fd = -1;
    if (fileName) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]&& !isAppend) {
            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
        }
        
        int flags = O_WRONLY | O_APPEND | O_CREAT;
        fd = open([fileName fileSystemRepresentation], flags, 0644);
    }
    
    if (fd != -1) {
        fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
    }
    
    return fileHandle;
}

#pragma mark - Private: File

- (NSString *)getFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths && [paths count]) {
        return [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    } else {
        return nil;
    }
}

- (NSDictionary *)parseLogToDic:(NSString *)logString
{
    NSArray *tmp = NULL;
    NSMutableDictionary *logDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *items = [logString componentsSeparatedByString:@"&"];
    for (NSString *item in items) {
        tmp = [item componentsSeparatedByString:@"="];
        if (tmp.count == 2) {
            [logDic setObject:tmp.lastObject forKey:tmp.firstObject];
        }
    }
    return logDic;
}

- (NSString *)getDescriptionForDic:(NSDictionary *)dic {
    if (dic) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

// 识别 结果 事件 回调 函数
-(FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    self.flutterEventSink = events;
    return nil;
}

-(FlutterError*)onCancelWithArguments:(id)arguments {
    //self.flutterListening = NO;
    return nil;
}

#pragma mark - MVoiceRecognitionClientDelegate

- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj {
    
    //NSLog(@"client delegate func");
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    switch (workStatus) {
            
            // 可以开始 说话了
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            [returnDic setObject:@"ready" forKey:@"type"];
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            
            [returnDic setObject:@"meter" forKey:@"type"];
            [returnDic setObject:aObj forKey:@"value"];
            
            self.flutterEventSink([self getDescriptionForDic:returnDic]);
            break;
            
        }
            
            
        case EVoiceRecognitionClientWorkStatusStart: {
            //[self printLogTextView:@"CALLBACK: detect voice start point.\n"];
            [returnDic setObject:@"start" forKey:@"type"];
            
            self.flutterEventSink([self getDescriptionForDic:returnDic]);
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusEnd: {
            //[self printLogTextView:@"CALLBACK: detect voice end point.\n"];
            [returnDic setObject:@"end" forKey:@"type"];
            
            self.flutterEventSink([self getDescriptionForDic:returnDic]);
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusCancel: {
            //[self printLogTextView:@"CALLBACK: user press cancel.\n"];
            [returnDic setObject:@"cancel" forKey:@"type"];
            
            self.flutterEventSink([self getDescriptionForDic:returnDic]);
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
            [returnDic setObject:@"longSpeechEnd" forKey:@"type"];
            
            if (aObj != nil) {
                [returnDic setObject:aObj forKey:@"value"];
            }
            
            self.flutterEventSink([self getDescriptionForDic:returnDic]);
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusFinish: {
            
            if (!self.longSpeechFlag) {
                [returnDic setObject:@"finish" forKey:@"type"];
            } else {
                [returnDic setObject:@"lfinish" forKey:@"type"];
            }
            
            [returnDic setObject:aObj forKey:@"value"];
            
            self.flutterEventSink([self getDescriptionForDic:returnDic]);
            
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusError: {
            
            [returnDic setObject:@"error" forKey:@"type"];
            [returnDic setObject:aObj forKey:@"value"];
            break;
        }
    }
}

@end
