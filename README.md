# Content Delivery Network (CDN) as device/browser Anti fingerprinter 

![AntiFP_arch](https://github.com/chamarakl-research/CDN_antifingerprinting/blob/main/AntiFP_NUC6.jpg "CDN")

### Anti fingerprinting framework system components  

1. **Your PCs** :- PC with windows subsystem for Linux (WSL) running ubuntu 24.04
2. **Next Unit of Computing (NUC)** :- PC running DEBIAN 12
3. Internet Connection
4. Your PCs are connected to the NUC ethernet port via a switch or wireless LAN router and NUC is connected to the internet via USB or ethernet by a internet router  

### IP addresses of the proposed system (Change to your requirement) 

1. *Your PCs subnetwork* 10.42.0.0/24. *Your PCs ipaddresses start from* 10.42.0.2 - 10.42.0.254. *CDN server (NUC) LAN interface ip address is* 10.42.0.1
2. *Internet connection subnetwork* 172.20.10.0/28 *and the NUC internet interface ip address is* 172.20.10.3

### Clone software to your home directory (~) in NUC 
1. ``` cd ~```
2. ``` git clone https://github.com/chamarakl-research/CDN_antifingerprinting.git```
3. ```sudo nano /etc/hosts```
4. Add ```cache_server <your NUC LAN interface ip address>```

### In EACH of your PCs install Windows Subsystem for Linux (WSL)
1. **Open** powershell
2. **Download** https://releases.ubuntu.com/noble/ubuntu-24.04.3-wsl-amd64.wsl
3. ```wsl --install --from-file "<path>\ubuntu-24.04.2-wsl-amd64.wsl"```
4. ```wsl```
5. ```sudo nano /etc/hosts```
6. **Add** ```myclient1 <your PCs LAN interface ip address>```
7. ```sudo apt-get install pulseaudio```
8. ```sudo apt-get install proxychains4 tor```
9. ```cd ~```
10. ```git clone https://github.com/chamarakl-research/CDN_antifingerprinting.git```
    
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
   4. **Line20:** ```listen-on-v6 { fe80::e25f:59e2:e2ff:83bc; };``` *Change NUC LAN interface IPv6 address to match your configuration*
   5. **Line20:** ```listen-on { 10.42.0.1; };``` *Change NUC LAN interface IP address to match your configuration*
   6. ```sudo ~/CDN_antifingerprinting/etc/bind/named.conf.options /etc/bind/```
   7. ```sudo apt-get install dnsmasq```
   8. ```sudo systemctl disable dnsmasq```
   9. ```sudo systemctl stop dnsmasq```
   10. ```sudo netstat -nap | grep 53``` *Find process ID (PID) of dnsmasq and kill the process*
   11. ```sudo kill -9 <process ID of dnsmasq>```
  
### 3. Install SQUID caching server in NUC
   1. ```sudo apt-get install squid```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/squid/squid.conf```
   3. **Line1334:** ```acl localnet src 10.42.0.0/24``` *Change NUC LAN interface IP subnetwork to match your configuration* 
   4. **Line2106:** ```http_port 10.42.0.1:3128``` *Change NUC LAN interface IP address to match your configuration*
   5. ```sudo cp ~/CDN_antifingerprinting/etc/squid/squid.conf /etc/squid/```

### 4. Install PRIVOXY ad blocker in NUC
   1. ```sudo apt-get install privoxy```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/privoxy/config```
   3. **Line794:** ```listen-address  10.42.0.1:8118``` *Change NUC LAN interface IP address to match your configuration*
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
   1. ```sudo apt-get install obfs4proxy tor```
   2. ```sudo nano ~/CDN_antifingerprinting/etc/tor/torrc.1```
   3. **Line19:** ```SocksPort 10.42.0.1:9110``` *Change NUC LAN interface IP address to match your configuration*
   4. **Line24:** ```SocksPolicy accept 10.42.0.0/24``` *Change NUC LAN interface subnetwork IP address to match your configuration*
   5. ```sudo cp ~/CDN_antifingerprinting/etc/tor/torrc.1 /etc/tor/```
   6. ```sudo nano ~/CDN_antifingerprinting/etc/tor/torrc.2```
   7. **Line19:** ```SocksPort 10.42.0.1:9120``` *Change NUC LAN interface IP address to match your configuration*
   8. **Line24:** ```SocksPolicy accept 10.42.0.0/24``` *Change NUC LAN interface subnetwork IP address to match your configuration*
   9. ```sudo cp ~/CDN_antifingerprinting/etc/tor/torrc.2 /etc/tor/```
   10. ```sudo nano ~/CDN_antifingerprinting/etc/tor/torrc.3```
   11. **Line19:** ```SocksPort 10.42.0.1:9130``` *Change NUC LAN interface IP address to match your configuration*
   12. **Line24:** ```SocksPolicy accept 10.42.0.0/24``` *Change NUC LAN interface subnetwork IP address to match your configuration*
   13. ```sudo cp ~/CDN_antifingerprinting/etc/tor/torrc.3 /etc/tor/```
   14. ```sudo nano ~/CDN_antifingerprinting/etc/tor/torrc.4```
   11. **Line19:** ```SocksPort 10.42.0.1:9140``` *Change NUC LAN interface IP address to match your configuration*
   12. **Line24:** ```SocksPolicy accept 10.42.0.0/24``` *Change NUC LAN interface subnetwork IP address to match your configuration*
   13. ```sudo cp ~/CDN_antifingerprinting/etc/tor/torrc.4 /etc/tor/```
   14. ```sudo nano ~/CDN_antifingerprinting/etc/tor/torrc.5```
   11. **Line19:** ```SocksPort 10.42.0.1:9150``` *Change NUC LAN interface IP address to match your configuration*
   12. **Line24:** ```SocksPolicy accept 10.42.0.0/24``` *Change NUC LAN interface subnetwork IP address to match your configuration*
   13. ```sudo cp ~/CDN_antifingerprinting/etc/tor/torrc.5 /etc/tor/`

### 9. Install haproxy in NUC
1. ```sudo apt-get install haproxy```
2. ```sudo nano ~/CDN_antifingerprinting/etc/haproxy/haproxy.cfg```
3. **Line28:** ```bind 10.42.0.1:9100``` *Change NUC LAN interface IP address to match your configuration*
4. **Line33:** ```server tor1 10.42.0.1:9110 check``` *Change NUC LAN interface IP address to match your configuration*
5. **Line34:** ```server tor2 10.42.0.1:9120 check``` *Change NUC LAN interface IP address to match your configuration*
6. **Line35:** ```server tor3 10.42.0.1:9130 check``` *Change NUC LAN interface IP address to match your configuration*
7. **Line36:** ```server tor4 10.42.0.1:9140 check``` *Change NUC LAN interface IP address to match your configuration*
8. **Line37:** ```server tor5 10.42.0.1:9150 check``` *Change NUC LAN interface IP address to match your configuration*
9. ```sudo cp ~/CDN_antifingerprinting/etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg```

### 10. Install openvpn server in NUC
   1. ```sudo apt-get install openvpn easy-rsa```
   2. ```sudo make-cadir /etc/openvpn/easy-rsa```
   3. ```sudo su```
   4. ```cd /etc/openvpn/easy-rsa```
   5. ```./easyrsa init-pki```
   6. ```./easyrsa build-ca```
   7. ```./easyrsa gen-req cache_server nopass``` *cache_server is the entry which you gave in* **/etc/hosts**
   8. ```./easyrsa sign-req server cache_server``` *cache_server is the entry which you gave in* **/etc/hosts**
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
   21. ```./easyrsa gen-req myclient1 nopass``` *myclient1 is the entry which you gave in* **/etc/hosts** *in your WSL ubuntu 24.04*
   22. ```./easyrsa sign-req client myclient1``` *myclient1 is the entry which you gave in* **/etc/hosts** *in your WSL ubuntu 24.04*
   23. ```mkdir ~/CDN_antifingerprinting/client_cert```
   24. ```sudo cp /etc/openvpn/easy-rsa/pki/ca.crt ~/CDN_antifingerprinting/client_cert/```
   25. ```sudo cp /etc/openvpn/easy-rsa/pki/issued/myclient1.crt ~/CDN_antifingerprinting/client_cert/```
   26. ```sudo cp /etc/openvpn/easy-rsa/pki/private/myclient1.key ~/CDN_antifingerprinting/client_cert/```
   27. ```sudo cp /etc/openvpn/ta.key ~/CDN_antifingerprinting/client_cert/```
   28. ```sudo systemctl restart danted bind9 privoxy squid nginx```
   29. ```sudo tor -f /etc/tor/torrc.1```
   30. ```sudo tor -f /etc/tor/torrc.2```
   31. ```sudo tor -f /etc/tor/torrc.3```
   32. ```sudo tor -f /etc/tor/torrc.4```
   33. ```sudo tor -f /etc/tor/torrc.5```
   34. ```sudo systemctl restart haproxy varnish openvpn@server```
   35. ```sudo  /usr/sbin/hitch --user _hitch --group _hitch --config /etc/hitch/hitch.conf```

### 11. In EACH of your PCs with Windows Subsystem for Linux (WSL) Ubuntu
1. **Setting web browsing enviroment**
    1. ```sudo cp ~/CDN_antifingerprinting/etc/proxychains.conf /etc/```
    2. ```sudo nano ~/CDN_antifingerprinting/etc/openvpn/client.conf```
    3. **Line42:** ```remote 10.42.0.1 1194``` *Change NUC LAN interface IP address to match your configuration*
    4. ```sudo cp ~/CDN_antifingerprinting/etc/openvpn/client.conf /etc/openvpn```
    5. ```scp <username>@<NUC LAN IP> ~/CDN_antifingerprinting/client_cert/ca.crt ~/CDN_antifingerprinting/```
    6. ```scp <username>@<NUC LAN IP> ~/CDN_antifingerprinting/client_cert/myclient1.crt ~/CDN_antifingerprinting/```
    7. ```scp <username>@<NUC LAN IP> ~/CDN_antifingerprinting/client_cert/myclient1.key ~/CDN_antifingerprinting/```
    8. ```scp <username>@<NUC LAN IP> ~/CDN_antifingerprinting/client_cert/ta.key ~/CDN_antifingerprinting/```
    9. ```cd ~/CDN_antifingerprinting/```
    10. ```sudo cp ca.crt myclient1.crt myclient1.key ta.key /etc/openvpn/```
    11. ```sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc```
    12. ```echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable stable main" | sudo tee /etc/apt/sources.list.d/mullvad.list```
    13. ```sudo apt-get update```
    14. ```sudo apt-get install mullvad-browser```
    15. ```sudo systemctl restart openvpn@client tor```
    16. ```proxychains mullvad-browser --detach --new-tab https://www.google.com```
2. **Setting OpenVPN**
    1. **Install openvpn client in windows** https://openvpn.net/downloads/openvpn-connect-v3-windows.msi
    2. **Create a folder** C:\Openvpn_keys
    3. **Copy** ca.crt myclient1.crt myclient1.key ta.key from NUC to C:\Openvpn_keys
    4. **Copy** myclient1.ovpn from repository to C:\Openvpn_keys
    5. **Edit** include the keys in myclient1.ovpn
    6. **Upload** the myclient1.ovpn to Openvpn connect app
3. **Enabling DNS over HTTPS (DOH)**
    1. **Enable** DNS over HTTPS in __Network & Internet__ 
    2. **Edit** DNS assignment *Prefered DNS* ```8.8.8.8```
    3. **Choose** DNS over HTTPS __on(manual template)__ 
    4. **Set** DNS over https template __https://dns.google/dns-query__ as we are using google DNS servers
    5. **Edit** DNS assignment *Alternate DNS* ```1.1.1.1```
    6. **Choose** DNS over HTTPS __on(manual template)__
    7. **Set** DNS over https template __https://security.cloudflare-dns.com/dns-query__ as we are using cloudfare DNS servers
4. **Setting Proxy Servers address**
    1. Set the following as the Proxy servers ```http: 10.42.0.1:80``` and ```https: 10.42.0.1:443``` and ```ftp: 10.42.0.1:3128``` and ```socks: 10.42.0.1:8118```

### 12. Test the anti fingerprinting framework in each of Your PCs
1. THREE APPROACHES of DEVICE/BROWSER FINGERPRINTING 
    1. IP ADDRESS + DEVICE/BROWSER DETAILS (random fingerprint)
         1. **Refresh the webpage after 5 minitues to see random fingerprint** *https://www.thumbmarkjs.com/resources/demo*
      2. DEVICE/BROWSER DETAILS (random fingerprint)
         1. **Refresh the webpage to see random fingerprint** *https://priyangsubanerjee.github.io/device-fingerprinting/*
      3. selected DEVICE/BROWSER DETAILS
         1. **Get fingerprint from all your PCs and the fingerprint will be same** *https://fingerprintjs.github.io/fingerprintjs/*
         2. It seems anti fingerprinting framework is irritating some, HA HA HA

![AntiFP_res](https://github.com/chamarakl-research/CDN_antifingerprinting/blob/main/AntiFP_Results7.jpg "CDN")

### Check your fingerprint in https://amiunique.org/fingerprint and refresh the page about after 10 minitues to see whether another unique fingerprint is genereated for your device/browser
1. **if the value "unique among fingerprints" is changing means a random fingerprint is genereated**

A. To enable windows update you must bypass the CDN antifingerprinting server. This done by adding the following ip addresses in the proxy exception list in "internet options"
    1. *.windowsupdate.com; *.microsoft.com; *.windows.com

### Advantages of Anti fingerprinting framework
1. As a Sri Lankan, we have always noticed two observations which I have heard from various freinds and family members:
   1. Typical download monthly quota assigned finishes quickly and typically a user requires around 80GB of traffic
   2. The internet speed in Sri Lanka is very low, specially mobile download 
2. You will find the proposed Anti fingerprinting framework resolves both issues. I am currently using less amount of internet traffic as shown by my Mydialog App and I can achieve 15Mbps speed in the 4G network when tested with fast.com. In Sri Lanka I have never seen anything higher than 6Mpbs.
3. I will keep interpretation open, but I can assure that this debacale has nothing to do with the Sri Lankan goverment or any neighbouring country. 
  
