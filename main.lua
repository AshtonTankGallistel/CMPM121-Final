-- Ashton Gallistel
-- CMPM 121 - Pickup
-- 4-11-25
io.stdout:setvbuf("no")

require "card"
require "GameManager"
require "mouse"
--require "stack"

function love.load()
  love.window.setMode(1440, 960)
  love.window.setTitle("Ashton's CCCG")
  love.graphics.setBackgroundColor(0,0.7,0.2,1)
  
  cardTypes = {
    WoodenCowPrototype:new()
  }
  
  myMouse = MouseClass:new()
  
  entities = {}
  gameManager = GameManagerClass:new(50,350,400,300)
  table.insert(entities, gameManager)
  
  --buttons
  submitButton = ButtonClass:new(1250,800,100,50, gameManager, BUTTONFUNCTIONS.SUBMIT)
  table.insert(entities, submitButton)
  
  gameManager:start()
  
  winner = nil
end
 
function love.draw()
  for _,entity in ipairs(entities) do
    entity:draw()
  end
  --Draw the mouse's held card above everything else if needed
  if myMouse.grabbedObject ~= nil then
    myMouse.grabbedObject:draw()
  end
  
end

function love.update(dt)
  myMouse:update()
  if myMouse.state == MOUSE_STATE.CLICKED then
    clickCheck(entities)
  elseif myMouse.state == MOUSE_STATE.HELD then
    --nothing for now...
  elseif myMouse.state == MOUSE_STATE.RELEASED then
    dropCheck(entities)
  end
  
  for _,entity in ipairs(entities) do
    if entity.update ~= nil then
      entity:update(dt)
    end
  end
  
end

function clickCheck(entityList, repeating)
  for _,entity in ipairs(entityList) do
    if entity.clickable == true and entity.onClick ~= nil then
      if pointInsideObject(entity, myMouse.currentMousePos) then
        entity:onClick(myMouse)
      end
    end
    
    if entity.childObjects ~= nil then
      clickCheck(entity.childObjects, true)
    end
  end
end

--This is literally just the same function as above, but it calls a diff function on the inside.
--Perhaps there's a way to send functions in lua as parameters.... oh well
function dropCheck(entityList, repeating)
  for _,entity in ipairs(entityList) do
    if entity.droppable == true and entity.insert ~= nil then
      if pointInsideObject(entity, myMouse.currentMousePos) then
        myMouse:onMouseRelease(entity)
        return
      end
    end
    
    if entity.childObjects ~= nil then
      dropCheck(entity.childObjects, true)
    end
  end
  if repeating ~= true then
    myMouse:onMouseRelease(nil)
  end
end