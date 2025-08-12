# Content Delivery Network (CDN) as device/website Anti fingerprinter 

### Anti fingerprinting framework system components  

1. Your PCs :- PC with windows subsystem for Linux (WSL) running ubuntu 24.04
2. Next Unit of Computing (NUC) :- PC running DEBIAN 12
3. Internet Connection
4. Your PCs are connected to the NUC ethernet port via a switch or wireless LAN router and NUC is connected to the internet via USB or ethernet by a internet router  

### IP addresses of the proposed system (Change to your requirement) 

1. Your PCs subnetwork 10.42.0.0/24. Your PCs ipaddresses start from 10.42.0.2 - 10.42.0.254. CDN server (NUC) LAN interface ip address is 10.42.0.1
2. Internet connection subnetwork 172.20.10.0/28 and the NUC internet interface ip address is 172.20.10.3

### Clone software to your home directory (~) in NUC 
1. ``` cd ~```
2. ``` git clone https://github.com/chamarakl-research/CDN_antifingerprinting.git```
3. ```sudo nano /etc/hosts```
4. Add ```cache_server <your NUC LAN interface ip address>```

### In your PCs install Windows Subsystem for Linux (WSL)
1. **Open** powershell
2. **Download** https://releases.ubuntu.com/noble/ubuntu-24.04.3-wsl-amd64.wsl
3. ```wsl --install --from-file "<path>\ubuntu-24.04.2-wsl-amd64.wsl"```
4. ```wsl```
5. ```sudo nano /etc/hosts```
6. Add ```myclient1 <your PCs LAN interface ip address>```
   
### 1. Install DANTE SOCKS server in NUC
   1. ```sudo apt-get install dante-server```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/danted.conf```
      1. **Line2:** ```internal: 10.42.0.1 port = 1080``` *Change NUC LAN interface ip address to match your configuration*
      2. **Line3:** ```external: 172.20.10.3``` *Change NUC internet interface ip address to match your configuration*
      3. **Line11:** ```from: 10.42.0.0/24 to: 172.20.10.0/28``` *Change NUC LAN interface IP subnetwork and LAN interface internet IP subnetwork to match your configuration* 
      4. **Line21:** ```from: 10.42.0.0/24 to: 172.20.10.0/28``` *Change NUC LAN interface IP subnetwork and LAN interface internet IP subnetwork to match your configuration* 
   4. ```sudo cp ~/CDN_antifingerprinting/etc/danted.conf /etc/```
  
### 2. Install BIND9 DNS server in NUC
   1. ```sudo apt-get install bind9 bind9utils dnsutils```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/bind/named.conf.options```
   3. **Line3:** ```10.42.0.0/24;``` *Change NUC LAN interface IP subnetwork to match your configuration*
   4. ```sudo ~/CDN_antifingerprinting/etc/bind/named.conf.options /etc/bind/```
  
### 3. Install SQUID caching server in NUC
   1. ```sudo apt-get install squid```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/squid/squid.conf```
   3. *Line1334:* ```acl localnet src 10.42.0.0/24``` *Change NUC LAN interface IP subnetwork to match your configuration* 
   4. *Line2106:* ```http_port 10.42.0.1:3128`` *Change NUC LAN interface IP address to match your configuration*
   5. ```sudo cp ~/CDN_antifingerprinting/etc/squid/squid.conf /etc/squid/```

### 4. Install PRIVOXY ad blocker in NUC
   1. ```sudo apt-get install privoxy```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/privoxy/config```
   3. **Line794:** ```listen-address  10.42.0.1:8118`` *Change NUC LAN interface IP address to match your configuration*
   4. ```sudo cp ~/CDN_antifingerprinting/etc/privoxy/config /etc/privoxy/```
  
### 5. Install NGINX reverse proxy in NUC
   1. ```sudo apt-get install nginx```
   2. ```sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/private_cache_server.key -out /etc/ssl/certs/public_cache_server_certificates.crt -subj "/CN=cache_server"```
   3. ```sudo cp ~/CDN_antifingerprinting/etc/nginx/sites-available/default /etc/nginx/sites-available/```
  
