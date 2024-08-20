scriptname RPB_Actions extends ObjectReference

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

string[] function GetActions()
    int actionArrayObj = JArray.object()
    JArray.addStr(actionArrayObj, "<No Action>")
    JArray.addStr(actionArrayObj, "Quit to Main Menu")
    JArray.addStr(actionArrayObj, "[MCM] Validate Options")
    JArray.addStr(actionArrayObj, "Play Animation on Selected Actor")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor (Escort Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Faction Arrest] Arrest Selected Actor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Add Selected Actor to Current Arrest")
    JArray.addStr(actionArrayObj, "[Prison] Bind All Prisoners")
    JArray.addStr(actionArrayObj, "[Prison] Reindex PrisonerList")
    JArray.addStr(actionArrayObj, "[Prison] Imprison Nearby Actors")
    JArray.addStr(actionArrayObj, "[Prison] Imprison Selected Actor")
    JArray.addStr(actionArrayObj, "[Prison] Check Prisoners AI Status")
    JArray.addStr(actionArrayObj, "[Prison] Release Prisoner from Prison")
    JArray.addStr(actionArrayObj, "[Prison] Bind Cell Package to Reference")
    JArray.addStr(actionArrayObj, "[Prison] Bind Actor to Cell Package")
    JArray.addStr(actionArrayObj, "[Prison] Toggle Show Prison Sentence")
    JArray.addStr(actionArrayObj, "[Prison] Toggle Show Prison Release Time")
    JArray.addStr(actionArrayObj, "[Prison] Toggle Show Prison Time Left")
    JArray.addStr(actionArrayObj, "[Prison] Toggle Show Prison Time Served")
    JArray.addStr(actionArrayObj, "[Prison] Toggle Show Prison Bounty")
    JArray.addStr(actionArrayObj, "[Prison] Toggle All Prison Stats")
    JArray.addStr(actionArrayObj, "Move Selected NPC to ObjectReference")
    JArray.addStr(actionArrayObj, "Test Actor Handcuffing")
    JArray.addStr(actionArrayObj, "Toggle Prisoner Effect on Selected Actor")
    string[] actionArray = JArray.asStringArray(actionArrayObj)
    return actionArray
endFunction

function ShowActionsMenu()
    RPB_UIInterface uilib   = (self as Form) as RPB_UIInterface
    string actionToPerform  = uilib.ShowList_ReturnElement("Execute Action", self.GetActions(), 0, 0)

    if (actionToPerform == "Quit to Main Menu")
        Game.QuitToMainMenu()

    elseif (actionToPerform == "[MCM] Validate Options")
        API.MCM.ValidateOptions()

    elseif (actionToPerform == "Play Animation on Selected Actor")
        Action_PlayAnimationOnActor(uilib)

    elseif (actionToPerform == "[Prison] Bind All Prisoners")
        Action_BindAllPrisoners(uilib)

    elseif (actionToPerform == "[Prison] Reindex PrisonerList")
        Action_TestReindexing(uilib)

    elseif (actionToPerform == "[Arrest] Arrest Selected Actor (Escort Prisoner)")
        Action_ArrestSelectedActor(uilib, true)

    elseif (actionToPerform == "[Arrest] Arrest Selected Actor (Teleport Prisoner)")
        Action_ArrestSelectedActor(uilib, false)

    elseif (actionToPerform == "[Faction Arrest] Arrest Selected Actor (Teleport Prisoner)")
        Action_ArrestSelectedActorForFaction(uilib)

    elseif (actionToPerform == "[Prison] Imprison Selected Actor")
        Action_ImprisonSelectedActor(uilib)

    elseif (actionToPerform == "[Prison] Check Prisoners AI Status")
        Action_CheckPrisonersAI(uilib)

    elseif(actionToPerform == "[Prison] Imprison Nearby Actors")
        Action_ImprisonNearbyActors(uilib)

    elseif (actionToPerform == "[Arrest] Add Selected Actor to Current Arrest")
        Action_AddSelectedActorToArrest(uilib)

    elseif (actionToPerform == "[Prison] Release Prisoner from Prison")
        Action_ReleasePrisoner(uilib)

    elseif (actionToPerform == "[Prison] Bind Cell Package to Reference")
        Action_BindCellPackageToReference(uilib)

    elseif (actionToPerform == "[Prison] Bind Actor to Cell Package")
        Action_BindActorToCellPackage(uilib, false)

    elseif (actionToPerform == "[Prison] Bind Actor to Cell Package (By Name)")
        Action_BindActorToCellPackage(uilib, true)

    elseif (actionToPerform == "Move Selected NPC to ObjectReference")
        Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
        string objectFormId = uilib.ShowInput("ObjectReference ID")
        selectedActor.MoveTo(Game.GetFormEx(0x34003881) as ObjectReference)

    elseif (actionToPerform == "Test Actor Handcuffing")
        Action_TestActorHandcuffing(uilib)

    elseif (actionToPerform == "Toggle Prisoner Effect on Selected Actor")
        Action_TogglePrisonerEffectOnSelectedActor(uilib)

    elseif (actionToPerform == "[Prison] Toggle Show Prison Sentence")
        Action_TogglePrisonStats(uilib, abSentence = true)

    elseif (actionToPerform == "[Prison] Toggle Show Prison Release Time")
        Action_TogglePrisonStats(uilib, abReleaseTime = true)

    elseif (actionToPerform == "[Prison] Toggle Show Prison Time Left")
        Action_TogglePrisonStats(uilib, abTimeLeft = true)

    elseif (actionToPerform == "[Prison] Toggle Show Prison Time Served")
        Action_TogglePrisonStats(uilib, abTimeServed = true)

    elseif (actionToPerform == "[Prison] Toggle Show Prison Bounty")
        Action_TogglePrisonStats(uilib, abBounty = true)
 
    elseif (actionToPerform == "[Prison] Toggle All Prison Stats")
        Action_TogglePrisonStats(uilib, true, true, true, true, true)
    endif
