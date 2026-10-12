scriptname RPB_ArrestMonitor extends ReferenceAlias

;/
    Arrests in progress, watched from the quest instead of the arrestee's own effect: an NPC's effect is gone while her 3D is
    unloaded (the player elsewhere), and so is anything it watches, while her Scene plays on. RPB_PrisonMonitor's twin for
    the arrest side; the prison's own monitor keeps what happens in the prison (releases, the escort to the cell).
    One entry per watched escortee; nothing runs while there are none (a single update, armed only while one is pending).
    No call into anyone's script, and none into a frozen actor.

@references:
    RPB_API API
    RPB_SceneManager SceneManager
    RPB_ArresteeList Arrestees
@functions:
    function WatchEscortToJail(Actor akEscortee)
    function StopWatching(Actor akEscortee)
    int function WatchedCount()
    function NoteConfrontationStep(Actor akArrestee, string asStep)
    function StopWatchingConfrontation(Actor akArrestee)
    function RestartClocksAfterLoad()
@events:
    event OnUpdate()
/;

import RPB_Utility
import RPB_Memory

; ==========================================================
;                     Script References
; ==========================================================

RPB_API property API
    RPB_API function get()
        return RPB_API.GetSelf()
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
    endFunction
endProperty

RPB_ArresteeList property Arrestees
    RPB_ArresteeList function get()
        return (self as ReferenceAlias) as RPB_ArresteeList
    endFunction
endProperty

; ==========================================================
;                         Watching
; ==========================================================

float property WAKE_SECONDS = 3.0 autoreadonly

; The escort to jail's "Reached Jail" phase ends on the guard within this of its Player_EscortLocation, and within the next
; one of the escortee (the plugin's conditions, the same for every prison: what differs between prisons is where their
; markers are). Copied by hand from today's Scene: the Scene refactor renames its aliases and may change these, and this is
; to read them from its config then
float property JAIL_REACHED_GUARD_DISTANCE = 300.0 autoreadonly
float property JAIL_REACHED_ESCORTEE_DISTANCE = 150.0 autoreadonly
int property STOPPED_SHORT_WAKES = 3 autoreadonly ; ~9s

int __escorts ; FastMap<Form>: escortee -> FastMap { shortWakes }

;/
    An NPC's escort to jail starts (RPB_Arrestee.OnArrestEnd): watched until it ends (RPB_Arrestee.EndEscortWatch), the
    arrest is gone (Destroy), or she leaves the arrestee list. Her guard is read from the Scene each wake (its Escort): a
    takeover by another guard changes him
/;
function WatchEscortToJail(Actor akEscortee)
    if (!akEscortee)
        return
    endif
    if (!__escorts || !JValue.isExists(__escorts))
        __escorts = FastMap("<Form>", retain = true)
    endif
    int entry = FastMap()
    FastMap_SetInt(entry, "shortWakes", 0)
    FastFormMap_SetObject(__escorts, akEscortee, entry)
    RegisterForSingleUpdate(WAKE_SECONDS) ; a single update: a second escort only moves the next wake
    Debug("ArrestMonitor::WatchEscortToJail", "watching " + akEscortee + "'s escort to jail (" + FastFormMap_Size(__escorts) + " watched)")
endFunction

function StopWatching(Actor akEscortee)
    if (akEscortee && __escorts && FastFormMap_HasKey(__escorts, akEscortee))
        FastFormMap_RemoveKey(__escorts, akEscortee)
        Debug("ArrestMonitor::StopWatching", akEscortee + "'s escort to jail no longer watched (" + FastFormMap_Size(__escorts) + " left)")
    endif
endFunction

int function WatchedCount()
    if (!__escorts)
        return 0
    endif
    return FastFormMap_Size(__escorts)
endFunction

