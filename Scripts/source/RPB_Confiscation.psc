scriptname RPB_Confiscation extends Quest

;/
    What's taken from someone and kept for them (2026-10-14): first the weapons a surrenderer drops (RPB_Surrender), picked
    up by the captor after the cuffs, handed in at the prison into its belongings chest and returned at the release; a
    fake surrender's turn in to the hold's prison. Later stolen items too (they'll count toward the sentence). Kept apart
    from the strip's belongings manifest: stripping is optional per hold, and what's confiscated is taken whether or not
    she's stripped.

@references:
    RPB_API API
@functions:
    function RecordDroppedWeapons(Actor akOwner, int aiRefs, int aiItems)
    int function GetDroppedWeapons(Actor akOwner)
    function ForgetDroppedWeapons(Actor akOwner)
/;

; ==========================================================
;                      Script References
; ==========================================================

RPB_API property API
    RPB_API function get()
        return RPB_API.GetSelf()
    endFunction
endProperty

; ==========================================================
;                     Dropped weapons
; ==========================================================

;/
    Remembers the weapons @akOwner just dropped: @aiRefs the dropped references, @aiItems their items (JArrays, the same
    order), in .rpb_root.droppedWeapons by owner. A new drop replaces the last one's record; nothing dropped forgets it.
    The dropped references aren't made persistent: the engine's cell reset cleans them up, and a gone one reads as none.
/;
function RecordDroppedWeapons(Actor akOwner, int aiRefs, int aiItems)
    if (RPB_Memory.FastArray_Size(aiRefs) == 0)
        self.ForgetDroppedWeapons(akOwner)
        return
    endif
    int record = JMap.object()
    RPB_Memory.FastMap_SetObject(record, "refs", aiRefs)
    RPB_Memory.FastMap_SetObject(record, "items", aiItems)
    RPB_Memory.FastMap_SetFloat(record, "time", Utility.GetCurrentGameTime())
    int all = JDB.solveObj(".rpb_root.droppedWeapons")
    if (!all)
        all = JFormMap.object()
        JDB.solveObjSetter(".rpb_root.droppedWeapons", all, true)
    endif
    RPB_Memory.FastFormMap_SetObject(all, akOwner, record)
endFunction

; The record of @akOwner's dropped weapons (a JMap: "refs", "items", "time"), 0 with none
int function GetDroppedWeapons(Actor akOwner)
    int all = JDB.solveObj(".rpb_root.droppedWeapons")
    if (!all)
        return 0
    endif
    return RPB_Memory.FastFormMap_GetObject(all, akOwner)
endFunction

function ForgetDroppedWeapons(Actor akOwner)
    int all = JDB.solveObj(".rpb_root.droppedWeapons")
    if (all)
        RPB_Memory.FastFormMap_RemoveKey(all, akOwner)
    endif
endFunction
