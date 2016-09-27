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
local M = {
   name = ...,
   pin = {led = 0, pump = 6, scale=7},
   wifi = {ssid = 'home', secret='12345678'},
   ntp = {server = '192.168.1.1'},
   telnetd = {port = 23},
   controller = {port = 8080},
   carbon = {host = '192.168.1.1', port = 2929},
   interval = { waterlevel = 4999, pump_auto = 14999},
   start_level = 300
}

_G[M.name] = M

return M
