if Synapse then return Synapse end -- No f--king around in here

Synapse = {}

Synapse.channels = {}

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