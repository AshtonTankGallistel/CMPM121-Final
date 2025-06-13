
require "vector"
require "cardBehavior"

CardClass = {}

megaFont = love.graphics.newFont(60)
largeFont = love.graphics.newFont(15)
smallFont = love.graphics.newFont(8)
cardSize = Vector(90,120)

COLORS = {
  RED = {1,0,0,1},
  BLACK = {0,0,0,1},
  GRAY = {0.5,0.5,0.5,1},
  WHITE = {1,1,1,1},
  BLUE = {0,0,1,1},
  CYAN = {0.3,0.3,1,1}
}

OUTLINE_STATE = {
  STANDARD = COLORS.BLACK,
  LOCKED = COLORS.GRAY,
  EFFECT = COLORS.BLUE,
  REACTING = COLORS.CYAN
}

function CardClass:new(xPos, yPos, behavior, flipped, myGM)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card,metadata)
  
  --Visible state
  card.position = Vector(xPos, yPos)
  card.size = cardSize
  card.outline = OUTLINE_STATE.STANDARD
  --card.state = CARD_STATE.IDLE
  if flipped == nil then card.flipped = false else card.flipped = flipped end
  
  --info state
  card.behavior = behavior
  card.name = behavior.name
  card.cost = behavior.baseCost
  card.power = behavior.basePower
  
  --location/mouse info
  card.heldBy = nil --set to mouse when held
  card.objectLocation = nil --object that has card as a child
  card.clickable = not flipped
  
  --Gamemanager since I'm lazy
  card.gameManager = myGM
  
  return card
end

function CardClass:draw()
  local red = {1,0,0,1}
  local black = {0,0,0,1}
  local gray = {0.5,0.5,0.5,1}
  local white = {1,1,1,1}
  
  
  --Set outline/back of card color
  --outline of card
  love.graphics.setColor(self.outline)
  love.graphics.rectangle("fill",self.position.x - 2,self.position.y - 2, 
    self.size.x + 4, self.size.y + 4, 4, 4)
  --back/front of card
  if self.flipped then
    love.graphics.setColor(COLORS.RED)
    love.graphics.rectangle("fill",self.position.x,self.position.y, 
      self.size.x, self.size.y, 1, 1)
    return --skip drawing the text since it's flipped
  else
    love.graphics.setColor(COLORS.WHITE)
    love.graphics.rectangle("fill",self.position.x,self.position.y, 
      self.size.x, self.size.y, 1, 1)
  end
  
--  if not self.flipped and self.sprite ~= nil then
--    love.graphics.setColor(white)
--    love.graphics.draw(self.sprite, 
--      self.position.x, self.position.y, 0)
--  end
  --PRINT INFO TEXT
  love.graphics.setColor(COLORS.BLACK)
  if string.len(self.name) > 8 then
    love.graphics.setFont(smallFont)
  else
    love.graphics.setFont(largeFont)
  end
  love.graphics.print(self.name,self.position.x + 2,self.position.y + 2)
  love.graphics.setFont(largeFont)
  love.graphics.print(self.cost,self.position.x + self.size.x - 10,self.position.y + 20)
  love.graphics.print(self.power,self.position.x + self.size.x - 10,self.position.y + self.size.y - 20)
  love.graphics.setFont(smallFont)
  if self.behavior.text ~= nil then
    love.graphics.printf(self.behavior.text,self.position.x + 2,self.position.y + self.size.y / 2, self.size.x - 4)
  end
end

function CardClass:onClick(myMouse)
  --check mana info stuff
  if self.objectLocation.player ~= nil then
    if (self.objectLocation.player.mana - self.objectLocation.player.spendingMana) < self.cost then
      return --too expensive, can't pick up
    end
  end
  --actually grab the card
  myMouse.grabbedObject = self
  self.heldBy = myMouse
end

--what happens to the card when dropped by the mouse. Parameter is the object it was dropped onto, nil if no object
function CardClass:onMouseRelease(dropObject)
  self.heldBy.grabbedObject = nil
  self.heldBy = nil
  --pop card from prev object if dropped into new object
  if self.objectLocation ~= nil and dropObject ~= nil then
    --decrease mana if pulled from hand
    if self.objectLocation.player ~= nil then
      self.objectLocation.player.spendingMana = self.objectLocation.player.spendingMana + self.cost
    end
    --then pop card
    oldObject = self.objectLocation
    self.objectLocation:remove(self)
    oldObject:updateLocations()
  end
  --Put card into new object (want to do regardless of if they had an object previously)
  if dropObject ~= nil then
    --increase mana if returned to hand
    if dropObject.player ~= nil then
      dropObject.player.spendingMana = dropObject.player.spendingMana - self.cost
    end
    --then properly insert
    dropObject:insert(self)
  end
  --update object's location stuff, regardless of current situation.
  if self.objectLocation ~= nil then
    self.objectLocation:updateLocations()
  end
end

function CardClass:lockSelf()
  self.outline = OUTLINE_STATE.LOCKED
  self.clickable = false
end

function CardClass:resetOutline()
  if self.clickable == false and self.flipped == false then
    self.outline = OUTLINE_STATE.LOCKED
  else
    self.outline = OUTLINE_STATE.STANDARD
  end
end

function CardClass:signalEffect()
  self.outline = OUTLINE_STATE.EFFECT
end

function CardClass:signalReacting()
  self.outline = OUTLINE_STATE.REACTING
end
