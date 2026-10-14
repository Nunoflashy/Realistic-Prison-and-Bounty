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
    bool function QueueWeaponPickup(Actor akOwner, Actor akCaptor)
    function PickUpWeapons(Actor akOwner, Actor akCaptor)
    function __WatchPickup(Actor akOwner)
    bool function __PickedUp(Actor akOwner)
    ObjectReference function __FirstWeaponOnGround(int aiRefs)
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
        RPB_Memory.FastFormMap_RemoveKey(all, akOwner)
    endif
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
