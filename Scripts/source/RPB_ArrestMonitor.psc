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
    if (!__escorts || !JValue.isExists(__escorts))
        return
    endif
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
    if (FastFormMap_Size(__escorts) > 0)
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
