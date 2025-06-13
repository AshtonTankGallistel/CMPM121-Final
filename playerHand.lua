
require "card"

PlayerHandClass = {}

function PlayerHandClass:new(xPos, yPos, xSize, ySize)
  local hand = {}
  local metadata = {__index = PlayerHandClass}
  setmetatable(hand,metadata)
  
  --Visible state
  hand.position = Vector(xPos, yPos)
  hand.size = Vector(cardSize.x * 7.7, cardSize.y * 1.1)
  --hand.size = Vector(xSize, ySize)
  --cardHolder.size = Vector(55, 75)
  
  --info state
  hand.myCards = {}
  hand.droppable = true
  hand.player = nil --Both the player and the hand access eachother, so this is set when the player object recieves their hand
  
  return hand
end

function PlayerHandClass:draw()
  love.graphics.setColor(0.5,0.5,0.5,0.5)
  love.graphics.rectangle("fill",self.position.x,self.position.y, 
    self.size.x, self.size.y, 12, 12)
  
end

function PlayerHandClass:insert(myCard)
  table.insert(self.myCards, myCard)
  myCard.objectLocation = self
end

function PlayerHandClass:remove(myCard)
  for _,card in ipairs(self.myCards) do
    if myCard == card then
      card.objectLocation = nil
      table.remove(self.myCards, _)
      break
    end
  end
end

function PlayerHandClass:updateLocations()
  if #self.myCards < 1 then return end --Exit early if no cards
  local handCenter = getCenterOfObject(self)
  local xPosition = handCenter.x - (#self.myCards - 1)*(cardSize.x / 2)
  for _,card in ipairs(self.myCards) do
    setCenterOfObject(card, Vector(xPosition, handCenter.y))
    xPosition = xPosition + cardSize.x
  end
end

function PlayerHandClass:resetCardOutlines()
  for _,card in ipairs(self.myCards) do
    card:resetOutline()
  end
end
