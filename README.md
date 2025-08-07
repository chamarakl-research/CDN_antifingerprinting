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
   1. sudo apt-get install 
