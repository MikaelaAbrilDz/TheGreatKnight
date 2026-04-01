extends Control
class_name KnightManager

const tavernPrice = 100

@export var bgDungeon : Texture2D
@export var bgMarket : Texture2D
@export var bgTavern : Texture2D

@export var enemies : Array[Enemy]
@onready var currentEnemy : Enemy = enemies[0]
@onready var currentEnemyLife : int = enemies[0].life

@export var enemiesAnim : Array[AnimationPlayer]
@export var enemiesVisuals : Array[Control]

@export var helmets : Array[Helmet]
@export var swords : Array[Sword]
@export var shields : Array[Shield]
@export var currentHelmet : Helmet
@export var currentSword : Sword
@export var currentShield : Shield
var nextObj : Resource

@onready var gamerManager : GamerManager = $"../Gamer"

@onready var anim : AnimationPlayer = $Anim/Knight/AnimationPlayer

@onready var knightLifeBar = $VBoxContainer/Life
@onready var knightSocialBar = $VBoxContainer/Social
@onready var knightLevelBar = $VBoxContainer/Level
@onready var goldText = $GoldLabel
@onready var goldTextOnDeal = $Deal/GoldLabel
@onready var fightText = $GridContainer/Fight/RichTextLabel
@onready var marketText = $GridContainer/Market/RichTextLabel
@onready var attackStat = $Stats/Attack
@onready var defenseStat = $Stats/Defense
@onready var healStat = $Stats/Heal
@onready var coinStat = $Stats/Coin
@onready var charismaStat = $Stats/Charisma
@onready var dealUI = $Deal
@onready var currentNameText = $Deal/Current/Name
@onready var newNameText = $Deal/New/Name
@onready var currentImage = $Deal/Current/TextureRect
@onready var newImage = $Deal/New/TextureRect
@onready var acceptText = $Deal/Options/Accept/RichTextLabel

@onready var currentHelmetImage = $Inventory/Helmet/TextureRect
@onready var currentShieldImage = $Inventory/Shield/TextureRect
@onready var currentSwordImage = $Inventory/Sword/TextureRect

@onready var sfxManager : SfxManager = $"../SfxManager"

enum KnightStatus {none, fighting, resting, tavern, market}

var knightMaxLife : int = 100
@onready var knightCurrentLife : int = knightMaxLife

var knightMaxSocial : int = 100
@onready var knightCurrentSocial : int = knightMaxSocial

var gold : int = 0
var marketPrice : int = 50

var experience : int = 0

var knightHeal : int = 5
var knightCharisma : int = 5
var knightAttack : int = 5
var knightLevel : int = 1
var enemyLevel : int = 1
@onready var knightCurrentStatus : KnightStatus

var midTransition : bool = false

var counterForSocial : float
var counterForEnemyAttack : float

var isFinalBoss : bool = false
var won : bool = false

func _ready() -> void:
	UpdateStatsNumbers()
	for i in enemiesAnim:
		i.animation_set_next("Enter", "Attack")
	for i in enemiesVisuals: i.visible = false
	$Anim/Enemies/Goblin/GoblinAnim.speed_scale = 0
	$Anim/Enemies/Goblin/GoblinAnim.play("Enter")

func _process(delta: float) -> void:
	if knightCurrentStatus != KnightStatus.tavern and knightCurrentStatus != KnightStatus.market:
		counterForSocial += delta
		if counterForSocial > 1:
			counterForSocial = 0
			ChangeKnightSocial(min(max(knightLevel / 4, 1), 20) * -1)
	
	if knightCurrentStatus == KnightStatus.fighting and not won:
		counterForEnemyAttack += delta
		if counterForEnemyAttack > 5 - currentEnemy.speed:
			counterForEnemyAttack = 0
			ChangeKnightLife(min(-currentEnemy.damage + currentShield.addedDefense + currentHelmet.addedDefense, 0))
	
	if gold < tavernPrice: $GridContainer/Tavern.disabled = true
	else: $GridContainer/Tavern.disabled = false
		
	if gold < marketPrice: $GridContainer/Market.disabled = true
	else: $GridContainer/Market.disabled = false
	

func _on_fight_pressed() -> void:
	knightCurrentStatus = KnightStatus.fighting
	anim.play("Fight")
	$BG/Enviro.texture = bgDungeon
	ChangeEnemyLife(min(-knightAttack - currentSword.addedAttack + currentEnemy.armor, 0))
	
	for i in enemiesVisuals: i.visible = true
	for i in enemiesAnim: i.speed_scale = 1

