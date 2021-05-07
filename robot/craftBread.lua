local component = require 'component'
local robot = require 'robot'
local sides = require 'sides'

local tankController = component['tank_controller']
local inventoryController = component['inventory_controller']
local craftingController = component['crafting']

local WATER_TANK_ID = 1
local MINIMUM_WATER_AMOUNT = 2000.0

local BREAD_SLOT_ID = 4
local WHEAT_SLOT_ID = 8
local BUCKET_SLOT_ID = 12
local MORTAR_AND_PESTLE_SLOT_ID = 13
local POT_SLOT_ID = 14
local MIXING_BOWL_SLOT_ID = 15
local BAKEWARE_SLOT_ID = 16
local FLOUR_SLOT_ID = 17
local SALT_SLOT_ID = 18
local DOUGH_SLOT_ID = 19

local requiredItems = {
  [8] = 'Wheat',
  [12] = 'Bucket',
  [13] = 'Mortar and Pestle',
  [14] = 'Pot',
  [15] = 'Mixing Bowl',
  [16] = 'Bakeware'
}

function findItemByLabelInSlot(label, slot)
  local item = inventoryController.getStackInInternalSlot(slot)

  if not item then return false end

  if item.label ~= label then return false end

  return true
end

function checkItemRequirements()
  for slot, label in pairs(requiredItems) do
    if not findItemByLabelInSlot(label, slot) then
      print('Unable to find \'' .. label .. '\' at slot ' .. slot)
      return false
    end
  end

  return true
end

function moveToWater()
  robot.turnLeft()
  for i=1,2 do robot.forward() end
end

function moveToCharger()
  robot.turnAround()
  for i=1,2 do robot.forward() end
  robot.turnLeft()
end

function checkWaterRequirements(tank, amount)
  return robot.tankLevel(tank) >= amount
end

function fillTankWithWater(tank)
  robot.selectTank(tank)

  while robot.tankSpace() ~= 0 do
    robot.drainDown()
  end
end

function craftFlour()
  robot.select(MORTAR_AND_PESTLE_SLOT_ID)
  robot.transferTo(1, 1)

  robot.select(WHEAT_SLOT_ID)
  robot.transferTo(2, 1)

  robot.select(FLOUR_SLOT_ID)
  craftingController.craft()

  robot.select(1)
  robot.transferTo(MORTAR_AND_PESTLE_SLOT_ID)
end

function fillBucketWithWater(tank)
  robot.selectTank(tank)
  robot.select(BUCKET_SLOT_ID)
  tankController.fill(1000)
end

function craftSalt()
  robot.select(POT_SLOT_ID)
  robot.transferTo(1, 1)

  robot.select(BUCKET_SLOT_ID)
  robot.transferTo(2, 1)

  robot.select(SALT_SLOT_ID)
  craftingController.craft()

  robot.select(1)
  robot.transferTo(POT_SLOT_ID, 1)
  
  robot.select(2)
  robot.transferTo(BUCKET_SLOT_ID, 1)
end

function craftDough()
  robot.select(MIXING_BOWL_SLOT_ID)
  robot.transferTo(1, 1)

  robot.select(BUCKET_SLOT_ID)
  robot.transferTo(2, 1)

  robot.select(FLOUR_SLOT_ID)
  robot.transferTo(5, 1)
  
  robot.select(SALT_SLOT_ID)
  robot.transferTo(6, 1)

  robot.select(DOUGH_SLOT_ID)
  craftingController.craft()

  robot.select(1)
  robot.transferTo(MIXING_BOWL_SLOT_ID, 1)
  
  robot.select(2)
  robot.transferTo(BUCKET_SLOT_ID, 1)
end

function craftBread()
  robot.select(BAKEWARE_SLOT_ID)
  robot.transferTo(1, 1)

  robot.select(DOUGH_SLOT_ID)
  robot.transferTo(2, 1)

  robot.select(BREAD_SLOT_ID)
  craftingController.craft()

  robot.select(1)
  robot.transferTo(BAKEWARE_SLOT_ID, 1)
end

function tryToCreateBread()
  if not checkItemRequirements() then return end

  if not checkWaterRequirements(WATER_TANK_ID, MINIMUM_WATER_AMOUNT) then
    moveToWater()
    fillTankWithWater(WATER_TANK_ID)
    moveToCharger()
  end

  craftFlour()
  fillBucketWithWater(WATER_TANK_ID)
  craftSalt()
  fillBucketWithWater(WATER_TANK_ID)
  craftDough()
  craftBread()
end

local count = ...

if not count then
  print("Usage: createBread count")
  return
end

for i=1,tonumber(count) do
  tryToCreateBread()
end