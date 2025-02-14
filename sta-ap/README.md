### CREATE LOCAL AP ON RASPBERRY PI ZERO W
>[NOTE: This does not give internet access.  <ins>Only creates a local network</ins>]

Run [sta-ap.start](https://github.com/TROUBLESOM0/LilyPin/blob/47238d7bfd912c3939e3449e3ea28df014eed21b/sta-ap/sta-ap.start) to create Access Point.  Default SSID is "LilyPin{random_number}".<br>
It will first rename *wpa_supplicant.conf* to *wpa_supplicant.conf.bkup* so that it is not used.<br>
Then, a backup will be made of existing **dnsmasq.conf, dhcpcd.conf,** and **hostapd.conf** (if it exists, it usually doesn't) and placed in folder named "pre-apsta-bkup" in the directory sta-ap.start is ran.<br>
Next, it will replace the required files, 1) stopping hostapd, 2) unmasking hostapd, 3) enabling hostapd, 4) starting hostapd.<br>
Finally, will perform reboot on system.

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
