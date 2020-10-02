# jul/17/2020 19:38:00 by RouterOS 6.48beta12
# software id = 3615-9B9N
#
# model = RouterBOARD SXTsq G-5acD
# serial number = 819307718685
/ip dns
set use-doh-server=
    
/ip dns static
add address= name= type=A
add address= name= type=A
add address= name= type=AAAA
add address= name= type=AAAA

#Alibaba Public DNS
#DoH/DoT/DNS Json API, Best DoH server in China

/ip dns
set use-doh-server=https://dns.alidns.com/dns-query

/ip dns static
add address=223.6.6.6 name=dns.alidns.com type=A
add address=223.5.5.5 name=dns.alidns.com type=A
add address=2400:3200::1 name=dns.alidns.com type=AAAA
add address=2400:3200:baba::1 name=dns.alidns.com type=AAAA
          
#AdGuard
#Default provides ad-blocking at DNS level, while Family protection adds adult site blocking
/ip dns
set use-doh-server=https://dns.adguard.com/dns-query
    
/ip dns static
add address=176.103.130.130 name=dns.adguard.com type=A
add address=176.103.130.131 name=dns.adguard.com type=A
add address=2a00:5a60::ad2:ff name=dns.adguard.com type=AAAA
add address=2a00:5a60::ad1:ff name=dns.adguard.com type=AAAA

#AdGuard Family
/ip dns
set use-doh-server=https://dns-family.adguard.com/dns-query
    
/ip dns static
add address= name=dns-family.adguard.com type=A
add address= name=dns-family.adguard.com type=A
add address=2a00:5a60::bad2:ff name=dns-family.adguard.com type=AAAA
add address=2a00:5a60::bad1:ff name=dns-family.adguard.com type=AAAA

#Google
#Full RFC 8484 support
/ip dns
set use-doh-server=https://dns.google/dns-query

/ip dns static
add address=8.8.8.8 name=dns.google type=A
add address=8.8.4.4 name=dns.google type=A

#Google DNS64
/ip dns
set use-doh-server=https://dns64.dns.google/dns-query

/ip dns static
add address=2001:4860:4860::64 name=dns64.dns.google type=AAAA
add address=2001:4860:4860::6464 name=dns64.dns.google type=AAAA

#Cloudflare
#Supports both -04 and -13 content-types
/ip dns
set use-doh-server=https://cloudflare-dns.com/dns-query
    
/ip dns static
add address=104.16.248.249 name=cloudflare-dns.com type=A
add address=104.16.249.249 name=cloudflare-dns.com type=A
add address=2606:4700::6810:f8f9 name=cloudflare-dns.com type=AAAA
add address=2606:4700::6810:f9f9 name=cloudflare-dns.com type=AAAA

#Cloudflare Mozilla
/ip dns
set use-doh-server=https://mozilla.cloudflare-dns.com/dns-query
    
/ip dns static
add address=104.16.249.249 name=mozilla.cloudflare-dns.com type=A
add address=104.16.248.249 name=mozilla.cloudflare-dns.com type=A
add address=2606:4700::6810:f9f9 name=mozilla.cloudflare-dns.com type=AAAA
add address=2606:4700::6810:f8f9 name=mozilla.cloudflare-dns.com type=AAAA

#Cloudflare Block Malware
/ip dns
set use-doh-server=https://security.cloudflare-dns.com/dns-query
    
/ip dns static
add address=104.18.212.220 name=security.cloudflare-dns.com type=A
add address=104.18.213.220 name=security.cloudflare-dns.com type=A
add address=2606:4700::6812:d5dc name=security.cloudflare-dns.com type=AAAA
add address=2606:4700::6812:d4dc name=security.cloudflare-dns.com type=AAAA

#Cloudflare Block Malware and Adult Content
/ip dns
set use-doh-server=https://family.cloudflare-dns.com/dns-query
    
/ip dns static
add address=104.18.209.237 name=family.cloudflare-dns.com type=A
add address=104.18.210.237 name=family.cloudflare-dns.com type=A
add address=2606:4700::6812:d1ed name=family.cloudflare-dns.com type=AAAA
add address=2606:4700::6812:d2ed name=family.cloudflare-dns.com type=AAAA

#Cloudflare DNS64
/ip dns
set use-doh-server=
    
/ip dns static
add address= name= type=A
add address= name= type=A
add address= name= type=AAAA
add address= name= type=AAAA

https://dns64.cloudflare-dns.com/dns-query
Addresses:  2606:4700:4700::64
          2606:4700:4700::6400
          



#Cloudflare
add address=104.16.249.249 name=cloudflare-dns.com type=A
add address=104.16.248.249 name=cloudflare-dns.com type=A

#Cloudflare Family
add address=104.18.209.237 name=family.cloudflare-dns.com type=A
add address=104.18.210.237 name=family.cloudflare-dns.com type=A

add address=8.8.8.8 name=dns.google type=A
add address=8.8.4.4 name=dns.google type=A
