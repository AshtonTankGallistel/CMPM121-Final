
CardPrototype = {}

function CardPrototype:new(name, cst, pow, txt)
  local behavior = {}
  local metadata = {__index = CardPrototype}
  setmetatable(behavior,metadata)
  
  --info state
  behavior.name = name
  behavior.baseCost = cst
  behavior.basePower = pow
  behavior.text = txt
  
  return behavior
end

--function CardPrototype:onReveal(gameManager, pNum, myCard, myLocation)
--  return
--end
--These prototypes are meant to 'slot' into regular cards, which pull information from them.
--New ones aren't made when called; rather, a pointer to the same store of info is returned when new() is ran
----------------
-- CARD TYPES --
----------------
--Wooden Cow--
WoodenCowPrototype = CardPrototype:new(
  "Wooden Cow",
  1,
  1
)
function WoodenCowPrototype:new()
  return WoodenCowPrototype
end
--Pegasus--
PegasusPrototype = CardPrototype:new(
  "Pegasus",
  3,
  5
)
function PegasusPrototype:new()
  return PegasusPrototype
end
--Minotaur--
MinotaurPrototype = CardPrototype:new(
  "Minotaur",
  5,
  9
)
function MinotaurPrototype:new()
  return MinotaurPrototype
end
--Titan--
TitanPrototype = CardPrototype:new(
  "Titan",
  6,
  12
)
function TitanPrototype:new()
  return TitanPrototype
end
--Zeus-- (1)
ZeusPrototype = CardPrototype:new(
  "Zeus",
  4,
  6,
  "When Revealed: Lower the power of each card in your opponent's hand by 1."
)
function ZeusPrototype:new()
  return ZeusPrototype
end
function ZeusPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  --if pNum == 1 then 2 else 1
  local enemyPNum = (pNum == 1) and 2 or 1
  for _,card in ipairs(gameManager.players[enemyPNum].myhand.myCards) do
    card:signalReacting()
    card.power = math.max(0,card.power - 1) --decrease by 1, unless it'd go below 0
  end
end
--Ares-- (2)
AresPrototype = CardPrototype:new(
  "Ares",
  6,
  8,
  "When Revealed: Gain +2 power for each enemy card here."
)
function AresPrototype:new()
  return AresPrototype
end
function AresPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  local enemyPNum = (pNum == 1) and 2 or 1
  for _,cardHolder in ipairs(myLocation.cardHolders[enemyPNum]) do
    if cardHolder.myCard ~= nil then
      myCard.power = myCard.power + 2
    end
  end
end
--Hera-- (3)
HeraPrototype = CardPrototype:new(
  "Hera",
  4,
  6,
  "When Revealed: Give cards in your hand +1 power."
)
function HeraPrototype:new()
  return HeraPrototype
end
function HeraPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  for _,card in ipairs(gameManager.players[pNum].myhand.myCards) do
    card:signalReacting()
    card.power = card.power + 1
  end
end
--Demeter-- (4)
DemeterPrototype = CardPrototype:new(
  "Demeter",
  4,
  6,
  "When Revealed: Both players draw a card."
)
function DemeterPrototype:new()
  return DemeterPrototype
end
function DemeterPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  gameManager.players[1].myDeck:pullCard()
  gameManager.players[2].myDeck:pullCard()
end

--Artemis-- (5)
ArtemisPrototype = CardPrototype:new(
  "Artemis",
  4,
  6,
  "When Revealed: Gain +5 power if there is exactly one enemy card here."
)
function ArtemisPrototype:new()
  return ArtemisPrototype
end
function ArtemisPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  local enemyPNum = (pNum == 1) and 2 or 1
  local enCardsPresent = 0
  for _,cardHolder in ipairs(myLocation.cardHolders[enemyPNum]) do
    if cardHolder.myCard ~= nil then
      enCardsPresent = enCardsPresent + 1
    end
  end
  if enCardsPresent == 1 then
    myCard.power = myCard.power + 5
  end
end
--Dionysus-- (6)
DionysusPrototype = CardPrototype:new(
  "Dionysus",
  4,
  6,
  "When Revealed: Gain +2 power for each of your other cards here."
)
function DionysusPrototype:new()
  return DionysusPrototype
end
function DionysusPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  for _,cardHolder in ipairs(myLocation.cardHolders[pNum]) do
    if cardHolder.myCard ~= nil then
      if myCard ~= cardHolder.myCard then
        myCard.power = myCard.power + 2
      end
    end
  end
end
--Midas-- (7)
MidasPrototype = CardPrototype:new(
  "Midas",
  3,
  3,
  "When Revealed: Set ALL cards here to 3 power."
)
function MidasPrototype:new()
  return MidasPrototype
end
function MidasPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  for i = 1,2 do
    for _,cardHolder in ipairs(myLocation.cardHolders[i]) do
      if cardHolder.myCard ~= nil then
        cardHolder.myCard:signalReacting()
        cardHolder.myCard.power = 3
      end
    end
  end
end
--Aphrodite-- (8)
AphroditePrototype = CardPrototype:new(
  "Aphrodite",
  4,
  6,
  "When Revealed: Lower the power of each enemy card here by 1."
)
function AphroditePrototype:new()
  return AphroditePrototype
end
function AphroditePrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  local enemyPNum = (pNum == 1) and 2 or 1
  for _,cardHolder in ipairs(myLocation.cardHolders[enemyPNum]) do
    if cardHolder.myCard ~= nil then
      cardHolder.myCard:signalReacting()
      cardHolder.myCard.power = math.max(0,cardHolder.myCard.power - 1)
    end
  end
end
--Hephaestus-- (9)
HephaestusPrototype = CardPrototype:new(
  "Hephaestus",
  4,
  3,
  "When Revealed: Lower the cost of 2 cards in your hand by 1."
)
function HephaestusPrototype:new()
  return HephaestusPrototype
end
function HephaestusPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  --create list of valid cards to affect
  local validCards = {}
  for i = 1, #gameManager.players[pNum].myhand.myCards do table.insert(validCards, i) end
  local affectedCardCount = 0
  --only run until there are no cards left to affect, or 2 cards have been affected
  while #validCards > 0 and affectedCardCount < 2 do
    --select card
    local cardNum = math.random(1,#validCards)
    table.remove(validCards,cardNum)
    --apply effect
    gameManager.players[pNum].myhand.myCards[cardNum]:signalReacting()
    gameManager.players[pNum].myhand.myCards[cardNum].cost = gameManager.players[pNum].myhand.myCards[cardNum].cost - 1
    affectedCardCount = affectedCardCount + 1
  end
end
--Pandora-- (10)
PandoraPrototype = CardPrototype:new(
  "Pandora",
  2,
  5,
  "When Revealed: If no ally cards are here, lower this card's power by 5."
)
function PandoraPrototype:new()
  return PandoraPrototype
end
function PandoraPrototype:onReveal(gameManager, pNum, myCard, myLocation)
  myCard:signalEffect()
  local allyCardsPresent = 0
  for _,cardHolder in ipairs(myLocation.cardHolders[pNum]) do
    if cardHolder.myCard ~= nil then
      allyCardsPresent = allyCardsPresent + 1
    end
  end
  if allyCardsPresent == 0 then
    myCard.power = math.max(0,myCard.power - 5)
  end
end