//
//  CryptLib.h
//  TEDASign
//
//  Created by Error on 2/7/2564 BE.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Foundation/Foundation.h>


@interface CryptLib : NSObject

-  (NSData *)encrypt:(NSData *)plainText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)decrypt:(NSData *)encryptedText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)generateRandomIV:(size_t)length;
-  (NSString *) md5:(NSString *) input;
-  (NSString *) sha256:(NSString *)key length:(NSInteger) length;
-  (NSString *) encryptPlainText:(NSString *)plainText key:(NSString *)key;
-  (NSString *) decryptCipherText:(NSString *)cipherText key:(NSString *)key;
-  (NSString *) encryptPlainTextRandomIVWithPlainText:(NSString *)plainText key:(NSString *)key;
-  (NSString *) decryptCipherTextRandomIVWithCipherText:(NSString *)cipherText key:(NSString *)key;

@end
