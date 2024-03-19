## Installing

I use [luabundler](https://github.com/Benjamin-Dobell/luabundler) to create one lua file which is easier to use
```
luabundler bundle src/main.lua -p "src/?.lua" -o antplus-dissector.lua
```

Copy the generated `antplus-dissector.lua` file to your [Wireshark Plugin Directory](https://www.wireshark.org/docs/wsug_html_chunked/ChPluginFolders.html)

Enjoy!

If you want to add more profiles to decode more sensors, I welcome you to make a PR.