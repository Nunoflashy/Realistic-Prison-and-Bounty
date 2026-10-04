scriptname RPB_EventManager extends Quest

;/
@references:
    RPB_API API
    RPB_Config Config
    RPB_Arrest Arrest
    RPB_SceneManager SceneManager
@functions:
    function RegisterEvents()
    function SendSurrenderSceneEvent(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent = "null", Form[] akParams = none, Form[] akParams2 = none)
    function SendArrestSceneEvent(string asScene, string asSceneEvent, Actor akArrestee, Actor akAuthority, string asSceneSecondaryEvent = "null")
    function SendArrestSceneBulkEvent(string asScene, string asSceneEvent, Form[] akArrestees, Actor akAuthority, string asSceneSecondaryEvent = "null")
    function SendPrisonSceneEvent(string asScene, string asSceneEvent, Actor akPrisoner, Actor akAuthority, string asSceneSecondaryEvent = "null")
    function SendPrisonSceneBulkEvent(string asScene, string asSceneEvent, Form[] akPrisoners, Actor akAuthority, string asSceneSecondaryEvent = "null")
    function TraceParams(string params, string paramNames = "", string caller = "")
@events:
    event OnTrace(string msg, string caller)
    event OnArrestBegin(string eventName, string arrestType, float arresteeIdFlt, Form sender)
    event OnArrestResist(string eventName, string unusedStr, float arrestResisterIdFlt, Form sender)
    event OnArrestDefeat(string eventName, string unusedStr, float unusedFlt, Form sender)
    event OnArrestEludeStart(string eventName, string eludeType, float unusedFlt, Form sender)
    event OnCombatYield(string eventName, string unusedStr, float unusedFlt, Form sender)
    event OnArrestSceneChanged(string eventName, string sceneName, float unusedFlt, Form sender)
    event OnArrestGoalChanged(string eventName, string newArrestGoal, float unusedFlt, Form sender)
    event OnPayBounty(string eventName, string categoryPayBounty, float arresteeFormIdFlt, Form sender)
    event OnArrestScene(string asScene, string asSceneEvent, RPB_Arrestee apArrestee, Actor akAuthority, string asSceneSecondaryEvent)
    event OnPrisonScene(string asScene, string asSceneEvent, RPB_Prison apPrison, RPB_Prisoner apPrisoner, Actor akAuthority, string asSceneSecondaryEvent)
    event OnSurrenderPreparing(Form akSurrenderer)
    event OnSurrenderScene(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent, Form[] akParams, Form[] akParams2)
    event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    Actor function __DialogueTargetOf(Actor akSpeaker, string asCaller)
    event OnDialogueTopicStart(string topicInfoDialogue, float topicInfoTypeFlt, Form sender, float afStartedAt)
    event OnDialogueTopicEnd(string topicInfoDialogue, float topicInfoTypeFlt, Form sender, float afStartedAt)
    event OnPackageStart(string eventName, string packageName, float unusedFlt, Form sender)
    event AIPackageManager_OnPackageStart(string packageName, ObjectReference[] data, Form sender)
    event AIPackageManager_OnPackageEnd(string packageName, ObjectReference[] data, Package sender)
/;

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
    RegisterForModEvent("RPB_CrimeLineBegan", "OnCrimeLineBegan")

    RegisterForModEvent("RPB_PayBounty", "OnPayBounty")                 ; Happens when the player is about to pay their bounty

    ; Package Event Handlers
    RegisterForModEvent("RPB_PackageEnd", "OnPackageEnd")
    RegisterForModEvent("RPB_PackageStart", "OnPackageStart")

    ; Guard side stacks: a frozen guard only ever holds these (RPB_Utility.ProbeGuard, Prisoner.ClearArrest)
    RegisterForModEvent("RPB_GuardProbe", "OnGuardProbe")
    RegisterForModEvent("RPB_GuardProbeCheck", "OnGuardProbeCheck")
    RegisterForModEvent("RPB_ReleaseCaptor", "OnReleaseCaptor")
    RegisterForModEvent("RPB_ReleaseCaptorBackstop", "OnReleaseCaptorBackstop")
    RegisterForModEvent("RPB_FreeGuard", "OnFreeGuard")

    ; A bounty set aside on submitting, given back if no arrest took it (RPB_Arrest.SetAsideBountyOnSubmission)
    RegisterForModEvent("RPB_SetAsideBountyCheck", "OnSetAsideBountyCheck")
    RegisterForModEvent("RPB_SubmissionTakeover", "OnSubmissionTakeover")
    RegisterForModEvent("RPB_FaintFrozenGuard", "OnFaintFrozenGuard")
endFunction

event OnFaintFrozenGuard(Form akGuard, bool abAlone)
    RPB_Utility.__FaintFrozenGuard(akGuard as Actor, abAlone)
endEvent

event OnSubmissionTakeover(Form akFrozenGuard)
    Arrest.TakeOverSubmission(akFrozenGuard as Actor)
endEvent

