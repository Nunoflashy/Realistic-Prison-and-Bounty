scriptname RPB_Confiscation extends Quest

;/
    What's taken from someone and kept for them (2026-10-14): first the weapons a surrenderer drops (RPB_Surrender), picked
    up by the captor after the cuffs, handed in at the prison into its belongings chest and returned at the release; a
    fake surrender's turn in to the hold's prison. Later stolen items too (they'll count toward the sentence). Kept apart
    from the strip's belongings: stripping is optional per hold, and what's confiscated is taken whether or not she's
    stripped.

    What's picked up goes into a parcel of hers of its own ("Weapons", RPB_Parcels, 2026-10-15): the captor carries its
    token ("Ralof's Weapons"), not the weapons, so he can't equip them and the exact items come back; at the prison the
    token goes into her belongings chest. Records from before it (the weapons themselves on the guard, a Confiscated list
    of items) are still handed in and returned item by item. A guard who takes over the arrest takes the token from the
    old one (CaptorChanged), so slipping away later means getting it back from whoever escorts her.

    A fake surrender (RPB_Surrender.__FakeSurrender, OnFakeSurrender): the guards who were coming become parcel carriers
    (RPB_ParcelCarrier), and PICKUP_AFTER_FAKE_PERCENT decides whether they go after what she dropped. With two or more,
    the nearest runs for it at once while the others fight (a package override ignoring combat: the engine won't start a
    Scene with an actor in combat); alone, he goes once his fight is over, or picks it up off-screen when he unloads. Carried, the token goes to his hold's prison, into its
    belongings chest, when he unloads: .rpb_root.turnedIn by parcel ("owner", "hold", "until", "carrier", "chest").
    Arrested in that hold before "until" (the hold's memory of the fake surrender), it's hers again (ClaimTurnedIn, at
    the arrival): returned at the release with the rest. After that it's lost: left where it is (stealable), not returned.

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
    function OnFakeSurrender(Actor akOwner, Actor[] akGuards, Faction akCrimeFaction)
    function OnCarrierCombatEnded(Actor akCarrier)
    function OnCarrierUnloaded(Actor akCarrier)
    bool function __RollPickup(Actor akOwner, int aiRecord, string asWhen)
    function __Claim(Actor akOwner, int aiRecord, Actor akCarrier)
    bool function __Fetch(Actor akOwner, int aiRecord, Actor akCarrier)
    function WatchFetch(Actor akOwner)
    function __EndFetch(int aiRecord, Actor akFetcher)
    function ResumeFetchesAfterLoad()
    function __PickUpOffScreen(Actor akOwner, int aiRecord, Actor akCarrier)
    function __TurnInPickup(Actor akOwner, int aiRecord, ObjectReference akParcel, Actor akCarrier)
    function __TurnInCarried(Actor akCarrier)
    function __TurnIn(ObjectReference akParcel, int aiEntry, Actor akCarrier)
    function __DropCarriersOf(Actor akOwner, Actor akExcept)
    int function __Map(string asPath)
    function __DropCarrier(Actor akCarrier)
    function CaptorChanged(Actor akOwner, Actor akOldCaptor, Actor akNewCaptor)
    function HandIn(Actor akOwner, ObjectReference akChest)
    function ClaimTurnedIn(Actor akOwner, string asHold, ObjectReference akChest)
    int function GetConfiscated(Actor akOwner)
    function ReturnConfiscated(Actor akOwner)
    int function __ReturnFromHolder(Actor akOwner)
    int function __ConfiscatedRecord(Actor akOwner, ObjectReference akChest)
    bool function __OpenIfHeldBy(ObjectReference akParcel, ObjectReference akHolder1, ObjectReference akHolder2, Actor akOwner)
    int function __HandInHeldItems(Actor akOwner, ObjectReference akChest, int aiRecord)
    string function __OwnerName(Actor akOwner)
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
    if (RPB_Memory.FastMap_GetForm(record, "parcel"))
        return false ; picked up already (the hand-in takes it from whoever holds it)
    endif
    ObjectReference target = self.__FirstWeaponOnGround(RPB_Memory.FastMap_GetObject(record, "refs"))
    if (!target)
        RPB_Utility.LogInfo("Nothing of " + akOwner + "'s dropped weapons is left on the ground, no pickup", "Confiscation::QueueWeaponPickup")
        self.__DropCarriersOf(akOwner, none)
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
        self.__DropCarriersOf(akOwner, none)
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
        self.__DropCarriersOf(akOwner, none)
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
    into her "Weapons" parcel, whose token he's given. Moved by its reference (the parcel's AddItem of the dropped
    reference), so it's the same weapon, tempering and enchantment included, and it isn't an activation (no theft of an
    item owned by the surrenderer). He holds only the token: nothing of hers to equip
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
    if (!self.__FirstWeaponOnGround(refs))
        RPB_Utility.LogInfo("Nothing of " + akOwner + "'s dropped weapons is left on the ground for " + akCaptor + " to pick up", "Confiscation::PickUpWeapons")
        return
    endif
    ObjectReference nearest = self.__FirstWeaponOnGround(refs)
    if (akCaptor.GetDistance(nearest) > PICKUP_REACH * 2.0)
        RPB_Utility.LogWarn(akCaptor + " is too far from " + akOwner + "'s dropped weapons to pick them up (" + (akCaptor.GetDistance(nearest) as int) + " from " + nearest + ")", "Confiscation::PickUpWeapons")
        RPB_Memory.FastMap_SetInt(record, "pickup", 0)
        return
    endif
    RPB_Parcels parcels = API.Parcels
    ObjectReference parcel = parcels.Create(akOwner, "Weapons", self.__OwnerName(akOwner) + "'s Weapons")
    if (!parcel)
        return ; logged by Create: they stay on the ground
    endif
    int picked = 0
    int i = 0
    while (i < RPB_Memory.FastArray_Size(refs))
        ObjectReference ref = RPB_Memory.FastArray_GetForm(refs, i) as ObjectReference
        if (ref && ref.Is3DLoaded() && akCaptor.GetDistance(ref) <= PICKUP_REACH * 2.0)
            parcels.PutRef(parcel, ref)
            picked += 1
        endif
        i += 1
    endWhile
    parcels.GiveTo(parcel, akCaptor)
    RPB_Memory.FastMap_SetForm(record, "parcel", parcel)
    RPB_Memory.FastMap_SetForm(record, "captor", akCaptor) ; who has it: a cancel opens it from him
    RPB_Utility.LogInfo(akCaptor + " picked up " + picked + " of " + RPB_Memory.FastArray_Size(refs) + " of " + akOwner + "'s dropped weapons, into " + parcel, "Confiscation::PickUpWeapons")
    if (RPB_Memory.FastMap_GetInt(record, "fake"))
        self.__TurnInPickup(akOwner, record, parcel, akCaptor)
    endif
endFunction

; ==========================================================
;                    A fake surrender's pickup
; ==========================================================

; The chance the guards go after a fake surrenderer's dropped weapons at all (an MCM option later)
int property PICKUP_AFTER_FAKE_PERCENT = 75 autoreadonly

;/
    @akOwner left her surrender while @akGuards were coming (RPB_Surrender.__FakeSurrender, after the surrender's undo and
    before they fight her): with weapons dropped, each living guard becomes a parcel carrier for them
    (.rpb_root.parcelCarriers: carrier -> owner), and the record remembers the hold (@akCrimeFaction's) and until when it
    remembers the fake surrender. Two guards or more: the roll now, and the one nearest the weapons goes for them while the
    others fight (the pickup's package ignores combat). One guard: he fights; the roll and the pickup come when his fight
    is over, or off-screen when he unloads (OnCarrierCombatEnded, OnCarrierUnloaded)
/;
function OnFakeSurrender(Actor akOwner, Actor[] akGuards, Faction akCrimeFaction)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record || !akCrimeFaction)
        return
    endif
    RPB_Memory.FastMap_SetInt(record, "fake", 1)
    RPB_Memory.FastMap_SetString(record, "hold", RPB_Utility.GetFormNameCached(akCrimeFaction))
    RPB_Memory.FastMap_SetFloat(record, "until", API.Surrender.GetFakedSurrenderUntil(akOwner, akCrimeFaction))
    RPB_Parcels parcels = API.Parcels
    int carriers = self.__Map(".rpb_root.parcelCarriers")
    ObjectReference target = self.__FirstWeaponOnGround(RPB_Memory.FastMap_GetObject(record, "refs"))
    Actor nearest = none
    float nearestDistance = 0.0
    int made = 0
    int i = 0
    while (i < akGuards.Length)
        Actor guard = akGuards[i]
        if (guard && !RPB_Utility.IsDeadNoCall(guard) && !RPB_Utility.IsFrozenNPC(guard))
            RPB_Memory.FastFormMap_SetForm(carriers, guard, akOwner)
            parcels.MakeCarrier(guard)
            made += 1
            if (target)
                float distance = guard.GetDistance(target)
                if (!nearest || distance < nearestDistance)
                    nearest = guard
                    nearestDistance = distance
                endif
            endif
        endif
        i += 1
    endWhile
    RPB_Utility.LogInfo(made + " guards of " + RPB_Memory.FastMap_GetString(record, "hold") + " may go after " + akOwner + "'s dropped weapons", "Confiscation::OnFakeSurrender")
    if (made >= 2 && nearest && self.__RollPickup(akOwner, record, "the fight"))
        self.__Claim(akOwner, record, nearest)
    endif
endFunction

;/
    Whether the guards go after @akOwner's dropped weapons: rolled once per fake surrender (PICKUP_AFTER_FAKE_PERCENT), at
    @asWhen. Not going: nobody is a carrier for them any more
/;
bool function __RollPickup(Actor akOwner, int aiRecord, string asWhen)
    if (RPB_Memory.FastMap_GetInt(aiRecord, "rolled"))
        return RPB_Memory.FastMap_GetInt(aiRecord, "going") != 0
    endif
    int roll = Utility.RandomInt(1, 100)
    int forced = JDB.solveInt(".rpb_root.tests.forcePickupRoll") ; test 212: 1 always goes, 2 never
    if (forced == 1)
        roll = 1
    elseif (forced == 2)
        roll = 100
    endif
    bool going = roll <= PICKUP_AFTER_FAKE_PERCENT
    RPB_Memory.FastMap_SetInt(aiRecord, "rolled", 1)
    RPB_Memory.FastMap_SetInt(aiRecord, "going", going as int)
    RPB_Utility.LogInfo("The guards " + RPB_Utility.string_if(going, "go", "don't go") + " after " + akOwner + "'s dropped weapons (rolled " + roll + " at " + asWhen + ", they go at " + PICKUP_AFTER_FAKE_PERCENT + " or less)", "Confiscation::__RollPickup")
    if (!going)
        self.__DropCarriersOf(akOwner, none)
    endif
    return going
endFunction

; @akCarrier goes after @akOwner's dropped weapons (the pickup Scene, as a captor's): the only carrier left for them
function __Claim(Actor akOwner, int aiRecord, Actor akCarrier)
    RPB_Memory.FastMap_SetForm(aiRecord, "claimed", akCarrier)
    self.__DropCarriersOf(akOwner, akCarrier)
    RPB_Utility.LogInfo(akCarrier + " goes after " + akOwner + "'s dropped weapons", "Confiscation::__Claim")
    if (!self.__Fetch(akOwner, aiRecord, akCarrier))
        self.__DropCarrier(akCarrier)
    endif
endFunction

; ==========================================================
;              The fetch (a guard who may be fighting)
; ==========================================================

;/
    The engine won't start a Scene with an actor in combat, and a fight ends a Scene's package at once, so a fake
    surrender's guard, fighting or not, runs to the weapon on Skyrim.esm's defaultTravelToLinkCustom04RunIgnoreCombat as a
    package override (PapyrusUtil), his LinkCustom04 linked reference set to it (his own put back after); already
    fighting, he's taken out of it first. His own stack's watch (WatchFetch) picks it up once he's there
/;
Package property FetchPackage
    Package function get()
        return Game.GetFormFromFile(0x09A771, "Skyrim.esm") as Package
    endFunction
endProperty

Keyword property FetchLink
    Keyword function get()
        return Game.GetFormFromFile(0x05D5FE, "Skyrim.esm") as Keyword
    endFunction
endProperty

; How long a fetch may take before it's given up (the weapons left for an off-screen pickup at his unload), and how close
; he has to be to pick a weapon up (a fetch's arrival, and any pickup: nothing is picked up from afar)
float property FETCH_SECONDS = 30.0 autoreadonly
float property PICKUP_REACH = 200.0 autoreadonly

; @akCarrier runs to the first of @akOwner's dropped weapons still on the ground. Whether he went
bool function __Fetch(Actor akOwner, int aiRecord, Actor akCarrier)
    ObjectReference target = self.__FirstWeaponOnGround(RPB_Memory.FastMap_GetObject(aiRecord, "refs"))
    if (!target || !akCarrier || RPB_Utility.IsFrozenNPC(akCarrier))
        RPB_Utility.LogInfo("Nothing of " + akOwner + "'s dropped weapons on the ground for " + akCarrier + " to fetch", "Confiscation::__Fetch")
        return false
    endif
    Keyword link = self.FetchLink
    RPB_Memory.FastMap_SetForm(aiRecord, "fetcher", akCarrier)
    RPB_Memory.FastMap_SetForm(aiRecord, "fetcherLink", akCarrier.GetLinkedRef(link))
    RPB_Memory.FastMap_SetFloat(aiRecord, "fetchStarted", Utility.GetCurrentRealTime())
    PO3_SKSEFunctions.SetLinkedRef(akCarrier, target, link)
    ActorUtil.AddPackageOverride(akCarrier, self.FetchPackage, 100)
    ; Ignore Combat keeps him from entering a fight while it runs, not from one he's already in (test 212: he swung at the
    ; air for 30s): out of it first; he goes back to it once he has the weapons
    bool wasFighting = akCarrier.IsInCombat()
    if (wasFighting)
        akCarrier.StopCombat()
    endif
    akCarrier.EvaluatePackage()
    RPB_Utility.LogInfo(akCarrier + " runs to " + akOwner + "'s dropped weapon " + target + " (" + (akCarrier.GetDistance(target) as int) + " away, was fighting " + wasFighting + ")", "Confiscation::__Fetch")
    int handle = ModEvent.Create("RPB_WatchFetch")
    if (handle)
        ModEvent.PushForm(handle, akOwner)
        ModEvent.Send(handle)
    endif
    return true
endFunction

;/
    @akOwner's fetch, on a stack of its own (RPB_EventManager): until the fetcher is within PICKUP_REACH of a weapon still
    on the ground (re-aimed when the one he ran to is taken), then he picks them up (PickUpWeapons). Given up after
    FETCH_SECONDS (real seconds, from the fetch's start: a load resumes it with the time left), or when he dies, freezes
    or unloads (his unload picks them up off-screen)
/;
function WatchFetch(Actor akOwner)
    int record = self.GetDroppedWeapons(akOwner)
    Actor fetcher = RPB_Memory.FastMap_GetForm(record, "fetcher") as Actor
    if (!fetcher)
        return
    endif
    Keyword link = self.FetchLink
    int refs = RPB_Memory.FastMap_GetObject(record, "refs")
    string outcome = ""
    while (outcome == "")
        ObjectReference target = self.__FirstWeaponOnGround(refs)
        if (RPB_Memory.FastMap_GetForm(record, "fetcher") != fetcher || self.GetDroppedWeapons(akOwner) != record)
            outcome = "ended elsewhere"
        elseif (RPB_Utility.IsDeadNoCall(fetcher) || RPB_Utility.IsFrozenNPC(fetcher))
            outcome = "he died or froze"
        elseif (!target)
            outcome = "nothing left on the ground"
        elseif (!fetcher.Is3DLoaded())
            outcome = "he unloaded"
        elseif (fetcher.GetDistance(target) <= PICKUP_REACH)
            outcome = "there"
        elseif (Utility.GetCurrentRealTime() - RPB_Memory.FastMap_GetFloat(record, "fetchStarted") > FETCH_SECONDS)
            outcome = "too long"
        else
            if (fetcher.GetLinkedRef(link) != target)
                PO3_SKSEFunctions.SetLinkedRef(fetcher, target, link) ; the one he ran to was taken: the next
                fetcher.EvaluatePackage()
            endif
            float elapsed = Utility.GetCurrentRealTime() - RPB_Memory.FastMap_GetFloat(record, "fetchStarted")
            RPB_Memory.FastMap_SetFloat(record, "fetchElapsedAtSave", elapsed)
            if ((elapsed as int) % 2 == 0 && (elapsed - (elapsed as int)) < 0.5)
                RPB_Utility.LogInfo(fetcher + " fetching for " + (elapsed as int) + "s: " + (fetcher.GetDistance(target) as int) + " from " + target + " (loaded " + target.Is3DLoaded() + ", at " + (target.GetPositionX() as int) + "," + (target.GetPositionY() as int) + "," + (target.GetPositionZ() as int) + "; he's at " + (fetcher.GetPositionX() as int) + "," + (fetcher.GetPositionY() as int) + "," + (fetcher.GetPositionZ() as int) + "), running " + PO3_SKSEFunctions.GetRunningPackage(fetcher) + ", in combat " + fetcher.IsInCombat() + ", linked " + fetcher.GetLinkedRef(link), "Confiscation::WatchFetch")
            endif
            Utility.Wait(0.5)
        endif
    endWhile
    RPB_Utility.LogInfo(fetcher + "'s fetch of " + akOwner + "'s weapons ended: " + outcome, "Confiscation::WatchFetch")
    if (outcome == "ended elsewhere")
        return
    endif
    self.__EndFetch(record, fetcher)
    if (outcome == "there")
        self.PickUpWeapons(akOwner, fetcher)
    elseif (outcome == "nothing left on the ground")
        self.__DropCarriersOf(akOwner, none)
        self.ForgetDroppedWeapons(akOwner)
    endif
    ; "too long": still her carrier, his unload picks them up off-screen
endFunction

; The fetch's package and link taken off @akFetcher (his own LinkCustom04 back), so he goes back to what he was doing
function __EndFetch(int aiRecord, Actor akFetcher)
    if (!akFetcher || RPB_Memory.FastMap_GetForm(aiRecord, "fetcher") != akFetcher)
        return
    endif
    RPB_Memory.FastMap_RemoveKey(aiRecord, "fetcher")
    if (RPB_Utility.IsFrozenNPC(akFetcher))
        return
    endif
    ActorUtil.RemovePackageOverride(akFetcher, self.FetchPackage)
    PO3_SKSEFunctions.SetLinkedRef(akFetcher, RPB_Memory.FastMap_GetForm(aiRecord, "fetcherLink") as ObjectReference, self.FetchLink)
    akFetcher.EvaluatePackage()
endFunction

;/
    After a load (RPB_ConfigAlias): the fetches under way when the game was saved go on (their watch didn't survive it,
    the package override did), with the time they had left
/;
function ResumeFetchesAfterLoad()
    int all = JDB.solveObj(".rpb_root.droppedWeapons")
    if (!all)
        return
    endif
    Form[] owners = JFormMap.allKeysPArray(all)
    int i = 0
    while (owners && i < owners.Length)
        int record = RPB_Memory.FastFormMap_GetObject(all, owners[i])
        if (RPB_Memory.FastMap_GetForm(record, "fetcher"))
            ; the real-time clock restarts with the game: keep the time left
            float elapsed = RPB_Memory.FastMap_GetFloat(record, "fetchElapsedAtSave")
            RPB_Memory.FastMap_SetFloat(record, "fetchStarted", Utility.GetCurrentRealTime() - elapsed)
            int handle = ModEvent.Create("RPB_WatchFetch")
            if (handle)
                ModEvent.PushForm(handle, owners[i])
                ModEvent.Send(handle)
            endif
            RPB_Utility.LogInfo("Resumed " + RPB_Memory.FastMap_GetForm(record, "fetcher") + "'s fetch of " + owners[i] + "'s weapons after the load", "Confiscation::ResumeFetchesAfterLoad")
        endif
        i += 1
    endWhile
endFunction

;/
    A carrier's fight is over (RPB_ParcelCarrier -> RPB_EventManager): nobody going after the weapons yet, he does if the
    roll says so. She's been arrested since (the arrest's own pickup takes it), or there's nothing left to go after: no
    longer a carrier
/;
function OnCarrierCombatEnded(Actor akCarrier)
    Actor owner = RPB_Memory.FastFormMap_GetForm(self.__Map(".rpb_root.parcelCarriers"), akCarrier) as Actor
    if (!owner)
        return
    endif
    int record = self.GetDroppedWeapons(owner)
    RPB_Utility.LogInfo(akCarrier + "'s fight is over: carrying for " + owner + ", record " + record + " (fake " + RPB_Memory.FastMap_GetInt(record, "fake") + ", parcel " + RPB_Memory.FastMap_GetForm(record, "parcel") + ", rolled " + RPB_Memory.FastMap_GetInt(record, "rolled") + ", claimed by " + RPB_Memory.FastMap_GetForm(record, "claimed") + "), she's arrested " + RPB_Utility.IsActorArrested(owner), "Confiscation::OnCarrierCombatEnded")
    Actor claimed = RPB_Memory.FastMap_GetForm(record, "claimed") as Actor
    if (claimed)
        if (claimed != akCarrier)
            self.__DropCarrier(akCarrier)
        endif
        return
    endif
    if (!record || !RPB_Memory.FastMap_GetInt(record, "fake") || RPB_Memory.FastMap_GetForm(record, "parcel") || RPB_Utility.IsActorArrested(owner))
        self.__DropCarrier(akCarrier)
        return
    endif
    if (self.__RollPickup(owner, record, "the end of " + akCarrier + "'s fight"))
        self.__Claim(owner, record, akCarrier)
    endif
endFunction

;/
    A carrier unloaded (RPB_ParcelCarrier -> RPB_EventManager): what he carries for a fake surrender is turned in to his
    hold's prison, into one of its belongings chests. Nobody got the weapons yet (one guard, fighting until now; a pickup
    that never happened): he picks them up off-screen, if the roll says so, and they go straight to the prison. Then he's
    no longer a carrier. Not a carrier (any more): nothing