endFunction


; ==========================================================
;                           Actions
; ==========================================================

function Action_PlayAnimationOnActor(RPB_UIInterface uilib)
    Actor selectedActor     = Game.GetCurrentConsoleRef() as Actor
    string actorName        = selectedActor.GetBaseObject().GetName()
    string animationToPlay  = uilib.ShowInput(actorName + " - Play Animation")

    Debug.SendAnimationEvent(selectedActor, animationToPlay)
    Debug("Actions::Action_PlayAnimationOnActor", "Playing " + animationToPlay + " on Actor " + actorName)
endFunction

; TODO: Add option to select the Prison
function Action_BindAllPrisoners(RPB_UIInterface uilib)
    RPB_Prison castleDourDungeon = API.PrisonManager.GetPrison("Haafingar")
    castleDourDungeon.BindAllPrisonersToCell()
endFunction

; TODO: Check what options are desired, or all, and allow to do this for selected NPC's as well as the Player
function Action_TogglePrisonStats(RPB_UIInterface uilib, bool abSentence = false, bool abReleaseTime = false, bool abTimeLeft = false, bool abTimeServed = false, bool abBounty = false)
    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison)

    if (prisoner == none)
        return none
    endif

    if (abSentence)
        prisoner.ShowSentence = !prisoner.ShowSentence
    endif

    if (abReleaseTime)
        prisoner.ShowReleaseTime = !prisoner.ShowReleaseTime
    endif

    if (abTimeLeft)
        prisoner.ShowTimeLeftInSentence = !prisoner.ShowTimeLeftInSentence
    endif

    if (abTimeServed)
        prisoner.ShowTimeServed = !prisoner.ShowTimeServed
    endif

    if (abBounty)
        prisoner.ShowBounty = !prisoner.ShowBounty
    endif
endFunction

function Action_ReleasePrisoner(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    if (selectedActor != none)
        RPB_Prison prisonBySelectedPrisoner = API.PrisonManager.FindPrisonByPrisoner(selectedActor)
        if (prisonBySelectedPrisoner != none)
            ; No need to check for selectedPrisoner result because FindPrisonByPrisoner(Actor) already implies that the Actor must be a prisoner,
            ; if selectedPrisoner is none, there's something wrong in the assignment of prisoners
            RPB_Prisoner selectedPrisoner = prisonBySelectedPrisoner.GetPrisoner(selectedActor)
            selectedPrisoner.Release()
            return
        endif
    endif

    ; Otherwise, proceed as normal and show the dropdown for the Prison & Prisoners

    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison, asListTitle = "Release Prisoner")

    if (prisoner == none)
        return none
    endif
    
    prisoner.Release()
endFunction

function Action_TestReindexing(RPB_UIInterface uilib)
    RPB_Prison prison           = API.PrisonManager.GetPrison("Haafingar")
    RPB_PrisonerList prisoners  = prison.Prisoners
    prisoners.__private_reindex_data()
endFunction

