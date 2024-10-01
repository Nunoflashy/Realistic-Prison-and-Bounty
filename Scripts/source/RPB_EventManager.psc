scriptname RPB_EventManager extends Quest

import RPB_Config
import RPB_Utility

RPB_API __api
RPB_API property API
    RPB_API function get()
        if (__api)
            return __api
        endif

        __api = RPB_API.GetSelf()
        return __api
    endFunction
endProperty

RPB_Config property Config
    RPB_Config function get()
        return API.Config
    endFunction
endProperty

RPB_Arrest property Arrest
    RPB_Arrest function get()
        return API.Arrest
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
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
    RegisterForModEvent("RPB_SetArrestGoal", "OnArrestGoalChanged")     ; Happens when there's a request to change the Arrest goal

    ; Surrender Event Handlers
    RegisterForModEvent("RPB_Surrender", "OnSurrenderPreparing")

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

    RegisterForModEvent("RPB_PayBounty", "OnPayBounty")                 ; Happens when the player is about to pay their bounty

    ; Package Event Handlers
    RegisterForModEvent("RPB_PackageEnd", "OnPackageEnd")
    RegisterForModEvent("RPB_PackageStart", "OnPackageStart")
endFunction

; ==========================================================
;                      Event Dispatchers
; ==========================================================

function SendSurrenderSceneEvent(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent = "null", Form[] akParams = none, Form[] akParams2 = none)
    self.OnSurrenderScene(asScene, asSceneEvent, akSurrenderer, akSurrendererCaptor, asSceneSecondaryEvent, akParams, akParams2)
endFunction

function SendArrestSceneEvent(string asScene, string asSceneEvent, Actor akArrestee, Actor akAuthority, string asSceneSecondaryEvent = "null")
    RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(akArrestee)

    if (arrestee == none)
        self.SendError("Could not retrieve the Arrestee reference from the actor, cannot proceed with the scene!")
        return
    endif

    self.OnArrestScene(asScene, asSceneEvent, arrestee, akAuthority, asSceneSecondaryEvent)
endFunction

function SendArrestSceneBulkEvent(string asScene, string asSceneEvent, Form[] akArrestees, Actor akAuthority, string asSceneSecondaryEvent = "null")
    if (akArrestees == none || akArrestees.Length == 0)
        self.SendError("No Arrestees provided for bulk scene event!")
        return
    endif

    int i = 0
    while (i < akArrestees.Length)
        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(akArrestees[i] as Actor)

        if (arrestee == none)
            self.SendError("Could not retrieve the Arrestee reference from the actor, cannot proceed with the scene!")
            return
        endif

        Debug("EventManager::SendArrestSceneBulkEvent", "Entering OnArrestScene (Arrestee: "+ arrestee +") (Event: "+ asSceneEvent +", "+ asSceneSecondaryEvent +")")
        self.OnArrestScene(asScene, asSceneEvent, arrestee, akAuthority, asSceneSecondaryEvent)
        i += 1
    endWhile
endFunction

function SendPrisonSceneEvent(string asScene, string asSceneEvent, Actor akPrisoner, Actor akAuthority, string asSceneSecondaryEvent = "null")
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akPrisoner)

    if (prison == none)
        self.SendError("Could not retrieve the prison from " + akPrisoner + ", cannot proceed with the scene!")
        return
    endif

    RPB_Prisoner prisoner = prison.AwaitPrisonerReference(akPrisoner) 

    if (prisoner == none)
        self.SendError("Could not retrieve the prisoner from the scene event, cannot proceed with the scene!")
        return
    endif

    self.OnPrisonScene(asScene, asSceneEvent, prison, prisoner, akAuthority, asSceneSecondaryEvent)
endFunction

