<p align="center">
<img src="http://static.rcgroups.net/forums/attachments/6/1/0/3/7/6/a9088858-102-inav.png" /><br /><br />
<a href="https://www.buymeacoffee.com/bosko" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Beer" style="height: auto !important;width: auto !important;" ></a>
</p>

**Thanks for supporters:** gdanas87, Jeremy

# Available on AppStore 
https://apps.apple.com/us/app/inav-telemetry/id1543244904

# What is iNavTelemetry
iNav telemetry is application for iOS devices (iPhone / iPad / MacOS / Safari Viewer)

# Setup on iNav flight controller
- smartport_fuel_unit = PERCENT
- frsky_pitch_roll = ON

# Screenshots / Videos
Application (youtube)|Browser Viewer (youtube)
----------|----------
[![Video presentation](http://img.youtube.com/vi/9Z63v9UPBO4/0.jpg)](http://www.youtube.com/watch?v=9Z63v9UPBO4 "Testing")|[![Video presentation](http://img.youtube.com/vi/csjpeDqP2JU/0.jpg)](http://www.youtube.com/watch?v=csjpeDqP2JU "Testing")
iPhone|iPad
![iPhone Application](iphone.jpg)|![iPad application](ipad.jpg)
MacOS|Browser
|![MacOS application](osx.jpg)|![Browser](browser.jpg)

# How to use if you dont have build in Bluetooth Module
In order this to work you need additional hardware: inverter and bluetooth module (HC-05 or HC-06 or something else, also you don't need module and inverter if your transmitter has internal one) One important thing: Module should be configured to work on 57600 baud rate, otherwise it won't work. Connect inverter to your Smart Port and then connect bluetooth module to the inverter. You now can connect your phone to your bluetooth module and view data

# Signal Inverter used
![Signal Inverter](inverter.jpg)

# Supported Protocol
- Custom Telemetry - check example of [Tracker](https://github.com/zosko/R9M_Inav_antenna_tracker/blob/master/bt_r9m_accst/bt_r9m_accst.ino)
- FrSky Smart Port 
- Multiwii Serial Protocol (MSP)
- MAVLink (by request if need)
- LTM (by request if need)
- Crossfire (by request if need)

