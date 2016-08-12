Binary file ./bin/fcserver-galileo matches
Binary file ./bin/fcserver-osx matches
Binary file ./bin/fcserver.exe matches
Binary file ./bin/fcserver-rpi matches
./README.md:148:The Fadecandy project includes an [Open Pixel Control](http://openpixelcontrol.org/) server which can drive multiple Fadecandy boards and DMX adaptors. USB devices may be hotplugged while the server is up, and the server uses a JSON configuration file to map OPC messages to individual Fadecandy boards and DMX devices.
./doc/fc_server_config.md:144:Using Open Pixel Control with DMX
./doc/fc_server_config.md:147:The Fadecandy server is designed to make it easy to drive all your lighting via Open Pixel Control, even when you're using a mixture of addressable LED strips and DMX devices.
./doc/fc_server_config.md:149:For DMX, `fcserver` supports the common [Enttec DMX USB Pro adapter](http://www.enttec.com/index.php?main_menu=Products&pn=70304). This device attaches over USB, has inputs and outputs for one DMX universe, and it has an LED indicator. With Fadecandy, the LED will flash any time we process a new frame of video.
./doc/fc_server_config.md:155:Enttec DMX devices can be configured in the same way as a Fadecandy device. For example:
./doc/fc_server_config.md:181:Enttec DMX devices use a different format for their mapping objects:
./doc/fc_server_config.md:183:* [ *OPC Channel*, *OPC Pixel*, *Pixel Color*, *DMX Channel* ]
./doc/fc_server_config.md:184:    * Map a single OPC pixel to a single DMX channel
./doc/fc_server_config.md:186:    * DMX channels are numbered from 1 to 512.
./doc/fc_server_config.md:187:* [ *Value*, *DMX Channel* ]
./doc/fc_server_config.md:188:    * Map a constant value to a DMX channel; good for configuration modes
./doc/images/host-internals-diagram.graffle:238:\f0\fs24 \cf0 Enttec DMX\
./doc/images/host-internals-diagram.graffle:544:\f0\fs24 \cf0 DMX Device}</string>
./server/http/js/home.js:316:             * As of this writing, there's already one of these: the Enttec DMX Pro.
Binary file ./server/.README.md.swp matches
./server/README.md:11:* Mix Fadecandy and DMX lighting devices
./server/src/enttecdmxdevice.cpp:2: * Fadecandy driver for the Enttec DMX USB Pro.
./server/src/enttecdmxdevice.cpp:52:    // Initialize a minimal valid DMX packet
./server/src/enttecdmxdevice.cpp:107:     * determine that the attached device is in fact an Enttec DMX USB Pro, since it doesn't
./server/src/enttecdmxdevice.cpp:124:        mFoundEnttecStrings = !strcmp(manufacturer, "ENTTEC") && !strcmp(product, "DMX USB PRO");
./server/src/enttecdmxdevice.cpp:165:    s << "Enttec DMX USB Pro";
./server/src/enttecdmxdevice.cpp:230:     * our set of DMX channels.
./server/src/enttecdmxdevice.cpp:232:     * XXX: We should probably throttle this so that we don't send DMX messages
./server/src/enttecdmxdevice.cpp:287:     *   [ OPC Channel, OPC Pixel, Pixel Color, DMX Channel ]
./server/src/enttecdmxdevice.h:2: * Fadecandy driver for the Enttec DMX USB Pro.
