
require "card"

--NOTE: PLAYER CARDS ARE ALWAYS CHILDREN OF THE DECK, EVEN WHEN NOT INDECK

PlayerDeckClass = {}

function PlayerDeckClass:new(xPos, yPos, myGM)
  local deck = {}
  local metadata = {__index = PlayerDeckClass}
  setmetatable(deck,metadata)
  
  --Visible state
  deck.position = Vector(xPos, yPos)
  deck.size = cardSize
  
  --info state
  deck.childObjects = {} --CARDS WILL ALWAYS BE IN HERE NO MATTER WHAT.
  deck.cardsInDeck = {} --Cards can be removed from here without affecting childObjects.
  deck.player = nil --Both the player and the deck access eachother, so this is set when the player object recieves their deck
  
  --Gamemanager since I'm lazy
  --card.gameManager = myGM
  
  return deck
end

function PlayerDeckClass:draw()
  for _,card in ipairs(self.childObjects) do
    card:draw()
  end
end

function PlayerDeckClass:setup()
  local cardTypes = {
    --vanilla
    WoodenCowPrototype:new(),
    PegasusPrototype:new(),
    MinotaurPrototype:new(),
    TitanPrototype:new(),
    --non-vanilla
    ZeusPrototype:new(),
    AresPrototype:new(),
    HeraPrototype:new(),
    DemeterPrototype:new(),
    ArtemisPrototype:new(),
    DionysusPrototype:new(),
    MidasPrototype:new(),
    AphroditePrototype:new(),
    HephaestusPrototype:new(),
    PandoraPrototype:new()
  }
  
  for i = 1,20 do
    table.insert(self.cardsInDeck, CardClass:new(self.position.x,self.position.y,cardTypes[1 + i % #cardTypes],true, self.gameManager))
    table.insert(self.childObjects, self.cardsInDeck[i])
  end
  
  --perform shuffle
  math.randomseed(os.time())
  for i = #self.cardsInDeck, 1, -1 do
    local cardHolder = table.remove(self.cardsInDeck, i)
    table.insert(self.cardsInDeck, math.random(i,#self.cardsInDeck), cardHolder)
  end
end

function PlayerDeckClass:pullCard()
  self.player.myhand:insert(self.cardsInDeck[#self.cardsInDeck]) --Add top card from deck
  if self.player.type == PLAYERTYPES.REAL then
    self.cardsInDeck[#self.cardsInDeck].flipped = false
    self.cardsInDeck[#self.cardsInDeck].clickable = true
  end
  table.remove(self.cardsInDeck, #self.cardsInDeck) --pop top card out of deck list
  self.player.myhand:updateLocations() --update visuals so that it's in the right place
end