function SendPrisonSceneBulkEvent(string asScene, string asSceneEvent, Form[] akPrisoners, Actor akAuthority, string asSceneSecondaryEvent = "null")
    if (akPrisoners == none || akPrisoners.Length == 0)
        self.SendError("No prisoners provided for bulk scene event!", "EventManager::SendPrisonSceneBulkEvent")
        return
    endif

    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akPrisoners[0] as Actor)

    if (prison == none)
        self.SendError("Could not retrieve the prison from " + akPrisoners[0] + ", cannot proceed with the scene!", "EventManager::SendPrisonSceneBulkEvent")
        return
    endif

    int i = 0
    while (i < akPrisoners.Length)
        RPB_Prisoner prisoner = prison.AwaitPrisonerReference(akPrisoners[i] as Actor) 

        if (prisoner == none)
            self.SendError("Could not retrieve the prisoner from the scene event, cannot proceed with the scene!", "EventManager::SendPrisonSceneBulkEvent")
            return
        endif

        self.OnPrisonScene(asScene, asSceneEvent, prison, prisoner, akAuthority, asSceneSecondaryEvent)
        i += 1
    endWhile
endFunction

; ==========================================================
;                       Logging Events
; ==========================================================

event OnTrace(string msg, string caller)
    Trace(caller, msg)
endEvent

event OnInfo(string msg, string caller, bool condition)
    Debug(caller, msg, condition)
    Info(msg, condition)
endEvent

event OnWarn(string msg, string caller, bool condition)
    DebugWarn(caller, msg, condition)
    Warn(msg, condition)
endEvent

event OnError(string msg, string caller, bool condition)
    DebugError(caller, msg, condition)
    Error(msg, condition)
endEvent

function SendError(string msg, string caller = "", bool condition = true)
    self.OnError(msg, caller, condition)
endFunction

function SendWarning(string msg, string caller = "", bool condition = true)
    self.OnWarn(msg, caller, condition)
endFunction

function SendInfo(string msg, string caller = "", bool condition = true)
    self.OnInfo(msg, caller, condition)
endFunction

function TraceParams(string params, string paramNames = "", string caller = "")
    string[] splitParams    = StringUtil.Split(params, ",")
    string[] splitNames     = StringUtil.Split(paramNames, ", ")

    string traceMsg = "[\n"
    int i = 0
    while (i < splitParams.Length)
        string paramName = string_if (splitNames[i], splitNames[i], i)
        traceMsg = "\t" + paramName + ": " + splitParams[i] + "\n"
        ; if (i < splitParams.Length - 1)
        ;     traceMsg += "\n"
        ; endif
        i += 1
    endWhile
    traceMsg += "\n]"
    
    self.OnTrace(traceMsg, caller)
endFunction

; ==========================================================
;                        Arrest Events
; ==========================================================

event OnArrestBegin(string eventName, string arrestType, float arresteeIdFlt, Form sender)
    Actor captor = (sender as Actor)
    Faction crimeFaction = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

    if (captor == none && crimeFaction == none)
        self.SendError("Either there's no Captor, or no Crime Faction! (["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"])", "EventManager::OnArrestBegin")
        return
    endif

    int actorPlayerId = 0x14
    bool isPlayer = (arresteeIdFlt as int) == actorPlayerId
    Actor arrestee = Game.GetFormEx(int_if (isPlayer, actorPlayerId, arresteeIdFlt as int)) as Actor

    if (!arrestee)
        self.SendError("There's no one to be arrested! (Arrestee is "+ arrestee +")", "EventManager::OnArrestBegin")
        return
    endif

    if (!Arrest.ValidateArrestType(arrestType))
        self.SendError("Arrest Type is invalid, got: " + arrestType + ". (valid options: "+ Arrest.GetValidArrestTypes() +") ", "EventManager::OnArrestBegin")
        return
    endif

    int arrestStatus = Arrest.GetActorArrestStatus(arrestee)

    if (arrestStatus == Arrest.ALREADY_ARRESTED)
        Config.NotifyArrest("You are already under arrest.", isPlayer) ; Might be removed
        self.SendError(arrestee.GetBaseObject().GetName() + " has already been arrested, cannot arrest for "+ crimeFaction.GetName() +", aborting!", "EventManager::OnArrestBegin")
        return

    elseif (arrestStatus == Arrest.ALREADY_IMPRISONED)
        Config.NotifyArrest("You are already in prison.", isPlayer) ; Might be removed
        self.SendError(arrestee.GetBaseObject().GetName() + " has already been arrested, and is currently in prison. Cannot arrest for "+ crimeFaction.GetName() +", aborting!", "EventManager::OnArrestBegin")
        return
    endif

    ; Handle Before Arrest event
    Arrest.OnArrestPreparing(arrestee, captor, crimeFaction, arrestType)

    RPB_Arrestee arresteeRef = Arrest.AwaitArresteeReference(arrestee)  ; Mark this Actor as one that is to be arrested (Cast the spell in order to have Arrestee related functions on them through RPB_Arrestee)

    ; Faction Arrest
    if (captor == none)
        Arrest.OnArrestBegin(arresteeRef, none, crimeFaction, arrestType)
        return
    endif

    RPB_Captor captorRef = Arrest.AwaitCaptorReference(captor)

    ; Captor Arrest
    Arrest.OnArrestBegin(arresteeRef, captorRef, crimeFaction, arrestType)
