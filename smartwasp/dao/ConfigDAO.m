//
//  AppDelegate.h
//  smartwasp
//
//  Created by luotao on 2021/4/16.
//
#import "ConfigDAO.h"

@interface ConfigDAO()

@property (nonatomic,strong) NSString *plistFilePath;

@end


@implementation ConfigDAO

static ConfigDAO *sharedSingleton = nil;

+ (ConfigDAO *)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
        //初始化沙箱目录中属性列表文件路径
        sharedSingleton.plistFilePath = [sharedSingleton applicationDocumentsDirectoryFile];
        //初始化属性列表文件
        [sharedSingleton createEditableCopyOfDatabaseIfNeeded];
    });
    return sharedSingleton;
}

//初始化属性列表文件
- (void)createEditableCopyOfDatabaseIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExits = [fileManager fileExistsAtPath:self.plistFilePath];
    if (!isExits) {
        [fileManager createFileAtPath:self.plistFilePath contents:nil attributes:nil];
    }
}

- (NSString *)applicationDocumentsDirectoryFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, TRUE) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"Config.plist"];
    return path;
}

//插入kv方法
-(BOOL) setKey:(NSString*)key forValue:(NSString*) value{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.plistFilePath] ;
    if(!dict){
        dict = [[NSMutableDictionary alloc] init];
    }
    [dict setValue:value forKey:key];
    BOOL isOk = [dict writeToFile:self.plistFilePath atomically:TRUE];
    return isOk;
}

//删除kv方法
-(int) remove:(NSString*)key{
    return 0;
}

//按照k查询数据方法
-(NSString*) findByKey:(NSString*)key{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:self.plistFilePath];
    NSEnumerator *enumerator = [dict keyEnumerator];
    id next;
    while ((next = [enumerator nextObject])) {
        if([next  isEqualToString:key]){
            return dict[key];
        }
    }
    return nil;
}

@end
