--
-- This piece of code is written by
--    Jianing Yang <jianingy.yang@gmail.com>
-- with love and passion!
--
--        H A P P Y    H A C K I N G !
--              _____               ______
--     ____====  ]OO|_n_n__][.      |    |
--    [________]_|__|________)<     |YANG|
--     oo    oo  'oo OOOO-| oo\\_   ~o~~o~
-- +--+--+--+--+--+--+--+--+--+--+--+--+--+
--                             30 Mar, 2016
--
require 'settings'
require 'wireless'
require 'ntp'

local pump_manually_on = 0
local pump_status = 0
local waterlevel = -1
local initial_weight = -1
local current_weight = -1

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function on_wifi_connected ()
   ntp.update(on_ready)
end

function send_data(text)
   local function on_sent(s)
      s:close()
      s = nil
   end

   local function on_connected (s)
      s:send(text, on_sent)
   end

   socket = net.createConnection(net.TCP, 0)
   socket:on('connection', on_connected)
   socket:connect(settings.carbon.port, settings.carbon.host)
   socket = nil
end

function on_ready ()
   print("app: system is ready. starting app version 0.1.6")

   local pin_pump = settings.pin.pump
   local pin_scale = settings.pin.scale
   print("app: configurating pins: pump=" .. pin_pump .. ", scale=" .. pin_scale .. ", start_level = " .. settings.start_level)
   gpio.mode(pin_pump, gpio.OUTPUT)
   gpio.mode(pin_scale, gpio.INPUT)

   print("app: configuring adc mode")
   adc.force_init_mode(adc.INIT_ADC)

   print("ctrld: pump deactivating")
   set_pump_power(0)

   start_controller_server()
   tmr.alarm(4, settings.interval.waterlevel, 1, read_waterlevel)
end

function start_controller_server()
   srv = net.createServer(net.TCP, 180)
   print("ctrld: controller server started")
   srv:listen(settings.controller.port, on_controller_server_connected)
end

function on_controller_server_connected (s)
   s:on("receive", on_controller_server_command)
end

function on_controller_server_command (s, payload)
   cmd = trim(payload)
   print("ctrld: got payload '" .. cmd .. "'")
   local pin_pump = settings.pin.pump
   if cmd == "pump on" then
      set_pump_power(1)
      print("pump: switched on manually")
      s:send("pump: switched on manually\r\n")
      pump_manually_on = 1
   elseif cmd == "pump off" then
      set_pump_power(0)
      print("pump: switched off manually")
      s:send("pump: switched off manually\r\n")
      pump_manually_on = 0
   elseif cmd == "pump auto" then
      print("pump: set pump power mode to auto")
      s:send("pump: set pump power mode to auto\r\n")
   elseif cmd == "pump status" then
      s:send("pump: status = " .. pump_status .. "\r\n")
   elseif cmd == "pump sensors" then
      s:send("pump: level = " .. waterlevel .. ", weight = " .. current_weight .. "/" .. initial_weight .. ". \r\n")
   end
   s:close()
   s = nil
end

function read_waterlevel ()
   tmr.stop(4)
   print('pump: reading scale')
   val = adc.read(0)
   current_weight = gpio.read(settings.pin.scale)
   waterlevel = val
   if initial_weight < 0 then
       initial_weight = current_weight
   end
   print('pump: set scale led')
   if current_weight == 1 then
      gpio.write(settings.pin.led, gpio.LOW)
   elseif current_weight == 0 and pump_manually_on == 0 then
      gpio.write(settings.pin.led, gpio.HIGH)
   end
   print('pump: waterlevel = ' .. val .. ', scale level = ' .. current_weight)
   if val > settings.start_level then
      print("pump: switch on automatically. material seems above waterlevel.")
      set_pump_power(1)
   elseif current_weight == 1 and pump_manually_on == 0 then
      set_pump_power(0)
      print("pump: switch off automatically. bucket seems empty.")
   end
   sec, usec = rtctime.get()
   send_data('daling.environment.ac.waterlevel ' .. val .. ' ' .. sec .. '\r\n')
   send_data('daling.environment.ac.pump_status ' .. pump_status .. ' ' .. sec .. '\r\n')
   tmr.alarm(4, settings.interval.waterlevel, 1, read_waterlevel)
end

function set_pump_power(status)
   local pin_pump = settings.pin.pump
   if status == 1 then
      gpio.write(pin_pump, gpio.LOW)
   else
      gpio.write(pin_pump, gpio.HIGH)
   end
   pump_status = status
end

wireless.connect(settings.wifi.ssid, settings.wifi.secret, on_wifi_connected)
