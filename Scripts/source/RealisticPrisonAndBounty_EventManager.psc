scriptname RealisticPrisonAndBounty_EventManager extends Quest

import RealisticPrisonAndBounty_Config
import RealisticPrisonAndBounty_Util

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property Arrest
    RealisticPrisonAndBounty_Arrest function get()
        return Config.Arrest
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property Jail
    RealisticPrisonAndBounty_Jail function get()
        return Config.Jail
    endFunction
endProperty

RealisticPrisonAndBounty_SceneManager property SceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        return Config.SceneManager
    endFunction
endProperty

function RegisterEvents()
    ; Arrest Event Handlers
    RegisterForModEvent("RPB_ArrestBegin", "OnArrestBegin")             ; Start the Arrest
    RegisterForModEvent("RPB_ResistArrest", "OnArrestResist")           ; Resisting Arrest
    RegisterForModEvent("RPB_EludingArrest", "OnArrestEludeStart")      ; Eluding Arrest (Start)
    RegisterForModEvent("RPB_ArrestDefeated", "OnArrestDefeat")         ; Happens after the player is defeated through DA
    RegisterForModEvent("RPB_CombatYield", "OnCombatYield")             ; Happens when the player is spared after yielding
    RegisterForModEvent("RPB_SetArrestScene", "OnArrestSceneChanged")   ; Happens when there's a request to change the Arrest scene
    RegisterForModEvent("RPB_SetArrestGoal", "OnArrestGoalChanged")   ; Happens when there's a request to change the Arrest scene

    ; Jail Event Handlers
    RegisterForModEvent("RPB_JailBegin", "OnJailBegin")
    RegisterForModEvent("RPB_JailEnd", "OnJailEnd")
    RegisterForModEvent("RPB_SendPrisonActionRequest", "OnPrisonActionRequest")

    ; Scene Event Handlers (SF_Scene Scripts)
    RegisterForModEvent("RPB_SceneStart", "OnSceneStart")               ; Handles Scene start events, whenever a Scene begins playing.
    RegisterForModEvent("RPB_ScenePlayingStart", "OnScenePlayingStart") ; Handles Scene ongoing events, divided by phases at the beginning of the phase.
    RegisterForModEvent("RPB_ScenePlayingEnd", "OnScenePlayingEnd")     ; Handles Scene ongoing events, divided by phases at the end of the phase.
    RegisterForModEvent("RPB_SceneEnd", "OnSceneEnd")                   ; Handles Scene end events, whenever a Scene ends playing.

    ; Topic Info Event Handlers (TIF Scripts)
    RegisterForModEvent("RPB_TopicInfoStart", "OnDialogueTopicStart")
    RegisterForModEvent("RPB_TopicInfoEnd", "OnDialogueTopicEnd")

    RegisterForModEvent("RPB_PayBounty", "OnPayBounty")               ; Happens when the player is about to pay their bounty

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

    if (!Arrest.ValidateArrestType(arrestType))
        Error(Arrest, "EventManager::OnArrestBegin", "Arrest Type is invalid, got: " + arrestType + ". (valid options: "+ Arrest.GetValidArrestTypes() +") ")
        return
    endif

    RPB_Arrestee arresteeRef = Arrest.MakeArrestee(arrestee)  ; Mark this Actor as one that is to be arrested (Cast the spell in order to have Arrestee related functions on them through RPB_Arrestee)
    Arrest.OnArrestBegin(arresteeRef, captor, crimeFaction, arrestType)
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

    Arrest.OnArrestResist(arrestResister, guard, crimeFaction)
endEvent

