# CDN_antifingerprinting
CDN Solution for Antifinger printing

System

PC with tor browser -> CDN Server for antifingerprinting -> Internet 

1. We are using DEBIAN 12 as the CDN with two internet connections
2. Internal 10.42.0.0/24
3. External 1: 172.20.10.0/28
4. External 2: 192.168.0.0/24 

Creating the CDN antifingerprinting server 
1. Install DANTE SOCKS server
   1. sudo apt-get install dante-server
   2. Change the ipaddress of danted.conf in the github repository to match your network interface ipaddress of the DEBIAN server (CDN server for antifingerprinting)
   3. sudo cp danted.conf /etc/
  
2. Install BIND9 DNS server
   1. sudo apt-get install bind9 bind9utils dnsutils
   2. Change the internal ip address block 10.42.0.0/24 of named.conf.options in the github repository to match your internal network interface ip address of the DEBIAN server (CDN server for fingerprinting)
   3. sudo cp bind/named.conf.options /etc/bind/
  
3. Install SQUID caching server
   1. sudo apt-get install squid
   2. Change "acl localnet src" address 10.42.0.0/24 (use Ctrl+F to find) in squid.conf in the github repository to match your internal network interface ip address of the DEBIAN server (CDN server for fingerprinting)
   3. Change "http_port 10.42.0.1:3128" in squid.conf in the github repository to match your internal network interface ip address of the DEBIAN server (CDN server for fingerprinting)
   4. sudo cp squid/squid.conf /etc/squid
