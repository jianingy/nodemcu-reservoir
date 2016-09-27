PORT := /dev/ttyUSB0
BAUDRATE := 115200

all: app settings

app: app.lua
	nodemcu-uploader  --start_baud $(BAUDRATE) --port $(PORT) upload --compile  $?

settings: settings.lua
	nodemcu-uploader  --start_baud $(BAUDRATE) --port $(PORT) upload --compile  $?
