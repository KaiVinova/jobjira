//
// Copyright (c) 2016 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//#import "utilities.h"
#import "File.h"
#import "Dir.h"
 
@implementation File

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)temp:(NSString *)ext
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	int interval = (int) [[NSDate date] timeIntervalSince1970];
	NSString *file = [NSString stringWithFormat:@"%d.%@", interval, ext];
	return [Dir cache:file];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)exist:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)remove:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)copy:(NSString *)src dest:(NSString *)dest overwrite:(BOOL)overwrite
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (overwrite) [self remove:dest];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([self exist:dest] == NO) [[NSFileManager defaultManager] copyItemAtPath:src toPath:dest error:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSDate *)created:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	return attributes[NSFileCreationDate];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSDate *)modified:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	return attributes[NSFileModificationDate];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (uint64_t)size:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	return [attributes[NSFileSize] unsignedLongLongValue];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (uint64_t)diskFree
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:nil];
	return [attributes[NSFileSystemFreeSize] unsignedLongLongValue];
}

@end

