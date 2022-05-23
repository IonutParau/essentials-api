Essentials.events = {}

function Essentials.BindEvent(event, callback)
  if not Essentials.events[event] then Essentials.events[event] = {} end

  table.insert(Essentials.events[event], callback)
end