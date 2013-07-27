
#import <Foundation/Foundation.h>


/*
 使用方法：
 1. 添加 IPADeploy 到 Project；
 2. 添加 MiniZip （在 Sources/ZipArchive 下的所有文件）到 Project；
 3. 添加 ZLib Framework 到 Project；
 4. #import "IPADeploy.h"；
 5. 在 C/C++、Object C/C++ 中均可调用 IPA Deploy 中的任何函数。
 如有问题，请邮件给 YonsmGuo@gmail.com
 */


//
#ifdef __cplusplus
#define EXTERN_C extern "C"
#else
#define EXTERN_C extern
#endif


// 安装结果
typedef enum
{
	IPAResultOK = 0,				// 安装成功
	IPAResultFail = -1,				// 安装失败
	IPAResultNoFunction = 0xBEFC,	// 私有 API 未找到
	IPAResultFileNotFound = 0xBFEC,	// 拷贝 IPA 错误
}
IPAResult;


// 提取 IPA 中的文件
// 参数 path：IPA 文件路径。
// 参数 suffix：要提取的文件名，调用 [NSString hasSuffix:suffix] 比较，匹配则提取（不支持通配符）。为 nil 则提取全部。
// 参数 to：suffix 为 nil 时，to 为目录（可以无需预先创建）；suffix 不为 nil 时，为具体的文件路径（路径的目录必须存在）。
EXTERN_C BOOL IPAExtractFile(NSString *path, NSString *suffix, NSString *to);

// 提取 IPA 的信息
// 返回：Info Plist 字典
EXTERN_C NSDictionary *IPAExtractInfo(NSString *path);

// 安装 IPA 文件
// 备注：此函数调用为同步方式，可以考虑在后台线程中调用（但无法获取到安装进度）。
// 备注：此函数调用私有 API 安装，无法列出所有返回值，除返回值 IPAResultOK 之外，请当做错误来出来。
EXTERN_C IPAResult IPAInstall(NSString *path);

// 获取已安装的 APP 字典
// 返回：返回所有已安装的程序的字典，.allKeys 包含所有 Bundle Identifier 数组；.allValues 包含所有 APP 的 Info Plist Dictionary 数组。
EXTERN_C NSDictionary *IPAInstalledApps();


// 检查 APP 是否已安装，传入 Bundel Identifier
NS_INLINE BOOL IPAIsAppInstalled(NSString *identifier)
{
	NSDictionary *dict = IPAInstalledApps();
	return [dict.allKeys containsObject:identifier];
}

// 检查 APP 是否已安装，传入 Info Plist Dictionary
NS_INLINE BOOL IPAIsPlistInstalled(NSDictionary *info)
{
	NSString *identifier = [info objectForKey:@"CFBundleIdentifier"];
	return identifier && IPAIsAppInstalled(identifier);
}

// 检查 IPA 是否已安装，传入 IPA 路径
NS_INLINE BOOL IPAIsInstalled(NSString *path)
{
	NSDictionary *info = IPAExtractInfo(path);
	return info && IPAIsPlistInstalled(info);
}

