scriptname RealisticPrisonAndBounty_EventManager extends Quest

import RealisticPrisonAndBounty_Config
import RealisticPrisonAndBounty_Util

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property arrest
    RealisticPrisonAndBounty_Arrest function get()
        return config.arrest
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property jail
    RealisticPrisonAndBounty_Jail function get()
        return config.jail
    endFunction
endProperty

RealisticPrisonAndBounty_SceneManager property sceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        return config.sceneManager
    endFunction
endProperty

function RegisterEvents()
    ; Arrest Event Handlers
    RegisterForModEvent("RPB_ArrestBegin", "OnArrestBegin")             ; Start the Arrest
    RegisterForModEvent("RPB_ResistArrest", "OnArrestResist")           ; Resisting Arrest
    RegisterForModEvent("RPB_EludingArrest", "OnArrestEludeStart")      ; Eluding Arrest (Start)
    RegisterForModEvent("RPB_ArrestDefeated", "OnArrestDefeat")         ; Happens after the player is defeated through DA
    ; RegisterForModEvent("RPB_ArrestWaiting", "OnArrestWait")            ; Wait the response from player during Arrest
    ; RegisterForModEvent("RPB_ArrestWaitingStop", "OnArrestWaitStop")    ; Something happened to prevent OnArrestWait, cancel the state

    ; Jail Event Handlers
    RegisterForModEvent("RPB_JailBegin", "OnJailBegin")
    RegisterForModEvent("RPB_JailEnd", "OnJailEnd")

    ; Scene Event Handlers
    RegisterForModEvent("RPB_SceneStart", "OnSceneStart")               ; Handles Scene start events, whenever a Scene begins playing.
    RegisterForModEvent("RPB_ScenePlayingStart", "OnScenePlayingStart") ; Handles Scene ongoing events, divided by phases at the beginning of the phase.
    RegisterForModEvent("RPB_ScenePlayingEnd", "OnScenePlayingEnd")     ; Handles Scene ongoing events, divided by phases at the end of the phase.
    RegisterForModEvent("RPB_SceneEnd", "OnSceneEnd")                   ; Handles Scene end events, whenever a Scene ends playing.

    ; Package Event Handlers
    RegisterForModEvent("RPB_PackageEnd", "OnPackageEnd")
    RegisterForModEvent("RPB_PackageStart", "OnPackageStart")
endFunction

; ==========================================================
;                        Arrest Events
; ==========================================================

event OnArrestBegin(string eventName, string arrestType, float arresteeIdFlt, Form sender)
    Actor captor = (sender as Actor)
    Faction crimeFaction = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

    if (captor == none && crimeFaction == none)
        Error(self, "EventManager::OnArrestBegin", "Either there's no Captor, or no Crime Faction! (["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"])")
        return
    endif

    int actorPlayerId = 0x14
    Actor arrestee = Game.GetFormEx(int_if (!arresteeIdFlt, actorPlayerId, arresteeIdFlt as int)) as Actor

    if (!arrestee)
        Error(self, "EventManager::OnArrestBegin", "There's no one to be arrested! (Arrestee is "+ arrestee +")")
        return
    endif

    arrest.OnArrestBegin(arrestee, captor, crimeFaction, arrestType)
endEvent

event OnArrestResist(string eventName, string unusedStr, float arrestResisterIdFlt, Form sender)
    Actor guard = (sender as Actor)
    Faction crimeFaction = form_if ((sender as Faction), (sender as Faction), guard.GetCrimeFaction()) as Faction

    if (guard == none && crimeFaction == none)
        Error(self, "EventManager::OnArrestResist", "Either there's no Guard, or no Crime Faction! (["+ "Lead Captor: "+ guard + ", Faction: " + crimeFaction +"])")
        return
    endif

    ; Not the player
    Actor arrestResister = Game.GetFormEx(arrestResisterIdFlt as int) as Actor
    if (arrestResister.GetFormID() != 0x14)
        Error(self, "EventManager::OnArrestResist", "Someone other than the player ("+ arrestResister +") has resisted arrest (how?), returning...")
        return
    endif

    arrest.OnArrestResist(arrestResister, guard, crimeFaction)
endEvent

