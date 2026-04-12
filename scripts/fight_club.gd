extends Control

@export var teamABox: VBoxContainer
@export var teamBBox: VBoxContainer
@export var battleButton: Button
@export var scoreLabel: Label
@export var rewardBar: TextureProgressBar
@export var actionDelaySeconds: float = 1.0

signal battle_finished(winning_team: int)

var lastBattleScore: float = 0.0
var lastBattleStars: int = 0
var _battleInProgress: bool = false

# Added by Copilot
func _ready() -> void:
	if teamABox == null or teamBBox == null:
		var team_boxes: Array[Node] = get_tree().get_nodes_in_group("team_box")
		if team_boxes.size() >= 2:
			teamABox = team_boxes[0] as VBoxContainer
			teamBBox = team_boxes[1] as VBoxContainer
	if battleButton == null:
		battleButton = get_node_or_null("FightPanel/FightPanelLayout/BattleControls/BattleButton")
	if scoreLabel == null:
		scoreLabel = get_node_or_null("FightPanel/FightPanelLayout/BattleControls/ScoreLabel")
	if rewardBar == null:
		rewardBar = get_node_or_null("FightPanel/FightPanelLayout/BattleControls/RewardBar")

	if battleButton != null:
		battleButton.pressed.connect(_on_battle_button_pressed)

	# Added by Copilot
	var battle_controls := get_node_or_null("FightPanel/FightPanelLayout/BattleControls")
	if battle_controls != null:
		var back_btn := Button.new()
		back_btn.text = "Back to Sea"
		back_btn.pressed.connect(_go_back_to_sea)
		battle_controls.add_child(back_btn)

	_update_score_label(0, 0.0)

# Added by Copilot
func start_battle() -> int:
	if _battleInProgress:
		_show_battle_status("Battle already running")
		return 0
	_battleInProgress = true

	if teamABox == null or teamBBox == null:
		_show_battle_status("Teams not wired")
		_battleInProgress = false
		return 0

	var team_a_slots: Array = _get_team_slots(teamABox)
	var team_b_slots: Array = _get_team_slots(teamBBox)
	if team_a_slots.is_empty() or team_b_slots.is_empty():
		_show_battle_status("No team slots found")
		_battleInProgress = false
		return 0

	if not _team_has_living_robot(team_a_slots) or not _team_has_living_robot(team_b_slots):
		_show_battle_status("Need living robots on both teams")
		_battleInProgress = false
		return 0

	var team_a_index: int = 0
	var team_b_index: int = 0
	var active_team: int = 0
	var turn_guard: int = 0
	const MAX_TURNS: int = 1000

	var health_snapshot: Dictionary = _snapshot_health(team_a_slots + team_b_slots)
	var participating_robots: Array[Robot] = _get_participating_robots(team_a_slots + team_b_slots)

	var style_score: float = _compute_style_variance_score(team_a_slots, team_b_slots)
	var initial_a_hp: int = _sum_team_health(team_a_slots)
	var initial_b_hp: int = _sum_team_health(team_b_slots)
	var damage_to_team_a: float = 0.0
	var damage_to_team_b: float = 0.0

	_refresh_all_slots(team_a_slots)
	_refresh_all_slots(team_b_slots)

	while _team_has_living_robot(team_a_slots) and _team_has_living_robot(team_b_slots):
		if turn_guard >= MAX_TURNS:
			break
		turn_guard += 1

		if active_team == 0:
			var before_b_hp: int = _sum_team_health(team_b_slots)
			team_a_index = await _execute_team_turn(team_a_slots, team_b_slots, team_a_index)
			var after_b_hp: int = _sum_team_health(team_b_slots)
			damage_to_team_b += float(max(0, before_b_hp - after_b_hp))
		else:
			var before_a_hp: int = _sum_team_health(team_a_slots)
			team_b_index = await _execute_team_turn(team_b_slots, team_a_slots, team_b_index)
			var after_a_hp: int = _sum_team_health(team_a_slots)
			damage_to_team_a += float(max(0, before_a_hp - after_a_hp))

		_refresh_all_slots(team_a_slots)
		_refresh_all_slots(team_b_slots)
		active_team = 1 - active_team

	var winner: int = 0
	if _team_has_living_robot(team_a_slots) and not _team_has_living_robot(team_b_slots):
		winner = 1
	elif _team_has_living_robot(team_b_slots) and not _team_has_living_robot(team_a_slots):
		winner = 2

	var final_a_hp: int = _sum_team_health(team_a_slots)
	var final_b_hp: int = _sum_team_health(team_b_slots)
	var hp_lost_total: int = max(0, (initial_a_hp + initial_b_hp) - (final_a_hp + final_b_hp))

	var length_score: float = _compute_fight_length_score(turn_guard)
	var balance_score: float = _compute_balance_score(damage_to_team_a, damage_to_team_b)
	var hp_loss_score: float = _compute_hp_loss_score(hp_lost_total)
	var total_score: float = _compute_total_score(style_score, length_score, balance_score, hp_loss_score)
	var stars: int = _score_to_stars(total_score)
	lastBattleScore = total_score
	lastBattleStars = stars

	var stars_text: String = ""
	for _i in range(stars):
		stars_text += "*"
	_update_score_label(stars, total_score)
	GameController.register_fight_energy_reward(stars)
	if scoreLabel != null:
		scoreLabel.text = ""
	emit_signal("battle_finished", winner)

	await get_tree().create_timer(3.0).timeout
	_return_all_to_roster(team_a_slots + team_b_slots, health_snapshot, participating_robots)
	_battleInProgress = false
	return winner

