### CREATE LOCAL AP ON RASPBERRY PI ZERO W
>[NOTE: This does not give internet access.  <ins>Only creates a local network</ins>]

List of required files:
- dnsmasq.conf - *configures ip range and interface*
- dhcpcd.conf - *configures device ip as AP*
- hostapd.conf - *configures SSID and security settings*
<br>
Steps to perform:

1. Make bkups of the 3 files.
2. dnsmasq.conf and dhcpcd.conf will be direct replacements.
3. hostapd.conf will require the below commands once replaced:
<br></br>
:warning: **EXTRA STEPS**

&nbsp; &nbsp; &nbsp; &nbsp; - remove wpa_supplicant 

&nbsp; &nbsp; &nbsp; &nbsp; <code>sudo mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bkup</code>

&nbsp; &nbsp; &nbsp; &nbsp; - stop hostapd <code>sudo systemctl stop hostapd</code>

&nbsp; &nbsp; &nbsp; &nbsp; - unmask hostapd <code>sudo systemctl unmask hostapd</code>

&nbsp; &nbsp; &nbsp; &nbsp; - enable hostapd <code>sudo systemctl enable hostapd</code>

&nbsp; &nbsp; &nbsp; &nbsp; - restart hostapd <code>sudo systemctl start hostapd</code>
<br>
<br>

Once files are replaced and hostapd is unmasked & restarted, Perform reboot.<br>
There should be an "Open" network named <ins> subcloud-AP1 </ins><br>
( this can be changed in the "hostapd.conf" file )
