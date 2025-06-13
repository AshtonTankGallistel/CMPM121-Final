
require "cardHolder"

LocationClass = {}

function LocationClass:new(xPos, yPos, xSize, ySize)
  local location = {}
  local metadata = {__index = LocationClass}
  setmetatable(location,metadata)
  
  --Visible state
  location.position = Vector(xPos, yPos)
  location.size = Vector(xSize, ySize)
  location.pointsWon = nil
  
  --info state
  location.childObjects = {}
  location.p1CardHolders = {}
  local xPosition = location.size.x / 5 + location.position.x
  local yPosition = location.size.y / 4 + location.position.y
  for i = 1,4 do
    table.insert(location.p1CardHolders, CardHolderClass:new(xPosition,yPosition,55,75))
    xPosition = xPosition + location.size.x / 5
    table.insert(location.childObjects, location.p1CardHolders[i])
    location.p1CardHolders[i].droppable = false --TODO: have this be decided by which player is AI. Currently always p1, but should be choosable
  end
  location.p2CardHolders = {}
  xPosition = location.size.x / 5 + location.position.x
  yPosition = 3*location.size.y / 4 + location.position.y
  for i = 1,4 do
    table.insert(location.p2CardHolders, CardHolderClass:new(xPosition,yPosition,55,75))
    xPosition = xPosition + location.size.x / 5
    table.insert(location.childObjects, location.p2CardHolders[i])
  end
  location.cardHolders = {location.p1CardHolders, location.p2CardHolders}
  
  return location
end

function LocationClass:draw()
  love.graphics.setColor(0.6,0.3,0.3,1)
  love.graphics.rectangle("fill",self.position.x,self.position.y, 
    self.size.x, self.size.y, 24, 24)
  
  for _,holder in ipairs(self.p1CardHolders) do
    holder:draw()
  end
  for _,holder in ipairs(self.p2CardHolders) do
    holder:draw()
  end
  
  --display points won
  if self.pointsWon ~= nil then
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(largeFont)
    if self.pointsWon < 0 then --p2
      love.graphics.print(self.pointsWon,self.position.x,self.position.y + self.size.y)
    else --p1
      love.graphics.print(-self.pointsWon,self.position.x,self.position.y-10)
    end
  end
end

function LocationClass:lockCards(gameManager)
  for _,holder in ipairs(self.p1CardHolders) do
    if holder.myCard ~= nil then
      holder.myCard.flipped = false
      holder.myCard:lockSelf()
      if holder.revealed == false then --if just revealed
        holder.revealed = true --set it as such...
        if holder.myCard.behavior.onReveal ~= nil then --then, run the 'on reveal' effect
          holder.myCard.behavior:onReveal(gameManager, 1, holder.myCard, self)
        end
      end
    end
  end
  for _,holder in ipairs(self.p2CardHolders) do
    if holder.myCard ~= nil then
      holder.myCard.flipped = false
      holder.myCard:lockSelf()
      if holder.revealed == false then
        holder.revealed = true
        if holder.myCard.behavior.onReveal ~= nil then
          holder.myCard.behavior:onReveal(gameManager, 2, holder.myCard, self)
        end
      end
    end
  end
end

--positive value is p1, negative is p2
function LocationClass:determineScore()
  local score = 0
  for i = 1,4 do
    local p1score
    local p2score
    if self.p1CardHolders[i].myCard == nil then p1score = 0 else p1score = self.p1CardHolders[i].myCard.power end
    if self.p2CardHolders[i].myCard == nil then p2score = 0 else p2score = self.p2CardHolders[i].myCard.power end
    score = score + (p1score - p2score)
  end
  return score
end

--hides all cards for the player under pNum
function LocationClass:hideFreshCards(pNum)
  for _,holder in ipairs(self.cardHolders[pNum]) do
    if holder.revealed == false and holder.myCard ~= nil then
      holder.myCard.flipped = true
    end
  end
end