# Added by Copilot
func _get_team_slots(team_box: VBoxContainer) -> Array:
	var slots: Array = []
	for child in team_box.get_children():
		if child is Control and child.has_method("set_slot_data") and child.has_method("clear_slot_data"):
			slots.append(child)
	return slots

# Added by Copilot
func _team_has_living_robot(team_slots: Array) -> bool:
	for slot in team_slots:
		var robot: Robot = slot.slotted_robot
		if robot != null and robot.health > 0:
			return true
	return false

# Added by Copilot
func _execute_team_turn(attacker_slots: Array, defender_slots: Array, start_index: int) -> int:
	if attacker_slots.is_empty():
		return 0

	var attacker_slot: Control = _find_next_living_slot(attacker_slots, start_index)
	if attacker_slot == null:
		return start_index

	var attacker: Robot = attacker_slot.slotted_robot
	if attacker == null or attacker.health <= 0:
		return start_index

	var target_robots: Array[Robot] = _get_living_robots(defender_slots)
	if target_robots.is_empty():
		return (attacker_slots.find(attacker_slot) + 1) % attacker_slots.size()

	if attacker_slot.has_method("set_active_indicator"):
		attacker_slot.set_active_indicator(true)

	for robot_function in attacker.functions:
		if robot_function == null:
			continue
		if robot_function.has_method("execute"):
			robot_function.execute(attacker, target_robots)
			_clamp_non_negative_health(defender_slots)
			_refresh_all_slots(attacker_slots)
			_refresh_all_slots(defender_slots)
			await _wait_action_delay()
			target_robots = _get_living_robots(defender_slots)
			if target_robots.is_empty():
				break

	if attacker_slot.has_method("set_active_indicator"):
		attacker_slot.set_active_indicator(false)

	return (attacker_slots.find(attacker_slot) + 1) % attacker_slots.size()

# Added by Copilot
func _find_next_living_slot(team_slots: Array, start_index: int) -> Control:
	if team_slots.is_empty():
		return null

	for offset in range(team_slots.size()):
		var idx: int = (start_index + offset) % team_slots.size()
		var slot: Control = team_slots[idx]
		var robot: Robot = slot.slotted_robot
		if robot != null and robot.health > 0:
			return slot

	return null

# Added by Copilot
func _get_living_robots(team_slots: Array) -> Array[Robot]:
	var living: Array[Robot] = []
	for slot in team_slots:
		var robot: Robot = slot.slotted_robot
		if robot != null and robot.health > 0:
			living.append(robot)
	return living

# Added by Copilot
func _snapshot_health(all_slots: Array) -> Dictionary:
	var snapshot: Dictionary = {}
	for slot in all_slots:
		var robot: Robot = slot.slotted_robot
		if robot != null:
			snapshot[robot] = robot.health
	return snapshot

# Added by Copilot
func _get_participating_robots(all_slots: Array) -> Array[Robot]:
	var robots: Array[Robot] = []
	var seen: Dictionary = {}
	for slot in all_slots:
		var robot: Robot = slot.slotted_robot
		if robot == null:
			continue
		if seen.has(robot):
			continue
		seen[robot] = true
		robots.append(robot)
	return robots

# Added by Copilot
func _return_all_to_roster(all_slots: Array, snapshot: Dictionary, participating_robots: Array[Robot]) -> void:
	var rosters: Array[Node] = get_tree().get_nodes_in_group("fighter_roster")
	var roster: Node = rosters[0] if rosters.size() > 0 else null
	var part_inventories: Array[Node] = get_tree().get_nodes_in_group("spare_parts_inventory")
	var part_inventory: Node = part_inventories[0] if part_inventories.size() > 0 else null
	var participating_lookup: Dictionary = {}
	for robot in participating_robots:
		participating_lookup[robot] = true

	for slot in all_slots:
		var robot: Robot = slot.slotted_robot
		if robot == null:
			continue

		if participating_lookup.has(robot):
			robot.register_completed_fight()

		if robot.is_broken():
			GameController.remove_fight_robot(robot)
			var salvage_part: SparePart = GameController.create_spare_part_from_tier(robot.tier)
			if salvage_part != null:
				GameController.add_fight_part(salvage_part)
				if part_inventory != null and part_inventory.has_method("add_part_card"):
					part_inventory.add_part_card(salvage_part)
		else:
			if snapshot.has(robot):
				robot.health = snapshot[robot]
			if roster != null and roster.has_method("add_robot_card"):
				roster.add_robot_card(robot)
		slot.clear_slot_data()

