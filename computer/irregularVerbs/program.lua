function loadVerbs(filename)
  local file = io.open(filename, 'r')
  local verbs = {}

  for line in file:lines() do
    _, _, baseForm, simplePast, pastParticiple = line:find('(%l+)%s(%l+)%s(%l+)')

    local verb = {}

    verb['baseForm'] = baseForm
    verb['simplePast'] = simplePast
    verb['pastParticiple'] = pastParticiple

    table.insert(verbs, verb)
  end

  file:close()

  return verbs
end

function newRandomNumberGenerator(min, max)
  local generator = {}

  generator.min = min
  generator.max = max
  generator.data = {}

  for i=min,max do
    table.insert(generator.data, i)
  end

  return generator
end

function getRandomNumber(generator)
  if #generator.data == 0 then
    for i=generator.min,generator.max do
      table.insert(generator.data, i)
    end
  end

  local index = math.random(1, #generator.data)
  local number = generator.data[index]

  table.remove(generator.data, index)

  return number
end

function run()
  local verbs = loadVerbs('data.txt')
  local generator = newRandomNumberGenerator(1, #verbs)

  while true do
    local verb = verbs[getRandomNumber(generator)]
    local type = math.random(1, 2)
    
    if type == 1 then
      io.write('What is the simple past form of verb "' .. verb['baseForm'] .. '"? ')
      local input = io.read('*line')

      if input == verb['simplePast'] then
        io.write('You are correct!\n')
      else
        io.write('You are wrong! The correct answer is "' .. verb['simplePast'] .. '"\n')
      end
    else
      io.write('What is the past participle form of verb "' .. verb['baseForm'] .. '"? ')
      local input = io.read('*line')

      if input == verb['pastParticiple'] then
        io.write('You are correct!\n')
      else
        io.write('You are wrong! The correct answer is "' .. verb['pastParticiple'] .. '"\n')
      end
    end
  end
end

run()