/;
function OnCarrierUnloaded(Actor akCarrier)
    Actor owner = RPB_Memory.FastFormMap_GetForm(self.__Map(".rpb_root.parcelCarriers"), akCarrier) as Actor
    if (!owner)
        return
    endif
    RPB_Utility.LogInfo(akCarrier + " unloaded, carrying for " + owner, "Confiscation::OnCarrierUnloaded")
    self.__TurnInCarried(akCarrier)
    int record = self.GetDroppedWeapons(owner)
    if (record && RPB_Memory.FastMap_GetInt(record, "fake") && !RPB_Memory.FastMap_GetForm(record, "parcel") && !RPB_Utility.IsActorArrested(owner))
        Actor claimed = RPB_Memory.FastMap_GetForm(record, "claimed") as Actor
        if ((!claimed || claimed == akCarrier) && self.__RollPickup(owner, record, akCarrier + "'s unload"))
            self.__EndFetch(record, akCarrier)
            self.__PickUpOffScreen(owner, record, akCarrier)
        endif
    endif
    self.__DropCarrier(akCarrier)
endFunction

;/
    @akCarrier, out of sight, picks up what of @akOwner's dropped weapons is still lying where it fell (loaded or not: in a
    cell, not in someone's inventory) into her "Weapons" parcel, which goes straight to his hold's prison