# Added by Copilot
func _clamp_non_negative_health(team_slots: Array) -> void:
	for slot in team_slots:
		var robot: Robot = slot.slotted_robot
		if robot != null and robot.health < 0:
			robot.health = 0

# Added by Copilot
func _refresh_all_slots(team_slots: Array) -> void:
	for slot in team_slots:
		if slot.has_method("refresh_slot_visuals"):
			slot.refresh_slot_visuals()

# Added by Copilot
func _sum_team_health(team_slots: Array) -> int:
	var total: int = 0
	for slot in team_slots:
		var robot: Robot = slot.slotted_robot
		if robot != null and robot.health > 0:
			total += robot.health
	return total

# Added by Copilot
func _compute_style_variance_score(team_a_slots: Array, team_b_slots: Array) -> float:
	var seen_styles := {}
	var total_functions: int = 0

	for slot in team_a_slots + team_b_slots:
		var robot: Robot = slot.slotted_robot
		if robot == null or robot.health <= 0:
			continue
		for robot_function in robot.functions:
			if robot_function == null:
				continue
			var style_name: String = String(robot_function.name)
			seen_styles[style_name] = true
			total_functions += 1

	if total_functions <= 0:
		return 0.0

	var unique_count: int = seen_styles.size()
	return clamp(float(unique_count) / min(4.0, float(total_functions)), 0.0, 1.0)

# Added by Copilot
func _compute_fight_length_score(turns: int) -> float:
	if turns <= 0:
		return 0.0

	const IDEAL_TURNS: float = 10.0
	const HARD_PENALTY_START: float = 16.0
	const HARD_PENALTY_END: float = 30.0

	var centered: float = clamp(1.0 - abs(float(turns) - IDEAL_TURNS) / IDEAL_TURNS, 0.0, 1.0)
	if float(turns) <= HARD_PENALTY_START:
		return centered

	var penalty: float = clamp(1.0 - (float(turns) - HARD_PENALTY_START) / (HARD_PENALTY_END - HARD_PENALTY_START), 0.0, 1.0)
	return centered * penalty

# Added by Copilot
func _compute_balance_score(damage_to_team_a: float, damage_to_team_b: float) -> float:
	var total_damage: float = damage_to_team_a + damage_to_team_b
	if total_damage <= 0.0:
		return 0.0
	var diff: float = abs(damage_to_team_a - damage_to_team_b)
	return clamp(1.0 - diff / total_damage, 0.0, 1.0)

# Added by Copilot
func _compute_hp_loss_score(hp_lost_total: int) -> float:
	# Higher raw HP loss indicates bigger/stronger fights.
	return clamp(float(hp_lost_total) / 20.0, 0.0, 1.0)

# Added by Copilot
func _compute_total_score(style_score: float, length_score: float, balance_score: float, hp_loss_score: float) -> float:
	return (
		style_score * 0.25 +
		length_score * 0.25 +
		balance_score * 0.25 +
		hp_loss_score * 0.25
	)

# Added by Copilot
func _score_to_stars(score: float) -> int:
	return int(clamp(round(score * 5.0), 1.0, 5.0))

# Added by Copilot
func _update_score_label(stars: int, score: float) -> void:
	if scoreLabel == null:
		return
	if stars <= 0:
		if scoreLabel != null:
			scoreLabel.text = ""
		if rewardBar != null:
			rewardBar.max_value = 5.0
			rewardBar.min_value = 0.0
			rewardBar.step = 1.0
			rewardBar.value = 0.0
		return
	if scoreLabel != null:
		scoreLabel.text = ""
	if rewardBar != null:
		rewardBar.max_value = 5.0
		rewardBar.min_value = 0.0
		rewardBar.step = 1.0
		rewardBar.value = stars

# Added by Copilot
func _show_battle_status(message: String) -> void:
	if scoreLabel == null:
		return
	scoreLabel.text = message

# Added by Copilot
func _go_back_to_sea() -> void:
	if _battleInProgress:
		return
	get_tree().change_scene_to_file("res://scenes/SeaOfScrap.tscn")

# Added by Copilot
func _on_battle_button_pressed() -> void:
	if _battleInProgress:
		return
	if battleButton != null:
		battleButton.disabled = true
	await start_battle()
	if battleButton != null:
		battleButton.disabled = false

# Added by Copilot
func _wait_action_delay() -> void:
	if actionDelaySeconds <= 0.0:
		return
	await get_tree().create_timer(actionDelaySeconds).timeout
