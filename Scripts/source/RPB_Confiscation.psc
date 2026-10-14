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
    function UnblockDroppedWeapons(Actor akOwner)
    bool function QueueWeaponPickup(Actor akOwner, Actor akCaptor)
    function PickUpWeapons(Actor akOwner, Actor akCaptor)
    function __WatchPickup(Actor akOwner)
    bool function __PickedUp(Actor akOwner)
    ObjectReference function __FirstWeaponOnGround(int aiRefs)
    function HandIn(Actor akOwner, ObjectReference akChest)
    int function GetConfiscated(Actor akOwner)
    function ReturnConfiscated(Actor akOwner)
    int function __ReturnFromHolder(Actor akOwner)
@events:
    event OnUpdate()
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
        self.UnblockDroppedWeapons(akOwner) ; whatever of it is still on the ground is anybody's now
        RPB_Memory.FastFormMap_RemoveKey(all, akOwner)
    endif
endFunction

;/
    What @akOwner dropped surrendering can be picked up again (RPB_Surrender blocks it at the drop: nobody takes it while
    the surrender is on). The ones picked up already aren't in the world any more (nothing to unblock)
/;
function UnblockDroppedWeapons(Actor akOwner)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record)
        return
    endif
    int refs = RPB_Memory.FastMap_GetObject(record, "refs")
    int i = 0
    while (i < RPB_Memory.FastArray_Size(refs))
        ObjectReference ref = RPB_Memory.FastArray_GetForm(refs, i) as ObjectReference
        if (ref)
            ref.BlockActivation(false)
        endif
        i += 1
    endWhile
endFunction

; ==========================================================
;                  The captor's pickup
; ==========================================================

; How long the pickup Scene waits in the queue to start, and then for him to reach the weapon, before it's given up
float property PICKUP_START_WAIT_SECONDS = 30.0 autoreadonly
float property PICKUP_REACH_SECONDS = 20.0 autoreadonly

;/
    After the cuffs, before the escort (RPB_Arrestee): @akCaptor walks to what @akOwner dropped and picks it up (the pickup
    Scene, queued ahead of the escort). Nothing dropped, or nothing of it left on the ground (someone took it): nothing
    queued. Returns whether it was queued. A watch gives it up if it never starts or he can't reach it, so the escort
    always follows: the weapon then stays on the ground
/;
bool function QueueWeaponPickup(Actor akOwner, Actor akCaptor)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record || !akCaptor)
        return false
    endif
    ObjectReference target = self.__FirstWeaponOnGround(RPB_Memory.FastMap_GetObject(record, "refs"))
    if (!target)
        RPB_Utility.LogInfo("Nothing of " + akOwner + "'s dropped weapons is left on the ground, no pickup", "Confiscation::QueueWeaponPickup")
        self.ForgetDroppedWeapons(akOwner)
        return false
    endif
    RPB_Memory.FastMap_SetForm(record, "captor", akCaptor)
    API.SceneManager.StartPickUpWeapons(akCaptor, target, akOwner)
    RPB_Utility.LogInfo(akCaptor + " picks up " + akOwner + "'s dropped weapons (walking to " + target + ")", "Confiscation::QueueWeaponPickup")
    ; The watch on a stack of its own (the caller goes on to queue the escort)
    __watchedOwner = akOwner
    RegisterForSingleUpdate(0.1)
    return true
endFunction

Actor __watchedOwner

event OnUpdate()
    Actor owner = __watchedOwner
    __watchedOwner = none
    if (owner)
        self.__WatchPickup(owner)
    endif
endEvent

;/
    Gives up the pickup Scene of @akOwner's weapons if it doesn't start within PICKUP_START_WAIT_SECONDS (a queue held up),
    or the captor doesn't reach the weapon within PICKUP_REACH_SECONDS of its start (no path, the weapon fell somewhere he
    can't go): the Scene is ended and the queue goes on to the escort, the weapon left on the ground. Real seconds, a menu's
    time not counted (the waits are counted)
/;
function __WatchPickup(Actor akOwner)
    RPB_SceneManager sceneManager = API.SceneManager
    string pickupScene = sceneManager.SCENE_PICK_UP_WEAPONS_01
    float waited = 0.0
    while (sceneManager.GetCurrentScene() != pickupScene && waited < PICKUP_START_WAIT_SECONDS)
        Utility.Wait(0.5)
        waited += 0.5
    endWhile
    if (sceneManager.GetCurrentScene() != pickupScene)
        RPB_Utility.LogInfo("The pickup of " + akOwner + "'s weapons never started (" + (waited as int) + "s), the weapons stay on the ground", "Confiscation::__WatchPickup")
        self.UnblockDroppedWeapons(akOwner)
        return
    endif
    waited = 0.0
    while (sceneManager.GetCurrentScene() == pickupScene && !self.__PickedUp(akOwner) && waited < PICKUP_REACH_SECONDS)
        Utility.Wait(0.5)
        waited += 0.5
    endWhile
    if (sceneManager.GetCurrentScene() == pickupScene && !self.__PickedUp(akOwner))
        RPB_Utility.LogWarn("The captor didn't reach " + akOwner + "'s dropped weapons in " + (waited as int) + "s, the pickup is given up (they stay on the ground)", "Confiscation::__WatchPickup")
        sceneManager.EndSceneEarly(pickupScene, "the captor didn't reach the dropped weapons")
        self.UnblockDroppedWeapons(akOwner) ; left on the ground: anybody's
    endif
