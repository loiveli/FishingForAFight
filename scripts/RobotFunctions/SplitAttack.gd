extends Attack

class_name SplitAttack

func execute(attacker: Robot, targets: Array[Robot]):
    for target in targets:
        target.health -= round(attacker.attackPower / targets.size())