event OnSetAsideBountyCheck(Form akActor, float afDelay)
    Utility.Wait(afDelay)
    ; A takeover guard still walking over (a surrender-like approach): its own end gives the bounty back or arrests
    while (Arrest.IsSurrendering(akActor as Actor))
        Utility.Wait(5.0)
    endWhile
    if (RPB_Arrest.GiveBackSetAsideBounty(akActor as Actor, "no arrest took it within " + (afDelay as int) + "s"))
        RPB_Utility.LogWarn("A submission's arrest never started: " + akActor + "'s bounty is back", "EventManager::OnSetAsideBountyCheck")
    endif
endEvent

event OnGuardProbe(string asStep, Form akGuard, float afDelay, float afDueAt)
    if (afDelay > 0.0)
        Utility.Wait(afDelay)
        RPB_Utility.__AddPendingProbe(akGuard as Actor, -1) ; out now
    endif
    RPB_Utility.__RunGuardProbe(akGuard as Actor, asStep, afDueAt)
endEvent

; The probe's answer should be in by now: IsFrozenGuard only reads the list, and reports a probe that never came back
; A look at the probe a few seconds on, again while it's still open: one look only missed the 2026-10-02 freeze (the check
; ran before the probe had written itself down, read "no probe", and never looked again)
event OnGuardProbeCheck(Form akGuard, float afDelay)
    Actor guard = akGuard as Actor
    if (afDelay > 0.0)
        Utility.Wait(afDelay)
    endif
    int looks = 0
    while (looks < 3)
        Utility.Wait(3.5)
        if (RPB_Utility.IsFrozenGuard(guard) || (looks > 0 && !RPB_Utility.IsGuardProbeOpen(guard)))
            return
        endif
        looks += 1
    endWhile
endEvent

event OnReleaseCaptor(Form akGuard, Form akArrestee, bool abFreeGuard)
    Arrest.ReleaseCaptorOf(akGuard as Actor, akArrestee as Actor, abFreeGuard)
endEvent

; Freeze experiment D: the guard's release if his package change never came (RPB_Captor.OnPackageChange clears the mark)
event OnReleaseCaptorBackstop(Form akGuard, Form akArrestee, float afDelay)
    Utility.Wait(afDelay)
    if (!RPB_StorageVars.GetFormOnReference("Release Pending", akGuard, "Captor"))
        return
    endif
    RPB_StorageVars.DeleteVariableOnReference("Release Pending", akGuard, "Captor")
    RPB_Utility.LogWarn(akGuard + ": no package change within " + afDelay + "s, released by the backstop (experiment D)", "EventManager::OnReleaseCaptorBackstop")
    Arrest.ReleaseCaptorOf(akGuard as Actor, akArrestee as Actor, true)
endEvent

; A guard's package lock and package, on their own stack (a dead or frozen guard held the handover there)
event OnFreeGuard(Form akGuard)
    RPB_Recovery.__FreeGuard(akGuard as Actor, SceneManager)
endEvent

; ==========================================================
;                      Event Dispatchers
; ==========================================================

function SendSurrenderSceneEvent(string asScene, string asSceneEvent, Actor akSurrenderer, Actor akSurrendererCaptor, string asSceneSecondaryEvent = "null", Form[] akParams = none, Form[] akParams2 = none)
    self.OnSurrenderScene(asScene, asSceneEvent, akSurrenderer, akSurrendererCaptor, asSceneSecondaryEvent, akParams, akParams2)
endFunction

function SendArrestSceneEvent(string asScene, string asSceneEvent, Actor akArrestee, Actor akAuthority, string asSceneSecondaryEvent = "null")
    if (self.__ArrestAlreadyEndedInPrison(akArrestee, asSceneSecondaryEvent))
        self.__EndSceneIfArresteeGone(asScene, akArrestee)
        return
    endif

    if (self.__ArrestGone(akArrestee, asSceneSecondaryEvent))
        SceneManager.EndSceneEarly(asScene, akArrestee + "'s arrest no longer exists", abRunEndEvents = false)
        return
    endif

    RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(akArrestee)

    if (arrestee == none)
        RPB_Utility.LogError("Could not retrieve the Arrestee reference from the actor, cannot proceed with the scene!")
        return
    endif

    self.OnArrestScene(asScene, asSceneEvent, arrestee, akAuthority, asSceneSecondaryEvent)
endFunction

function SendArrestSceneBulkEvent(string asScene, string asSceneEvent, Form[] akArrestees, Actor akAuthority, string asSceneSecondaryEvent = "null")
    if (!akArrestees || akArrestees.Length == 0)
        RPB_Utility.LogError("No Arrestees provided for bulk scene event!")
        return
    endif

    int i = 0
    while (i < akArrestees.Length)
        if (self.__ArrestAlreadyEndedInPrison(akArrestees[i] as Actor, asSceneSecondaryEvent))
            if (akArrestees.Length == 1)
                self.__EndSceneIfArresteeGone(asScene, akArrestees[i] as Actor)
            endif
        elseif (self.__ArrestGone(akArrestees[i] as Actor, asSceneSecondaryEvent))
            if (akArrestees.Length == 1)
                SceneManager.EndSceneEarly(asScene, akArrestees[i] + "'s arrest no longer exists", abRunEndEvents = false)
            endif
        else
            RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(akArrestees[i] as Actor)

            if (arrestee == none)
                RPB_Utility.LogError("Could not retrieve the Arrestee reference from the actor, cannot proceed with the scene!")
                return
            endif

            Debug("EventManager::SendArrestSceneBulkEvent", "Entering OnArrestScene (Arrestee: "+ arrestee +") (Event: "+ asSceneEvent +", "+ asSceneSecondaryEvent +")")
            self.OnArrestScene(asScene, asSceneEvent, arrestee, akAuthority, asSceneSecondaryEvent)
        endif
        i += 1
    endWhile
