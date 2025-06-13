
require "vector"

MOUSE_STATE = {
  IDLE = 0,
  CLICKED = 1,
  HELD = 2,
  RELEASED = 3
}

MouseClass = {}

function MouseClass:new()
  local mouse = {}
  local metadata = {__index = MouseClass}
  setmetatable(mouse,metadata)
  
--  mouse.onClickMousePos = nil
  mouse.currentMousePos = nil
  
--  mouse.grabPos = nil
--  mouse.flipping = false --bool, true on frame you try to flip
--  mouse.pressRC = false --bool, true on frame you try to flip
  
  mouse.state = nil
  mouse.grabbedObject = nil --set to an object when it grabs an object. Only occurs for some clicked objects, not all
  
  return mouse
end

function MouseClass:update()
  --Update position
  self.currentMousePos = Vector(
      love.mouse.getX(),
      love.mouse.getY()
    )
  --Handles state of mouse; updates based on if the left mouse button is down and previous states to determine specifics for gameplay
  if love.mouse.isDown(1) then --Holding Left Click on this frame
    if self.state == MOUSE_STATE.IDLE then --If previously not, then they clicked
      self.state = MOUSE_STATE.CLICKED
    else --Otherwise, they're holding it
      self.state = MOUSE_STATE.HELD
    end
  else --Not holding LC
    if self.state == MOUSE_STATE.RELEASED then --If just released, return to idle
      self.state = MOUSE_STATE.IDLE
    elseif self.state ~= MOUSE_STATE.IDLE then --If previously held, release whatever it is
      self.state = MOUSE_STATE.RELEASED
    end
  end
  --Handles state of grabbed object
  if self.grabbedObject ~= nil then
    setCenterOfObject(self.grabbedObject, self.currentMousePos)
    --self.grabbedObject.position = self.currentMousePos
  end
  
end

function MouseClass:onMouseRelease(dropObject)
  if self.grabbedObject ~= nil then
    self.grabbedObject:onMouseRelease(dropObject)
    self.grabbedObject = nil
  end
end