event OnUpdate()
    int pending = 0
    if (__escorts && JValue.isExists(__escorts))
        Form escortee = FastFormMap_NextKey(__escorts)
        while (escortee)
            Form nextEscortee = FastFormMap_NextKey(__escorts, escortee)
            Actor escorteeActor = escortee as Actor
            ; Out of the arrest some way nothing told me about (the list's index: no call into her)
            if (!escorteeActor || !Arrestees.AtKey(escorteeActor))
                FastFormMap_RemoveKey(__escorts, escortee)
            else
                self.__CheckStoppedShort(escorteeActor, FastFormMap_GetObject(__escorts, escortee))
            endif
            escortee = nextEscortee
        endWhile
        pending += FastFormMap_Size(__escorts)
    endif
    if (__confrontations && JValue.isExists(__confrontations))
        float now = Utility.GetCurrentRealTime()
        Form arrestee = FastFormMap_NextKey(__confrontations)
        while (arrestee)
            Form nextArrestee = FastFormMap_NextKey(__confrontations, arrestee)
            Actor arresteeActor = arrestee as Actor
            if (!arresteeActor || !Arrestees.AtKey(arresteeActor))
                FastFormMap_RemoveKey(__confrontations, arrestee)
            else
                self.__CheckConfrontation(arresteeActor, FastFormMap_GetObject(__confrontations, arrestee), now)
            endif
            arrestee = nextArrestee
        endWhile
        pending += FastFormMap_Size(__confrontations)
    endif
    if (pending > 0)
        RegisterForSingleUpdate(WAKE_SECONDS)
    endif
endEvent

;/
    The temporary nudge (until the Scene refactor gives the escort to jail conditions that don't leave her there): an
    escortee who stopped short of her guard at the escort's end holds the Scene, the strip and her escort to the cell
    (2026-10-08: minutes; off-screen the guard drifted off and led her back outside). Short for STOPPED_SHORT_WAKES wakes in a
    row: moved up to him. Her Scene not the current one (queued behind another): nothing to judge yet
/;
function __CheckStoppedShort(Actor akEscortee, int aiEntry)
    string current = SceneManager.GetCurrentScene()
    if (!SceneManager.IsSceneOfType(current, SceneManager.CATEGORY_ESCORT_TO_JAIL) || SceneManager.GetSceneNthReferenceOfType(current, "Escortee") != akEscortee)
        FastMap_SetInt(aiEntry, "shortWakes", 0)
        return
    endif
    Actor guard = SceneManager.GetSceneNthReferenceOfType(current, "Escort") as Actor
    ObjectReference destination = SceneManager.GetSceneNthReferenceOfType(current, "Player_EscortLocation")
    if (!guard || !destination || IsFrozenNPC(guard) || IsFrozenNPC(akEscortee))
        return
    endif
    float fromGuard = akEscortee.GetDistance(guard)
    if (destination.GetDistance(guard) >= JAIL_REACHED_GUARD_DISTANCE || fromGuard < JAIL_REACHED_ESCORTEE_DISTANCE)
        FastMap_SetInt(aiEntry, "shortWakes", 0)
        return
    endif
    int wakes = FastMap_GetInt(aiEntry, "shortWakes") + 1
    if (wakes < STOPPED_SHORT_WAKES)
        FastMap_SetInt(aiEntry, "shortWakes", wakes)
        return
    endif
    FastMap_SetInt(aiEntry, "shortWakes", 0)
    akEscortee.MoveTo(guard, afXOffset = -80.0, abMatchRotation = false)
    Info("ArrestMonitor: " + akEscortee + " stopped " + (fromGuard as int) + " units short of " + guard + " at the escort to jail's end: moved up to him")
endFunction

;                    Stuck confrontations
; ==========================================================

;/
    A confrontation that took hold and then stopped moving (#4: stuck after "Hands Behind Back", its guard's AI off; #9: its
    guard frozen, nothing happened): judged from its own steps (RPB_EventManager.OnArrestScene stamps each), so it works
    while either of them is unloaded and after a load. Stuck: no step for CONFRONTATION_APPROACH_SECONDS while the guard
    walks up, CONFRONTATION_STEP_SECONDS after that (about double what each step takes, 2026-10-10), or its guard frozen.
    Not judged while it isn't the current Scene (queued), or while either of them fights (the arrestee's own fight watch
    owns that). Stuck: RPB_ConfrontationStalled, on its own stack (RPB_Arrest.TakeOverStalledConfrontation: another guard
    of the hold replays it; with none, the arrest is cancelled, or, with nobody there to see it, she goes to the prison)
/;
float property CONFRONTATION_APPROACH_SECONDS = 30.0 autoreadonly
float property CONFRONTATION_STEP_SECONDS = 20.0 autoreadonly

int __confrontations ; FastMap<Form>: arrestee -> FastMap { step, since }

; A step of @akArrestee's confrontation: "Begun" (it took hold), "Hands Behind Back", "Handcuff", or "Resumed" (re-armed after
; a load or her 3D loading again, its step unknown: judged as the approach, the longest)
function NoteConfrontationStep(Actor akArrestee, string asStep)
    if (!akArrestee)
        return
    endif
    if (!__confrontations || !JValue.isExists(__confrontations))
        __confrontations = FastMap("<Form>", retain = true)
    endif
    int entry = FastFormMap_GetObject(__confrontations, akArrestee)
    if (!entry)
        entry = FastMap()
        FastFormMap_SetObject(__confrontations, akArrestee, entry)
    endif
    FastMap_SetString(entry, "step", asStep)
    FastMap_SetFloat(entry, "since", Utility.GetCurrentRealTime())
    RegisterForSingleUpdate(WAKE_SECONDS)
    Debug("ArrestMonitor::NoteConfrontationStep", akArrestee + "'s confrontation: " + asStep)