endFunction

;/
    True if @akActor's arrest has already ended in imprisonment: no longer an Arrestee, already a Prisoner. A confrontation
    Scene keeps playing its later phases after that when the arrest finishes first (the player leaves right after the
    confirmation, and the off-screen path imprisons in about a second while the Scene is still before "Handcuff").
    Awaiting the Arrestee then would put the Arrestee spell back on the prisoner (AwaitEntityReference ensures the spell
    first), and a new Arrestee effect would start on them once they load. So the event is ignored instead.
    The Arrestee lookup comes first and is the only cost for a normal arrest.
/;
bool function __ArrestAlreadyEndedInPrison(Actor akActor, string asSceneSecondaryEvent)
    if (!akActor || Arrest.Arrestees.AtKey(akActor))
        return false
    endif

    if (!akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        return false
    endif

    Debug("EventManager::__ArrestAlreadyEndedInPrison", akActor + "'s arrest already ended in imprisonment, ignoring the Scene's '" + asSceneSecondaryEvent + "' event")
    return true
endFunction

;/
    @asScene was started but never began playing (the engine silently refuses a Start() it can't run, e.g. an actor still
    in combat). Nothing else will ever move that arrest on, so for an escort I finish it the way the unloaded case in
    Arrestee.EscortToPrison already does: straight to the prison, or to the cell, without the Scene. Only a prisoner that
    isn't imprisoned yet: anything else has already moved on.
/;
function OnSceneStartFailed(string asScene)
    string sceneType = SceneManager.GetSceneType(asScene)
    if (sceneType == SceneManager.CATEGORY_SURRENDER)
        Actor surrenderer = SceneManager.GetSceneNthReferenceOfType(asScene, "Surrenderer") as Actor
        if (surrenderer)
            ; The surrender's watch starts it again (a guard back in combat), and undoes it after the last retry
            Arrest.OnSurrenderSceneFailed(surrenderer)
        endif
        return
    endif

    if (sceneType != SceneManager.CATEGORY_ESCORT_TO_JAIL && sceneType != SceneManager.CATEGORY_ESCORT_TO_CELL)
        return
    endif

    Actor escort    = SceneManager.GetSceneNthReferenceOfType(asScene, "Escort") as Actor
    Actor escortee  = SceneManager.GetSceneNthReferenceOfType(asScene, "Escortee") as Actor
    if (!escortee)
        return
    endif

    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(escortee)
    if (!prison)
        return
    endif

    RPB_Prisoner prisoner = prison.Prisoners.AtKey(escortee)
    if (!prisoner || prisoner.IsImprisoned)
        return
    endif

    Info("EventManager: " + asScene + " never started for " + escortee + " (in combat " + escortee.IsInCombat() + ", escort " + escort + " in combat " + (escort && escort.IsInCombat()) + "), moving them without the Scene")
    if (sceneType == SceneManager.CATEGORY_ESCORT_TO_JAIL && escort)
        prisoner.MoveToPrison(escort)
    else
        prisoner.MoveToCell()
    endif
endFunction

;/
    True if @akActor's arrest doesn't exist anymore at all: not an arrestee (no entry, no Arrestee spell) and not a
    prisoner either (no Prisoner spell) - released, reverted or reset while its Scene was still playing. Awaiting the
    Arrestee would put the arrest back on them (AwaitEntityReference ensures the spell first): a prisoner released
    mid-arrest got the Arrestee spell again from the confrontation Scene's next step. A live arrest always passes: the
    Arrestee spell is added first thing in OnArrestBegin, before any Scene starts.
/;
bool function __ArrestGone(Actor akActor, string asSceneSecondaryEvent)
    if (!akActor || Arrest.Arrestees.AtKey(akActor))
        return false
    endif

    if (akActor.HasSpell(RPB_Utility.RPB_ArresteeSpell()) || akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        return false
    endif

    Debug("EventManager::__ArrestGone", akActor + "'s arrest no longer exists, ignoring the Scene's '" + asSceneSecondaryEvent + "' event")
    return true
endFunction

;/
    The rest of an arrest Scene is only for whoever can see it: once its only arrestee is already imprisoned and not even
    loaded (the player left, the off-screen path imprisoned them), it would otherwise keep playing for up to ~50s and
    hold up every Scene queued behind it. Only called after the arrest has fully ended, so it never cuts a Scene short
    while it still matters.
/;
function __EndSceneIfArresteeGone(string asScene, Actor akArrestee)
    if (akArrestee && !akArrestee.Is3DLoaded())
        SceneManager.EndSceneEarly(asScene, akArrestee + " is already imprisoned and not loaded")
    endif
endFunction

function SendPrisonSceneEvent(string asScene, string asSceneEvent, Actor akPrisoner, Actor akAuthority, string asSceneSecondaryEvent = "null")
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akPrisoner)

    if (prison == none)
        RPB_Utility.LogError("Could not retrieve the prison from " + akPrisoner + ", cannot proceed with the scene!")
        return
    endif

    if (self.__PrisonerAlreadyGone(prison, akPrisoner, asSceneSecondaryEvent))
        return
    endif

    RPB_Prisoner prisoner = prison.AwaitPrisonerReference(akPrisoner)

    if (prisoner == none)
        RPB_Utility.LogError("Could not retrieve the prisoner from the scene event, cannot proceed with the scene!")
        return
    endif

    self.OnPrisonScene(asScene, asSceneEvent, prison, prisoner, akAuthority, asSceneSecondaryEvent)
endFunction

function SendPrisonSceneBulkEvent(string asScene, string asSceneEvent, Form[] akPrisoners, Actor akAuthority, string asSceneSecondaryEvent = "null")
    if (!akPrisoners || akPrisoners.Length == 0)
        RPB_Utility.LogError("No prisoners provided for bulk scene event!", "EventManager::SendPrisonSceneBulkEvent")
        return
    endif

    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(akPrisoners[0] as Actor)

    if (prison == none)
        RPB_Utility.LogError("Could not retrieve the prison from " + akPrisoners[0] + ", cannot proceed with the scene!", "EventManager::SendPrisonSceneBulkEvent")
        return
    endif

    int i = 0
    while (i < akPrisoners.Length)
        if (!self.__PrisonerAlreadyGone(prison, akPrisoners[i] as Actor, asSceneSecondaryEvent))
            RPB_Prisoner prisoner = prison.AwaitPrisonerReference(akPrisoners[i] as Actor)

            if (prisoner == none)
                RPB_Utility.LogError("Could not retrieve the prisoner from the scene event, cannot proceed with the scene!", "EventManager::SendPrisonSceneBulkEvent")
                return
            endif

            self.OnPrisonScene(asScene, asSceneEvent, prison, prisoner, akAuthority, asSceneSecondaryEvent)
        endif
        i += 1
    endWhile
endFunction

;/
    True if @akActor is no longer a prisoner of @apPrison (released, or reset): neither registered nor carrying the Prisoner
    spell (checked second: an away prisoner isn't in the list but keeps the spell). A Scene can still be running for them,
    and awaiting the prisoner would make them one again (AwaitEntityReference ensures the spell first) and run its step on
    them anyway: a prisoner released mid-escort got stripped a second later by the escort's own end.
/;
bool function __PrisonerAlreadyGone(RPB_Prison apPrison, Actor akActor, string asSceneSecondaryEvent)
    if (!akActor || apPrison.Prisoners.AtKey(akActor))
        return false
    endif

    if (akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        return false
    endif

    Debug("EventManager::__PrisonerAlreadyGone", akActor + " is no longer a prisoner of " + apPrison.Name + ", ignoring the Scene's '" + asSceneSecondaryEvent + "' event")
    return true
endFunction

; ==========================================================
;                       Logging Events
; ==========================================================

event OnTrace(string msg, string caller)
    Trace(caller, msg)
endEvent

; Logging: RPB_Utility.LogInfo/LogWarn/LogError (the leveled log); the SendInfo/SendWarning/SendError copies here are gone

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
    RPB_Utility.FlowEnsure("Arrest -> Imprison")
    RPB_Utility.FlowMark("EventManager.OnArrestBegin: mod event delivered")

    Actor captor = (sender as Actor)
    ; Before any call on him: a frozen guard's first call never returns, and this arrest would hang with it
    if (captor && RPB_Utility.IsFrozenGuard(captor))
        Warn("Arrest by " + captor + " rejected: the guard is frozen (see FROZEN GUARD)")
        ; A submission to him: another guard takes it over (no-op otherwise)
        RPB_Arrest.RequestSubmissionTakeover(captor)
        return
    endif
    Faction crimeFaction = form_if ((sender as Faction), (sender as Faction), captor.GetCrimeFaction()) as Faction

    if (captor == none && crimeFaction == none)
        RPB_Utility.LogError("Either there's no Captor, or no Crime Faction! (["+ "Captor: "+ captor + ", Faction: " + crimeFaction +"])", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    ; A dead guard can't arrest anyone. Rejected here, before any arrest state exists: later, the Captor effect can't even
    ; start on a dead actor, and the arrest only got cancelled after that wait timed out (~10s)
    if (captor && (captor.IsDead() || captor.IsDisabled()))
        Info("Arrest by " + captor + " rejected: the guard is dead or gone")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    int actorPlayerId = 0x14
    bool isPlayer = (arresteeIdFlt as int) == actorPlayerId
    Actor arrestee = Game.GetFormEx(int_if (isPlayer, actorPlayerId, arresteeIdFlt as int)) as Actor

    if (!arrestee)
        RPB_Utility.LogError("There's no one to be arrested! (Arrestee is "+ arrestee +")", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    if (!Arrest.ValidateArrestType(arrestType))
        RPB_Utility.LogError("Arrest Type is invalid, got: " + arrestType + ". (valid options: "+ Arrest.GetValidArrestTypes() +") ", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    int arrestStatus = Arrest.GetActorArrestStatus(arrestee)

    if (arrestStatus == Arrest.ALREADY_ARRESTED)
        Config.NotifyArrest("You are already under arrest.", isPlayer) ; Might be removed
        RPB_Utility.LogError(arrestee.GetBaseObject().GetName() + " has already been arrested, cannot arrest for "+ RPB_Utility.GetFormNameCached(crimeFaction) +", aborting!", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return

    elseif (arrestStatus == Arrest.ALREADY_IMPRISONED)
        Config.NotifyArrest("You are already in prison.", isPlayer) ; Might be removed
        RPB_Utility.LogError(arrestee.GetBaseObject().GetName() + " has already been arrested, and is currently in prison. Cannot arrest for "+ RPB_Utility.GetFormNameCached(crimeFaction) +", aborting!", "EventManager::OnArrestBegin")
        RPB_Arrest.GiveBackSetAsideBounty(Game.GetFormEx(arresteeIdFlt as int) as Actor, "the arrest was rejected")
        return
    endif

    RPB_Utility.FlowMark("OnArrestBegin: validated (type, arrest status)")
    RPB_Utility.Crumb(arrestee, "OnArrestBegin: validated (type, arrest status)")

    ; Handle Before Arrest event
    Arrest.OnArrestPreparing(arrestee, captor, crimeFaction, arrestType)
    RPB_Utility.FlowMark("Arrest.OnArrestPreparing done")
    RPB_Utility.Crumb(arrestee, "Arrest.OnArrestPreparing done")

    RPB_Arrestee arresteeRef = Arrest.AwaitArresteeReference(arrestee)  ; Mark this Actor as one that is to be arrested (Cast the spell in order to have Arrestee related functions on them through RPB_Arrestee)

    RPB_Utility.FlowMark("AwaitArresteeReference done (spell, effect start, register)")
    RPB_Utility.Crumb(arrestee, "AwaitArresteeReference done (spell, effect start, register)")

    if (!arresteeRef)
        ; The Arrestee never registered - e.g. the actor died before its effect could start (a corpse can't take it).
        ; Nothing else has run yet, so undo the only things that did happen - the spell and its Hold binding - instead
        ; of leaving the actor half-arrested with a spell no script will ever answer for.
        arrestee.RemoveSpell(RPB_Utility.RPB_ArresteeSpell())
        RPB_StorageVars.DeleteVariableOnReference("Hold UUID", arrestee, "Arrest")
        RPB_Utility.Crumb(arrestee, "OnArrestBegin: arrestee never registered, spell removed (reverted)")
        Config.NotifyArrest("Could not arrest " + arrestee.GetDisplayName())
        RPB_Utility.LogError("Could not arrest " + arrestee + " for "+ RPB_Utility.GetFormNameCached(crimeFaction) +", the Arrestee never registered! (reverted)", "EventManager::OnArrestBegin")
        return
    endif

    if (!arresteeRef.InitializeState())
        Config.NotifyArrest("Could not arrest " + arresteeRef.Name)
        RPB_Utility.LogError("Could not arrest " + arresteeRef.Name + " for "+ RPB_Utility.GetFormNameCached(crimeFaction) +", the state was invalid! (aborting)", "EventManager::OnArrestBegin")
        return
    endif

    RPB_Utility.FlowMark("Arrestee.InitializeState done")
    RPB_Utility.Crumb(arrestee, "Arrestee.InitializeState done")

    ; Faction Arrest
    if (captor == none)
        Arrest.OnArrestBegin(arresteeRef, none, crimeFaction, arrestType)
        return
    endif

    RPB_Captor captorRef = Arrest.AwaitCaptorReference(captor)
    RPB_Utility.FlowMark("AwaitCaptorReference done")
    RPB_Utility.Crumb(arrestee, "AwaitCaptorReference done" + RPB_Utility.string_if(!captorRef, " - NO CAPTOR (" + captor + " never registered)", ""))
    RPB_Utility.Crumb(captor, "Captor await for " + arrestee + ": " + captorRef)

    ; Captor Arrest
    Arrest.OnArrestBegin(arresteeRef, captorRef, crimeFaction, arrestType)
endEvent

event OnArrestResist(string eventName, string unusedStr, float arrestResisterIdFlt, Form sender)
    Actor guard = (sender as Actor)
    Faction crimeFaction = form_if ((sender as Faction), (sender as Faction), guard.GetCrimeFaction()) as Faction

    if (guard == none && crimeFaction == none)
        RPB_Utility.LogError("Either there's no Guard, or no Crime Faction! (["+ "Lead Captor: "+ guard + ", Faction: " + crimeFaction +"])", "EventManager::OnArrestResist")
        return
    endif

    ; Not the player
    Actor arrestResister = Game.GetFormEx(arrestResisterIdFlt as int) as Actor
    if (arrestResister.GetFormID() != 0x14)
        RPB_Utility.LogError("Someone other than the player ("+ arrestResister +") has resisted arrest (how?), returning...", "EventManager::OnArrestResist")
        return
    endif

    Arrest.OnArrestResist(arrestResister, guard, crimeFaction)
endEvent

event OnArrestDefeat(string eventName, string unusedStr, float unusedFlt, Form sender)
    Actor attacker = (sender as Actor)
    Faction crimeFaction = attacker.GetCrimeFaction()

    if (!attacker)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestDefeat")
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
        RPB_Utility.LogError("There is no Elude Type, failed check!", "EventManager::OnArrestEludeStart")
        return
    endif

    if (!eludedGuard)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestEludeStart")
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
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnCombatYield")
        return
    endif

    if (!guard.IsGuard())
        RPB_Utility.LogError("Actor is not a guard, the event will not proceed!", "EventManager::OnCombatYield")
        return
    endif

    ; A real dialogue target only, not __DialogueTargetOf's nearby-player fallback: a yield bark ("All right, you've had
    ; enough") has none, and with the fallback (0.13.1) every yield arrested the player on the spot. Without it, as before,
    ; the guard's own forcegreet follows and the arrest dialogue decides
    Actor yieldedArrestee = guard.GetDialogueTarget()
    if (yieldedArrestee == guard)
        yieldedArrestee = none
    endif

    if (!yieldedArrestee)
        RPB_Utility.Debug("EventManager::OnCombatYield", guard + "'s yield line has no dialogue target: left to his forcegreet")
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
        RPB_Utility.LogError("There was no Scene passed in to the request.", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!arrestee)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!SceneManager.SceneExists(sceneName))
        RPB_Utility.LogError("The Scene " + sceneName + " does not exist, returning...", "EventManager::OnArrestSceneChanged")
        return
    endif

    if (!SceneManager.IsSceneOfType(sceneName, SceneManager.CATEGORY_ARREST_START))
        RPB_Utility.LogError("The Scene " + sceneName + " is not a valid Scene for the type "+ SceneManager.CATEGORY_ARREST_START +", returning...", "EventManager::OnArrestSceneChanged")
        return
    endif

    Arrest.OnArrestSceneChanged(arrestee, sceneName)
endEvent

event OnArrestGoalChanged(string eventName, string newArrestGoal, float unusedFlt, Form sender)
    Actor arrestee = (sender as Actor)
    
    if (newArrestGoal == "")
        RPB_Utility.LogError("There was no Arrest Goal passed in to the request.", "EventManager::OnArrestGoalChanged")
        return
    endif

    string currentArrestGoal = Arrest.GetArrestGoal(arrestee)

    if (newArrestGoal == currentArrestGoal)
        RPB_Utility.LogError("The requested arrest goal is the same as the current one set, returning...", "EventManager::OnArrestGoalChanged")
        return
    endif

    if (!arrestee)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnArrestGoalChanged")
        return
    endif

    if (!Arrest.IsValidArrestGoal(newArrestGoal))
        RPB_Utility.LogError("The Arrest Goal Type " + newArrestGoal + " is not a valid goal, returning...", "EventManager::OnArrestGoalChanged")
        return
    endif

    Arrest.OnArrestGoalChanged(arrestee, currentArrestGoal, newArrestGoal)
endEvent

event OnPayBounty(string eventName, string categoryPayBounty, float arresteeFormIdFlt, Form sender)
    Actor guard = (sender as Actor)

    if (!guard)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnPayBounty")
        return
    endif

    if (!guard.IsGuard())
        RPB_Utility.LogError("Actor is not a Guard, the event will not proceed!", "EventManager::OnPayBounty")
        return
    endif

    Actor arrestee = self.__DialogueTargetOf(guard, "EventManager::OnPayBounty")

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!arrestee)
        RPB_Utility.LogError("Could not get the dialogue target of " + guard + ", returning...", "EventManager::OnPayBounty")
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
                ; Back turned to him, read from the arrestee alone: copying his angle was a call into him, and a frozen guard
                ; held the pose back until he answered, after the cuffs were on (2026-10-04)
                RPB_Utility.TurnBackTo(apArrestee.GetActor(), escort)
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
        RPB_Utility.LogInfo("Prison: " + prison + ", Escort: " + escort + ", Arrestee: " + apArrestee.GetActor(), "EventManager::OnArrestScene")

        if (asSceneEvent == SceneManager.EVENT_ESCORT_BEGIN)
            prison.OnEscortPrisonerToJailBegin(apArrestee, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            prison.OnEscortPrisonerToJailEnd(apArrestee, escort)
        endif

        RPB_Utility.LogInfo("Arrestee -> " + asScene + ": " + asSceneEvent, "EventManager::OnArrestScene")

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

    ; Nothing is done to the prisoner by a dead guard: a phase event already on its way when he died (the handover ends his
    ; Scene, RPB_Arrestee.HandOverInPrison) still stripped and cuffed the prisoner with nobody there. The next guard's own
    ; Scene does it.
    ; Asked without calling into him (PO3 reads it engine side): this runs inside SceneManager's own Scene events, and a
    ; frozen guard's IsDead() held them there, so a stripping never started nor the escort to the cell after it (2026-10-03)
    if ((sceneType == SceneManager.CATEGORY_STRIPPING || sceneType == SceneManager.CATEGORY_RESTRAIN || sceneType == SceneManager.CATEGORY_CLOTHING) && RPB_Utility.IsDeadNoCall(akAuthority))
        Debug("EventManager::OnPrisonScene", asScene + " " + asSceneEvent + " (" + asSceneSecondaryEvent + ") skipped: " + akAuthority + " is dead")
        return
    endif

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
            ; No Crumb() coverage existed anywhere in this Scene's own phase transitions before round 19 - the
            ; confrontation flow (OnArrestBegin, MoveToPrison, etc.) is densely instrumented, but a stalled off-screen
            ; Escort-to-Cell walk had no trail at all to show how far it actually got. Added specifically to diagnose
            ; test 101's continued off-screen stall with real evidence instead of another guessed fix.
            RPB_Utility.Crumb(apPrisoner.GetActor(), "EscortToCell: Begin")

        elseif (asSceneEvent == SceneManager.EVENT_ESCORTING)
            if (asSceneSecondaryEvent == "Release from Captor") ; May be refactored into OnArrestScene
                RPB_Captor captor = Arrest.AwaitCaptorReference(escort)
                captor.StopEscorting()
                ; Arrest.OnCaptorEscortPrisonerEnd()
                ; Arrest.OnCaptorEscortedPrisoner()
            endif

            RPB_Utility.Crumb(apPrisoner.GetActor(), "EscortToCell: Escorting" + RPB_Utility.string_if(handlingSecondaryEvent, " (" + asSceneSecondaryEvent + ")", ""))

            if (handlingSecondaryEvent)
                return
            endif

            apPrison.OnEscortingPrisonerToCell(apPrisoner, escort)

        elseif (asSceneEvent == SceneManager.EVENT_ESCORT_END)
            if (asSceneSecondaryEvent == "Lock Cell")
                jailCell.CellDoor.Close()
                jailCell.CellDoor.Lock()
                Debug.SendAnimationEvent(escort, "IdleLockpick") ; Lock animation
                RPB_Utility.Crumb(apPrisoner.GetActor(), "EscortToCell: Lock Cell")

                ; Arms the Escort-to-Cell stall failsafe here, not at the Scene's own start: a real debug-level log
                ; confirmed this is the last phase cue that reliably fires in a stalled run - phase 4/5/6 end and this
                ; one (phase 7 start) always arrive, nothing after it ever does, in both the successful and the
                ; stalled case. A short, universal timeout from here is safe regardless of player distance, unlike a
                ; longer one guessed from the Scene's own start (round 6's now-removed distance-based split) - lives
                ; on RPB_Prison, not the escorted RPB_Prisoner itself (see QueueEscortToCellStallCheck's own comment).
                apPrison.QueueEscortToCellStallCheck(apPrisoner.GetActor(), 8.0)

            elseif (asSceneSecondaryEvent == "Unlock Cell")
                Debug.SendAnimationEvent(escort, "IdleLockpick")
                jailCell.CellDoor.Unlock()
                jailCell.CellDoor.Open()

            elseif (asSceneSecondaryEvent == "Hands Behind Back")
                apPrisoner.OrientRelativeTo(escort, afRotZ = 180)
                apPrisoner.PlayAnimation("ZazAPC001")

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
                ; Front cuffs; any other pair comes off first (and no load-order-dependent FormID)
                RPB_Utility.EquipCuffs(apPrisoner.GetActor(), abFront = true)

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
        Actor clothingGiver = akAuthority

        if (asSceneEvent == SceneManager.EVENT_CLOTHING_BEGIN)
            apPrison.OnPrisonerClothingBegin(apPrisoner, clothingGiver)

        elseif (asSceneEvent == SceneManager.EVENT_CLOTHING)
            apPrison.OnPrisonerClothingOngoing(apPrisoner, clothingGiver)

        elseif (asSceneEvent == SceneManager.EVENT_CLOTHING_END)
            ; ReleaseAI(apPrisoner.IsPlayer())
            apPrison.OnPrisonerClothingEnd(apPrisoner, clothingGiver)
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
    Debug("EventManager::OnSurrenderPreparing", "RPB_Surrender received for " + akSurrenderer)
    if (!surrenderer)
        return
    endif

    ; The captors that will surround the surrenderer
    Actor[] surrendererCaptors = PO3_SKSEFunctions.GetCombatTargets(surrenderer)
    Debug("EventManager::OnSurrenderPreparing", "combat targets of " + surrenderer + ": " + surrendererCaptors + " (in combat " + surrenderer.IsInCombat() + ")")

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
            ; Not for a surrender already undone: that would lock the player again, with nothing left to release them
            RetainAI(akSurrenderer.GetFormID() == 0x14 && Arrest.IsSurrendering(akSurrenderer))

            ; The forced arrest dialogue stays off from here: turned back on at BeginArrest's end (Arrest.OnArrestEnd), once
            ; the bounty is hidden, or by an undone surrender. Turned on here, an alerted guard force-greeted the player in
            ; the seconds the surrender bounty was still active, and leaving that dialogue counted as resisting.
            Arrest.OnSurrenderEnd(akSurrenderer, akSurrendererCaptor)
        endif
    endif
endEvent

; ==========================================================
;                        Scene Events
; ==========================================================

event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        RPB_Utility.LogError("There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnSceneStart")
        return
    endif

    SceneManager.OnSceneStart(sceneName, (sender as Scene))
endEvent

event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        RPB_Utility.LogError("[" + sceneName + ": PHASE_START] There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnScenePlayingStart")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        RPB_Utility.LogError("[" + sceneName + ": PHASE_START] There's no passed in Scene Phase as a parameter, returning!", "EventManager::OnScenePlayingStart")
        return
    endif
    
    SceneManager.OnScenePlaying(sceneName, SceneManager.PHASE_START, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        RPB_Utility.LogError("[" + sceneName + ": PHASE_END] There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnScenePlayingEnd")
        return
    endif

    if ((scenePhaseFlt as int) < 1 || !scenePhaseFlt)
        RPB_Utility.LogError("[" + sceneName + ": PHASE_END] There's no passed in Scene Phase as a parameter, returning!", "EventManager::OnScenePlayingEnd")
        return
    endif
    
    SceneManager.OnScenePlaying(sceneName, SceneManager.PHASE_END, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    if (sceneName == "" || !(sender as Scene))
        RPB_Utility.LogError("There's either no Scene Name, or the event sender is not a Scene, returning!", "EventManager::OnSceneEnd")
        return
    endif

    SceneManager.OnSceneEnd(sceneName, (sender as Scene))
endEvent

; ====================================================================================================================
;                                                   Topic Dialogue Events
; ====================================================================================================================

;/
    Who @akSpeaker is talking to, for his dialogue fragments' events. GetDialogueTarget() returns none when many guards talk
    at once, and sometimes the speaker himself: a guard who had been fighting next to the player confronted "himself", and
    his go-to-jail line then arrested him instead of the player (2026-10-02). Either way, the player is the fallback when
    nearby: for now these crime lines are only spoken to the player. When NPCs get them too (NPC Bounty Detection), this
    fallback has to know the real target instead.
/;
Actor function __DialogueTargetOf(Actor akSpeaker, string asCaller)
    Actor target = akSpeaker.GetDialogueTarget()
    if (target && target != akSpeaker)
        return target
    endif
    if (akSpeaker.GetDistance(Config.Player) <= 1000)
        RPB_Utility.LogWarn("The dialogue target of " + akSpeaker + " came back as " + target + ", falling back to the player since they are nearby", asCaller)
        return Config.Player
    endif
    return none
endFunction

; A crime line began (RPB_Utility.ProbeSpeaker): a speaker whose earlier line is still stuck is probed
event OnCrimeLineBegan(Form akSpeaker)
    RPB_Utility.__NoteCrimeLine(akSpeaker as Actor)
endEvent

event OnDialogueTopicStart(string topicInfoDialogue, float topicInfoTypeFlt, Form sender, float afStartedAt)
    string eventName = "RPB_TopicInfoStart"
    int topicInfoType = (topicInfoTypeFlt as int)
    Actor akSpeaker = (sender as Actor)

    if (!RPB_Utility.IsTopicInfoFresh(afStartedAt))
        RPB_Utility.LogWarn("Ignored a crime line by " + akSpeaker + " that began before the last load (a replay): '" + topicInfoDialogue + "'", "EventManager::OnDialogueTopicStart")
        return
    endif

    if (!topicInfoType)
        RPB_Utility.LogError("Topic Info Type is none or invalid, returning...", "EventManager::OnDialogueTopicStart")
        return
    endif

    if (!akSpeaker)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnDialogueTopicStart")
        return
    endif

    Actor akSpokenTo = self.__DialogueTargetOf(akSpeaker, "EventManager::OnDialogueTopicStart")

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!akSpokenTo)
        RPB_Utility.LogError("Could not get the dialogue target of " + akSpeaker + ", returning...", "EventManager::OnDialogueTopicStart")
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

event OnDialogueTopicEnd(string topicInfoDialogue, float topicInfoTypeFlt, Form sender, float afStartedAt)
    string eventName    = "RPB_TopicInfoEnd"
    int topicInfoType   = (topicInfoTypeFlt as int)
    Actor akSpeaker     = (sender as Actor)

    if (!RPB_Utility.IsTopicInfoFresh(afStartedAt))
        RPB_Utility.LogWarn("Ignored a crime line by " + akSpeaker + " that began before the last load (a replay): '" + topicInfoDialogue + "'", "EventManager::OnDialogueTopicEnd")
        return
    endif

    if (!topicInfoType)
        RPB_Utility.LogError("Topic Info Type is none or invalid, returning...", "EventManager::OnDialogueTopicEnd")
        return
    endif

    if (!akSpeaker)
        RPB_Utility.LogError("sender is not an Actor, failed check! [sender: "+ sender +"]", "EventManager::OnDialogueTopicEnd")
        return
    endif

    Actor akSpokenTo = self.__DialogueTargetOf(akSpeaker, "EventManager::OnDialogueTopicEnd")

    ; Failed to get dialogue target even with fallback, player must not be near
    if (!akSpokenTo)
        RPB_Utility.LogError("Could not get the dialogue target of " + akSpeaker + ", returning...", "EventManager::OnDialogueTopicEnd")
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
