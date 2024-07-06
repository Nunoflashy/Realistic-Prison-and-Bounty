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
    JArray.addStr(actionArrayObj, "Move Selected NPC to ObjectReference")
    JArray.addStr(actionArrayObj, "Test Actor Handcuffing")
    JArray.addStr(actionArrayObj, "Toggle Prisoner Effect on Selected Actor")
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

    elseif (actionToPerform == "Move Selected NPC to ObjectReference")
        Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
        string objectFormId = uilib.ShowInput("ObjectReference ID")
        selectedActor.MoveTo(Game.GetFormEx(0x34003881) as ObjectReference)

    elseif (actionToPerform == "Test Actor Handcuffing")
        Action_TestActorHandcuffing(uilib)

    elseif (actionToPerform == "Toggle Prisoner Effect on Selected Actor")
        Action_TogglePrisonerEffectOnSelectedActor(uilib)

    elseif (actionToPerform == "Advance Solitude Execution")
        Action_AdvanceSolitudeExecution(uilib)

    elseif (actionToPerform == "Toggle Show Prison Sentence")
        Action_TogglePrisonStats(uilib, abSentence = true)

    elseif (actionToPerform == "Toggle Show Prison Release Time")
        Action_TogglePrisonStats(uilib, abReleaseTime = true)

    elseif (actionToPerform == "Toggle Show Prison Time Left")
        Action_TogglePrisonStats(uilib, abTimeLeft = true)

    elseif (actionToPerform == "Toggle Show Prison Time Served")
        Action_TogglePrisonStats(uilib, abTimeServed = true)

    elseif (actionToPerform == "Toggle Show Prison Bounty")
        Action_TogglePrisonStats(uilib, abBounty = true)
 
    elseif (actionToPerform == "Toggle All Prison Stats")
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
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    if (selectedActor == none)
        selectedActor == Game.GetPlayer()
    endif

    RPB_Prison prison     = API.PrisonManager.FindPrisonByPrisoner(selectedActor)
    RPB_Prisoner prisoner = prison.GetPrisoner(selectedActor)

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

    API.Arrest.ArrestActor(randomGuard, selectedActor, string_if (abEscortArrestee, API.Arrest.ARREST_TYPE_ESCORT_TO_CELL, API.Arrest.ARREST_TYPE_TELEPORT_TO_CELL))
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