function MDestruction.explode(x, y, size, config)
  local bomb = GetCell(x, y)
  for cx = x - size, x + size do
    for cy = y - size, y + size do
      local dist = math.sqrt((cx - x) ^ 2 + (cy - y) ^ 2)
      if dist <= size then
        local rc = V(config.replacecell, cx, cy, x, y, dist, bomb)
        SetCell(cx, cy, rc or getempty())
      end
    end
  end
  local runParticles = config.particles or enemyparticles
  if fancy then runParticles:setPosition(x * 20 - 10, y * 20 - 10) runParticles:emit(50) end
  if not config.silent then
    PlaySound(config.sound or sound.destroy)
  end
  if type(config.execute) == "function" then config.execute() end
end

function MDestruction.DoMissle(x, y, dir, vars, size, config)
  if not PushCell(x, y, dir, vars) then
    MDestruction.explode(x, y, size, config)
  end
end

Essentials.AddCustomFix("missle", function(self, dir, vars, size, config)
  MDestruction.DoMissle(self:pos().x, self:pos().y, dir, vars, size, config)
end)

function MDestruction.DoMine(x, y, size, config)
  for cx = x - size, x + size do
    for cy = y - size, y + size do
      if cx ~= x or cy ~= y then
        local c = GetCell(cx, cy)
        local d = math.sqrt(math.pow(cx - x, 2) + math.pow(cy - y, 2))
        if ((c.id ~= 0) and (d < size)) then
          MDestruction.explode(x, y, size, config)
          return true
        end
      end
    end
  end
  return false
end

function MDestruction.DoSmartMine(x, y, eyesight, size, config)
  for cx = x - eyesight, x + eyesight do
    for cy = y - eyesight, y + eyesight do
      if cx ~= x or cy ~= y then
        local c = GetCell(cx, cy)
        local d = math.sqrt(math.pow(cx - x, 2) + math.pow(cy - y, 2))
        if ((c.id ~= 0) and (d < size) and (d > size)) then
          MDestruction.explode(x, y, size, config)
          return true
        end
      end
    end
  end
  return false
end

Essentials.AddCustomFix("mine", function(self, size, config)
  MDestruction.DoMine(self:pos().x, self:pos().y, size, config)
end)

Essentials.AddCustomFix("smartMine", function(self, eyesight, size, config)
  MDestruction.DoSmartMine(self:pos().x, self:pos().y, eyesight, size, config)
end)

function MDestruction.DoFirework(x, y, dir, vars, size, config)
  if not MDestruction.DoMine(x, y, size, config) then
    PushCell(x, y, dir, vars)
  end
end

Essentials.AddCustomFix("firework", function(self, dir, vars, size, config)
  MDestruction.DoFirework(self:pos().x, self:pos().y, dir, vars, size, config)
end)

function MDestruction.DoSmartFirework(x, y, dir, vars, eyesight, size, config)
  if not MDestruction.DoSmartMine(x, y, eyesight, size, config) then
    PushCell(x, y, dir, vars)
  end
end

Essentials.AddCustomFix("smartFirework", function(self, dir, vars, eyesight, size, config)
  MDestruction.DoSmartFirework(self:pos().x, self:pos().y, dir, vars, eyesight, size, config)
end)

function MDestruction.TimeBomb(x, y, duration, size, vars)
  local c = GetCell(x, y)
  c.vars.timeBomb = (c.vars.timeBomb or 0) + 1

  if c.vars.timeBomb == duration then
    MDestruction.explode(x, y, size, vars)
  end
end