func _on_rest_pressed() -> void:
	knightCurrentStatus = KnightStatus.resting
	anim.play("Rest")
	ChangeKnightLife(knightHeal + currentShield.addedHealing)
	
	for i in enemiesVisuals: i.visible = false
	for i in enemiesAnim: i.speed_scale = 0

func _on_tavern_pressed() -> void:
	if gold >= tavernPrice:
		knightCurrentStatus = KnightStatus.tavern
		anim.play("Party")
		$BG/Enviro.texture = bgTavern
		ChangeGold(-tavernPrice)
		ChangeKnightSocial(knightCharisma * 2 + currentHelmet.addedCharisma)
		
		for i in enemiesVisuals: i.visible = false
		for i in enemiesAnim: i.speed_scale = 0

func _on_market_pressed() -> void:
	if gold >= marketPrice:
		knightCurrentStatus = KnightStatus.market
		anim.play("Market")
		$BG/Enviro.texture = bgMarket
		ChangeGold(-marketPrice)
		marketPrice = (max(knightLevel/2, 1)) * (randi() % 49 + 1) + (gold * 0.1)
		marketText.text = "GO TO THE MARKET \n(" + str(marketPrice) + " GOLD)" 
		var randomNum = randf()
		print(randomNum)
		if randomNum > 0.66:
			GetDeal(swords[randi() % min(max(knightLevel/3, 1), len(swords))])
		elif randomNum > 0.33:
			GetDeal(shields[randi() % min(max(knightLevel/3, 1), len(shields))])
		elif randomNum > 0:
			GetDeal(helmets[randi() % min(max(knightLevel/3, 1), len(helmets))])
		
		for i in enemiesVisuals: i.visible = false
		for i in enemiesAnim: i.speed_scale = 0

func ChangeKnightLife(lifeChange : int):
	if lifeChange < 0:
		$BG/KnightDamage.text = str(lifeChange)
		if not $BG/KnightDamage.visible : $BG/KnightDamage.visible = true
		else:
			$BG/KnightDamage.ResetStuff()
	elif  lifeChange > 0:
		$BG/KnightHealing.text = "+" + str(lifeChange)
		if not $BG/KnightHealing.visible : $BG/KnightHealing.visible = true
		else:
			$BG/KnightHealing.ResetStuff()
	knightCurrentLife += lifeChange
	if knightCurrentLife > knightMaxLife : knightCurrentLife = knightMaxLife
	elif knightCurrentLife <= 0 :
		knightCurrentLife = 0
		GameManager.howDidLose = GameManager.losingMode.knightLife
		LoseGame()
	UpdateKnightLifeBar()

func ChangeKnightSocial(socialChange : int):
	knightCurrentSocial += socialChange
	if knightCurrentSocial > knightMaxSocial : knightCurrentSocial = knightMaxSocial
	elif knightCurrentSocial <= 0 :
		knightCurrentSocial = 0
		GameManager.howDidLose = GameManager.losingMode.knightSocial
		LoseGame()
	UpdateKnightSocialBar()

func ChangeGold(goldChange : int):
	if goldChange > 0:
		$BG/GoldUp.text = "+ " + str(goldChange)
		if not $BG/GoldUp.visible : $BG/GoldUp.visible = true
		else: $BG/GoldUp.ResetStuff()
	elif goldChange < 0:
		$BG/GoldDown.text = str(goldChange)
		if not $BG/GoldDown.visible : $BG/GoldDown.visible = true
		else: $BG/GoldDown.ResetStuff()
	gold += goldChange
	if gold < 0 : gold = 0
	UpdateGoldNumber()

func ChangeExperience(xpChange : int):
	experience += xpChange
	if experience < 0 : experience = 0
	if experience > 100 * (knightLevel + 2):
		experience = experience - (100 * (knightLevel + 2))
		LevelUp()
	UpdateKnightLevelBar()

