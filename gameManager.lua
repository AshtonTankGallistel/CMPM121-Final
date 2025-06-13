
require "player"
require "location"
require "button"

GameManagerClass = {}

function GameManagerClass:new(playerType, hand)
  local manager = {}
  local metadata = {__index = GameManagerClass}
  setmetatable(manager,metadata)
  
  --Visible state
  --...oh yeah, there is none! probably...
  
  --info state
  manager.childObjects = {}
  --info on players
  manager.player1Hand = PlayerHandClass:new(450,50,500,100)
  table.insert(manager.childObjects, manager.player1Hand)
  manager.player1Deck = PlayerDeckClass:new(350,50)
  table.insert(manager.childObjects, manager.player1Deck)
  manager.player2Hand = PlayerHandClass:new(450,800,500,100)
  table.insert(manager.childObjects, manager.player2Hand)
  manager.player2Deck = PlayerDeckClass:new(350,800)
  table.insert(manager.childObjects, manager.player2Deck)
  manager.player1 = PlayerClass:new(PLAYERTYPES.AI, manager.player1Hand, manager.player1Deck)
  manager.player2 = PlayerClass:new(PLAYERTYPES.REAL, manager.player2Hand, manager.player2Deck)
  manager.players = {manager.player1, manager.player2}
  --info on locations
  manager.locations = {}
  for i = 0,2 do --loop through the 3 locations required and add them to both the location list and the child list
    table.insert(manager.locations, LocationClass:new(10 + i*(450+20),350,460,300))
    table.insert(manager.childObjects, manager.locations[i+1])
  end
  
  
  --game stats
  manager.turn = 1
  manager.winScore = 15
  manager.processingResults = false
  manager.processTime = 1
  manager.eventQueue = {}
  manager.winner = nil
  
  return manager
end

function GameManagerClass:draw()
  local black = {0,0,0,1}
  
  --location display
  for _,location in ipairs(self.locations) do
    location:draw()
  end
  --P1
  self.player1Hand:draw()
  self.player1Deck:draw()
  love.graphics.setColor(black)
  love.graphics.setFont(largeFont)
  love.graphics.print("Score:" .. tostring(self.player1.score),self.player1Hand.position.x -20,self.player1Hand.position.y - 40)
  if self.player1.spendingMana == 0 then
    love.graphics.print("Mana:" .. tostring(self.player1.mana),self.player1Hand.position.x -20,self.player1Hand.position.y - 20)
  else
    love.graphics.print("Mana:"..tostring(self.player1.mana).." - "..tostring(self.player1.spendingMana).." = "..tostring(self.player1.mana-self.player1.spendingMana),
      self.player1Hand.position.x -20,self.player1Hand.position.y - 20)
  end
  --P2
  self.player2Hand:draw()
  self.player2Deck:draw()
  love.graphics.setColor(black)
  love.graphics.setFont(largeFont)
  love.graphics.print("Score:" .. tostring(self.player2.score),self.player2Hand.position.x -20,self.player2Hand.position.y - 40)
  love.graphics.print("Mana:" .. tostring(self.player2.mana),self.player2Hand.position.x -20,self.player2Hand.position.y - 20)
  if self.player2.spendingMana == 0 then
    love.graphics.print("Mana:" .. tostring(self.player2.mana),self.player2Hand.position.x -20,self.player2Hand.position.y - 20)
  else
    love.graphics.print("Mana:"..tostring(self.player2.mana).." - "..tostring(self.player2.spendingMana).." = "..tostring(self.player2.mana-self.player2.spendingMana),
      self.player2Hand.position.x -20,self.player2Hand.position.y - 20)
  end
  
  --WINNER DISPLAY ZONE
  if self.winner ~= nil then
    love.graphics.setColor(0.1,0.1,0.1,0.8)
    love.graphics.rectangle("fill",20,20, 
      1400, 920, 64, 64)
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(megaFont)
    if self.winner == 1 then
      love.graphics.print("Player 1 won!",520,445)
    else
      love.graphics.print("Player 2 won!",520,445)
    end
  end
  
end


function GameManagerClass:update(dt)
  --A coroutine would be preferable, but I can't figure out how they work in lua before the submission time...
  if self.processingResults and #self.eventQueue > 0 then
    self.processTime = self.processTime - dt
    if self.processTime <= 0 then
      self.processTime = 1
      --updating here
      self.eventQueue[1]()
      table.remove(self.eventQueue, 1)
    end
  end
  
  
end


function GameManagerClass:start()
  --setup P1
  self.player1Deck:setup()
  for i = 1,3 do self.player1Deck:pullCard() end
  self.player1.mana = self.turn
  --setup P2
  self.player2Deck:setup()
  for i = 1,3 do self.player2Deck:pullCard() end
  self.player2.mana = self.turn
  
end

function GameManagerClass:endSubmission()
  self.player1.mana = self.player1.mana - self.player1.spendingMana
  self.player1Hand:resetCardOutlines()
  self.player2.mana = self.player2.mana - self.player2.spendingMana
  self.player2Hand:resetCardOutlines()
  for _,location in ipairs(self.locations) do
    location:lockCards(self)
  end
  self.turn = self.turn + 1
end

function GameManagerClass:compareLocationPlays()
  for _,location in ipairs(self.locations) do
    local score = location:determineScore()
    --returns positive if p1, and negative if p2
    if score >= 0 then self.player1.score = self.player1.score + score else self.player2.score = self.player2.score - score end
  end
end

function GameManagerClass:startSubmission()
  --update mana
  self.player1.spendingMana = 0
  self.player1.mana = self.turn
  self.player2.spendingMana = 0
  self.player2.mana = self.turn
  --draw
  if #self.player1Hand.myCards < 7 then self.player1Deck:pullCard() end
  if #self.player2Hand.myCards < 7 then self.player2Deck:pullCard() end
end

function GameManagerClass:checkWin()
  if self.player1.score > self.winScore then
    self.winner = 1
  elseif self.player2.score > self.winScore then
    self.winner = 2
  end
end

function GameManagerClass:submit()
  if self.processingResults or self.winner then return end
--  self.processingResults = true
  
  --Update player info in prep for submission
  for pNum,player in ipairs(self.players) do
    if player.type == PLAYERTYPES.AI then
      --Do AI player turn
      player:runAI(self.locations)
    else --not AI
      --Hide fresh cards from non-AI
      for _,location in ipairs(self.locations) do
--        location:hideFreshCards(pNum)
      end
    end
  end
  --Player is done with their turn - now we go through the results
--  self.eventQueue = {}
--  table.insert(self.eventQueue,self.compareLocationPlaysAt(self, 1))
--  table.insert(self.eventQueue,self.compareLocationPlaysAt(self, 2))
--  table.insert(self.eventQueue,self.compareLocationPlaysAt(self, 3))
  self:endSubmission()
  self:compareLocationPlays()
  self:checkWin()
  if winner ~= nil then return end
  self:startSubmission()
  --self.processingResults = false
end

--Our barely servicable code has ascended. Beyond lies only the refuse and regret of it's creation.
--function GameManagerClass:compareLocationPlaysAt(myGM, i)
--  return function compLocPlays()
--    local score = myGM.locations[i]:determineScore()
--    --returns positive if p1, and negative if p2
--    if score >= 0 then myGM.player1.score = myGM.player1.score + score else myGM.player2.score = myGM.player2.score - score end
--    myGM.locations[i].pointsWon = score
--  end
--  --return compLocPlays
--end

--function GameManagerClass:
