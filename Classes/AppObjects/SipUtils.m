//
//  SipUtils.m
//  linphone
//
//  Created by admin on 6/13/18.
//

#import "SipUtils.h"
#import "PhoneMainView.h"

@implementation SipUtils

+ (BOOL)loginSipWithDomain: (NSString *)domain username: (NSString *)username password: (NSString *)password port: (NSString *)port {
    NSString *displayName = @"";
    
    LinphoneProxyConfig *config = linphone_core_create_proxy_config(LC);
    LinphoneAddress *addr = linphone_address_new(NULL);
    LinphoneAddress *tmpAddr = linphone_address_new([NSString stringWithFormat:@"sip:%@:%@",domain, port].UTF8String);
    linphone_address_set_username(addr, username.UTF8String);
    linphone_address_set_port(addr, linphone_address_get_port(tmpAddr));
    linphone_address_set_domain(addr, linphone_address_get_domain(tmpAddr));
    if (displayName && ![displayName isEqualToString:@""]) {
        linphone_address_set_display_name(addr, displayName.UTF8String);
    }
    linphone_proxy_config_set_identity_address(config, addr);
    
    // set transport
    NSString *transport = @"UDP";
    linphone_proxy_config_set_route(config, [NSString stringWithFormat:@"%s;transport=%s", domain.UTF8String, transport.lowercaseString.UTF8String].UTF8String);
    linphone_proxy_config_set_server_addr(config, [NSString stringWithFormat:@"%s;transport=%s", domain.UTF8String, transport.lowercaseString.UTF8String].UTF8String);
    
    linphone_proxy_config_enable_publish(config, FALSE);
    linphone_proxy_config_enable_register(config, TRUE);
    
    LinphoneAuthInfo *info =
    linphone_auth_info_new(linphone_address_get_username(addr), // username
                           NULL,                                // user id
                           password.UTF8String,                 // passwd
                           NULL,                                // ha1
                           linphone_address_get_domain(addr),   // realm - assumed to be domain
                           linphone_address_get_domain(addr)    // domain
                           );
    linphone_core_add_auth_info(LC, info);
    linphone_address_unref(addr);
    linphone_address_unref(tmpAddr);
    
    if (config) {
        //  [[LinphoneManager instance] configurePushTokenForProxyConfig:config];
        if (linphone_core_add_proxy_config(LC, config) != -1) {
            linphone_core_set_default_proxy_config(LC, config);
            return TRUE;
        } else {
            return FALSE;
        }
    } else {
        return FALSE;
    }
}