func ChangeEnemyLife(lifeChange : int):
	$BG/EnemyDamage.text = str(lifeChange)
	if not $BG/EnemyDamage.visible : $BG/EnemyDamage.visible = true
	else:
		$BG/EnemyDamage.ResetStuff()
	
	currentEnemyLife += lifeChange
	if currentEnemyLife < 0 : currentEnemyLife = 0
	if currentEnemyLife == 0 :
		ChangeGold((currentEnemy.life + ((currentEnemy.damage * 15 / (6 - currentEnemy.speed))) / 2) * currentSword.moneyMultiplier)
		ChangeExperience(currentEnemy.life + (currentEnemy.damage * 10))
		if isFinalBoss and not won:
			WinGame()
		else:
			SetNewEnemy()

func UpdateKnightLifeBar():
	knightLifeBar.value = float(knightCurrentLife) / float(knightMaxLife)

func UpdateKnightSocialBar():
	knightSocialBar.value = float(knightCurrentSocial) / float(knightMaxSocial)

func UpdateKnightLevelBar():
	knightLevelBar.value = float(experience) / float(100 * knightLevel)

func UpdateGoldNumber():
	goldText.text = "GOLD: " + str(gold)
	goldTextOnDeal.text = "GOLD: " + str(gold)

func UpdateStatsNumbers():
	attackStat.text = "ATTACK: " + str(knightAttack + currentSword.addedAttack)
	defenseStat.text = "DEFENSE: " + str(currentShield.addedDefense + currentHelmet.addedDefense)
	charismaStat.text = "CHARISMA: " + str(knightCharisma + currentHelmet.addedCharisma)
	healStat.text = "HEAL: " + str(knightHeal + currentShield.addedHealing)
	coinStat.text = "COIN MULT: " + str(currentSword.moneyMultiplier)

func UpdateInventoryImages():
	currentSwordImage.texture = currentSword.visual
	currentShieldImage.texture = currentShield.visual
	currentHelmetImage.texture = currentHelmet.visual

func LevelUp():
	sfxManager.PlaySfx(SfxManager.sfx.KnightLevelUp)
	knightLevel += 1
	knightAttack += 1
	$BG/KnightLevelUp.visible = true
	UpdateStatsNumbers()
	if knightLevel == 5:
		enemyLevel = 2
	elif knightLevel == 10: 
		enemyLevel = 3
	elif knightLevel == 15: #CHANGE TO DOLLARS
		enemyLevel = 4
		FirstTransition()
	elif knightLevel == 20:
		enemyLevel = 5
	elif knightLevel == 25:
		enemyLevel = 6
	elif knightLevel == 35:
		enemyLevel = 7
	elif knightLevel == 40:
		enemyLevel = 8

func FirstTransition():
		midTransition = true
		GetDeal(swords[4])
		$Deal/Options/Decline.visible = false
		knightCurrentStatus = KnightStatus.tavern
		anim.play("Market")
		$BG/Enviro.texture = bgMarket
		await get_tree().create_timer(0.2).timeout
		knightCurrentStatus = KnightStatus.tavern
		anim.play("Market")
		$BG/Enviro.texture = bgMarket
		await get_tree().create_timer(5).timeout
		knightCurrentStatus = KnightStatus.tavern
		anim.play("Market")
		$BG/Enviro.texture = bgMarket
		for i in enemiesVisuals: i.visible = false
		for i in enemiesAnim: i.speed_scale = 0
		$"../MusicManager".ChangeMusicToGamer()
		$"../Camera2D".Move(Vector2(2086, 0))
		$"..".FirstTransition()

func SetNewEnemy():
	var enemyIndex = randi() % min(enemyLevel, len(enemies))
	
	for i in len(enemiesAnim):
		if currentEnemy == enemies[i]:
			enemiesAnim[i].play("Die")
	
	currentEnemy = enemies[enemyIndex]
	
	for i in len(enemiesAnim):
		if i == enemyIndex:
			EnemyEnter(enemiesAnim[i])
	
	if enemyIndex == len(enemies) - 1:
		isFinalBoss = true
	
	currentEnemyLife = currentEnemy.life
	counterForEnemyAttack = -1
	fightText.text = "FIGHT " + currentEnemy.name

func EnemyEnter(enemyToEnter):
	await get_tree().create_timer(1).timeout
	for i in len(enemiesAnim):
		if enemies[i] == currentEnemy and enemiesAnim[i] == enemyToEnter:
			enemyToEnter.play("Enter")

