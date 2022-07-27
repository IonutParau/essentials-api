local _Anim = {}
_Anim.__index = _Anim
local AnimationManager = {}

function _Anim:new(frames)
  return setmetatable({ frames = frames, current = 0 }, self)
end

function Animation()
  return _Anim:new()
end

function AnimationManager.update(amount, type)

end
