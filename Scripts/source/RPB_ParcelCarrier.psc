scriptname RPB_ParcelCarrier extends ActiveMagicEffect

;/
    The parcel carrier (2026-10-15): on whoever was given a job around a parcel (RPB_Parcels.MakeCarrier): a guard who'll
    pick up a fake surrenderer's weapons and turn them in at his prison; later bounty hunters, escapes. All I do is say
    what happens to my actor, as mod events with him as the only argument; whoever gave him the job decides what it means
    (RPB_EventManager hands them on). An effect, not an alias: any number of carriers, no record for each.

    Restarted when his 3D loads again (an ability's effects are), so I keep nothing but him: the jobs live with whoever
    gave them.

@events:
    event OnEffectStart(Actor akTarget, Actor akCaster)
    event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    event OnUnload()
/;

Actor __carrier

event OnEffectStart(Actor akTarget, Actor akCaster)
    __carrier = akTarget
endEvent

; "RPB_ParcelCarrierCombatEnded": his fight is over
event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    if (aeCombatState == 0)
        self.__Send("RPB_ParcelCarrierCombatEnded")
    endif
endEvent

; "RPB_ParcelCarrierUnloaded": out of sight
event OnUnload()
    self.__Send("RPB_ParcelCarrierUnloaded")
endEvent

function __Send(string asEvent)
    if (!__carrier)
        return
    endif
    int handle = ModEvent.Create(asEvent)
    if (handle)
        ModEvent.PushForm(handle, __carrier)
        ModEvent.Send(handle)
    endif
endFunction
