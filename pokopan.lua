ROWS = 6
COLUMNS = 7

-- returns new two-dimension array
function make_field ()
  field = {}
  for r = 1, ROWS do
    field[r] = {}
    for c = 1, COLUMNS do
      field[r][c] = 0
    end
  end
  return field
end

function print_field (field)
  print('  1234567')
  for rr = 1, ROWS * 2 do
    local r = math.ceil(rr / 2)
    io.write(r)
    io.write(' ')
    for c = 1, COLUMNS do 
      if rr % 2 == 1 then
        if c % 2 == 0 then
          io.write(field[r][c])
        else
          io.write(' ')
        end
      else
        if c % 2 == 1 then
          io.write(field[r][c])
        else
          io.write(' ')
        end
      end
    end
    print()
  end
end

-- tests that the trail contains {r, c}
function trail_contains (trail, r, c)
  for i = 1, table.getn(trail) do
    if trail[i][1] == r and trail[i][2] == c then
      return true
    end
  end
  return false
end

-- returns last position of the trail
function trail_last (trail)
  return trail[table.getn(trail)]
end

-- appends new position {r, c} to trail, then returns it
function trail_append (trail, r, c)
  -- copy table ... http://rainyday.blog.so-net.ne.jp/2008-01-20
  trail_copy = {unpack(trail)}
  table.insert(trail_copy, {r, c})
  return trail_copy
end

-- return longer trail
function max_trail (t1, t2)
  if table.getn(t1) > table.getn(t2) then
    return t1
  else
    return t2
  end
end

-- returns neighbor cells' addresses
function neighbors (r, c)
  -- when c is even:
  --            {r-1,c}
  -- {r-1,c-1}          {r-1,c+1}
  --            {r  ,c} 
  -- {r  ,c-1}          {r  ,c+1}
  --            {r+1,c}
  
  -- when c is odd:
  --            {r-1,c}
  -- {r  ,c-1}          {r  ,c+1}
  --            {r  ,c} 
  -- {r+1,c-1}          {r+1,c+1}
  --            {r+1,c}
  
  local ns = {}
  if c % 2 == 0 then
    ns[1] = { r - 1, c - 1 }
    ns[2] = { r - 1, c     }
    ns[3] = { r - 1, c + 1 }
    ns[4] = { r    , c - 1 }
    ns[5] = { r    , c + 1 }
    ns[6] = { r + 1, c     }
  else
    ns[1] = { r    , c - 1 }
    ns[2] = { r - 1, c     }
    ns[3] = { r    , c + 1 }
    ns[4] = { r + 1, c - 1 }
    ns[5] = { r + 1, c + 1 }
    ns[6] = { r + 1, c     }
  end
  local ns_size = table.getn(ns)
  for i = ns_size, 1, -1 do
    local ns_r = ns[i][1]
    local ns_c = ns[i][2]
    if ns_r < 1 or ns_r > ROWS or ns_c < 1 or ns_c > COLUMNS then
      table.remove(ns, i)
    end
  end
  return ns
  
end

-- find same color at the last of the trail,
-- and make new trails
function connect (field, trail)
  local last_pos = trail_last(trail)
  local r = last_pos[1]
  local c = last_pos[2]
  local color = field[r][c]
  local ns = neighbors(r, c)
  local result_trails = {}
  for i = 1, table.getn(ns) do
    local n = ns[i]
    local nr = n[1]
    local nc = n[2]
    -- is this neighbor cell have same color, and not used in the trail?
    if field[nr][nc] == color and not(trail_contains(trail, nr, nc)) then
      -- create new trail, and append found position to that
      local new_trail = trail_append(trail, nr, nc)
      table.insert(result_trails, new_trail)
    end
  end
  return result_trails  
end

-- find longest trail, beginning from specified trail
function longest_trail (field, init_trail)
  local new_trails = connect(field, init_trail)
  if table.getn(new_trails) == 0 then
    return init_trail
  else
    local longest = {}
    for i = 1, table.getn(new_trails) do
      longest = max_trail(longest, longest_trail(field, new_trails[i]))
    end
    return longest
  end
end

-- make random field
function set_random_colors (field, colors)
  math.randomseed(os.time())
  for r = 1, ROWS do
    for c = 1, COLUMNS do
      field[r][c] = math.random(colors)
    end
  end
end


-- find longest 
function field_longest_trail (field)
  local longest = {}
  for r = 1, ROWS do
    for c = 1, COLUMNS do
      longest = max_trail(longest, longest_trail(field, {{r, c}}))
    end
  end
  return longest
end

--
-- demonstration
--

-- make new field
field = make_field()
set_random_colors(field, 4)

-- print it
print_field(field)
print()

-- find longest cell connection
longest = field_longest_trail(field)

-- print the "trail" (array of {row, column})
for i = 1, table.getn(longest) do
  local r = longest[i][1]
  local c = longest[i][2]
  io.write(string.format(' -> (%d, %d)', r, c))
  
  -- also replace cells 
  field[r][c] = '@'
end

-- print result
print()
print()
print_field(field)

