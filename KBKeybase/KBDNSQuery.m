//
//  KBDNSQuery.m
//  KBKeybase
//
//  Created by Gabriel on 11/11/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBDNSQuery.h"

#import <GHKit/GHKit.h>
#include <dns_sd.h>

@implementation KBDNSQuery

typedef void (^KBDNSInternalCompletionHandler)(DNSServiceErrorType errorCode, NSData *data, BOOL finished);

static void callback(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char *fullname, uint16_t rrtype, uint16_t rrclass, uint16_t rdlen, const void *rdata, uint32_t ttl, void *context) {
  
  KBDNSInternalCompletionHandler cb = (__bridge KBDNSInternalCompletionHandler)(context);
  
  if (errorCode) {
    cb(errorCode, nil, YES);
    return;
  }
  
  BOOL more = (flags & kDNSServiceFlagsMoreComing) != 0;
  NSData *data = (rdlen > 0 ? [NSData dataWithBytes:rdata length:rdlen] : nil);
  cb(kDNSServiceErr_NoError, data, !more);
};


- (void)TXTRecordsWithName:(NSString *)name completion:(KBDNSCompletionHandler)completion {
  __block DNSServiceRef serviceRef = NULL;
  NSMutableArray *records = [NSMutableArray array];
  
  KBDNSInternalCompletionHandler cb = ^(DNSServiceErrorType errorCode, NSData *data, BOOL finished) {
    if (errorCode != kDNSServiceErr_NoError) {
      if (serviceRef) {
        DNSServiceRefDeallocate(serviceRef);
        serviceRef = NULL;
      }
      completion(GHNSError(errorCode, @"DNS Error (Callback)"), records);
      return;
    }
    
    if (data) {
      NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      if (str) [records addObject:str];
    }
    
    if (finished) {
      if (serviceRef) {
        DNSServiceRefDeallocate(serviceRef);
        serviceRef = NULL;
      }
      completion(nil, records);
    }
  };
  
  DNSServiceErrorType error = DNSServiceQueryRecord(&serviceRef, kDNSServiceFlagsTimeout, 0, [name cStringUsingEncoding:NSUTF8StringEncoding], kDNSServiceType_TXT, kDNSServiceClass_IN, callback, (__bridge void *)(cb));
  
  if (error != kDNSServiceErr_NoError) {
    completion(GHNSError(error, @"DNS Error (DNSServiceQueryRecord)"), nil);
    return;
  }

  DNSServiceProcessResult(serviceRef);
  
  if (serviceRef) {
    DNSServiceRefDeallocate(serviceRef);
    serviceRef = NULL;
  }
}


@end