### 6. Install VARNISH HTTP accelerator in NUC
   1. ```sudo apt-get install varnish```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/varnish/default.vcl```
   3. **Line4:** ```.host = "10.42.0.1";``` *Change NUC LAN interface IP address to match your configuration*
   4. ```sudo cp  ~/CDN_antifingerprinting/etc/varnish/default.vcl /etc/varnish/default.vcl```
   5. ```sudo cp /CDN_antifingerprinting/lib/systemd/system/varnish.service /lib/systemd/system/varnish.service```
   6. ```sudo systemctl daemon-reload```

### 7. Install HITCH HTTPS accelerator in NUC
   1. ```sudo apt-get install hitch```
   2. ```sudo cp ~/CDN_antifingerprinting/hitch/hitch.conf /etc/hitch```
   3. ```sudo useradd hitch```
   4. ```sudo groupadd hitch```
   5. ```sudo usermod –a –G hitch hitch```
   6. ```sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/CDN_antifingerprinting/hitch/private_hitch.key -out ~/CDN_antifingerprinting/hitch/public_hitch.crt -subj "/CN=cache_server"```
   7. ```cd ~/CDN_antifingerprinting/hitch```
   8. ```cat private_hitch.key public_hitch.crt > hitch.pem```
   9. ```sudo cp ~/CDN_antifingerprinting/hitch/hitch.pem /etc/hitch/```
  
### 8. Enabling TOR service in NUC (Creative Commons Attribution 3.0 United States License)
   1. ```sudo apt-get install tor```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/tor/torrc```
   3. **Line19:** ```SocksPort 10.42.0.1:9100``` *Change NUC LAN interface IP address to match your configuration*
   4. **Line24:** ```SocksPolicy accept 10.42.0.0/24``` *Change NUC LAN interface subnetwork IP address to match your configuration*
   5. ```sudo cp ~/CDN_antifingerprinting/etc/tor/torrc /etc/tor/```

### 9. Install openvpn server in NUC
   1. ```sudo apt-get install openvpn easy-rsa```
   2. ```sudo make-cadir /etc/openvpn/easy-rsa```
   3. ```sudo su```
   4. ```cd /etc/openvpn/easy-rsa```
   5. ```./easyrsa init-pki```
   6. ```./easyrsa build-ca```
   7. ```./easyrsa gen-req cache_server nopass``` cache_server is the entry which you gave in **/etc/hosts**
   8. ```./easyrsa sign-req server cache_server``` cache_server is the entry which you gave in **/etc/hosts**
   9. ```cp pki/dh.pem pki/ca.crt pki/issued/cache_server.crt pki/private/cache_server.key /etc/openvpn/```
   10. ```Ctrl+D```
   11. ```cd /etc/openvpn```
   12. ```sudo openvpn --genkey --secret ta.key```
   13. ```sudo nano /etc/sysctl.conf```
   14. **Line28:** *remove* **#** *and enable* ```net.ipv4.ip_forward=1```
   15. ```sudo sysctl -p /etc/sysctl.conf```
   16. ```sudo nano ~/CDN_antifingerprinting/etc/openvpn/server.conf```
   17. **Line25:** ```local 10.42.0.1``` *Change NUC LAN interface IP address to match your configuration*
   18. ```sudo cp ~/CDN_antifingerprinting/etc/openvpn/server.conf /etc/openvpn/```
   19. ```sudo su```
   20. ```cd /etc/openvpn/easy-rsa```
   21. ```./easyrsa gen-req myclient1 nopass``` myclient1 is the entry which you gave in **/etc/hosts** in your WSL ubuntu 24.04 
   22. ```./easyrsa sign-req client myclient1``` myclient1 is the entry which you gave in **/etc/hosts** in your WSL ubuntu 24.04
   23. ```mkdir ~/CDN_antifingerprinting/client_cert```
   24. ```sudo cp /etc/openvpn/easy-rsa/pki/ca.crt ~/CDN_antifingerprinting/client_cert/```
   25. ```sudo cp /etc/openvpn/easy-rsa/pki/issued/myclient1.crt ~/CDN_antifingerprinting/client_cert/```
   26. ```sudo cp /etc/openvpn/easy-rsa/pki/private/myclient1.key ~/CDN_antifingerprinting/client_cert/```
   27. ```sudo cp /etc/openvpn/ta.key ~/CDN_antifingerprinting/client_cert/```
   28. ```sudo systemctl restart danted bind9 privoxy squid nginx tor varnish openvpn@server```
   29. ```sudo  /usr/sbin/hitch --user _hitch --group _hitch --config /etc/hitch/hitch.conf```

30. To futher reduce the fingerprint you can run the the torbrowser through WSL which emulate the complete computer system (Optional) 
    1. Download -> https://releases.ubuntu.com/noble/ubuntu-24.04.3-wsl-amd64.wsl
    2. Install ubuntu wsl using powershell -> wsl --install --from-file "<path>\ubuntu-24.04.2-wsl-amd64.wsl"
    3. Run WSL -> wsl
    4. Download torbrowser -> wget https://dist.torproject.org/torbrowser/14.5.5/tor-browser-linux-x86_64-14.5.5.tar
    5. Extract -> tar -xvf tor-browser-linux-x86_64-14.5.5.tar
    6. run torbrowser -> cd tor-browser -> ./start-tor-browser.desktop
    7. You will see in https://coveryourtracks.eff.org that the number bits used to represent your device/website fingerprint has reduced
    8. To get sound install in WSL -> sudo apt-get install pulseaudio

31. To further reduce fingerprint openvpn connection can be setup between WSL emulated system and anti fingerprinting CDN DEBIAN server internal interface (Optional -Advanced)
    
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