event OnArrestDefeat(string eventName, string unusedStr, float unusedFlt, Form sender)
    Actor attacker = (sender as Actor)
    Faction crimeFaction = attacker.GetCrimeFaction()

    if (!attacker)
        Error(self, "EventManager::OnArrestDefeat", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    Arrest.OnArrestDefeat(attacker)
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
    Actor eludedGuard = (sender as Actor)

    if (!eludeType)
        Error(self, "EventManager::OnArrestEludeStart", "There is no Elude Type, failed check!")
        return
    endif

    if (!eludedGuard)
        Error(self, "EventManager::OnArrestEludeStart", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    if (!Arrest.MeetsPursuitEludeRequirements(config.Player) && eludeType == "Pursuit")
        ; Player is not running, therefore this doesn't count as eluding arrest if we're processing Pursuit eludes.
        ; This verification is in place to avoid triggering Eluding when going to jail / speaking to the guards,
        ; because those dialogue lines do trigger this since the script is attached to them.
        return
    endif

    Arrest.OnArrestEludeStart(eludedGuard, eludeType)
endEvent

event OnCombatYield(string eventName, string unusedStr, float unusedFlt, Form sender)
    Actor guard = (sender as Actor)

    if (!guard)
        Error(self, "EventManager::OnCombatYield", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    if (!guard.IsGuard())
        Info(self, "EventManager::OnCombatYield", "Actor is not a guard, the event will not proceed!")
        return
    endif

    Actor yieldedArrestee = guard.GetDialogueTarget()

    ; Fallback to Player if nearby, since GetDialogueTarget() fails if there are many guards talking at once, yieldedArrestee will be none
    if (!yieldedArrestee && guard.GetDistance(Config.Player) <= 1000)
        yieldedArrestee = Config.Player
        Debug(self, "EventManager::OnCombatYield", "Could not get the dialogue target of " + guard + ", falling back to Player since they are nearby.")
    endif

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!yieldedArrestee)
        Error(self, "EventManager::OnCombatYield", "Could not get the dialogue target of " + guard + ", returning...")
        Trace(self, "EventManager::OnCombatYield", "Stack Trace: [\n" + \
            "\teventName: " + eventName + "\n" + \
            "\tsender: " + sender + "\n" + \
            "\tguard: " + guard + "\n" + \
            "\tyieldedArrestee: " + yieldedArrestee + "\n" + \
        "\n]")
        return
    endif

    Arrest.OnCombatYield(guard, yieldedArrestee)
endEvent

event OnArrestSceneChanged(string eventName, string sceneName, float unusedFlt, Form sender)
    Actor arrestee = (sender as Actor)

    if (sceneName == "")
        Error(self, "EventManager::OnArrestSceneChanged", "There was no Scene passed in to the request.")
        return
    endif

    if (!arrestee)
        Error(self, "EventManager::OnArrestSceneChanged", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    if (!SceneManager.SceneExists(sceneName))
        Error(self, "EventManager::OnArrestSceneChanged", "The Scene " + sceneName + " does not exist, returning...")
        return
    endif

    string sceneCategoryArrestStart = SceneManager.CATEGORY_ARREST_START

    if (!SceneManager.IsValidScene(sceneCategoryArrestStart, sceneName))
        Error(self, "EventManager::OnArrestSceneChanged", "The Scene " + sceneName + " is not a valid Scene for the type "+ sceneCategoryArrestStart +", returning...")
        return
    endif

    Arrest.OnArrestSceneChanged(arrestee, sceneName)
endEvent

event OnArrestGoalChanged(string eventName, string newArrestGoal, float unusedFlt, Form sender)
    Actor arrestee = (sender as Actor)
    
    if (newArrestGoal == "")
        Error(self, "EventManager::OnArrestGoalChanged", "There was no Arrest Goal passed in to the request.")
        return
    endif

    string currentArrestGoal = Arrest.GetArrestGoal(arrestee)

    if (newArrestGoal == currentArrestGoal)
        Debug(self, "EventManager::OnArrestGoalChanged", "The requested arrest goal is the same as the current one set, returning...")
        return
    endif

    if (!arrestee)
        Error(self, "EventManager::OnArrestGoalChanged", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    if (!Arrest.IsValidArrestGoal(newArrestGoal))
        Error(self, "EventManager::OnArrestGoalChanged", "The Arrest Goal Type " + newArrestGoal + " is not a valid goal, returning...")
        return
    endif

    Arrest.OnArrestGoalChanged(arrestee, currentArrestGoal, newArrestGoal)
endEvent

event OnPayBounty(string eventName, string categoryPayBounty, float arresteeFormIdFlt, Form sender)
    Actor guard = (sender as Actor)

    if (!guard)
        Error(self, "EventManager::OnPayBounty", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    if (!guard.IsGuard())
        Info(self, "EventManager::OnPayBounty", "Actor is not a Guard, the event will not proceed!")
        return
    endif

    Actor arrestee = guard.GetDialogueTarget()

    ; Fallback to Player if nearby, since GetDialogueTarget() fails if there are many guards talking at once, arrestee will be none
    if (!arrestee && guard.GetDistance(Config.Player) <= 1000)
        arrestee = Config.Player
        Debug(self, "EventManager::OnPayBounty", "Could not get the dialogue target of " + guard + ", falling back to Player since they are nearby.")
    endif

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!arrestee)
        Error(self, "EventManager::OnPayBounty", "Could not get the dialogue target of " + guard + ", returning...")
        Trace(self, "EventManager::OnPayBounty", "Stack Trace: [\n" + \
            "\teventName: " + eventName + "\n" + \
            "\tsender: " + sender + "\n" + \
            "\tguard: " + guard + "\n" + \
            "\tarrestee: " + arrestee + "\n" + \
        "\n]")
        return
    endif

    Faction crimeFaction = guard.GetCrimeFaction()

    Arrest.OnArrestPayBounty(guard, arrestee, crimeFaction, categoryPayBounty)

endEvent

; ==========================================================
;                         Jail Events
; ==========================================================

event OnJailBegin(string eventName, string strArg, float numArg, Form sender)
    Actor prisoner = (sender as Actor)

    if (!prisoner)
        Error(self, "EventManager::OnJailBegin", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    RPB_Prisoner prisonerRef = Jail.GetPrisonerReference(prisoner)

    if (!prisonerRef)
        Error(self, "EventManager::OnJailBegin", "Actor " + prisoner + " is not registered as a prisoner, there is no reference. Returning...")
        return
    endif

    Jail.OnJailBegin(prisonerRef)
endEvent

event OnPrisonActionRequest(string eventName, string actionName, float numArg, Form sender)
    Actor prisoner = (sender as Actor)

    if (!prisoner)
        Error(self, "EventManager::OnPrisonActionRequest", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    RPB_Prisoner prisonerRef = Jail.GetPrisonerReference(prisoner)

    if (!prisonerRef)
        Error(self, "EventManager::OnPrisonActionRequest", "Actor " + prisoner + " is not registered as a prisoner, there is no reference. Returning...")
        return
    endif

    Jail.OnPrisonActionRequest(actionName, prisonerRef)
endEvent


; ==========================================================
;                        Scene Events
; ==========================================================

event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        Error(self, "EventManager::OnSceneStart", "There's either no Scene Name, or the event sender is not a Scene, returning!")
        return
    endif

    SceneManager.OnSceneStart(sceneName, (sender as Scene))
endEvent

event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        Error(self, "EventManager::OnScenePlayingStart", "[" + sceneName + ": PHASE_START] There's either no Scene Name, or the event sender is not a Scene, returning!")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        Error(self, "EventManager::OnScenePlayingStart", "[" + sceneName + ": PHASE_START] There's no passed in Scene Phase as a parameter, returning!");
        return
    endif
    
    SceneManager.OnScenePlaying(sceneName, SceneManager.PHASE_START, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        Error(self, "EventManager::OnScenePlayingEnd", "[" + sceneName + ": PHASE_END] There's either no Scene Name, or the event sender is not a Scene, returning!")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        Error(self, "EventManager::OnScenePlayingEnd", "[" + sceneName + ": PHASE_END] There's no passed in Scene Phase as a parameter, returning!");
        return
    endif
    
    SceneManager.OnScenePlaying(sceneName, SceneManager.PHASE_END, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        Error(self, "EventManager::OnSceneEnd", "There's either no Scene Name, or the event sender is not a Scene, returning!")
        return
    endif

    SceneManager.OnSceneEnd(sceneName, (sender as Scene))
endEvent

; ====================================================================================================================
;                                                   Topic Dialogue Events
; ====================================================================================================================

event OnDialogueTopicStart(string eventName, string topicInfoDialogue, float topicInfoTypeFlt, Form sender)
    int topicInfoType = (topicInfoTypeFlt as int)
    Actor akSpeaker = (sender as Actor)

    if (!topicInfoType)
        Error(self, "EventManager::OnDialogueTopicStart", "Topic Info Type is none or invalid, returning...")
        return
    endif

    if (!akSpeaker)
        Error(self, "EventManager::OnDialogueTopicStart", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    Actor akSpokenTo = akSpeaker.GetDialogueTarget()

    ; Fallback to Player if nearby, since GetDialogueTarget() fails if there are many guards talking at once, akSpokenTo will be none
    if (!akSpokenTo && akSpeaker.GetDistance(Config.Player) <= 1000)
        akSpokenTo = Config.Player
        Debug(self, "EventManager::OnDialogueTopicStart", "Could not get the dialogue target of " + akSpeaker + ", falling back to Player since they are nearby.")
    endif

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!akSpokenTo)
        Error(self, "EventManager::OnDialogueTopicStart", "Could not get the dialogue target of " + akSpeaker + ", returning...")
        Trace(self, "EventManager::OnDialogueTopicStart", "Stack Trace: [\n" + \
            "\teventName: " + eventName + "\n" + \
            "\ttopicInfoDialogue: " + topicInfoDialogue + "\n" + \
            "\ttopicInfoType: " + topicInfoType + "\n" + \
            "\tsender: " + sender + "\n" + \
            "\takSpeaker: " + akSpeaker + "\n" + \
            "\takSpokenTo: " + akSpokenTo + "\n" + \
        "\n]")
        return
    endif

    ; Only handle Arrest Events
    if (topicInfoType >= Arrest.TOPIC_TYPE_ARREST_SUSPICIOUS && topicInfoType <= Arrest.TOPIC_TYPE_ARREST_GO_TO_JAIL)
        Arrest.OnArrestDialogue(Arrest.TOPIC_START, topicInfoType, topicInfoDialogue, akSpeaker, akSpokenTo)
    endif
endEvent

event OnDialogueTopicEnd(string eventName, string topicInfoDialogue, float topicInfoTypeFlt, Form sender)
    int topicInfoType   = (topicInfoTypeFlt as int)
    Actor akSpeaker     = (sender as Actor)

    if (!topicInfoType)
        Error(self, "EventManager::OnDialogueTopicEnd", "Topic Info Type is none or invalid, returning...")
        return
    endif

    if (!akSpeaker)
        Error(self, "EventManager::OnDialogueTopicEnd", "sender is not an Actor, failed check! [sender: "+ sender +"]")
        return
    endif

    Actor akSpokenTo = akSpeaker.GetDialogueTarget()

    ; Fallback to Player if nearby, since GetDialogueTarget() fails if there are many guards talking at once, akSpokenTo will be none
    if (!akSpokenTo && akSpeaker.GetDistance(Config.Player) <= 1000)
        akSpokenTo = Config.Player
        Debug(self, "EventManager::OnDialogueTopicStart", "Could not get the dialogue target of " + akSpeaker + ", falling back to Player since they are nearby.")
    endif

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!akSpokenTo)
        Error(self, "EventManager::OnDialogueTopicEnd", "Could not get the dialogue target of " + akSpeaker + ", returning...")
        Trace(self, "EventManager::OnDialogueTopicEnd", "Stack Trace: [\n" + \
            "\teventName: " + eventName + "\n" + \
            "\ttopicInfoDialogue: " + topicInfoDialogue + "\n" + \
            "\ttopicInfoType: " + topicInfoType + "\n" + \
            "\tsender: " + sender + "\n" + \
            "\takSpeaker: " + akSpeaker + "\n" + \
            "\takSpokenTo: " + akSpokenTo + "\n" + \
        "\n]")
        return
    endif

    ; Only handle Arrest Events
    if (topicInfoType >= Arrest.TOPIC_TYPE_ARREST_SUSPICIOUS && topicInfoType <= Arrest.TOPIC_TYPE_ARREST_GO_TO_JAIL)
        Arrest.OnArrestDialogue(Arrest.TOPIC_END, topicInfoType, topicInfoDialogue, akSpeaker, akSpokenTo)
    endif
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
    ; if (packageName == "RPB_DGForcegreetPackage")
    ;     Actor speaker = (sender as Actor)
    ;     Arrest.ApplyArrestEludedPenalty(speaker.GetCrimeFaction())

    ; elseif (packageName == "RPB_LockCellDoor")
    ;     OrientRelative(data[1], data[0], afRotZ = 180)
    ; endif
endEvent

event AIPackageManager_OnPackageEnd(string packageName, ObjectReference[] data, Package sender)
    if (packageName == "RPB_LockCellDoor")
        data[0].SetLockLevel(100)
        data[0].Lock()
    endif
endEvent
