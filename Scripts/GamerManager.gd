extends Control
class_name GamerManager

@onready var gamerAnim = $Anim/Gamer/AnimationPlayer
@onready var healthStat = $Stats/Health
@onready var intelligenceStat = $Stats/Intelligence
@onready var charismaStat = $Stats/Charisma
@onready var lifeBar = $VBoxContainer/Life
@onready var happinessBar = $VBoxContainer/Happiness
@onready var socialBar = $VBoxContainer/Social
@onready var dollarsNumber = $MoneyLabel
@onready var studyText = $GridContainer/Study/RichTextLabel

var maxLife : int = 100
@onready var currentLife : int = maxLife

var maxHappiness : int = 100
@onready var currentHappiness : int = maxHappiness

var maxSocial : int = 100
@onready var currentSocial : int = maxSocial

enum GamerStatus {none, working, studying, resting, gaming, workingOut, goingOut}
@onready var gamerCurrentStatus : GamerStatus

var dollars : int = 0

var health : int = 0
var intelligence : int = 0
var charisma : int = 0

var counter : float

func _ready() -> void:
	UpdateStatsNumbers()

func _process(delta: float) -> void:
	counter += delta
	if counter > 1:
		counter = 0
		if gamerCurrentStatus == GamerStatus.working:
			ChangeIntelligence(-1)
			ChangeHealth(-1)
			ChangeHappiness(-1)
			ChangeSocial(-2)
			ChangeLife(-10/max(health / 10, 1))
		elif gamerCurrentStatus == GamerStatus.studying:
			ChangeHappiness(-1)
			ChangeSocial(-1)
		elif gamerCurrentStatus == GamerStatus.resting:
			ChangeSocial(-1)
		elif gamerCurrentStatus == GamerStatus.workingOut:
			ChangeLife(-5/max(health / 10, 1))
		elif gamerCurrentStatus == GamerStatus.goingOut:
			ChangeLife(-15/max(health /10, 1))
		
		
		if dollars < 50 * max(float(intelligence/2),1,1):
			$GridContainer/Study.disabled = true
		else: $GridContainer/Study.disabled = false
		
		if dollars < 25:
			$GridContainer/WorkOut.disabled = true
		else: $GridContainer/WorkOut.disabled = false
		
		if dollars < 35:
			$GridContainer/GoOut.disabled = true
		else: $GridContainer/GoOut.disabled = false

func _on_go_work_pressed() -> void:
	gamerAnim.play("Work")
	gamerCurrentStatus = GamerStatus.working
	ChangeDollars(5 + intelligence)


func _on_study_pressed() -> void:
		if dollars >= 50 * max(float(intelligence/2),1,1):
			gamerAnim.play("Study")
			ChangeDollars(-(50 * max(float(intelligence/2),1)))
			gamerCurrentStatus = GamerStatus.studying
			ChangeIntelligence(5)


func _on_rest_pressed() -> void:
	gamerAnim.play("Rest")
	gamerCurrentStatus = GamerStatus.resting
	ChangeLife(1 + health / 10)


func _on_game_pressed() -> void:
	gamerAnim.play("PlayVideogames")
	gamerCurrentStatus = GamerStatus.gaming
	ChangeHappiness(5)


func _on_work_out_pressed() -> void:
	if dollars >= 25:
		gamerAnim.play("WorkOut")
		ChangeDollars(-25)
		gamerCurrentStatus = GamerStatus.workingOut
		ChangeHealth(5)


func _on_go_out_pressed() -> void:
	if dollars >= 35:
		gamerAnim.play("GoOut")
		ChangeDollars(-35)
		gamerCurrentStatus = GamerStatus.goingOut
		ChangeSocial(5 + charisma / 10)

func ChangeLife(lifeChange : int):
	currentLife += lifeChange
	if currentLife > maxLife : currentLife = maxLife
	elif currentLife <= 0 :
		currentLife = 0
		GameManager.howDidLose = GameManager.losingMode.gamerEnergy
		LoseGame()
	UpdateLifeBar()

func ChangeSocial(socialChange : int):
	currentSocial += socialChange
	if currentSocial > maxSocial : currentSocial = maxSocial
	elif currentSocial <= 0 :
		currentSocial = 0
		GameManager.howDidLose = GameManager.losingMode.gamerSocial
		LoseGame()
	UpdateSocialBar()

func ChangeHappiness(happinessChange : int):
	currentHappiness += happinessChange
	if currentHappiness > maxHappiness : currentHappiness = maxHappiness
	elif currentHappiness <= 0 :
		currentHappiness = 0
		GameManager.howDidLose = GameManager.losingMode.gamerHappiness
		LoseGame()
	UpdateHappinessBar()

func ChangeDollars(dollarChange : int):
	dollars += dollarChange
	if dollars < 0 : dollars = 0
	UpdateDollarsNumber()

func UpdateDollarsNumber():
	dollarsNumber.text = "$" + str(dollars)

func ChangeIntelligence(intelligenceChange : int):
	intelligence += intelligenceChange
	if intelligence < 0 : intelligence = 0
	studyText.text = "STUDY \n($" + str(50 * max(float(intelligence/2),1)) + ")"
	UpdateStatsNumbers()

func ChangeHealth(healthChange : int):
	health += healthChange
	if health < 0 : health = 0
	UpdateStatsNumbers()

func UpdateStatsNumbers():
	healthStat.text = "HEALTH: " + str(health)
	intelligenceStat.text = "INTELLIGENCE: " + str(intelligence)
	charismaStat.text = "CHARISMA: " + str(charisma)


func UpdateLifeBar():
	lifeBar.value = float(currentLife) / float(maxLife)

func UpdateHappinessBar():
	happinessBar.value = float(currentHappiness) / float(maxHappiness)

func UpdateSocialBar():
	socialBar.value = float(currentSocial) / float(maxSocial)

func LoseGame():
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/Lose.tscn")