endFunction

function StopWatchingConfrontation(Actor akArrestee)
    if (akArrestee && __confrontations && FastFormMap_HasKey(__confrontations, akArrestee))
        FastFormMap_RemoveKey(__confrontations, akArrestee)
        Debug("ArrestMonitor::StopWatchingConfrontation", akArrestee + "'s confrontation no longer watched")
    endif
endFunction

; After a game load (RPB_Arrest.ResumeEscortWatchesAfterLoad): real time starts over with each session, so every clock
; starts again from now (a load never reads as a stall)
function RestartClocksAfterLoad()
    if (!__confrontations || !JValue.isExists(__confrontations))
        return
    endif
    float now = Utility.GetCurrentRealTime()
    Form arrestee = FastFormMap_NextKey(__confrontations)
    while (arrestee)
        FastMap_SetFloat(FastFormMap_GetObject(__confrontations, arrestee), "since", now)
        arrestee = FastFormMap_NextKey(__confrontations, arrestee)
    endWhile
    if (FastFormMap_Size(__confrontations) > 0)
        RegisterForSingleUpdate(WAKE_SECONDS)
    endif
endFunction

function __CheckConfrontation(Actor akArrestee, int aiEntry, float afNow)
    string current = SceneManager.GetCurrentScene()
    if (!SceneManager.IsSceneOfType(current, SceneManager.CATEGORY_ARREST_START) || SceneManager.GetSceneNthReferenceOfType(current, "Escortee") != akArrestee)
        FastMap_SetFloat(aiEntry, "since", afNow) ; not playing (queued, or between Scenes): nothing to judge yet
        return
    endif
    Actor guard = SceneManager.GetSceneNthReferenceOfType(current, "Escort") as Actor
    if (!guard)
        return
    endif
    string step = FastMap_GetString(aiEntry, "step")
    string reason = ""
    if (IsFrozenNPC(guard))
        if (akArrestee == Game.GetPlayer())
            return ; the player's own path: his freeze cancels the arrest, the bounty set aside, and another guard comes for them (RPB_Arrest.TakeOverSubmission)
        endif
        reason = "its guard is frozen"
    else
        ; No call into him: this loop is every arrest's, and a guard who froze (not marked yet) held it (the prison's intake
        ; watch did, 2026-10-12). His fight ends the confrontation through his own combat event (no longer the current Scene
        ; above); the arrestee's is read here
        if (!IsFrozenNPC(akArrestee) && akArrestee.IsInCombat())
            FastMap_SetFloat(aiEntry, "since", afNow) ; a fight: the arrestee's fight watch owns it
            return
        endif
        float limit = CONFRONTATION_STEP_SECONDS
        if (step == "Begun" || step == "Resumed")
            limit = CONFRONTATION_APPROACH_SECONDS
        endif
        float stuckFor = afNow - FastMap_GetFloat(aiEntry, "since")
        if (stuckFor < limit)
            return
        endif
        reason = "no step for " + (stuckFor as int) + "s after '" + step + "'"
    endif
    FastFormMap_RemoveKey(__confrontations, akArrestee)
    Info("ArrestMonitor: " + akArrestee + "'s confrontation by " + guard + " is stuck (" + reason + ")")
    int handle = ModEvent.Create("RPB_ConfrontationStalled")
    if (handle)
        ModEvent.PushForm(handle, akArrestee)
        ModEvent.PushForm(handle, guard)
        ModEvent.PushString(handle, "the confrontation is stuck: " + reason)
        ModEvent.PushString(handle, step)
        ModEvent.Send(handle)
    endif
endFunction