/;
function __PickUpOffScreen(Actor akOwner, int aiRecord, Actor akCarrier)
    RPB_Parcels parcels = API.Parcels
    int refs = RPB_Memory.FastMap_GetObject(aiRecord, "refs")
    ObjectReference parcel = none
    int picked = 0
    int i = 0
    while (i < RPB_Memory.FastArray_Size(refs))
        ObjectReference ref = RPB_Memory.FastArray_GetForm(refs, i) as ObjectReference
        if (ref && ref.GetParentCell())
            if (!parcel)
                parcel = parcels.Create(akOwner, "Weapons", self.__OwnerName(akOwner) + "'s Weapons")
            endif
            if (parcel)
                parcels.PutRef(parcel, ref)
                picked += 1
            endif
        endif
        i += 1
    endWhile
    if (!parcel)
        RPB_Utility.LogInfo("Nothing of " + akOwner + "'s dropped weapons is left where it fell for " + akCarrier + " to pick up", "Confiscation::__PickUpOffScreen")
        self.ForgetDroppedWeapons(akOwner)
        return
    endif
    RPB_Utility.LogInfo(akCarrier + " picked up " + picked + " of " + RPB_Memory.FastArray_Size(refs) + " of " + akOwner + "'s dropped weapons off-screen, into " + parcel, "Confiscation::__PickUpOffScreen")
    self.__TurnInPickup(akOwner, aiRecord, parcel, none)
