extends Attack

class_name SmartAttack

func execute(attacker: Robot, targets: Array[Robot]):
    var aliveTargets = targets.filter(func(t): return t.health > 0)
    if aliveTargets.size() == 0:
        return
    var target = aliveTargets[0]
    for t in aliveTargets:
        if t.health < target.health:
            target = t
    target.health -= attacker.attackPower