endEvent

event OnArrestResist(string eventName, string unusedStr, float arrestResisterIdFlt, Form sender)
    Actor guard = (sender as Actor)
    Faction crimeFaction = form_if ((sender as Faction), (sender as Faction), guard.GetCrimeFaction()) as Faction

    if (guard == none && crimeFaction == none)
        self.SendError("Either there's no Guard, or no Crime Faction! (["+ "Lead Captor: "+ guard + ", Faction: " + crimeFaction +"])", "EventManager::OnArrestResist")
        return
    endif

    ; Not the player
    Actor arrestResister = Game.GetFormEx(arrestResisterIdFlt as int) as Actor
    if (arrestResister.GetFormID() != 0x14)
        self.SendError("Someone other than the player ("+ arrestResister +") has resisted arrest (how?), returning...", "EventManager::OnArrestResist")
        return
    endif

    Arrest.OnArrestResist(arrestResister, guard, crimeFaction)
endEvent

event OnArrestDefeat(string eventName, string unusedStr, float unusedFlt, Form sender)
    Actor attacker = (sender as Actor)
    Faction crimeFaction = attacker.GetCrimeFaction()

    if (!attacker)
        self.SendError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestDefeat")
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
        self.SendError("There is no Elude Type, failed check!", "EventManager::OnArrestEludeStart")
        return
    endif

    if (!eludedGuard)
        self.SendError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestEludeStart")
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
        self.SendError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnCombatYield")
        return
    endif

    if (!guard.IsGuard())
        self.SendError("Actor is not a guard, the event will not proceed!", "EventManager::OnCombatYield")
        return
    endif

    Actor yieldedArrestee = guard.GetDialogueTarget()

    ; Fallback to Player if nearby, since GetDialogueTarget() fails if there are many guards talking at once, yieldedArrestee will be none
    if (!yieldedArrestee && guard.GetDistance(Config.Player) <= 1000)
        self.SendError("Could not get the dialogue target of " + guard + ", falling back to Player since they are nearby.", "EventManager::OnCombatYield")
    endif

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!yieldedArrestee)
        self.SendError("Could not get the dialogue target of " + guard + ", returning...", "EventManager::OnCombatYield")
        Trace("EventManager::OnCombatYield", "Stack Trace: [\n" + \
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
        self.SendError("There was no Scene passed in to the request.", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!arrestee)
        self.SendError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!SceneManager.SceneExists(sceneName))
        self.SendError("The Scene " + sceneName + " does not exist, returning...", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!SceneManager.IsSceneOfType(sceneName, SceneManager.CATEGORY_ARREST_START))
        self.SendError("The Scene " + sceneName + " is not a valid Scene for the type "+ SceneManager.CATEGORY_ARREST_START +", returning...", "EventManager::OnArrestSceneChanged")
        return
    endif

    Arrest.OnArrestSceneChanged(arrestee, sceneName)
endEvent

event OnArrestGoalChanged(string eventName, string newArrestGoal, float unusedFlt, Form sender)
    Actor arrestee = (sender as Actor)
    
    if (newArrestGoal == "")
        self.SendError("There was no Arrest Goal passed in to the request.", "EventManager::OnArrestGoalChanged")
        return
    endif

    string currentArrestGoal = Arrest.GetArrestGoal(arrestee)

    if (newArrestGoal == currentArrestGoal)
        self.SendError("The requested arrest goal is the same as the current one set, returning...", "EventManager::OnArrestGoalChanged")
        return
    endif

    if (!arrestee)
        self.SendError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestGoalChanged")
        return
    endif

    if (!Arrest.IsValidArrestGoal(newArrestGoal))
        self.SendError("The Arrest Goal Type " + newArrestGoal + " is not a valid goal, returning...", "EventManager::OnArrestGoalChanged")
        return
    endif

    Arrest.OnArrestGoalChanged(arrestee, currentArrestGoal, newArrestGoal)