endFunction

;/
    A fake surrender's parcel picked up (PickUpWeapons by @akCarrier, or __PickUpOffScreen with none): it moves from her
    dropped-weapons record (freed for a later drop) to the turned-in ones. Carried, it stays with him until he unloads;
    picked up off-screen, or he's out of sight already, it's turned in now
/;
function __TurnInPickup(Actor akOwner, int aiRecord, ObjectReference akParcel, Actor akCarrier)
    int entry = JMap.object()
    RPB_Memory.FastMap_SetForm(entry, "owner", akOwner)
    RPB_Memory.FastMap_SetString(entry, "hold", RPB_Memory.FastMap_GetString(aiRecord, "hold"))
    RPB_Memory.FastMap_SetFloat(entry, "until", RPB_Memory.FastMap_GetFloat(aiRecord, "until"))
    RPB_Memory.FastFormMap_SetObject(self.__Map(".rpb_root.turnedIn"), akParcel, entry)
    self.ForgetDroppedWeapons(akOwner)
    if (akCarrier && akCarrier.Is3DLoaded())
        RPB_Memory.FastMap_SetForm(entry, "carrier", akCarrier)
        return
    endif
    self.__TurnIn(akParcel, entry, akCarrier)
endFunction

; What @akCarrier carries of the turned-in parcels goes to his hold's prison (his unload)
function __TurnInCarried(Actor akCarrier)
    int turnedIn = self.__Map(".rpb_root.turnedIn")
    Form[] keys = JFormMap.allKeysPArray(turnedIn)
    int i = 0
    while (keys && i < keys.Length)
        int entry = RPB_Memory.FastFormMap_GetObject(turnedIn, keys[i])
        if (RPB_Memory.FastMap_GetForm(entry, "carrier") == akCarrier)
            self.__TurnIn(keys[i] as ObjectReference, entry, akCarrier)
        endif
        i += 1
    endWhile