endFunction

; Whether the pickup of @akOwner's weapons is done (or under way: the "Pick Up" phase began)
bool function __PickedUp(Actor akOwner)
    int record = self.GetDroppedWeapons(akOwner)
    return !record || RPB_Memory.FastMap_GetInt(record, "pickup") != 0
endFunction

; The first of @aiRefs still lying in the world (taken by someone, it's no longer in a loaded cell), or none
ObjectReference function __FirstWeaponOnGround(int aiRefs)
    int i = 0
    while (i < RPB_Memory.FastArray_Size(aiRefs))
        ObjectReference ref = RPB_Memory.FastArray_GetForm(aiRefs, i) as ObjectReference
        if (ref && ref.Is3DLoaded())
            return ref
        endif
        i += 1
    endWhile
    return none
endFunction

;/
    The pickup Scene's "Pick Up" phase (RPB_SceneManager -> RPB_EventManager.OnPickUpWeapons, on a stack of its own): the
    captor, by the weapon, bends down (IdlePickup_Ground) and each of @akOwner's dropped weapons still on the ground goes
    into his inventory. Moved by its reference (AddItem of the dropped reference), so it's the same weapon, tempering and
    enchantment included, and it isn't an activation (no theft of an item owned by the surrenderer). He may equip it if
    it's better than his own (the engine's choice). What he holds is recorded for the hand-in at the prison
/;
function PickUpWeapons(Actor akOwner, Actor akCaptor)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record || !akCaptor || RPB_Utility.IsFrozenNPC(akCaptor))
        return
    endif
    RPB_Memory.FastMap_SetInt(record, "pickup", 1)
    Debug.SendAnimationEvent(akCaptor, "IdlePickup_Ground")
    Utility.Wait(0.6) ; the hand down to the ground
    int refs = RPB_Memory.FastMap_GetObject(record, "refs")
    int items = RPB_Memory.FastMap_GetObject(record, "items")
    int held = JArray.object()
    int i = 0
    while (i < RPB_Memory.FastArray_Size(refs))
        ObjectReference ref = RPB_Memory.FastArray_GetForm(refs, i) as ObjectReference
        if (ref && ref.Is3DLoaded())
            akCaptor.AddItem(ref, 1, true)
            RPB_Memory.FastArray_AddForm(held, RPB_Memory.FastArray_GetForm(items, i))
        endif
        i += 1
    endWhile
    RPB_Memory.FastMap_SetObject(record, "held", held)
    RPB_Memory.FastMap_SetForm(record, "holder", akCaptor)
    RPB_Utility.LogInfo(akCaptor + " picked up " + RPB_Memory.FastArray_Size(held) + " of " + RPB_Memory.FastArray_Size(refs) + " of " + akOwner + "'s dropped weapons", "Confiscation::PickUpWeapons")
endFunction

; ==========================================================
;                The hand-in and the return
; ==========================================================

