extends Node3D

signal round_finished
signal game_over
signal game_finished

@onready var beam_collision = $Anchor/BeamCollision
@onready var mark = $Anchor/Mark
@onready var nicole = $Anchor/Nicole
@onready var m_beam = $Anchor/Mark/Beam
@onready var n_beam = $Anchor/Nicole/Beam
@onready var m_sprite = $Anchor/Mark/Sprite
@onready var n_sprite = $Anchor/Nicole/Sprite
@onready var m_explode_anim = $Anchor/Mark/Explosion/AnimationPlayer
@onready var n_explode_anim = $Anchor/Nicole/Explosion/AnimationPlayer
@onready var p1_hp = $UI/P1_HP
@onready var p2_hp = $UI/P2_HP
@onready var logger = $UI/Anchor/Container/LogContainer
@onready var countdown_label = $UI/Countdown
@onready var cam_bg = $CamBG
@onready var prematch = $PreScreen/PrematchScreen
var score: float = 0.0:
	set(v):
		score = v
		beam_collision.factor = score / 100.0
		m_beam.total_width = beam_collision.extent * (beam_collision.factor + 1.0)
		n_beam.total_width = beam_collision.extent * 2 - m_beam.total_width
		
		if score >= 100.0:
			win_round("p1")
		elif score <= -100.0:
			win_round("p2")

var _enabled = false
var _round_no: int = 1
var _p2_enabled = false
var _over = false


func _ready():
	_reset()
	m_sprite.animation = "idle"
	n_sprite.animation = "idle"
	$CamSample2.make_current()
	mark.hp_changed.connect(p1_hp.set_hp)
	nicole.hp_changed.connect(p2_hp.set_hp)
	round_finished.connect(_on_round_finished)
	game_over.connect(_on_game_over)
	logger.push("MG_RPG_CONNECT_MSG", {character = _get_tl(mark.player_name)})
	logger.push("MG_RPG_CONNECT_MSG", {character = _get_tl(nicole.player_name)})
	start()


func _process(delta):
	if is_visible_in_tree() != visible:
		visible = is_visible_in_tree()
	if not _enabled:
		return
	if _p2_enabled:
		var constant_mult = [1.0, 1.6, 1.2][_round_no - 1]
		var time_variance = [-0.1, -0.3, -0.2][_round_no - 1]
		self.score -= delta \
				* (max(10.0, 60.0 * pow(score / 100.0, 2.0)) \
				* constant_mult \
				+ Utils.sin_bounded(Utils.t, 0, time_variance, _round_no))


func start():
	prematch.show()
	prematch.play_intro()
	await prematch.prematch_finished
	start_round()


func start_round():
	prematch.hide()
	
	var show_ready = _round_no > 1
	countdown_label.start_countdown(show_ready)
	if show_ready:
		await countdown_label.countdown_started
	
	m_sprite.animation = "idle"
	n_sprite.animation = "idle"
	await countdown_label.countdown_finished
	
	m_sprite.animation = "attack"
	n_sprite.animation = "attack"
	
	var tween = create_tween().set_parallel()
	tween.tween_property(m_beam, "total_width", beam_collision.extent, 0.4)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(n_beam, "total_width", beam_collision.extent, 0.4)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

	_p2_enabled = true
	_enabled = true
	beam_collision.visible = true


func mash():
	if _enabled:
		self.score += max(2.0, 10.0 * pow(score / 100.0, 1.6))
	elif countdown_label != null and countdown_label._waiting:
		countdown_label.mash()
	elif prematch != null:
		prematch.mash()


func win_round(winner: String):
	_enabled = false
	_p2_enabled = false
	beam_collision.visible = false
	(n_sprite if winner == "p1" else m_sprite).animation = "lose"

	var tween = create_tween().set_parallel()
	tween.tween_property(m_beam if winner == "p1" else n_beam, "total_width", 0, 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	if winner == "p1":
		var dmg: int = mark.atk
		nicole.take_damage(dmg)
		n_explode_anim.play("boom")

		logger.push("MG_RPG_BATTLE_MSG", {receiver = _get_tl(nicole.player_name), damage = dmg, attacker = _get_tl(mark.player_name)})
		if nicole.hp <= 0:
			logger.push("MG_RPG_DEFEAT_MSG", {character = _get_tl(nicole.player_name)})

			await get_tree().create_timer(2.5).timeout
			logger.push("MG_RPG_DISCONNECT_MSG", {character = _get_tl(nicole.player_name)})
			await get_tree().create_timer(3).timeout
			emit_signal("game_over")
			return
	elif winner == "p2":
		var dmg: int = nicole.atk
		m_explode_anim.play("boom")
		
		if mark.hp <= dmg:
			scripted_disconnect()
			return
		else:
			mark.take_damage(dmg)
		
		logger.push(
			"MG_RPG_BATTLE_MSG", {receiver = _get_tl(mark.player_name), damage = dmg, attacker = _get_tl(nicole.player_name)}
		)
	
	await tween.finished
	(m_sprite if winner == "p1" else n_sprite).animation = "win"
	emit_signal("round_finished")


func scripted_disconnect():
	_p2_enabled = false
	await Utils.wait(1)
	logger.push("MG_RPG_DISCONNECT_MSG", {character = _get_tl(nicole.player_name)})
	n_sprite.stop()
	await Utils.wait(1)
	n_sprite.visible = false
	force_game_over()


func force_game_over():
	if _over:
		return
	_over = true
	await get_tree().create_timer(5).timeout
	emit_signal("game_over")


func _on_round_finished():
	_reset()
	_round_no += 1
	
	if _round_no > 3:  #3 rounds has passed with no winner
		#force dc nicole here
		scripted_disconnect()
		return
	
	await get_tree().create_timer(1).timeout
	start_round()


func _reset():
	score = 0
	beam_collision.visible = false
	m_beam.total_width = 0
	n_beam.total_width = 0
	_enabled = false
	_p2_enabled = false


func _on_game_over():
	#go victory screen
	$Anchor.visible = false
	$UI.visible = false
	$PreScreen.visible = false
	$VictoryScreen.visible = true
	cam_bg.make_current()
	$VictoryScreen/VictoryUI.play_animation(mark)
	await $VictoryScreen/VictoryUI.finished
	emit_signal("game_finished")

func _get_tl(text):
	return tr(text)
