
require "playerHand"
require "playerDeck"

PlayerClass = {}

PLAYERTYPES = {
  REAL = 1,
  AI = 2
}

function PlayerClass:new(playerType, hand, playerDeck)
  local player = {}
  local metadata = {__index = PlayerClass}
  setmetatable(player,metadata)
  
  --Visible state
  --...oh yeah, there is none! probably...
  
  --info state
  player.type = playerType --real or ai
  player.myhand = hand --pointer to player hand object
  player.myDeck = playerDeck --pointer to player deck object
  if player.type == PLAYERTYPES.AI then player.myhand.droppable = false end --prevent dropping if AI
  playerDeck.player = player
  hand.player = player
  
  --player stats
  player.mana = 0
  player.spendingMana = 0 --Mana that will be spent when the player ends their turn
  player.score = 0
  
  return player
end


function PlayerClass:runAI(locationList)
  math.randomseed(os.time())
  --setup info
  local playableCards = {}
  for i = 1, #self.myhand.myCards do
    table.insert(playableCards, self.myhand.myCards[i])
  end
  local playableLocations = {}
  for i = 0, 11 do
    table.insert(playableLocations, i)
  end
  --go through info for valid combos until none possible
  while #playableCards > 0 and #playableLocations > 0 do
    local curCard = table.remove(playableCards, math.random(1,#playableCards))
    if curCard.cost <= self.mana - self.spendingMana then
      while #playableLocations > 0 do
        local curHolder = table.remove(playableLocations, math.random(1,#playableLocations))
        print("curHolder" .. tostring(curHolder))
        local locID = 1+math.floor(curHolder/4)
        local holdID = 1+curHolder%4
        print(locID)
        print(holdID)
        if locationList[locID].p1CardHolders[holdID].myCard == nil then
          self.myhand:remove(curCard)
          locationList[locID].p1CardHolders[holdID]:insert(curCard)
          locationList[locID].p1CardHolders[holdID]:updateLocations()
          self.spendingMana = self.spendingMana + curCard.cost
          break;
        end
      end
    end
  end
end