endEvent

event OnPayBounty(string eventName, string categoryPayBounty, float arresteeFormIdFlt, Form sender)
    Actor guard = (sender as Actor)

    if (!guard)
        self.SendError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnPayBounty")
        return
    endif

    if (!guard.IsGuard())
        self.SendError("Actor is not a Guard, the event will not proceed!", "EventManager::OnPayBounty")
        return
    endif

    Actor arrestee = guard.GetDialogueTarget()

    ; Fallback to Player if nearby, since GetDialogueTarget() fails if there are many guards talking at once, arrestee will be none
    if (!arrestee && guard.GetDistance(Config.Player) <= 1000)
        arrestee = Config.Player
        self.SendError("Could not get the dialogue target of " + guard + ", falling back to Player since they are nearby.", "EventManager::OnPayBounty")
    endif

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!arrestee)
        self.SendError("Could not get the dialogue target of " + guard + ", returning...", "EventManager::OnPayBounty")
        Trace("EventManager::OnPayBounty", "Stack Trace: [\n" + \
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

;/
    Handles an Arrest Scene based Event sent from SceneManager.

    string          @asScene: The name of the Scene.
    string          @asSceneEvent: The event that takes place within the Scene.
    RPB_Arrestee    @apArrestee: The arrestee that is taking part in the Scene.
    Actor           @akAuthority: The authority figure of this event (Guard, Captor, Escort, etc...)
    string          @asSceneSecondaryEvent: The secondary event taking place within this scene event.
/;
event OnArrestScene(string asScene, string asSceneEvent, RPB_Arrestee apArrestee, Actor akAuthority, string asSceneSecondaryEvent)
    string sceneType = SceneManager.GetSceneType(asScene)

    if (sceneType == SceneManager.CATEGORY_ARREST_START)
        Actor escort = akAuthority
        
        if (asSceneEvent == SceneManager.EVENT_ARREST_BEGIN)
            RetainAI(apArrestee.IsPlayer())

            if (asSceneSecondaryEvent == "Hands Behind Back")
                Debug("EventManager::OnArrestScene", "Arrestee: " + apArrestee + ", Secondary Event: " + asSceneSecondaryEvent)
                apArrestee.OrientRelativeTo(escort)
                apArrestee.PlayAnimation("IdleHandsBehindBack")
            
            elseif (asSceneSecondaryEvent == "Handcuff")
                apArrestee.Restrain()
                Arrest.OnArresteeRestrained(apArrestee)

            elseif (asSceneSecondaryEvent == "Kneel Down")
                apArrestee.PlayAnimation("ZazAPC018")

            elseif (asSceneSecondaryEvent == "Lie Down")
                apArrestee.PlayAnimation("ZazAPC011")
            endif

            apArrestee.OnArrestBegin()

        elseif (asSceneEvent == SceneManager.EVENT_ARREST_END)
            apArrestee.OnArrestEnd()
        endif

    elseif (sceneType == SceneManager.CATEGORY_ESCORT_TO_JAIL)
        RPB_Prison prison = apArrestee.GetPotentialPrison()
        Actor escort = akAuthority
        self.SendInfo("Prison: " + prison + ", Escort: " + escort + ", Arrestee: " + apArrestee.GetActor(), "EventManager::OnArrestScene")

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            prison.OnEscortPrisonerToJailBegin(apArrestee, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            prison.OnEscortPrisonerToJailEnd(apArrestee, escort)
        endif

        self.SendInfo("Arrestee -> " + asScene + ": " + asSceneEvent, "EventManager::OnArrestScene")

    elseif (sceneType == SceneManager.CATEGORY_ELUDING)
        Actor guard = akAuthority

        if (asSceneEvent == SceneManager.EVENT_ELUDE_BEGIN)
            if (asSceneSecondaryEvent == "Dialogue")
                Arrest.OnArrestEludeTriggered(guard, asSceneSecondaryEvent)
            endif
        endif

    elseif (sceneType == SceneManager.CATEGORY_PAY_BOUNTY)
        Actor escort    = akAuthority
        Actor escortee  = apArrestee.GetActor()

        if (asSceneEvent == SceneManager.EVENT_ARREST_PAYING_BOUNTY)
            if (asSceneSecondaryEvent == "Hands Behind Back")
                RetainAI(apArrestee.IsPlayer())
                apArrestee.OrientRelativeTo(escort, afRotZ = 180)
                apArrestee.PlayAnimation("ZazAPC001") ; Make arrestee put their hands behind the back
            endif

        elseif (asSceneEvent == SceneManager.EVENT_ARREST_PAY_BOUNTY_END)
            if (asSceneSecondaryEvent == "Follow Willingly")
                Arrest.OnArrestPayBountyEnd(escort, escortee, escort.GetCrimeFaction(), false)

            elseif (asSceneSecondaryEvent == "Escort by Force")
                Arrest.OnArrestPayBountyEnd(escort, escortee, escort.GetCrimeFaction(), true)
            endif

            ReleaseAI(apArrestee.IsPlayer()) ; Need to check if this makes sense in this Scene
        endif
    endif
endEvent

; ==========================================================
;                       Prison Events
; ==========================================================

;/
    Handles a Prison Scene based Event sent from SceneManager.

    string          @asScene: The name of the Scene.
    string          @asSceneEvent: The event that takes place within the Scene.
    RPB_Prison      @apPrison: The prison that is responsible for the Scene.
    RPB_Prisoner    @apPrisoner: The prisoner that is taking part in the Scene.
    Actor           @akAuthority: The authority figure of this event (Guard, Captor, Escort, Stripper, etc...)
    string          @asSceneSecondaryEvent: The secondary event taking place within this scene event.
/;
event OnPrisonScene(string asScene, string asSceneEvent, RPB_Prison apPrison, RPB_Prisoner apPrisoner, Actor akAuthority, string asSceneSecondaryEvent)
    string sceneType  = SceneManager.GetSceneType(asScene)

    ; Return right before calling the event handler for the main event if we're processing a secondary event
    bool handlingSecondaryEvent = asSceneSecondaryEvent != "null"

    if (sceneType == SceneManager.CATEGORY_ESCORT_TO_JAIL)
        Actor escort = akAuthority

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            RetainAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerToJailBegin(apPrisoner, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            apPrison.OnEscortPrisonerToJailEnd(apPrisoner, escort)
        endif

    elseif (sceneType == SceneManager.CATEGORY_ESCORT_TO_CELL)
        Actor escort = akAuthority
        RPB_JailCell jailCell = apPrisoner.JailCell

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            RetainAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerToCellBegin(apPrisoner, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORTING)
            if (asSceneSecondaryEvent == "Release from Captor") ; May be refactored into OnArrestScene
                RPB_Captor captor = Arrest.AwaitCaptorReference(escort)
                captor.StopEscorting()
                ; Arrest.OnCaptorEscortPrisonerEnd()
                ; Arrest.OnCaptorEscortedPrisoner()
            endif

            if (handlingSecondaryEvent)
                return
            endif

            apPrison.OnEscortingPrisonerToCell(apPrisoner, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            if (asSceneSecondaryEvent == "Lock Cell")
                jailCell.CellDoor.Close()
                jailCell.CellDoor.Lock()
                Debug.SendAnimationEvent(escort, "IdleLockpick") ; Lock animation

            elseif (asSceneSecondaryEvent == "Unlock Cell")
                Debug.SendAnimationEvent(escort, "IdleLockpick")
                jailCell.CellDoor.Unlock()
                jailCell.CellDoor.Open()

            elseif (asSceneSecondaryEvent == "Restrain Prisoner")
                apPrison.RestrainPrisoner(apPrisoner)
            endif

            if (handlingSecondaryEvent)
                return
            endif

            ReleaseAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerToCellEnd(apPrisoner, jailCell, escort)
        endif

    elseif (sceneType == SceneManager.CATEGORY_ESCORT_FROM_CELL)
        Actor escort = akAuthority

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            RetainAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerFromCellBegin(apPrisoner, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORTING)
            RetainAI(apPrisoner.IsPlayer())

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            ReleaseAI(apPrisoner.IsPlayer())
            apPrison.OnEscortPrisonerFromCellEnd(apPrisoner, escort)
        endif

    elseif (sceneType == SceneManager.CATEGORY_STRIPPING)
        Actor stripper = akAuthority

        if (asSceneEvent == SceneManager.EVENT_STRIP_BEGIN)
            RetainAI(apPrisoner.IsPlayer())

            if (asSceneSecondaryEvent == "Undress to Underwear")
                apPrisoner.Strip(abRemoveUnderwear = false)

            elseif (asSceneSecondaryEvent == "Lie Down")
                apPrisoner.PlayAnimation("IdleLayDownEnter")
            endif

            if (handlingSecondaryEvent)
                return
            endif

            apPrison.OnPrisonerStripBegin(apPrisoner, stripper)

        elseif (asSceneEvent == SceneManager.EVENT_STRIPPING)
            RetainAI(apPrisoner.IsPlayer())
            apPrison.OnPrisonerStripping(apPrisoner, stripper, asSceneSecondaryEvent)

        elseif (asSceneEvent == SceneManager.EVENT_STRIP_END)
            if (asSceneSecondaryEvent == "Restrain Prisoner")
                Form cuffs = Game.GetFormEx(0xA081D33)
                apPrisoner.SheatheWeapon()
                apPrisoner.EquipItem(cuffs, true, true)

            elseif (asSceneSecondaryEvent == "Stand Up (Kneel)")
                apPrisoner.PlayAnimation("IdleKneelExit") ; TODO: Not working
                API.Arrest.RestrainArrestee(apPrisoner.GetActor())
            endif

            if (handlingSecondaryEvent)
                return
            endif

            apPrison.OnPrisonerStripEnd(apPrisoner, stripper)

        elseif (asSceneEvent == SceneManager.EVENT_FORCED_STRIP_BEGIN)
            apPrison.OnPrisonerStripBegin(apPrisoner, stripper)

        elseif (asSceneEvent == SceneManager.EVENT_FORCED_STRIPPING)
            apPrison.OnPrisonerStripping(apPrisoner, stripper, asSceneSecondaryEvent)

        elseif (asSceneEvent == SceneManager.EVENT_FORCED_STRIP_END)
            apPrison.OnPrisonerStripEnd(apPrisoner, stripper)
        endif

    elseif (sceneType == SceneManager.CATEGORY_CLOTHING)
        if (asSceneEvent == SceneManager.EVENT_CLOTHING_BEGIN)

        elseif (asSceneEvent == SceneManager.EVENT_CLOTHING)

        elseif (asSceneEvent == SceneManager.EVENT_CLOTHING_END)
            ReleaseAI(apPrisoner.IsPlayer())

        endif

    elseif (sceneType == SceneManager.CATEGORY_NO_CLOTHING)

    elseif (sceneType == SceneManager.CATEGORY_RESTRAIN)
        Actor guard = akAuthority

        if (asSceneEvent == SceneManager.EVENT_RESTRAIN_BEGIN)
            if (asSceneSecondaryEvent == "Hands in Front")
                apPrisoner.PlayAnimation("IdleWarmHands")

            elseif (asSceneSecondaryEvent == "Hands Behind Back")
                apPrisoner.OrientRelativeTo(guard)
                apPrisoner.PlayAnimation("IdleHandsBehindBack")
            endif

        elseif (asSceneEvent == SceneManager.EVENT_RESTRAIN_END)
            apPrison.RestrainPrisoner(apPrisoner, true)
        endif
    endif
endEvent

; ==========================================================
;                        Surrender Events
; ==========================================================

event OnSurrenderPreparing(Form akSurrenderer)
    Actor surrenderer = akSurrenderer as Actor
    if (!surrenderer)
        return
    endif

    ; The captors that will surround the surrenderer
    Actor[] surrendererCaptors = PO3_SKSEFunctions.GetCombatTargets(surrenderer)

    if (!Arrest.CanActorSurrender(surrenderer, surrendererCaptors))
        return
    endif

    ; Should only be for player (to avoid forced dialogue during surrender)
    RPB_Arrest.DisableForcedArrestDialogue()

    Arrest.OnSurrenderBegin(surrenderer, surrendererCaptors)
endEvent

event OnSurrenderScene(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent, Form[] akParams, Form[] akParams2)
    string sceneType = SceneManager.GetSceneType(asScene)

    if (sceneType == SceneManager.CATEGORY_SURRENDER)
        if (asSceneEvent == SceneManager.EVENT_SURRENDER_BEGIN)
            ; TODO: Refactor this
            Form[] captors = akParams
            Actor mainCaptor = RPB_Utility.GetNearestActorFromList(akSurrenderer, captors)
            ReferenceAlias paramBinder = SceneManager.GetSceneNthAliasOfType(asScene, "SurrendererCaptor")
            BindAliasTo(paramBinder, mainCaptor)
            Debug("EventManager::OnSurrenderScene", "akParams: " + akParams + ", akSurrenderer: " + akSurrenderer)

        elseif (asSceneEvent == SceneManager.EVENT_SURRENDER_END)
            RetainAI(akSurrenderer.GetFormID() == 0x14)

            Arrest.OnSurrenderEnd(akSurrenderer, akSurrendererCaptor)
            
            ; Re-enable forced arrest dialogue for next times (Actor has surrendered)
            RPB_Arrest.EnableForcedArrestDialogue()
        endif
    endif
endEvent

; ==========================================================
;                        Scene Events
; ==========================================================

event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        self.SendError("There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnSceneStart")
        return
    endif

    SceneManager.OnSceneStart(sceneName, (sender as Scene))
endEvent

event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        self.SendError("[" + sceneName + ": PHASE_START] There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnScenePlayingStart")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        self.SendError("[" + sceneName + ": PHASE_START] There's no passed in Scene Phase as a parameter, returning!", "EventManager::OnScenePlayingStart")
        return
    endif
    
    SceneManager.OnScenePlaying(sceneName, SceneManager.PHASE_START, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        self.SendError("[" + sceneName + ": PHASE_END] There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnScenePlayingEnd")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        self.SendError("[" + sceneName + ": PHASE_END] There's no passed in Scene Phase as a parameter, returning!", "EventManager::OnScenePlayingEnd")
        return
    endif
    
    SceneManager.OnScenePlaying(sceneName, SceneManager.PHASE_END, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        self.SendError("There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnSceneEnd")
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
        self.SendError("Topic Info Type is none or invalid, returning...", "EventManager::OnDialogueTopicStart")
        return
    endif

    if (!akSpeaker)
        self.SendError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnDialogueTopicStart")
        return
    endif

    Actor akSpokenTo = akSpeaker.GetDialogueTarget()

    ; Fallback to Player if nearby, since GetDialogueTarget() fails if there are many guards talking at once, akSpokenTo will be none
    if (!akSpokenTo && akSpeaker.GetDistance(Config.Player) <= 1000)
        akSpokenTo = Config.Player
        self.SendError("Could not get the dialogue target of " + akSpeaker + ", falling back to Player since they are nearby.", "EventManager::OnDialogueTopicStart")
    endif

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!akSpokenTo)
        self.SendError("Could not get the dialogue target of " + akSpeaker + ", returning...", "EventManager::OnDialogueTopicStart")
        Trace("EventManager::OnDialogueTopicStart", "Stack Trace: [\n" + \
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
        self.SendError("Topic Info Type is none or invalid, returning...", "EventManager::OnDialogueTopicEnd")
        return
    endif

    if (!akSpeaker)
        self.SendError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnDialogueTopicEnd")
        return
    endif

    Actor akSpokenTo = akSpeaker.GetDialogueTarget()

    ; Fallback to Player if nearby, since GetDialogueTarget() fails if there are many guards talking at once, akSpokenTo will be none
    if (!akSpokenTo && akSpeaker.GetDistance(Config.Player) <= 1000)
        akSpokenTo = Config.Player
        self.SendError("Could not get the dialogue target of " + akSpeaker + ", falling back to Player since they are nearby.", "EventManager::OnDialogueTopicStart")
    endif

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!akSpokenTo)
        self.SendError("Could not get the dialogue target of " + akSpeaker + ", returning...", "EventManager::OnDialogueTopicEnd")
        TraceParams(eventName + "," + topicInfoDialogue +","+topicInfoType, "eventName, topicInfoDialogue, topicInfoType")
        Trace("EventManager::OnDialogueTopicEnd", "Stack Trace: [\n" + \
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
