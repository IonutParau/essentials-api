MDestruction.bombTypes = {}

MDestruction.bombTypes.normal = {}

MDestruction.bombTypes.acidic = {
  replacecell = function(cx, cy, bx, by, dist, bomb)
    local c = GetCell(cx, cy)

    c.lastvars = { bx, by, c.rot }

    c.id = 240

    return c
  end,
}

MDestruction.bombTypes.chemical = {
  replacecell = function(cx, cy, bx, by, dist, bomb)
    local c = GetCell(cx, cy)

    c.lastvars = { bx, by, c.rot }

    c.id = 241

    return c
  end,
}

MDestruction.bombTypes.nuclear = {
  replacecell = function(cx, cy, bx, by, dist, bomb)
    if dist <= 4 then
      return getempty()
    else
      local c = GetCell(cx, cy)
      if c.id ~= 0 then
        if love.math.random(1, 100) <= 50 then
          c.id = "MD uranium"
          c.vars = { love.math.random(150, 690) }
        end
      end
      return c
    end
  end,
}
