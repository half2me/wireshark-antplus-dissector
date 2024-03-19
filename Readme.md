## Wireshark dissector for the [ANT+](https://www.thisisant.com/developer/ant-plus/ant-antplus-defined) Protocol
This dissector can be used to analyze ANT+ data captured from a usb device.

## Building and Installing

Use [luabundler](https://github.com/Benjamin-Dobell/luabundler) to create one lua file which is easier to use
```bash
luabundler bundle src/main.lua -p "src/?.lua" -o antplus-dissector.lua
```
Copy the generated `antplus-dissector.lua` file to your [Wireshark Plugin Directory](https://www.wireshark.org/docs/wsug_html_chunked/ChPluginFolders.html)


If you want to add profiles to support more sensors, I welcome you to make a PR.

## Capturing ANT+ data
Make sure the usbmon kernel module is loaded: `modprobe usbmon`,  
Then you should be able to capture usb data on `usbmon0`. For example using `tshark`:
```bash
tshark -i usbmon0 -I -w usb-dump.pcapng -P
```
Make sure you actually have some ant+ data flowing. You can use the `antdump` utility from [antgo](https://github.com/half2me/antgo) to dump all broadcast messages to console, meanwhile `tshark` should capture all the traffic.