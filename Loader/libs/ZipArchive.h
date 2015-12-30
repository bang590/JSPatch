/**
//  @header ZipArchive.h
//  
//  An objective C wrapper for minizip and libz for creating and exanding ZIP files.
//
//  @author Created by aish on 08-9-11.
//  acsolu@gmail.com
//  @copyright Copyright 2008  Inc. All rights reserved.
//
*/

#import <Foundation/Foundation.h>


/**
 a block that is called from UnzipFileTo:overwrite:withProgressBlock: where the percentage of
 files processed (as an integer from 0 to 100), the number of files processed so far and the
 total number of files in the archive is called after each file is processed.
 */
typedef void(^ZipArchiveProgressUpdateBlock)(int percentage, int filesProcessed, unsigned long numFiles);
	
/**
    @protocol
    @discussion  methods for a delegate to receive error notifications and control overwriting of files
*/

@protocol ZipArchiveDelegate <NSObject>
@optional

/**
    @brief   Delegate method to be notified of errors
    
    ZipArchive calls this selector on the delegate when errors are encountered.
    
    @param      msg     a string describing the error.
    @result     void
*/

-(void) ErrorMessage:(NSString*) msg;

/**
    @brief   Delegate method to determine if a file should be replaced
    
    When an zip file is being expanded and a file is about to be replaced, this selector
    is called on the delegate to notify that file is about to be replaced. The delegate method
    should return YES to overwrite the file, or NO to skip it.
 
    @param      file - path to the file to be overwritten.
    @result     a BOOL - YES to replace, NO to skip
*/

-(BOOL) OverWriteOperation:(NSString*) file;

@end

/**
    @class
    @brief      An object that can create zip files and expand existing ones.
    This class provides methods to create a zip file (optionally with a password) and
    add files to that zip archive. 
                 
    It also provides methods to expand an existing archive file (optionally with a password),
    and extract the files.
*/

@interface ZipArchive : NSObject {
@private
	void*           _zipFile;
	void*           _unzFile;
	
    unsigned long   _numFiles;
	NSString*       _password;
	__weak id       _delegate;
    ZipArchiveProgressUpdateBlock _progressBlock;
    
    NSArray*    _unzippedFiles;
    
    NSFileManager* _fileManager;
    NSStringEncoding _stringEncoding;
}

/** a delegate object conforming to ZipArchiveDelegate protocol */
@property (nonatomic, weak) id<ZipArchiveDelegate> delegate;
@property (nonatomic, readonly) unsigned long numFiles;
@property (nonatomic, copy) ZipArchiveProgressUpdateBlock progressBlock;

/**
    @brief      String encoding to be used when interpreting file names in the zip file.
*/
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/** an array of files that were successfully expanded. Available after calling UnzipFileTo:overWrite: */
@property (nonatomic, readonly,strong) NSArray *unzippedFiles;

-(id) initWithFileManager:(NSFileManager*) fileManager;

-(BOOL) CreateZipFile2:(NSString*) zipFile;
-(BOOL) CreateZipFile2:(NSString*) zipFile Password:(NSString*) password;
-(BOOL) addFileToZip:(NSString*) file newname:(NSString*) newname;
-(BOOL) CloseZipFile2;

-(BOOL) UnzipOpenFile:(NSString*) zipFile;
-(BOOL) UnzipOpenFile:(NSString*) zipFile Password:(NSString*) password;
-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite;
-(BOOL) UnzipCloseFile;
-(NSArray*) getZipFileContents;     // list the contents of the zip archive. must be called after UnzipOpenFile

@end