endFunction

; @akParcel's token into a belongings chest of its hold's prison (from @akCarrier, or wherever it is), recorded in @aiEntry
function __TurnIn(ObjectReference akParcel, int aiEntry, Actor akCarrier)
    string hold = RPB_Memory.FastMap_GetString(aiEntry, "hold")
    RPB_Prison prison = RPB_Prison.GetPrisonForHold(hold)
    ObjectReference chest = none
    if (prison)
        chest = prison.GetRandomPrisonerContainer("Belongings") as ObjectReference
    endif
    if (!chest)
        RPB_Utility.LogWarn(akParcel + " not turned in: no prison for " + hold, "Confiscation::__TurnIn")
        return
    endif
    API.Parcels.GiveTo(akParcel, chest)
    RPB_Memory.FastMap_SetForm(aiEntry, "chest", chest)
    RPB_Memory.FastMap_RemoveKey(aiEntry, "carrier")
    RPB_Utility.LogInfo(RPB_Memory.FastMap_GetForm(aiEntry, "owner") + "'s weapons (" + akParcel + ") turned in to " + hold + "'s prison, " + chest + RPB_Utility.string_if(akCarrier, " by " + akCarrier, ""), "Confiscation::__TurnIn")
endFunction

; @akOwner's carriers stop being carriers, but @akExcept
function __DropCarriersOf(Actor akOwner, Actor akExcept)
    int carriers = self.__Map(".rpb_root.parcelCarriers")
    Form[] keys = JFormMap.allKeysPArray(carriers)
    int i = 0
    while (keys && i < keys.Length)
        if (keys[i] != akExcept && RPB_Memory.FastFormMap_GetForm(carriers, keys[i]) == akOwner)
            self.__DropCarrier(keys[i] as Actor)
        endif
        i += 1
    endWhile
