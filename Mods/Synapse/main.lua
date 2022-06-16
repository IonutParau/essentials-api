if Synapse then return Synapse end -- No f--king around in here

Synapse = {}

Synapse.channels = {}

local _connections = {}

-- Creates a port to be used for completely localized trusted connections
---@param id string The ID of the port
---@param listener function The function called by the connections. What this returns, the connection will receive.
---@param filter function This function gets 1 parameter, the connection data, which is optional. If it returns true, the connection will be accepted. Otherwise, it will be closed.
function Synapse.createConnectable(id, listener, filter)
  local t = {
    listener = listener,
    filter = filter or function() return true end,
  }

  _connections[id] = id
end

-- Connect using the ID to the connection port
---@param id string
---@param connectionData any|nil Optional
function Synapse.connect(id, connectionData)
  if _connections[id] == nil then
    return function() end
  end

  local c = _connections[id]

  if c.filter(connectionData) == true then
    return function(...)
      return unpack { c.listener(...) }
    end
  else
    return function() end
  end
end

function Synapse.NewChannel(name)
  Synapse.channels[name] = {}
end

function Synapse.RemoveChannel(name)
  Synapse.channels[name] = nil
  collectgarbage("collect")
end

function Synapse.AddListener(channelName, listenerName, callback)
  Synapse.channels[channelName][listenerName] = callback
end

function Synapse.RemoveListener(channelName, listenerName)
  Synapse.channels[channelName][listenerName] = nil
end

function Synapse.SendToChannel(channel, ...)
  for _, listener in pairs(Synapse.channels[channel]) do
    listener(...)
  end
end

function Synapse.Broadcast(...)
  for _, channel in pairs(Synapse.channels) do
    for _, listener in pairs(channel) do
      listener(...)
    end
  end
end

return Synapse
