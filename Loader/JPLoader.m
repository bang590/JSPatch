//
//  JSPatch.m
//  JSPatch
//
//  Created by bang on 15/11/14.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPLoader.h"
#import "JPEngine.h"
#import "ZipArchive.h"
#import "RSA.h"
#import <CommonCrypto/CommonDigest.h>

#define kJSPatchVersion(appVersion)   [NSString stringWithFormat:@"JSPatchVersion_%@", appVersion]

void (^JPLogger)(NSString *log);

#pragma mark - Extension

@interface JPLoaderInclude : JPExtension

@end

@implementation JPLoaderInclude

+ (void)main:(JSContext *)context
{
    context[@"include"] = ^(NSString *filePath) {
        if (!filePath.length || [filePath rangeOfString:@".js"].location == NSNotFound) {
            return;
        }
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *scriptPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"JSPatch/%@/%@", appVersion, filePath]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
            [JPEngine startEngine];
            [JPEngine evaluateScriptWithPath:scriptPath];
        }
    };
}

@end

@interface JPLoaderTestInclude : JPExtension

@end

@implementation JPLoaderTestInclude

+ (void)main:(JSContext *)context
{
    context[@"include"] = ^(NSString *filePath) {
        NSArray *component = [filePath componentsSeparatedByString:@"."];
        if (component.count > 1) {
            NSString *testPath = [[NSBundle bundleForClass:[self class]] pathForResource:component[0] ofType:component[1]];
            [JPEngine evaluateScriptWithPath:testPath];
        }
    };
}

@end

#pragma mark - Loader

@implementation JPLoader

+ (BOOL)run
{
    if (JPLogger) JPLogger(@"JSPatch: runScript");
    
    NSString *scriptDirectory = [self fetchScriptDirectory];
    NSString *scriptPath = [scriptDirectory stringByAppendingPathComponent:@"main.js"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
        [JPEngine startEngine];
        [JPEngine addExtensions:@[@"JPLoaderInclude"]];
        [JPEngine evaluateScriptWithPath:scriptPath];
        if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: evaluated script %@", scriptPath]);
        return YES;
    } else {
        return NO;
    }
}