endFunction

; The JFormMap at @asPath, made the first time
int function __Map(string asPath)
    int all = JDB.solveObj(asPath)
    if (!all)
        all = JFormMap.object()
        JDB.solveObjSetter(asPath, all, true)
    endif
    return all
endFunction

function __DropCarrier(Actor akCarrier)
    RPB_Memory.FastFormMap_RemoveKey(self.__Map(".rpb_root.parcelCarriers"), akCarrier)
    if (akCarrier && !RPB_Utility.IsFrozenNPC(akCarrier) && !RPB_Utility.IsDeadNoCall(akCarrier))
        API.Parcels.UnmakeCarrier(akCarrier)
    endif
endFunction

;/
    A guard took over @akOwner's arrest from @akOldCaptor (RPB_Arrestee's takeovers): what the old one carries of hers
    goes to @akNewCaptor, from his body too. A frozen one can't be touched: it stays on him (the release tries again)
/;
function CaptorChanged(Actor akOwner, Actor akOldCaptor, Actor akNewCaptor)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record || !akNewCaptor)
        return
    endif
    RPB_Memory.FastMap_SetForm(record, "captor", akNewCaptor)
    ObjectReference parcel = RPB_Memory.FastMap_GetForm(record, "parcel") as ObjectReference
    RPB_Parcels parcels = API.Parcels
    if (!parcel || !parcels.GetToken(parcel))
        return
    endif
    Actor holder = parcels.GetHolder(parcel) as Actor
    if (holder == akNewCaptor)
        return
    endif
    if (holder && RPB_Utility.IsFrozenNPC(holder))
        RPB_Utility.LogWarn(akNewCaptor + " can't take " + akOwner + "'s weapons (" + parcel + ") from " + holder + ": frozen", "Confiscation::CaptorChanged")
        return
    endif
    parcels.GiveTo(parcel, akNewCaptor)
    RPB_Utility.LogInfo(akNewCaptor + " took " + akOwner + "'s weapons (" + parcel + ") from " + holder + RPB_Utility.string_if(RPB_Utility.IsDeadNoCall(holder), " (his body)", ""), "Confiscation::CaptorChanged")
endFunction

; ==========================================================
;                The hand-in and the return
; ==========================================================