+ (void)registerProxyWithUsername: (NSString *)username password: (NSString *)accountPassword domain: (NSString *)domain port: (NSString *)port {
    LinphoneCoreSettingsStore *core = [[LinphoneCoreSettingsStore alloc] init];
    [core setBool:YES forKey:@"account_outbound_proxy_preference"];
    
    //  NSString *username = @"14924";
    //  NSString *proxyAddress = @"125.253.125.196:51000";
    NSString *proxyAddress = [NSString stringWithFormat:@"%@:%@", domain, port];
    if (![proxyAddress hasPrefix:@"sip:"] && ![proxyAddress hasPrefix:@"sips:"]) {
        proxyAddress = [NSString stringWithFormat:@"sip:%@", proxyAddress];
    }
    
    char *proxy = ms_strdup(proxyAddress.UTF8String);
    LinphoneAddress *proxy_addr = linphone_core_interpret_url(LC, proxy);
    
    if (proxy_addr) {
        LinphoneTransportType type = LinphoneTransportUdp;
        linphone_address_set_transport(proxy_addr, type);
        ms_free(proxy);
        proxy = linphone_address_as_string_uri_only(proxy_addr);
    }
    
    LinphoneProxyConfig *proxyCfg = NULL;
    
    const MSList *proxies = linphone_core_get_proxy_config_list(LC);
    while (proxies) {
        if (proxies->data != NULL) {
            const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data));
            if (strcmp(username.UTF8String, proxyUsername) == 0) {
                proxyCfg = proxies->data;
                break;
            }
        }
        proxies = proxies->next;
    }
    //  proxyCfg = bctbx_list_nth_data(linphone_core_get_proxy_config_list(LC), 0);
    
    LinphoneAddress *linphoneAddress = linphone_core_interpret_url(LC, "sip:user@domain.com");
    linphone_address_set_username(linphoneAddress, username.UTF8String);
    if ([LinphoneManager.instance lpConfigBoolForKey:@"use_phone_number" inSection:@"assistant"]) {
        char *user = linphone_proxy_config_normalize_phone_number(proxyCfg, username.UTF8String);
        if (user) {
            linphone_address_set_username(linphoneAddress, user);
            ms_free(user);
        }
    }
    
    //  NSString *domain = @"125.253.125.196";
    NSString *displayName = username;
    //  NSString *accountPassword = @"@xui@123456";
    
    linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    linphone_address_set_display_name(linphoneAddress, (displayName.length ? displayName.UTF8String : NULL));
    const char *identity = linphone_address_as_string(linphoneAddress);
    linphone_address_destroy(linphoneAddress);
    const char *password = [accountPassword UTF8String];
    
    
    if (linphone_proxy_config_set_identity(proxyCfg, identity) == -1) {
        NSLog(@"%@", NSLocalizedString(@"Invalid username or domain", nil));
    }
    
    // use proxy as route if outbound_proxy is enabled
    const char *route = proxy;
    
    if (linphone_proxy_config_set_server_addr(proxyCfg, proxy) == -1) {
        NSLog(@"%@", NSLocalizedString(@"Invalid proxy address", nil));
    }
    
    if (linphone_proxy_config_set_route(proxyCfg, route) == -1) {
        NSLog(@"%@", NSLocalizedString(@"Invalid route", nil));
    }
    
    BOOL is_default = YES;
    int expire = 3600;
    BOOL use_avpf = NO;
    
    linphone_proxy_config_enable_register(proxyCfg, YES);
    linphone_proxy_config_enable_avpf(proxyCfg, use_avpf);
    linphone_proxy_config_set_expires(proxyCfg, expire);
    if (is_default) {
        linphone_core_set_default_proxy_config(LC, proxyCfg);
    } else if (linphone_core_get_default_proxy_config(LC) == proxyCfg) {
        linphone_core_set_default_proxy_config(LC, NULL);
    }
    
    LinphoneAuthInfo *proxyAi = (LinphoneAuthInfo *)linphone_proxy_config_find_auth_info(proxyCfg);
    char *realm;
    if (proxyAi) {
        realm = ms_strdup(linphone_auth_info_get_realm(proxyAi));
    } else {
        realm = NULL;
    }
    // setup new proxycfg
    linphone_proxy_config_done(proxyCfg);
    
    // modify auth info only after finishing editting the proxy config, so that
    // UNREGISTER succeed
    if (proxyAi) {
        linphone_core_remove_auth_info(LC, proxyAi);
    }
    if (strcmp(password,"") == 0) {
        password = NULL;
    }
    
    NSString *accountHa1 = @"";
    const char *ha1 = [accountHa1 UTF8String];
    
    LinphoneAddress *from = linphone_core_interpret_url(LC, identity);
    if (from) {
        const char *userid_str = (username != nil) ? [username UTF8String] : NULL;
        LinphoneAuthInfo *info;
        if (password) {
            info = linphone_auth_info_new(linphone_address_get_username(from), userid_str, password, NULL,
                                          linphone_proxy_config_get_realm(proxyCfg),
                                          linphone_proxy_config_get_domain(proxyCfg));
        } else {
            info = linphone_auth_info_new(linphone_address_get_username(from), userid_str, NULL, ha1,
                                          realm ? realm : linphone_proxy_config_get_realm(proxyCfg),
                                          linphone_proxy_config_get_domain(proxyCfg));
        }
        
        linphone_address_destroy(from);
        linphone_core_add_auth_info(LC, info);
        linphone_auth_info_destroy(info);
        ms_free(realm);
    }
}

+ (void)registerPBXAccount: (NSString *)pbxAccount password: (NSString *)password ipAddress: (NSString *)address port: (NSString *)portID
{
    NSString *displayName = @"";
    LinphoneProxyConfig *config = linphone_core_create_proxy_config(LC);
    
    NSString *strAddress = [NSString stringWithFormat:@"sip:%@@%@:%@", pbxAccount, address, portID];
    LinphoneAddress *addr = linphone_address_new(strAddress.UTF8String);
    
    if (displayName && ![displayName isEqualToString:@""]) {
        linphone_address_set_display_name(addr, displayName.UTF8String);
    }
    linphone_proxy_config_set_identity_address(config, addr);
    
    linphone_proxy_config_set_server_addr(config, strAddress.UTF8String);
    
    linphone_proxy_config_enable_publish(config, TRUE);
    linphone_proxy_config_enable_register(config, TRUE);
    
    LinphoneAuthInfo *info =
    linphone_auth_info_new(linphone_address_get_username(addr), // username
                           NULL,                                // user id
                           password.UTF8String,                        // passwd
                           NULL,                                // ha1
                           linphone_address_get_domain(addr),   // realm - assumed to be domain
                           linphone_address_get_domain(addr)    // domain
                           );
    linphone_core_add_auth_info(LC, info);
    linphone_address_unref(addr);
    
    if (config) {
        if (linphone_core_add_proxy_config(LC, config) != -1) {
            linphone_core_set_default_proxy_config(LC, config);
        }
    }
}

@end