function Action_BindCellPackageToReference(RPB_UIInterface uilib)
    int packageIndex = uilib.ShowInput("Cell Package ID") as int
    ReferenceAlias cellPackage  = API.Prisonmanager.GetCellPackageByName("S_000" + packageIndex)
    ObjectReference selectedRef = Game.GetCurrentConsoleRef()

    BindAliasTo(cellPackage, selectedRef)
    Debug("Actions::Action_BindCellPackageToReference", "Bound Cell Package " + cellPackage.GetName() + " to " + selectedRef)
endFunction

function Action_TogglePrisonerEffectOnSelectedActor(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    if (selectedActor == none)
        selectedActor == Game.GetPlayer()
    endif

    RPB_Prison prison       = API.PrisonManager.FindPrisonByPrisoner(selectedActor)

    if (!prison)
        Debug("Actions::Action_TogglePrisonerEffectOnSelectedActor", "Could not find prison for the selected prisoner!")
        return
    endif

    ; if prisoner fails, and prison doesn't, something is wrong with Prison.GetPrisoner()
    RPB_Prisoner prisoner   = prison.GetPrisoner(selectedActor)

    if (prisoner.GetState() == "Imprisoned")
        prisoner.GotoState("")
        RegisterForUpdateGameTime(1.0)

    else
        prisoner.GotoState("Imprisoned")
        RegisterForUpdateGameTime(1.0)
    endif
endFunction

function Action_BindActorToCellPackage(RPB_UIInterface uilib, bool abByName = false)
    if (abByName)
        string packageName = uilib.ShowInput("Cell Package Name")
        ReferenceAlias cellPackage  = API.Prisonmanager.GetCellPackageByName(packageName)
        Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    
        BindAliasTo(cellPackage, selectedActor)
        Debug("Actions::Action_BindActorToCellPackage", "Bound Cell Package " + cellPackage.GetName() + " to " + selectedActor)
        return
    endif

    int packageIndex = uilib.ShowInput("Cell Package ID") as int
    ReferenceAlias cellPackage  = API.Prisonmanager.GetCellPackageByName("S_000" + packageIndex)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    BindAliasTo(cellPackage, selectedActor)
    Debug("Actions::Action_BindActorToCellPackage", "Bound Cell Package " + cellPackage.GetName() + " to " + selectedActor)
endFunction

function Action_TestActorHandcuffing(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    if (selectedActor == none)
        selectedActor == Game.GetPlayer()
    endif

    Armor handcuffs = RPB_Utility.RPB_PrisonerHandCuffs()
    Idle IdleBoundHandsBehindBackInstant = Game.GetFormEx(0x109837) as Idle

    selectedActor.PlayIdle(IdleBoundHandsBehindBackInstant)
    selectedActor.EquipItem(handcuffs, true, true)
    Game.DisablePlayerControls(abFighting = true)
endFunction

function Action_ArrestSelectedActor(RPB_UIInterface uilib, bool abEscortArrestee = true)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    Actor randomGuard   = RPB_Utility.GetNearestGuard(selectedActor, 500, selectedActor)
    string actorName    = selectedActor.GetBaseObject().GetName()
    string holdName     = randomGuard.GetCrimeFaction().GetName()
    bool isPlayer       = selectedActor.GetFormID() == 0x14

    int currentBounty
    if (!isPlayer)
        currentBounty = RPB_ActorVars.GetCrimeGold(randomGuard.GetCrimeFaction(), selectedActor)
    else
        currentBounty = randomGuard.GetCrimeFaction().GetCrimeGold()
    endif

    int arrestBounty = int_if (currentBounty == 0, (uilib.ShowInput(holdName + " - Bounty to set for " + actorName) as int), currentBounty)

    if (arrestBounty == 0)
        return
    endif

    if (!isPlayer)
        RPB_ActorVars.SetCrimeGold(randomGuard.GetCrimeFaction(), selectedActor, arrestBounty)
    else
        randomGuard.GetCrimeFaction().SetCrimeGold(arrestBounty)
    endif

    ; Select Cell
    ; string cellId = uilib.ShowInput("Cell for Imprisonment of " + actorName + " in " + holdName)
    ; uilib.ShowList_ReturnElement("Cell for Imprisonment of ", cellIds, 0, 0)

    API.Arrest.ArrestActor(randomGuard, selectedActor, string_if (abEscortArrestee, API.Arrest.ARREST_TYPE_ESCORT_TO_CELL, API.Arrest.ARREST_TYPE_TELEPORT_TO_CELL))
endFunction

function Action_AddSelectedActorToArrest(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    RPB_SceneManager sceneManager = API.SceneManager

    BindAliasTo(sceneManager.GetEscortee(1), selectedActor)
endFunction

function Action_ArrestSelectedActorForFaction(RPB_UIInterface uilib)
    string selectedFaction  = uilib.ShowHoldList("Select Faction for Arrest")

    Faction crimeFaction    = API.Config.GetFaction(selectedFaction)
    if (crimeFaction == none)
        return
    endif

    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    string actorName    = selectedActor.GetBaseObject().GetName()
    string holdName     = crimeFaction.GetName()
    bool isPlayer       = selectedActor.GetFormID() == 0x14

    int currentBounty
    if (!isPlayer)
        currentBounty = RPB_ActorVars.GetCrimeGold(crimeFaction, selectedActor)
    else
        currentBounty = crimeFaction.GetCrimeGold()
    endif

    int arrestBounty = int_if (currentBounty == 0, (uilib.ShowInput(holdName + " - Bounty to set for " + actorName) as int), currentBounty)

    if (arrestBounty == 0)
        return
    endif

    if (!isPlayer)
        RPB_ActorVars.SetCrimeGold(crimeFaction, selectedActor, arrestBounty)
    else
        RPB_ActorVars.SetCrimeGold(crimeFaction, selectedActor, arrestBounty)
        ; crimeFaction.SetCrimeGold(arrestBounty)
    endif

    API.Arrest.ArrestActorForFaction(crimeFaction, selectedActor, API.Arrest.ARREST_TYPE_TELEPORT_TO_CELL)
endFunction

function Action_ImprisonSelectedActor(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    if (selectedActor == none)
        selectedActor == Game.GetPlayer()
    endif

    RPB_Prison prison       = uilib.ShowPrisonList(abNotEmpty = false, abShowCity = true, abShowHold = false, abShowPrisonerCount = false, asListTitle = "Send " + selectedActor.GetBaseObject().GetName() + " to Prison")
    RPB_Prisoner prisoner   = prison.MakePrisoner(selectedActor)

    ; Set showable options in prisoner info menu
    prisoner.ShowReleaseTime          = true
    prisoner.ShowSentence             = true
    prisoner.ShowTimeServed           = true
    prisoner.ShowTimeLeftInSentence   = true
    prisoner.ShowBounty               = true

    prisoner.SetBelongingsContainer()
    prisoner.UndetermineSentence()
    ; prisoner.SetSentence(10)

    prisoner.AssignCell()
    prisoner.MoveToCell()
endFunction

function Action_CheckPrisonersAI(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList()

    int i = 0
    while (i < prison.Prisoners.Count)
        RPB_Prisoner prisoner = prison.Prisoners.AtIndex(i)
        int nameLength  = StringUtil.GetLength(prisoner.Name)
        string tabs     = string_if (nameLength >= 10, "\t", "\t\t")
        Debug("Actions::Action_CheckPrisonersAI", "["+ prisoner.Name +"] "+ tabs + prisoner.GetActor() +"\t{ AI: " + prisoner.HasAI() + " | In Cell: "+ prisoner.IsInCell +" | Jail Cell: "+ prisoner.JailCell +" Location: "+ prisoner.GetCurrentCell() +"}")
        i += 1
    endWhile
endFunction

function Action_ImprisonNearbyActors(RPB_UIInterface uilib)
    int i = 0
    int actorsToImprison = 30
    RPB_Prison prison       = API.PrisonManager.GetPrison("Haafingar")
    ObjectReference selectedRef       = Game.GetCurrentConsoleRef()

    while (i < actorsToImprison)
        Actor scannedActor = Game.FindClosestActorFromRef(selectedRef, 7000)

        RPB_Prisoner prisoner
        
        if (scannedActor)
            prisoner = prison.MakePrisoner(scannedActor)
            selectedRef = scannedActor
        endif

        ; Set showable options in prisoner info menu
        prisoner.ShowReleaseTime          = true
        prisoner.ShowSentence             = true
        prisoner.ShowTimeServed           = true
        prisoner.ShowTimeLeftInSentence   = true
        prisoner.ShowBounty               = true

        prisoner.SetBelongingsContainer()
        prisoner.UndetermineSentence()
        ; prisoner.SetSentence(10)

        prisoner.AssignCell()
        prisoner.MoveToCell()
        i += 1
    endWhile
endFunction
