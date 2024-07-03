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
    JArray.addStr(actionArrayObj, "Don't do anything")
    JArray.addStr(actionArrayObj, "Quit to Main Menu")
    JArray.addStr(actionArrayObj, "Validate Options")
    JArray.addStr(actionArrayObj, "Play Animation on Selected Actor")
    JArray.addStr(actionArrayObj, "Bind All Prisoners")
    JArray.addStr(actionArrayObj, "[Captor Arrest] Arrest Selected Actor (Escort Prisoner)")
    JArray.addStr(actionArrayObj, "[Captor Arrest] Arrest Selected Actor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Faction Arrest] Arrest Selected Actor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Add Selected Actor to Current Arrest")
    JArray.addStr(actionArrayObj, "[Prison] Imprison Selected Actor")
    JArray.addStr(actionArrayObj, "Release Prisoner from Prison (Escort)")
    JArray.addStr(actionArrayObj, "Release Prisoner from Prison (Teleport)")
    JArray.addStr(actionArrayObj, "Bind Cell Package to Reference")
    JArray.addStr(actionArrayObj, "Bind Actor to Cell Package")
    JArray.addStr(actionArrayObj, "Evaluate Selected NPC Package")
    JArray.addStr(actionArrayObj, "Advance Solitude Execution")
    JArray.addStr(actionArrayObj, "Toggle Show Prison Sentence")
    JArray.addStr(actionArrayObj, "Toggle Show Prison Release Time")
    JArray.addStr(actionArrayObj, "Toggle Show Prison Time Left")
    JArray.addStr(actionArrayObj, "Toggle Show Prison Time Served")
    JArray.addStr(actionArrayObj, "Toggle Show Prison Bounty")
    JArray.addStr(actionArrayObj, "Toggle All Prison Stats")

    string[] actionArray = JArray.asStringArray(actionArrayObj)
    return actionArray
endFunction

function ShowActionsMenu()
    RPB_UIInterface uilib   = (self as Form) as RPB_UIInterface
    string actionToPerform  = uilib.ShowList_ReturnElement("Execute Action", self.GetActions(), 0, 0)

    if (actionToPerform == "Quit to Main Menu")
        Game.QuitToMainMenu()

    elseif (actionToPerform == "Validate Options")
        API.MCM.ValidateOptions()

    elseif (actionToPerform == "Play Animation on Selected Actor")
        Action_PlayAnimationOnActor(uilib)

    elseif (actionToPerform == "Bind All Prisoners")
        Action_BindAllPrisoners(uilib)

    elseif (actionToPerform == "[Captor Arrest] Arrest Selected Actor (Escort Prisoner)")
        Action_ArrestSelectedActor(uilib, true)

    elseif (actionToPerform == "[Captor Arrest] Arrest Selected Actor (Teleport Prisoner)")
        Action_ArrestSelectedActor(uilib, false)

    elseif (actionToPerform == "[Faction Arrest] Arrest Selected Actor (Teleport Prisoner)")
        Action_ArrestSelectedActorForFaction(uilib)

    elseif (actionToPerform == "[Arrest] Add Selected Actor to Current Arrest")
        Action_AddSelectedActorToArrest(uilib)

    elseif (actionToPerform == "Release Prisoner from Prison (Escort)")
        Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    elseif (actionToPerform == "Release Prisoner from Prison (Teleport)")
        Action_ReleasePrisoner(uilib)

    elseif (actionToPerform == "Bind Cell Package to Reference")
        Action_BindCellPackageToReference(uilib)

    elseif (actionToPerform == "Bind Actor to Cell Package")
        Action_BindActorToCellPackage(uilib, false)

    elseif (actionToPerform == "Bind Actor to Cell Package (By Name)")
        Action_BindActorToCellPackage(uilib, true)

    elseif (actionToPerform == "Evaluate Selected NPC Package")
        Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
        Package SolitudeOpeningGretaWait = Game.GetFormEx(0xA3BD0) as Package
        ActorUtil.AddPackageOverride(selectedActor, SolitudeOpeningGretaWait)
        selectedActor.EvaluatePackage()

    elseif (actionToPerform == "Advance Solitude Execution")
        Action_AdvanceSolitudeExecution(uilib)

    elseif (actionToPerform == "Toggle Show Prison Sentence")
        RPB_Prison playerPrison = API.PrisonManager.FindPrisonByPrisoner(Game.GetForm(0x14) as Actor)
        RPB_Prisoner playerPrisoner = playerPrison.GetPrisoner(Game.GetForm(0x14) as Actor)
        playerPrisoner.ShowSentence = !playerPrisoner.ShowSentence

    elseif (actionToPerform == "Toggle Show Prison Release Time")
        RPB_Prison playerPrison = API.PrisonManager.FindPrisonByPrisoner(Game.GetForm(0x14) as Actor)
        RPB_Prisoner playerPrisoner = playerPrison.GetPrisoner(Game.GetForm(0x14) as Actor)
        playerPrisoner.ShowReleaseTime = !playerPrisoner.ShowReleaseTime

    elseif (actionToPerform == "Toggle Show Prison Time Left")
        RPB_Prison playerPrison = API.PrisonManager.FindPrisonByPrisoner(Game.GetForm(0x14) as Actor)
        RPB_Prisoner playerPrisoner = playerPrison.GetPrisoner(Game.GetForm(0x14) as Actor)
        playerPrisoner.ShowTimeLeftInSentence = !playerPrisoner.ShowTimeLeftInSentence

    elseif (actionToPerform == "Toggle Show Prison Time Served")
        RPB_Prison playerPrison = API.PrisonManager.FindPrisonByPrisoner(Game.GetForm(0x14) as Actor)
        RPB_Prisoner playerPrisoner = playerPrison.GetPrisoner(Game.GetForm(0x14) as Actor)
        playerPrisoner.ShowTimeServed = !playerPrisoner.ShowTimeServed

    elseif (actionToPerform == "Toggle Show Prison Bounty")
        RPB_Prison playerPrison = API.PrisonManager.FindPrisonByPrisoner(Game.GetForm(0x14) as Actor)
        RPB_Prisoner playerPrisoner = playerPrison.GetPrisoner(Game.GetForm(0x14) as Actor)
        playerPrisoner.ShowBounty = !playerPrisoner.ShowBounty

    elseif (actionToPerform == "Toggle All Prison Stats")
        Action_TogglePrisonStats(uilib)
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
function Action_TogglePrisonStats(RPB_UIInterface uilib)
    RPB_Prison playerPrison                 = API.PrisonManager.FindPrisonByPrisoner(Game.GetForm(0x14) as Actor)
    RPB_Prisoner playerPrisoner             = playerPrison.GetPrisoner(Game.GetForm(0x14) as Actor)
    playerPrisoner.ShowSentence             = !playerPrisoner.ShowSentence
    playerPrisoner.ShowReleaseTime          = !playerPrisoner.ShowReleaseTime
    playerPrisoner.ShowTimeLeftInSentence   = !playerPrisoner.ShowTimeLeftInSentence
    playerPrisoner.ShowTimeServed           = !playerPrisoner.ShowTimeServed
    playerPrisoner.ShowBounty               = !playerPrisoner.ShowBounty