event OnArrestDefeat(string eventName, string unusedStr, float unusedFlt, Form sender)
    Actor attacker = (sender as Actor)
    Faction crimeFaction = attacker.GetCrimeFaction()

    if (!attacker)
        Error(self, "EventManager::OnArrestDefeat", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    arrest.OnArrestDefeat(attacker)
endEvent

;/
    Event that happens when the player is beginning to elude arrest.
    For Pursuit type arrest eludes, this is the only event that happens, because once the state is changed to Eluded,
    the penalty is given there. However, for Dialogue type arrest eluding, this is the event that is first fired upon making
    contact with a guard, which then gives way to their new dialogue that triggers OnEludingArrestDialogue which is where the penalties are given
    for that arrest elude type.

    string  @eludeType: How the arrest is being eluded, options are: [Dialogue, Pursuit]
        Eluding arrest through Dialogue means that the player has tried to avoid the "Wait, I know you..." guard dialogue
        but they caught up and demanded an explanation.

        Eluding arrest through Pursuit means that the player is trying to run away from the guards after they say lines such as:
        "In the name of the Jarl, I command you to stop!", or "Come quietly or face the Jarl's justice!"

    Form    @sender: Can only be cast to Actor, this is either akSpeaker in case of Dialogue or akPursuer in case of Pursuit.
/;
event OnArrestEludeStart(string eventName, string eludeType, float unusedFlt, Form sender)
    Debug(self, "EventManager::OnArrestEludeStart", "This is called")
    Actor eludedGuard = (sender as Actor)

    if (!eludeType)
        Error(self, "EventManager::OnArrestEludeStart", "There is no Elude Type, failed check!")
        return
    endif

    if (!eludedGuard)
        Error(self, "EventManager::OnArrestEludeStart", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    if (!arrest.MeetsPursuitEludeRequirements(config.Player) && eludeType == "Pursuit")
        ; Player is not running, therefore this doesn't count as eluding arrest if we're processing Pursuit eludes.
        ; This verification is in place to avoid triggering Eluding when going to jail / speaking to the guards,
        ; because those dialogue lines do trigger this since the script is attached to them.
        return
    endif

    arrest.OnArrestEludeStart(eludedGuard, eludeType)
endEvent


; ==========================================================
;                         Jail Events
; ==========================================================

event OnJailBegin(string eventName, string strArg, float numArg, Form sender)
    jail.OnJailBegin()
endEvent

; ==========================================================
;                        Scene Events
; ==========================================================

event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        Error(self, "EventManager::OnSceneStart", "There's either no Scene Name, or the event sender is not a Scene, returning!")
        return
    endif

    sceneManager.OnSceneStart(sceneName, (sender as Scene))
endEvent

event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        Error(self, "EventManager::OnScenePlayingStart", "[" + sceneName + ": SCENE_START] There's either no Scene Name, or the event sender is not a Scene, returning!")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        Error(self, "EventManager::OnScenePlayingStart", "[" + sceneName + ": SCENE_START] There's no passed in Scene Phase as a parameter, returning!");
        return
    endif
    
    sceneManager.OnScenePlaying(sceneName, sceneManager.SCENE_START, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        Error(self, "EventManager::OnScenePlayingEnd", "[" + sceneName + ": SCENE_END] There's either no Scene Name, or the event sender is not a Scene, returning!")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        Error(self, "EventManager::OnScenePlayingEnd", "[" + sceneName + ": SCENE_END] There's no passed in Scene Phase as a parameter, returning!");
        return
    endif
    
    sceneManager.OnScenePlaying(sceneName, sceneManager.SCENE_END, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        Error(self, "EventManager::OnSceneEnd", "There's either no Scene Name, or the event sender is not a Scene, returning!")
        return
    endif

    sceneManager.OnSceneEnd(sceneName, (sender as Scene))
endEvent

; ==========================================================
;                        Package Events
; ==========================================================

; event OnPackageEnd(string eventName, string packageName, float unusedFlt, Form sender)
;     ObjectReference[] data = new ObjectReference[10]

;     data[0] = Guard_EscortLocation.GetReference()
;     data[1] = Escort.GetActorReference()

;     ; AIPackageManager.OnPackageEnd(packageName, data, (sender as Package))
; endEvent


event OnPackageStart(string eventName, string packageName, float unusedFlt, Form sender)
    AIPackageManager_OnPackageStart(packageName, none, sender)
    ; AIPackageManager.OnPackageStart(packageName, data, (sender as Package))
endEvent


; AIPackageManager.psc
event AIPackageManager_OnPackageStart(string packageName, ObjectReference[] data, Form sender)
    if (packageName == "RPB_DGForcegreetPackage")
        Actor speaker = (sender as Actor)
        arrest.ApplyArrestEludedPenalty(speaker.GetCrimeFaction())

    elseif (packageName == "RPB_LockCellDoor")
        OrientRelative(data[1], data[0], afRotZ = 180)
    endif
endEvent

event AIPackageManager_OnPackageEnd(string packageName, ObjectReference[] data, Package sender)
    if (packageName == "RPB_LockCellDoor")
        data[0].SetLockLevel(100)
        data[0].Lock()
    endif
endEvent