func GetDeal(dealObj : Resource):
	newNameText.text = dealObj.name
	newImage.texture = dealObj.visual
	$TitleHolder/Mover.disabled = true
	if dealObj.priceIsInDollars :
		acceptText.text = "ACCEPT ($" + str(dealObj.price) + ")"
		goldTextOnDeal.text = "$" + str(gamerManager.dollars)
	else :
		acceptText.text = "ACCEPT (" + str(dealObj.price - (knightCharisma * knightCharisma) - currentHelmet.addedCharisma) + " GOLD)"
		goldTextOnDeal.text = "GOLD: " + str(gold)
	nextObj = dealObj
	if dealObj.type == "Sword":
		currentNameText.text = currentSword.name
		currentImage.texture = currentSword.visual
		var a = dealObj.addedAttack - currentSword.addedAttack
		if a < 0 : $Deal/FirstStat.text = str(a) + " attack"
		else : $Deal/FirstStat.text = "+ " + str(a) + " attack"
		var b = dealObj.moneyMultiplier - currentSword.moneyMultiplier
		if b < 0 : $Deal/SecondStat.text = str(b) + " coin mult."
		else : $Deal/SecondStat.text = "+ " + str(b) + " coin mult."
	elif dealObj.type == "Shield":
		currentNameText.text = currentShield.name
		currentImage.texture = currentShield.visual
		var a = dealObj.addedDefense - currentShield.addedDefense
		if a < 0 : $Deal/FirstStat.text = str(a) + " defense"
		else : $Deal/FirstStat.text = "+ " + str(a) + " defense"
		var b = dealObj.addedHealing - currentShield.addedHealing
		if b < 0 : $Deal/SecondStat.text = str(b) + " heal"
		else : $Deal/SecondStat.text = "+ " + str(b) + " heal"
	elif dealObj.type == "Helmet":
		currentNameText.text = currentHelmet.name
		currentImage.texture = currentHelmet.visual
		var a = dealObj.addedDefense - currentHelmet.addedDefense
		if a < 0 : $Deal/FirstStat.text = str(a) + " defense"
		else : $Deal/FirstStat.text = "+ " + str(a) + " defense"
		var b = dealObj.addedCharisma - currentHelmet.addedCharisma
		if b < 0 : $Deal/SecondStat.text = str(b) + " charisma"
		else : $Deal/SecondStat.text = "+ " + str(b) + " charisma"
	
	dealUI.Move(Vector2(-803.0, -308.0))
	
func AcceptDeal():
	if midTransition and gamerManager.dollars < nextObj.price:
		$"../Camera2D".Move(Vector2(2086, 0))
		$"../MusicManager".ChangeMusicToGamer()
		for i in enemiesVisuals: i.visible = false
		for i in enemiesAnim: i.speed_scale = 0
	else:
		midTransition = false
		$Deal/Options/Decline.visible = true
		if not nextObj.priceIsInDollars and gold >= nextObj.price - (knightCharisma * knightCharisma) - currentHelmet.addedCharisma:
			ChangeGold(-nextObj.price + (knightCharisma * knightCharisma) + currentHelmet.addedCharisma)
			if nextObj.type == "Sword":
				currentSword = nextObj
			elif nextObj.type == "Shield":
				currentShield = nextObj
			elif nextObj.type == "Helmet":
				currentHelmet = nextObj
			UpdateStatsNumbers()
			UpdateInventoryImages()
			dealUI.Move(Vector2(-803.0, 572))
		if nextObj.priceIsInDollars and gamerManager.dollars >= nextObj.price:
			gamerManager.ChangeDollars(-nextObj.price)
			if nextObj.type == "Sword":
				currentSword = nextObj
			elif nextObj.type == "Shield":
				currentShield = nextObj
			elif nextObj.type == "Helmet":
				currentHelmet = nextObj
			UpdateStatsNumbers()
			UpdateInventoryImages()
			dealUI.Move(Vector2(-803.0, 572))
		
		$TitleHolder/Mover.disabled = false

func _on_gamerMover_pressed() -> void:
	goldTextOnDeal.text = "$" + str(gamerManager.dollars)

func DeclineDeal() -> void:
	$TitleHolder/Mover.disabled = false
	dealUI.Move(Vector2(-803.0, 572))

func WinGame():
	won = true
	for i in len(enemiesAnim):
		if currentEnemy == enemies[i]:
			enemiesAnim[i].play("Die")
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Scenes/Win.tscn")

func LoseGame():
	await get_tree().create_timer(0.3).timeout
	if knightCurrentLife == 0 or knightCurrentSocial == 0:
		get_tree().change_scene_to_file("res://Scenes/Lose.tscn")
