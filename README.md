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
   7.    sudo  /usr/sbin/hitch --user _hitch --group _hitch --config /etc/hitch/hitch.conf

10. To futher reduce the fingerprint you can run the the torbrowser through WSL which emulate the complete computer system (Optional) 
    1. Download -> https://releases.ubuntu.com/noble/ubuntu-24.04.3-wsl-amd64.wsl
    2. Install ubuntu wsl using powershell -> wsl --install --from-file "<path>\ubuntu-24.04.2-wsl-amd64.wsl"
    3. Run WSL -> wsl
    4. Download torbrowser -> wget https://dist.torproject.org/torbrowser/14.5.5/tor-browser-linux-x86_64-14.5.5.tar
    5. Extract -> tar -xvf tor-browser-linux-x86_64-14.5.5.tar
    6. run torbrowser -> cd tor-browser -> ./start-tor-browser.desktop
    7. You will see in https://coveryourtracks.eff.org that the number bits used to represent your device/website fingerprint has reduced
    8. To get sound install in WSL -> sudo apt-get install pulseaudio

11. To further reduce fingerprint openvpn connection can be setup between WSL emulated system and anti fingerprinting CDN DEBIAN server internal interface (Optional -Advanced)
    
    This is based on the assumption that device\website fingerprinter use Large Language Models (LLM) to model the temporal packet transmission relationship in the ISP backbone
    We use openvpn with UDP beetween WSL ubuntu client and anti fingerprinting CDN DEBIAN server so that the packet sizes are random 
    1. Install in anitifingerprinting CDN -> sudo apt-get install openvpm easy-rsa
    2. sudo make-cadir /etc/openvpn/easy-rsa
    3. sudo su
    4. cd /etc/openvpn/easy-rsa
    5. ./easyrsa init-pki
    6. ./easyrsa build-ca
    7. ./easyrsa gen-req cache_server nopass (cache_server is the name given in /etc/hosts file with internal interface ip address of anti fingerprinting CDN DEBIAN server)
    8. ./easyrsa gen-dh
    9. ./easyrsa sign-req server cache_server (cache_server is the name given in /etc/hosts file with internal interface ip address of anti fingerprinting CDN DEBIAN server)
    10. cp pki/dh.pem pki/ca.crt pki/issued/cache_server.crt pki/private/cache_server.key /etc/openvpn/
    11. Ctrl + D (exit sudo)
    12. cd /etc/open
    13. sudo openvpn --genkey --secret ta.key
    14. sudo nano /etc/sysctl.conf and set net.ipv4.ip_forward=1
    15. sudo sysctl -p /etc/sysctl.conf
    16. sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server.conf
    17. copy github repository server.conf file to /etc/openvpn/ (Set internal ip address 10.42.0.1 to match your antifingerprinting CDN DEBIAN server internal ip address)
    18. Start the CDN server with -> sudo systemctl restart danted bind9 privoxy squid nginx tor varnish openvpn@server
    19. sudo  /usr/sbin/hitch --user _hitch --group _hitch --config /etc/hitch/hitch.conf   
    20. ./easyrsa gen-req myclient1 nopass  (myclient1 is the name given in /etc/hosts file with internal interface ip address of WSL ubuntu client)
    21. ./easyrsa sign-req client myclient1  (myclient1 is the name given in /etc/hosts file with internal interface ip address of USL ubuntu client)

   WSL Ubuntu client 
   
    1. cp pki/ca.crt pki/issued/myclient1.crt pki/private/myclient1.key /etc/openvpn/ta.key from anti fingerprinting CDN DEBIAN server to WSL ubuntu client (use scp to copy and chown to change ownership of files )
    2. copy github repository client.conf file to /etc/openvpn/ in WSL ubuntu client
    3. sudo systemctl restart openvpn@client
    
12. NEW  ---> RANDOM fingerprint with Mullvad browser + tor service in WSL ubuntu client and anti fingerprinting CDN DEBIAN server (PLEASE TEST) <-----
    1. Setting up proxychains in WSL ubuntu client  -> sudo apt-get install proxychains4 tor
    2. cp etc/proxychains.conf from github repository to /etc/ in WSL ubuntu client
    3. sudo systemctl restart openvpn@client tor
    4. proxychains mullvad-browser --detach
    5. In browserleaks.com the number of adblockers keep changing and the DNS ip addresses are not localized to a region
   
13. Test the anti fingerprinting framework (Upto point 12)
    1. It seems there are three methods of doing fingerprinting
      1. use ip address + device/browser detatils (random fingerprint)
         1. https://www.thumbmarkjs.com/resources/demo => refresh the webpage in anti fingerprinting framework
      2. device/browser details only (random fingerprint)
         1. https://priyangsubanerjee.github.io/device-fingerprinting/ => refresh the webpage in anti fingerprinting framework
      3. selected device/browser details to show that anti fingerprinting framework is not working (fingerprint which doesn't change accross different PC systems)
         1. https://fingerprintjs.github.io/fingerprintjs/ => refresh the webpage in anti fingerprinting framework and will show same fingerprint
         2. Compare fingerprint in two anti fingerprinting frameworks and will show still same fingerprint 
         3. It seems anti fingerprinting framework is irritating some, HA HA HA
         4. In my opinion ip address must be used for device/browser fingerprinting 

A. To enable windows update you must bypass the CDN antifingerprinting server. This done by adding the following ip addresses in the proxy exception list in "internet options"
    1. *.windowsupdate.com; *.microsoft.com; *.windows.com
  
B. It is possible to use Mullvad browser (https://mullvad.net) without the VPN service with the anti fingerprinting CDN and get the same level as privacy as the Tor browser with anti fingerprinting CDN 
