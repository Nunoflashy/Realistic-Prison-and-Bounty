scriptname RPB_Restraints extends ObjectReference

import RPB_Utility

Idle property Idle_BoundHandsBehindBack
    Idle function get()
        return Game.GetFormEx(0xB600A) as Idle
    endFunction
endProperty

Idle property Idle_BoundHandsBehindBackInstant
    Idle function get()
        return Game.GetFormEx(0x109837) as Idle
    endFunction
endProperty

Idle property Idle_ForceDefaultState
    Idle function get()
        return Game.GetFormEx(0x86840) as Idle
    endFunction
endProperty


function Apply(Actor akActor)

endFunction

function Remove(Actor akActor)

endFunction

; If the cuffs are of Metal or a material that makes sense having a locking mechanism
function LockCuffs(int aiLockLevel)
endFunction

function UnlockCuffs()
endFunction

event OnActivate(ObjectReference akRef)
    ; Check type of cuffs (Hand, Feet, Chains)
    ; Check material of cuffs

    Debug("Restraints::OnActivate", "Equipped Restraints " + GetName())
    ; For now, just use leather from the animation
    (akRef as Actor).PlayIdle(Idle_BoundHandsBehindBackInstant)
    RetainAI()

    ; Lock controls if player
endEvent

event OnEquipped(Actor akActor)
    ; Check type of cuffs (Hand, Feet, Chains)
    ; Check material of cuffs

    Debug("Restraints::OnEquipped", "Equipped Restraints " + GetName())
    ; For now, just use leather from the animation
    akActor.PlayIdle(Idle_BoundHandsBehindBackInstant)
    RetainAI()

    ; Lock controls if player

endEvent

event OnUnequipped(Actor akActor)
    ; Restore controls
    ; Cancel the behind the back animation possibly
endEvent