;/
    At the prison (RPB_Prison.PrepareArrival, the arrival's setup): the token of @akOwner's "Weapons" parcel goes from
    whoever holds it into her belongings chest @akChest, recorded as confiscated (returned at the release, whether or not
    she was stripped). Never picked up (given up, or no pickup on the way): it stays where it fell, lost. Its holder dead
    (he died on the way, or inside before the escort's end): the token stays on his body (the player looting it gets the
    weapons). Its holder frozen: no call into him, it stays on him, and the release or a cancel tries him again. Taken
    from him already (the player's pickpocketing opens it): nothing to hand in
/;
function HandIn(Actor akOwner, ObjectReference akChest)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record)
        return
    endif
    ObjectReference parcel = RPB_Memory.FastMap_GetForm(record, "parcel") as ObjectReference
    if (!parcel)
        if (RPB_Memory.FastMap_GetObject(record, "held"))
            self.__HandInHeldItems(akOwner, akChest, record) ; picked up before parcels
        else
            RPB_Utility.LogInfo(akOwner + "'s dropped weapons were never picked up, they stay where they fell", "Confiscation::HandIn")
            self.ForgetDroppedWeapons(akOwner)
        endif
        return
    endif
    RPB_Parcels parcels = API.Parcels
    if (!parcels.GetToken(parcel))
        RPB_Utility.LogInfo(akOwner + "'s weapons (" + parcel + ") were opened already: taken from the guard", "Confiscation::HandIn")
        self.ForgetDroppedWeapons(akOwner)
        return
    endif
    Actor holder = parcels.GetHolder(parcel) as Actor
    if (holder && RPB_Utility.IsDeadNoCall(holder))
        RPB_Utility.LogInfo(holder + " died holding " + akOwner + "'s weapons (" + parcel + "), they stay on his body", "Confiscation::HandIn")
        self.ForgetDroppedWeapons(akOwner)
        return
    endif
    if (!akChest || (holder && RPB_Utility.IsFrozenNPC(holder)))
        RPB_Utility.LogWarn("Not handing in " + akOwner + "'s weapons now (chest: " + akChest + ", " + holder + " frozen: " + RPB_Utility.IsFrozenNPC(holder) + "), he keeps them until the release", "Confiscation::HandIn")
        return
    endif
    parcels.GiveTo(parcel, akChest)
    RPB_Memory.FastMap_SetForm(self.__ConfiscatedRecord(akOwner, akChest), "parcel", parcel)
    self.ForgetDroppedWeapons(akOwner)
    RPB_Utility.LogInfo(holder + " handed in " + akOwner + "'s weapons (" + parcel + ") into " + akChest, "Confiscation::HandIn")
endFunction

;/
    At the arrival in @asHold's prison (RPB_Prison.PrepareArrival, after HandIn): what a fake surrender to this hold left
    with its guards, turned in or still carried, is hers again if the hold still remembers it ("until"): into her chest
    @akChest, merged into what was handed in now if anything was, and returned at the release. Past "until" it's lost:
    left where it is, not returned. A carrier who died with it: on his body. Other holds' turned-in parcels stay put
/;
function ClaimTurnedIn(Actor akOwner, string asHold, ObjectReference akChest)
    RPB_Parcels parcels = API.Parcels
    int turnedIn = JDB.solveObj(".rpb_root.turnedIn")
    if (!turnedIn || !akChest)
        return
    endif
    Form[] keys = JFormMap.allKeysPArray(turnedIn)
    int i = 0
    while (keys && i < keys.Length)
        ObjectReference parcel = keys[i] as ObjectReference
        int entry = RPB_Memory.FastFormMap_GetObject(turnedIn, parcel)
        if (RPB_Memory.FastMap_GetForm(entry, "owner") == akOwner && RPB_Memory.FastMap_GetString(entry, "hold") == asHold)
            Actor holder = parcels.GetHolder(parcel) as Actor
            if (!parcels.GetToken(parcel))
                RPB_Memory.FastFormMap_RemoveKey(turnedIn, parcel) ; opened already (taken by her)
            elseif (Utility.GetCurrentGameTime() > RPB_Memory.FastMap_GetFloat(entry, "until"))
                RPB_Utility.LogInfo(akOwner + "'s weapons turned in to " + asHold + " (" + parcel + ") are lost: the hold no longer remembers her fake surrender", "Confiscation::ClaimTurnedIn")
                RPB_Memory.FastFormMap_RemoveKey(turnedIn, parcel)
            elseif (holder && RPB_Utility.IsDeadNoCall(holder))
                RPB_Memory.FastFormMap_RemoveKey(turnedIn, parcel) ; on his body
            elseif (!(holder && RPB_Utility.IsFrozenNPC(holder)))
                int confiscated = self.__ConfiscatedRecord(akOwner, akChest)
                ObjectReference handedIn = RPB_Memory.FastMap_GetForm(confiscated, "parcel") as ObjectReference
                if (handedIn && parcels.GetToken(handedIn))
                    parcels.Open(parcel, handedIn) ; into what was handed in now: one parcel back
                else
                    parcels.GiveTo(parcel, akChest)
                    RPB_Memory.FastMap_SetForm(confiscated, "parcel", parcel)
                endif
                if (holder)
                    self.__DropCarrier(holder)
                endif
                RPB_Memory.FastFormMap_RemoveKey(turnedIn, parcel)
                RPB_Utility.LogInfo(akOwner + "'s weapons turned in to " + asHold + " (" + parcel + ", held by " + holder + ") are hers again, in " + akChest + RPB_Utility.string_if(handedIn, ", merged into " + handedIn, ""), "Confiscation::ClaimTurnedIn")
            endif
        endif
        i += 1
    endWhile
endFunction

; @akOwner's Confiscated record (a JMap: "parcel" the parcel, or "items" the items from before parcels; "chest" where
; they're kept), 0 with none
int function GetConfiscated(Actor akOwner)
    int all = JDB.solveObj(".rpb_root.confiscated")
    if (!all)
        return 0
    endif
    return RPB_Memory.FastFormMap_GetObject(all, akOwner)
endFunction

; @akOwner's Confiscated record, made the first time, its chest @akChest
int function __ConfiscatedRecord(Actor akOwner, ObjectReference akChest)
    int confiscated = self.GetConfiscated(akOwner)
    if (!confiscated)
        confiscated = JMap.object()
        int all = JDB.solveObj(".rpb_root.confiscated")
        if (!all)
            all = JFormMap.object()
            JDB.solveObjSetter(".rpb_root.confiscated", all, true)
        endif
        RPB_Memory.FastFormMap_SetObject(all, akOwner, confiscated)
    endif
    RPB_Memory.FastMap_SetForm(confiscated, "chest", akChest)
    return confiscated
endFunction

;/
    At the release (RPB_Prison.TeleportPrisonerToRelease) or a cancelled arrest (RPB_Recovery.CancelArrest): @akOwner gets
    back what was confiscated from her: her "Weapons" parcel opened into her from the chest it was handed into, or from
    a living guard still holding it (a cancel before the prison, a hand-in a frozen guard missed). Its token taken from the
    chest by someone else: it's theirs now, not returned
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
    ObjectReference parcel = RPB_Memory.FastMap_GetForm(confiscated, "parcel") as ObjectReference
    bool opened = parcel && self.__OpenIfHeldBy(parcel, chest, none, akOwner)
    int items = RPB_Memory.FastMap_GetObject(confiscated, "items") ; handed in before parcels
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
    RPB_Utility.LogInfo("Returned " + akOwner + "'s confiscated things from " + chest + ": parcel " + parcel + RPB_Utility.string_if(parcel && !opened, " (not in the chest any more)", "") + RPB_Utility.string_if(items != 0, ", " + returned + " of " + RPB_Memory.FastArray_Size(items) + " items", "") + " (" + fromHolder + " from the guard)", "Confiscation::ReturnConfiscated")
endFunction

; The dropped weapons a living, unfrozen guard still holds go back to @akOwner (dead: on his body; never picked up: where
; they fell), the record forgotten either way. How many went back (a parcel counts as one)
int function __ReturnFromHolder(Actor akOwner)
    int record = self.GetDroppedWeapons(akOwner)
    if (!record)
        return 0
    endif
    ObjectReference parcel = RPB_Memory.FastMap_GetForm(record, "parcel") as ObjectReference
    Actor captor = RPB_Memory.FastMap_GetForm(record, "captor") as Actor
    int held = RPB_Memory.FastMap_GetObject(record, "held") ; picked up before parcels
    Actor holder = RPB_Memory.FastMap_GetForm(record, "holder") as Actor
    self.ForgetDroppedWeapons(akOwner)
    if (parcel)
        return self.__OpenIfHeldBy(parcel, captor, akOwner, akOwner) as int
    endif
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

;/
    Opens @akParcel into @akOwner if its token is still with @akHolder1 or @akHolder2 (none matches nothing), and that
    holder isn't a body or frozen. Anywhere else (taken by someone), or opened already: left alone. Whether it was opened
/;
bool function __OpenIfHeldBy(ObjectReference akParcel, ObjectReference akHolder1, ObjectReference akHolder2, Actor akOwner)
    RPB_Parcels parcels = API.Parcels
    if (!parcels.GetToken(akParcel))
        return false
    endif
    ObjectReference holder = parcels.GetHolder(akParcel)
    if (!holder || (holder != akHolder1 && holder != akHolder2))
        RPB_Utility.LogInfo(akOwner + "'s " + akParcel + " is with " + holder + " now, not given back", "Confiscation::__OpenIfHeldBy")
        return false
    endif
    Actor holderActor = holder as Actor
    if (holderActor && (RPB_Utility.IsDeadNoCall(holderActor) || RPB_Utility.IsFrozenNPC(holderActor)))
        return false
    endif
    parcels.Open(akParcel, akOwner)
    return true
endFunction

; The hand-in of weapons picked up before parcels (the items themselves on the guard): item by item into @akChest, on
; @akOwner's Confiscated list. With his own copy of one, which goes is the engine's choice. How many went in
int function __HandInHeldItems(Actor akOwner, ObjectReference akChest, int aiRecord)
    int held = RPB_Memory.FastMap_GetObject(aiRecord, "held")
    Actor holder = RPB_Memory.FastMap_GetForm(aiRecord, "holder") as Actor
    if (!holder || RPB_Utility.IsDeadNoCall(holder))
        self.ForgetDroppedWeapons(akOwner)
        return 0
    endif
    if (!akChest || RPB_Utility.IsFrozenNPC(holder))
        return 0
    endif
    int confiscated = self.__ConfiscatedRecord(akOwner, akChest)
    int items = RPB_Memory.FastMap_GetObject(confiscated, "items")
    if (!items)
        items = JArray.object()
        RPB_Memory.FastMap_SetObject(confiscated, "items", items)
    endif
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
    RPB_Utility.LogInfo(holder + " handed in " + handedIn + " of " + RPB_Memory.FastArray_Size(held) + " of " + akOwner + "'s weapons (picked up before parcels) into " + akChest, "Confiscation::__HandInHeldItems")
    return handedIn
endFunction

; @akOwner's name for her parcel's token: the stored one (no call into a frozen NPC), the player's read
string function __OwnerName(Actor akOwner)
    string name = RPB_Utility.ActorNameNoCall(akOwner)
    if (name == "" && !RPB_Utility.IsFrozenNPC(akOwner))
        name = akOwner.GetDisplayName()
    endif
    return name
endFunction
