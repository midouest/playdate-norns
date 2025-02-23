local mod = require('core/mods')
local serial = require('core/serial')

playdate = {}

function playdate.send(msg)
  if playdate.dev then
    _norns.serial_send(playdate.dev, "msg "..msg.."\n")
  end
end

function playdate.run(path)
  if playdate.dev then
      _norns.serial_send(playdate.dev, "run "..path.."\n")
  end
end

function playdate.controller_start()
  if playdate.dev then
    _norns.serial_send(playdate.dev, "controller start\n")
  end
end

function playdate.controller_stop()
  if playdate.dev then
    _norns.serial_send(playdate.dev, "controller stop\n")
  end
end

function playdate.connected()
  return playdate.dev ~= nil
end

_norns.playdate = {}

function _norns.playdate.init()
  playdate.add = function(id, name, dev)
    print(">>>>>> playdate.add / " .. id .. " / " .. name)
  end
  playdate.remove = function(id) print(">>>>>> playdate.remove " .. id) end
  playdate.event = nil
  playdate.accel = nil
  playdate.button = nil
  playdate.crank = nil
  playdate.crankdock = nil
end

function _norns.playdate.add(id, name, dev)
  print("playdate add: " .. id .. " " .. name)
  serial.send(dev, "echo off\n")
  playdate.dev = dev
  playdate.add(id, name, dev)
end

function _norns.playdate.remove(id)
  print("playdate remove: " .. id)
  playdate.dev = nil
  playdate.remove(id)
end

local ebuffer = ""
function _norns.playdate.event(id, line)
  local function evalplaydate(line)
    line = ebuffer .. line
    ebuffer = ""
    if line == "echo off" then
      return
    elseif line:sub(1, 6) == "~ctl: " then
      if line:sub(7, 12) == "accel " then
        if playdate.accel ~= nil then
          local next = line:sub(13, #line):gmatch("%S+")
          local x = tonumber(next())
          local y = tonumber(next())
          local z = tonumber(next())
          playdate.accel(x, y, z)
        end
      elseif line:sub(7, 12) == "crank " then
        if playdate.crank ~= nil then
          local d = tonumber(line:sub(13, #line))
          playdate.crank(d)
        end
      elseif line:sub(7, 10) == "btn " then
        if playdate.button ~= nil then
          local b = line:sub(11, 11)
          local s = tonumber(line:sub(13, 13))
          playdate.button(b, s)
        end
      elseif line:sub(7, 16) == "crankdock " then
        if playdate.crankdock ~= nil then
          local s = tonumber(line:sub(17, 17))
          playdate.crankdock(s)
        end
      end
    else
      if playdate.event ~= nil then
        playdate.event(line)
      end
    end
  end

  local n, m = line:find("%c+")
  if not n then
    ebuffer = ebuffer .. line
  else
    evalplaydate(line:sub(1, n - 1))
    if m < #line then
      _norns.playdate.event(id, line:sub(m + 1, -1))
    end
  end
end

local config = {
  ispeed = serial.B115200,
  ospeed = serial.B115200,
  cflag = serial.CS8 | serial.CLOCAL | serial.CREAD,
  iflag = ~(serial.IXON | serial.IXOFF | serial.IXANY),
  oflag = 0,
  lflag = 0,
  cc = {
    [serial.VMIN] = 0,
    [serial.VTIME] = 5,
  },
}

mod.hook.register("system_startup", "playdate device", function()
  serial.handler {
    id = "playdate",
    configure = function(vendor, model)
      if vendor == "Panic_Inc" and model == "Playdate" then
        return config
      end
    end,
    add = _norns.playdate.add,
    remove = _norns.playdate.remove,
    event = _norns.playdate.event,
  }
end)

mod.hook.register("script_post_cleanup", "cleanup playdate device handlers", function()
  _norns.playdate.init()
end)

_norns.playdate.init()