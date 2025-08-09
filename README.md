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

4. Install PRIVOXY ad blocker
   1. sudo apt-get install privoxy
   2. Change "listen-address 10.42.0.1:8118" in config in the github repostiry to match your internal network interface IP address of the DEBIAN server (CDN server for fingerprinting)
   3. sudo cp privoxy/config /etc/privoxy/config
  
5. Install NGINX reverse proxy
   1. sudo apt-get install nginx
   2. sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/private_cache_server.key -out /etc/ssl/certs/public_cache_server_certificates.crt -subj "/CN=cache_server"
   3. change the host file with the entry cache_server with the ipaddress of the internal network interface
  
6. Install VARNISH HTTP accelerator
   1. sudo apt-get install varnish
   2. change the internal ip address of varnish/default.vcl to your internal interface ip address
   3. sudo cp varnish/default.vcl /etc/varnish/
   4. sudo cp systemd/system/varnish.service to /lib/systemd/system/varnish.service

7. Install HITCH HTTPS accelerator
   1. sudo apt-get install hitch
   2. sudo cp hitch/hitch.conf /etc/hitch
   3. create user "hitch" belonging to group "hitch"
   4. sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/Documents/hitch/private_hitch.key -out ~/Documents/hitch/public_hitch.crt -subj "/CN=cache_server"
   5. In ~/Documents/hitch/ cat private_hitch.key public_hitch.crt > hitch.pem
   6. sudo cp ~/Documents/hitch/hitch.pem /etc/hitch/
  
8. Start CDN antifingerprinting server with
   1. sudo systemctl restart danted bind9 privoxy squid nginx varnish 
   2. sudo  /usr/sbin/hitch --user _hitch --group _hitch --config /etc/hitch/hitch.conf
   3. Configure proxy in windows computer
   4. Download torbrowser https://www.torproject.org/download/ and use torbrowser only. Other browsers will also show a reduction in fingerprint.
  
9. Enabling TOR service in the CDN antifingerprinting server (Creative Commons Attribution 3.0 United States License) (Optional) 
   1. sudo apt-get install tor
   2. Change "SockPort" and "SocksPolicy" torrc file in the github repository to match your internal netwrok interface IP address pf the DEBIAN server (CDN server for fingerprinting)
   3. sudo cp tor/torrc /etc/tor/
   4. Update privoxy /etc/privoxy/config file with "forward-socks5t / cache_server:9100 ."
   5. Check the number of bits conveyed by your device/ website fingerprint using https://coveryourtracks.eff.org (smaller the better)
   6. Start the CDN server with -> sudo systemctl restart danted bind9 privoxy squid nginx tor varnish
   7.                           -> sudo  /usr/sbin/hitch --user _hitch --group _hitch --config /etc/hitch/hitch.conf
  
10. To enable windows update you must bypass the CDN antifingerprinting server. This done by adding the following ip addresses in the proxy exception list in "internet options"
    1. *.windowsupdate.com; *.microsoft.com; *.windows.com
  