endFunction

; Releases the selected Prisoner
function Action_ReleasePrisoner(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    RPB_Prison prison   = API.PrisonManager.FindPrisonByPrisoner(selectedActor)

    if (!prison)
        return
    endif

    RPB_Prisoner prisoner = prison.GetPrisoner(selectedActor)
    prisoner.Release()
endFunction

function Action_BindCellPackageToReference(RPB_UIInterface uilib)
    int packageIndex = uilib.ShowInput("Cell Package ID") as int
    ReferenceAlias cellPackage  = API.Prisonmanager.GetCellPackageByName("S_000" + packageIndex)
    ObjectReference selectedRef = Game.GetCurrentConsoleRef()

    BindAliasTo(cellPackage, selectedRef)
    Debug("Actions::Action_BindCellPackageToReference", "Bound Cell Package " + cellPackage.GetName() + " to " + selectedRef)
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

function Action_AdvanceSolitudeExecution(RPB_UIInterface uilib)
    int questStage = uilib.ShowInput("Advance to Quest Stage") as int
    SolitudeOpeningScript solitudeQuest = Game.GetForm(0xB2FD9) as SolitudeOpeningScript
    solitudeQuest.SetStage(questStage)
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

    API.Arrest.ArrestActor(randomGuard, selectedActor, string_if (abEscortArrestee, API.Arrest.ARREST_TYPE_ESCORT_TO_JAIL, API.Arrest.ARREST_TYPE_TELEPORT_TO_CELL))
endFunction

function Action_AddSelectedActorToArrest(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    RPB_SceneManager sceneManager = API.SceneManager

    BindAliasTo(sceneManager.GetEscortee(1), selectedActor)
endFunction

function Action_ArrestSelectedActorForFaction(RPB_UIInterface uilib)
    int selectedFactionFormID
    int factionsArrayObj = JArray.object()
    JArray.addStr(factionsArrayObj, "Haafingar")

    string[] factionsArray = JArray.asStringArray(factionsArrayObj)
    string selectedFaction = uilib.ShowList_ReturnElement("Crime Faction for Arrest", factionsArray, 0, 0)
    
    ; TODO: Add the other Factions
    if (selectedFaction == "Haafingar")
        selectedFactionFormID = 0x29DB0
    endif

    Faction crimeFaction = Game.GetForm(selectedFactionFormID) as Faction

    if (!crimeFaction)
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