;/
    At the prison (RPB_Prison.PrepareArrival, the arrival's setup): what was picked up of @akOwner's dropped weapons goes
    from whoever holds it into her belongings chest @akChest, on her Confiscated list (returned at the release, whether or
    not she was stripped). Never picked up (given up, or no pickup on the way): it stays where it fell, lost. Its holder
    dead (he died on the way, or inside before the escort's end): it stays on his body. Its holder frozen: no call into
    him, it stays on him, and the release or a cancel tries him again. By the item, not the reference (in an inventory
    there's none left): with his own copy of it, which one goes is the engine's choice
/;
function HandIn(Actor akOwner, ObjectReference akChest)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record)
        return
    endif
    int held = RPB_Memory.FastMap_GetObject(record, "held")
    Actor holder = RPB_Memory.FastMap_GetForm(record, "holder") as Actor
    if (!held || !holder)
        RPB_Utility.LogInfo(akOwner + "'s dropped weapons were never picked up, they stay where they fell", "Confiscation::HandIn")
        self.ForgetDroppedWeapons(akOwner)
        return
    endif
    if (RPB_Utility.IsDeadNoCall(holder))
        RPB_Utility.LogInfo(holder + " died holding " + akOwner + "'s weapons, they stay on his body", "Confiscation::HandIn")
        self.ForgetDroppedWeapons(akOwner)
        return
    endif
    if (!akChest || RPB_Utility.IsFrozenNPC(holder))
        RPB_Utility.LogWarn("Not handing in " + akOwner + "'s weapons now (chest: " + akChest + ", " + holder + " frozen: " + RPB_Utility.IsFrozenNPC(holder) + "), he keeps them until the release", "Confiscation::HandIn")
        return
    endif
    int confiscated = self.GetConfiscated(akOwner)
    if (!confiscated)
        confiscated = JMap.object()
        RPB_Memory.FastMap_SetObject(confiscated, "items", JArray.object())
        int all = JDB.solveObj(".rpb_root.confiscated")
        if (!all)
            all = JFormMap.object()
            JDB.solveObjSetter(".rpb_root.confiscated", all, true)
        endif
        RPB_Memory.FastFormMap_SetObject(all, akOwner, confiscated)
    endif
    RPB_Memory.FastMap_SetForm(confiscated, "chest", akChest)
    int items = RPB_Memory.FastMap_GetObject(confiscated, "items")
    int handedIn = 0
    int i = 0
    while (i < RPB_Memory.FastArray_Size(held))
        Form item = RPB_Memory.FastArray_GetForm(held, i)
        if (item && holder.GetItemCount(item) > 0)
            holder.RemoveItem(item, 1, true, akChest)
            RPB_Memory.FastArray_AddForm(items, item)
            handedIn += 1
        endif
        i += 1
    endWhile
    self.ForgetDroppedWeapons(akOwner)
    RPB_Utility.LogInfo(holder + " handed in " + handedIn + " of " + RPB_Memory.FastArray_Size(held) + " of " + akOwner + "'s weapons into " + akChest, "Confiscation::HandIn")
endFunction

; @akOwner's Confiscated list (a JMap: "items" the items, "chest" where they're kept), 0 with none
int function GetConfiscated(Actor akOwner)
    int all = JDB.solveObj(".rpb_root.confiscated")
    if (!all)
        return 0
    endif
    return RPB_Memory.FastFormMap_GetObject(all, akOwner)
endFunction

;/
    At the release (RPB_Prison.TeleportPrisonerToRelease) or a cancelled arrest (RPB_Recovery.CancelArrest): @akOwner gets
    back what was confiscated from her, out of the chest it was handed into, and what a living guard still holds (a cancel
    before the prison, a hand-in a frozen guard missed). Anything gone from the chest (taken by someone) isn't returned
/;
function ReturnConfiscated(Actor akOwner)
    int fromHolder = self.__ReturnFromHolder(akOwner)
    int confiscated = self.GetConfiscated(akOwner)
    if (!confiscated)
        if (fromHolder > 0)
            RPB_Utility.LogInfo("Returned " + fromHolder + " of " + akOwner + "'s weapons from the guard who held them", "Confiscation::ReturnConfiscated")
        endif
        return
    endif
    ObjectReference chest = RPB_Memory.FastMap_GetForm(confiscated, "chest") as ObjectReference
    int items = RPB_Memory.FastMap_GetObject(confiscated, "items")
    int returned = 0
    int i = 0
    while (chest && i < RPB_Memory.FastArray_Size(items))
        Form item = RPB_Memory.FastArray_GetForm(items, i)
        if (item && chest.GetItemCount(item) > 0)
            chest.RemoveItem(item, 1, true, akOwner)
            returned += 1
        endif
        i += 1
    endWhile
    RPB_Memory.FastFormMap_RemoveKey(JDB.solveObj(".rpb_root.confiscated"), akOwner)
    RPB_Utility.LogInfo("Returned " + returned + " of " + RPB_Memory.FastArray_Size(items) + " confiscated items to " + akOwner + " from " + chest + " (" + fromHolder + " from the guard)", "Confiscation::ReturnConfiscated")
endFunction

; The dropped weapons a living, unfrozen guard still holds go back to @akOwner (dead: on his body; never picked up: where
; they fell), the record forgotten either way. How many went back
int function __ReturnFromHolder(Actor akOwner)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record)
        return 0
    endif
    int held = RPB_Memory.FastMap_GetObject(record, "held")
    Actor holder = RPB_Memory.FastMap_GetForm(record, "holder") as Actor
    self.ForgetDroppedWeapons(akOwner)
    if (!held || !holder || RPB_Utility.IsDeadNoCall(holder) || RPB_Utility.IsFrozenNPC(holder))
        return 0
    endif
    int returned = 0
    int i = 0
    while (i < RPB_Memory.FastArray_Size(held))
        Form item = RPB_Memory.FastArray_GetForm(held, i)
        if (item && holder.GetItemCount(item) > 0)
            holder.RemoveItem(item, 1, true, akOwner)
            returned += 1
        endif
        i += 1
    endWhile
    return returned
endFunction
