
require "card"

CardHolderClass = {}

function CardHolderClass:new(xPos, yPos, xSize, ySize)
  local cardHolder = {}
  local metadata = {__index = CardHolderClass}
  setmetatable(cardHolder,metadata)
  
  --Visible state
  cardHolder.position = Vector(xPos, yPos)
  cardHolder.size = Vector(cardSize.x - 5, cardSize.y - 5)
  --cardHolder.size = Vector(xSize, ySize)
  setCenterOfObject(cardHolder, Vector(xPos, yPos))
  --cardHolder.size = Vector(55, 75)
  
  --info state
  cardHolder.myCard = nil
  cardHolder.droppable = true
  cardHolder.revealed = false
  
  return cardHolder
end

function CardHolderClass:draw()
  love.graphics.setColor(0.5,0.5,0.5,0.5)
  love.graphics.rectangle("fill",self.position.x,self.position.y, 
    self.size.x, self.size.y, 6, 6)
  
end

function CardHolderClass:insert(myCard)
  self.myCard = myCard
  myCard.objectLocation = self
  self.droppable = false
end

function CardHolderClass:remove()
  self.myCard.objectLocation = nil
  self.myCard = nil
  self.droppable = true
end

function CardHolderClass:updateLocations()
  if self.myCard ~= nil then alignCenters(self, self.myCard) end
end