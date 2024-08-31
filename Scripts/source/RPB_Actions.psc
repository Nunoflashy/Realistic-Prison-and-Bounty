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
    JArray.addStr(actionArrayObj, "[Bounty] Set Bounty for Selected Actor")
    JArray.addStr(actionArrayObj, "[Bounty] Set Violent Bounty for Selected Actor")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor (Escort Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor with Selected Captor (Escort Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Faction Arrest] Arrest Selected Actor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Add Selected Actor to Current Arrest")
    JArray.addStr(actionArrayObj, "[Prison] Bind All Prisoners")
    JArray.addStr(actionArrayObj, "[Prison] Refresh Cell Options")
    JArray.addStr(actionArrayObj, "[Prison] Pre-Assign Cell to Prisoner")
    JArray.addStr(actionArrayObj, "[Prison] Reindex PrisonerList")
    JArray.addStr(actionArrayObj, "[Prison] Imprison Nearby Actors")
    JArray.addStr(actionArrayObj, "[Prison] Imprison Selected Actor")
    JArray.addStr(actionArrayObj, "[Prison] Check Prisoners AI Status")
    JArray.addStr(actionArrayObj, "[Prison] Show Prison Container")
    JArray.addStr(actionArrayObj, "[Prison] Show Prisoner Inventory")
    JArray.addStr(actionArrayObj, "[Prison] Return Prisoner Belongings")
    JArray.addStr(actionArrayObj, "[Prison] Strip Prisoner")
    JArray.addStr(actionArrayObj, "[Prison] Strip Prisoner to Underwear")
    JArray.addStr(actionArrayObj, "[Prison] Set Prisoner State Property")
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

    elseif (actionToPerform == "[Bounty] Set Bounty for Selected Actor")
        Action_SetBountyForActor(uilib)

    elseif (actionToPerform == "[Bounty] Set Violent Bounty for Selected Actor")
        Action_SetBountyForActor(uilib, true)

    elseif (actionToPerform == "[Prison] Bind All Prisoners")
        Action_BindAllPrisoners(uilib)

    elseif (actionToPerform == "[Prison] Refresh Cell Options")
        Action_RefreshCellOptions(uilib)

    elseif (actionToPerform == "[Prison] Pre-Assign Cell to Prisoner")
        Action_PreAssignCellToPrisoner(uilib)

    elseif (actionToPerform == "[Prison] Reindex PrisonerList")
        Action_TestReindexing(uilib)

    elseif (actionToPerform == "[Arrest] Arrest Selected Actor (Escort Prisoner)")
        Action_ArrestSelectedActor(uilib, true)

    elseif (actionToPerform == "[Arrest] Arrest Selected Actor with Selected Captor (Escort Prisoner)")
        Action_ArrestSelectedActor(uilib, true, true)

    elseif (actionToPerform == "[Arrest] Arrest Selected Actor (Teleport Prisoner)")
        Action_ArrestSelectedActor(uilib, false)

    elseif (actionToPerform == "[Faction Arrest] Arrest Selected Actor (Teleport Prisoner)")
        Action_ArrestSelectedActorForFaction(uilib)

    elseif (actionToPerform == "[Prison] Imprison Selected Actor")
        Action_ImprisonSelectedActor(uilib)

    elseif (actionToPerform == "[Prison] Check Prisoners AI Status")
        Action_CheckPrisonersAI(uilib)

    elseif (actionToPerform == "[Prison] Show Prison Container")
        Action_ShowPrisonContainer(uilib)

    elseif (actionToPerform == "[Prison] Show Prisoner Inventory")
        Action_ShowPrisonerInventory(uilib)

    elseif (actionToPerform == "[Prison] Return Prisoner Belongings")
        Action_ReturnPrisonerBelongings(uilib)

    elseif (actionToPerform == "[Prison] Strip Prisoner")
        Action_StripPrisoner(uilib)

    elseif (actionToPerform == "[Prison] Strip Prisoner to Underwear")
        Action_StripPrisoner(uilib, true)

    elseif (actionToPerform == "[Prison] Set Prisoner State Property")
        Action_SetPrisonerStateProperty(uilib)

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

function Action_SetBountyForActor(RPB_UIInterface uilib, bool abViolentBounty = false)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    if (selectedActor == none)
        return
    endif

    string crimeHold = uilib.ShowHoldList(asListTitle = "Set Bounty In")

    if (!crimeHold)
        return
    endif

    Faction crimeFaction = API.Config.GetFaction(crimeHold)

    if (crimeFaction == none)
        return
    endif

    string actorName = selectedActor.GetBaseObject().GetName()
    int bountyToSet = uilib.ShowInput("Setting Bounty for " + actorName) as int

    if (selectedActor.GetFormID() != 0x14) ; NPC
        if (abViolentBounty)
            RPB_ActorVars.SetCrimeGoldViolent(crimeFaction, selectedActor, bountyToSet)
        else
            RPB_ActorVars.SetCrimeGold(crimeFaction, selectedActor, bountyToSet)
        endif

    else ; Player
        if (abViolentBounty)
            crimeFaction.SetCrimeGoldViolent(bountyToSet)
        else
            crimeFaction.SetCrimeGold(bountyToSet)
        endif
        
    endif

    DebugWithArgs("Actions::Action_SetBountyForActor", "abViolentBounty: " + YesNo(abViolentBounty), "Set " + actorName + "'s Bounty to " + bountyToSet)
endFunction

; TODO: Add option to select the Prison
function Action_BindAllPrisoners(RPB_UIInterface uilib)
    RPB_Prison castleDourDungeon = API.PrisonManager.GetPrison("Haafingar")
    castleDourDungeon.BindAllPrisonersToCell()
endFunction

function Action_RefreshCellOptions(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList(false, false, true, false, false)

    if (prison == none)
        return none
    endif

    RPB_JailCell jailCell = uilib.ShowCellList(prison)
    jailCell.RefreshOptions()
endFunction

function Action_PreAssignCellToPrisoner(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    if (selectedActor == none)
        return
    endif

    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_JailCell jailCell = uilib.ShowCellList(prison)

    RPB_StorageVars.SetFormOnForm("Assigned Prison Cell", selectedActor, jailCell, "Jail")
    Debug("Actions::Action_PreAssignCellToPrisoner", "Assigned " + jailCell.ID + " to " + selectedActor.GetBaseObject().GetName())
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

function Action_ArrestSelectedActor(RPB_UIInterface uilib, bool abEscortArrestee = true, bool abShowCaptorInputField = false)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    Actor guard = none

    if (abShowCaptorInputField)
        int formId = PO3_SKSEFunctions.StringToInt(uilib.ShowInput("Captor Form ID", "0x10C06D"))
        guard = Game.GetFormEx(formId) as Actor
    else
        guard = RPB_Utility.GetNearestGuard(selectedActor, 500, selectedActor)
    endif

    string actorName    = selectedActor.GetBaseObject().GetName()
    string holdName     = guard.GetCrimeFaction().GetName()
    bool isPlayer       = selectedActor.GetFormID() == 0x14

    int currentBounty
    if (!isPlayer)
        currentBounty = RPB_ActorVars.GetCrimeGold(guard.GetCrimeFaction(), selectedActor)
    else
        currentBounty = guard.GetCrimeFaction().GetCrimeGold()
    endif

    int arrestBounty = int_if (currentBounty == 0, (uilib.ShowInput(holdName + " - Bounty to set for " + actorName, "1200") as int), currentBounty)

    if (arrestBounty == 0)
        return
    endif

    if (!isPlayer)
        RPB_ActorVars.SetCrimeGold(guard.GetCrimeFaction(), selectedActor, arrestBounty)
    else
        guard.GetCrimeFaction().SetCrimeGold(arrestBounty)
    endif

    API.Arrest.ArrestActor(guard, selectedActor, string_if (abEscortArrestee, API.Arrest.ARREST_TYPE_ESCORT_TO_JAIL, API.Arrest.ARREST_TYPE_TELEPORT_TO_CELL))
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
        LogNoType("["+ prisoner.Name +"] "+ tabs + prisoner.GetActor() +"\t{ AI: " + YesNo(prisoner.HasAI()) + " | In Cell: "+ YesNo(prisoner.IsInCell) +" | " + prisoner.JailCell.ID +" ("+ prisoner.JailCell +" ) | " + "Location: "+ prisoner.GetCurrentCell() +"}")
        i += 1
    endWhile
endFunction

function Action_ShowPrisonContainer(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList(abNotEmpty = false, abShowPrisonerCount = false)

    if (prison == none)
        return none
    endif

    ObjectReference prisonContainer = uilib.ShowPrisonContainerList(prison) as ObjectReference
    Debug("Actions::Action_ShowPrisonContainer", "Prison Container: " + prisonContainer + ", Name: " + prisonContainer.GetBaseObject().GetName())
    
    string debugInfo = prisonContainer + " (Faction Owner: "+ prisonContainer.GetFactionOwner() + ") " + "\n"

    int i = 0
    while (i < prisonContainer.GetNumItems())
        Form item = prisonContainer.GetNthForm(i)
        string formId           = "[FormID: " + item.GetFormID() + "] "
        string objectClassName  = item.GetName()
        int quantity            = prisonContainer.GetItemCount(item)
        debugInfo += "\t["+i+"]: " + item + "\t " + (item as ObjectReference).GetActorOwner() + " " + objectClassName + " (x"+ quantity +") " + "\n"
        i += 1
    endWhile

    prisonContainer.SetOpen()


    debugInfo += "\n"
    LogNoType(debugInfo)
endFunction

function Action_ShowPrisonerInventory(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison, asListTitle = "Show Inventory Of")

    if (prisoner == none)
        return none
    endif

    prisoner.GetActor().OpenInventory(true)

    prisoner.GotoState("Imprisoned")
    prisoner.RegisterForSingleUpdateGameTime(1.0)
endFunction

function Action_ReturnPrisonerBelongings(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison, asListTitle = "Return Belongings To")

    if (prisoner == none)
        return none
    endif

    ObjectReference prisonerContainer = prisoner.PrisonerBelongingsContainer
    prisonerContainer.RemoveAllItems(prisoner.GetActor(), false, true)
    prisoner.GetActor().OpenInventory(true)
endFunction

function Action_StripPrisoner(RPB_UIInterface uilib, bool abStripToUnderwear = false)
    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison, asListTitle = "Strip Prisoner")

    if (prisoner == none)
        return none
    endif

    prisoner.Test_Strip(abStripToUnderwear)
endFunction

function Action_SetPrisonerStateProperty(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison)

    if (prisoner == none)
        return none
    endif

    int propertyTypes = JArray.object()
    JArray.addStr(propertyTypes, "<No Type>")
    JArray.addStr(propertyTypes, "Bool")
    JArray.addStr(propertyTypes, "Integer")
    JArray.addStr(propertyTypes, "Float")
    JArray.addStr(propertyTypes, "String")

    string propertyType = uilib.ShowList_ReturnElement("Select Property Type", JArray.asStringArray(propertyTypes))
    
    if (propertyType == "<No Type>")
        return
    endif

    string propertyName = uilib.ShowInput("Property Name")
    
    if (!propertyName)
        return
    endif

    if (propertyType == "Bool")
        int propertyValues = JArray.object()
        JArray.addStr(propertyValues, "False")
        JArray.addStr(propertyValues, "True")

        ; Can cast since indices are 0 and 1, can be implicitly cast to bool
        bool propertyValueToSet = uilib.ShowList("Set " + propertyName + " To", JArray.asStringArray(propertyValues)) as bool
        prisoner.SetBool(propertyName, propertyValueToSet)
        Debug("Actions::Actions_SetPrisonerStateProperty", "Set " + propertyName + " to: " + propertyValueToSet)

    elseif (propertyType == "Integer")
        int propertyValueToSet = uilib.ShowInput("Set " + propertyName + " To") as int
        prisoner.SetInt(propertyName, propertyValueToSet)
        Debug("Actions::Actions_SetPrisonerStateProperty", "Set " + propertyName + " to: " + propertyValueToSet)

    elseif (propertyType == "Float")
        float propertyValueToSet = uilib.ShowInput("Set " + propertyName + " To") as float
        prisoner.SetFloat(propertyName, propertyValueToSet)
        Debug("Actions::Actions_SetPrisonerStateProperty", "Set " + propertyName + " to: " + propertyValueToSet)

    elseif (propertyType == "String")
        string propertyValueToSet = uilib.ShowInput("Set " + propertyName + " To")
        prisoner.SetString(propertyName, propertyValueToSet)
        Debug("Actions::Actions_SetPrisonerStateProperty", "Set " + propertyName + " to: " + propertyValueToSet)
    endif
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
