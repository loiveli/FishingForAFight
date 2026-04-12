extends Attack

class_name BasicAttack

func execute(attacker: Robot, targets: Array[Robot]):
    targets[0].health -= attacker.attackPower