+ (void)updateToVersion:(NSInteger)version callback:(JPUpdateCallback)callback
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: updateToVersion: %@", @(version)]);
    
    // create url request
    NSString *downloadKey = [NSString stringWithFormat:@"/%@/v%@.zip", appVersion, @(version)];
    NSURL *downloadURL = [NSURL URLWithString:[rootUrl stringByAppendingString:downloadKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    
    if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: request file %@", downloadURL]);
    
    // create task
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: request file success, data length:%@", @(data.length)]);
            
            // script directory
            NSString *scriptDirectory = [self fetchScriptDirectory];
            
            // temporary files and directories
            NSString *downloadTmpPath = [NSString stringWithFormat:@"%@patch_%@_%@", NSTemporaryDirectory(), appVersion, @(version)];
            NSString *unzipVerifyDirectory = [NSString stringWithFormat:@"%@patch_%@_%@_unzipTest/", NSTemporaryDirectory(), appVersion, @(version)];
            NSString *unzipTmpDirectory = [NSString stringWithFormat:@"%@patch_%@_%@_unzip/", NSTemporaryDirectory(), appVersion, @(version)];
            
            // save data
            [data writeToFile:downloadTmpPath atomically:YES];
            
            // is the processing flow failed
            BOOL isFailed = NO;
            
            // 1. unzip encrypted md5 file and script file
            NSString *keyFilePath;
            NSString *scriptZipFilePath;
            ZipArchive *verifyZipArchive = [[ZipArchive alloc] init];
            [verifyZipArchive UnzipOpenFile:downloadTmpPath];
            BOOL verifyUnzipSucc = [verifyZipArchive UnzipFileTo:unzipVerifyDirectory overWrite:YES];
            if (verifyUnzipSucc) {
                for (NSString *filePath in verifyZipArchive.unzippedFiles) {
                    NSString *filename = [filePath lastPathComponent];
                    if ([filename isEqualToString:@"key"]) {
                        // encrypted md5 file
                        keyFilePath = filePath;
                    } else if ([[filename pathExtension] isEqualToString:@"zip"]) {
                        // script file
                        scriptZipFilePath = filePath;
                    }
                }
            } else {
                if (JPLogger) JPLogger(@"JSPatch: fail to unzip file");
                isFailed = YES;
                
                if (callback) {
                    callback([NSError errorWithDomain:@"org.jspatch" code:JPUpdateErrorUnzipFailed userInfo:nil]);
                }
            }
            
            // 2. decrypt and verify md5 file
            if (!isFailed) {
                NSData *md5Data = [RSA decryptData:[NSData dataWithContentsOfFile:keyFilePath] publicKey:publicKey];
                NSString *decryptMD5 = [[NSString alloc] initWithData:md5Data encoding:NSUTF8StringEncoding];
                NSString *md5 = [self fileMD5:scriptZipFilePath];
                if (![decryptMD5 isEqualToString:md5]) {
                    if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: decompress error, md5 didn't match, decrypt:%@ md5:%@", decryptMD5, md5]);
                    isFailed = YES;
                    
                    if (callback) {
                        callback([NSError errorWithDomain:@"org.jspatch" code:JPUpdateErrorVerifyFailed userInfo:nil]);
                    }
                }
            }
            
            // 3. unzip script file and save
            if (!isFailed) {
                ZipArchive *zipArchive = [[ZipArchive alloc] init];
                [zipArchive UnzipOpenFile:scriptZipFilePath];
                BOOL unzipSucc = [zipArchive UnzipFileTo:unzipTmpDirectory overWrite:YES];
                if (unzipSucc) {
                    for (NSString *filePath in zipArchive.unzippedFiles) {
                        NSString *filename = [filePath lastPathComponent];
                        if ([[filename pathExtension] isEqualToString:@"js"]) {
                            [[NSFileManager defaultManager] createDirectoryAtPath:scriptDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                            NSString *newFilePath = [scriptDirectory stringByAppendingPathComponent:filename];
                            [[NSData dataWithContentsOfFile:filePath] writeToFile:newFilePath atomically:YES];
                        }
                    }
                }
                else
                {
                    if (JPLogger) JPLogger(@"JSPatch: fail to unzip script file");
                    isFailed = YES;
                    
                    if (callback) {
                        callback([NSError errorWithDomain:@"org.jspatch" code:JPUpdateErrorUnzipFailed userInfo:nil]);
                    }
                }
            }
            
            // success
            if (!isFailed) {
                if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: updateToVersion: %@ success", @(version)]);
                
                [[NSUserDefaults standardUserDefaults] setInteger:version forKey:kJSPatchVersion(appVersion)];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (callback) callback(nil);
            }
            
            // clear temporary files
            [[NSFileManager defaultManager] removeItemAtPath:downloadTmpPath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:unzipVerifyDirectory error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:unzipTmpDirectory error:nil];
        } else {
            if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: request error %@", error]);
            
            if (callback) callback(error);
        }
    }];
    [task resume];
}

+ (void)runTestScriptInBundle
{
    [JPEngine startEngine];
    [JPEngine addExtensions:@[@"JPLoaderTestInclude"]];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"main" ofType:@"js"];
    NSAssert(path, @"can't find main.js");
    NSString *script = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [JPEngine evaluateScript:script];
}

+ (void)setLogger:(void (^)(NSString *))logger {
    JPLogger = [logger copy];
}

+ (NSInteger)currentVersion
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [[NSUserDefaults standardUserDefaults] integerForKey:kJSPatchVersion(appVersion)];
}

+ (NSString *)fetchScriptDirectory
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *scriptDirectory = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"JSPatch/%@/", appVersion]];
    return scriptDirectory;
}

#pragma mark utils

+ (NSString *)fileMD5:(NSString *)filePath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if(!handle)
    {
        return nil;
    }
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while (!done)
    {
        NSData *fileData = [handle readDataOfLength:256];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if([fileData length] == 0)
            done = YES;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    
    NSString *result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        digest[0], digest[1],
                        digest[2], digest[3],
                        digest[4], digest[5],
                        digest[6], digest[7],
                        digest[8], digest[9],
                        digest[10], digest[11],
                        digest[12], digest[13],
                        digest[14], digest[15]];
    return result;
}

@end