
require "vector"

buttonFont = love.graphics.newFont(20)

ButtonClass = {}

BUTTONFUNCTIONS = {
  SUBMIT = 1,
  RESTART = 2
  }

function ButtonClass:new(xPos, yPos, xSize, ySize, myGM, functionality)
  local button = {}
  local metadata = {__index = ButtonClass}
  setmetatable(button,metadata)
  
  --Visible state
  button.position = Vector(xPos, yPos)
  button.size = Vector(xSize, ySize)
  --setCenterOfObject(button, Vector(xPos, yPos))
  
  --info state
  button.functionality = functionality
  button.gameManager = myGM
  print(button.gameManager.childObjects)
  button.clickable = true
  self.name = "Submit"
  
  return button
end

function ButtonClass:draw()
  love.graphics.setColor(0.1,0.1,0.1,1)
  love.graphics.rectangle("fill",self.position.x,self.position.y, 
    self.size.x, self.size.y, 6, 6)
  love.graphics.setColor(1,1,1,1)
  love.graphics.setFont(buttonFont)
  love.graphics.print(self.name,self.position.x + 2,self.position.y + 2)
  
end

function ButtonClass:onClick(myMouse)
  if self.functionality == BUTTONFUNCTIONS.SUBMIT then
    print(self.gameManager.childObjects)
    self.gameManager:submit()
  end
end