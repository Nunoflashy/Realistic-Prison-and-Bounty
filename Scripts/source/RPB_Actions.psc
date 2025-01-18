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
    JArray.addStr(actionArrayObj, "[Actor] Log Selected Actor State Variables")
    JArray.addStr(actionArrayObj, "[Actor] Delete Selected Actor State")
    JArray.addStr(actionArrayObj, "Check Item Stolen")
    JArray.addStr(actionArrayObj, "[Prison] Verify Jail Cells Integrity")
    JArray.addStr(actionArrayObj, "Distance between two Objects")
    JArray.addStr(actionArrayObj, "Play Animation on Selected Actor")
    JArray.addStr(actionArrayObj, "[Monitoring] Apply RPB_Actor on Actor")
    JArray.addStr(actionArrayObj, "[Monitoring] Remove RPB_Actor from Actor")
    JArray.addStr(actionArrayObj, "[Monitoring] Attach RPB_BountyDecayable on Actor")
    JArray.addStr(actionArrayObj, "[Monitoring] Detach RPB_BountyDecayable from Actor")
    JArray.addStr(actionArrayObj, "[Bounty] Set Bounty for Selected Actor")
    JArray.addStr(actionArrayObj, "[Bounty] Set Violent Bounty for Selected Actor")
    JArray.addStr(actionArrayObj, "[Bounty] Set Bounty for Prisoner")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor (Escort Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor with Selected Captor (Escort Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Arrest Selected Actor with Selected Captor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Faction Arrest] Arrest Selected Actor (Teleport Prisoner)")
    JArray.addStr(actionArrayObj, "[Arrest] Add Selected Actor to Current Arrest")
    JArray.addStr(actionArrayObj, "[Prison] Initialize Prisons")
    JArray.addStr(actionArrayObj, "[Prison] Configure Prison in Slot")
    JArray.addStr(actionArrayObj, "[Prison] Bind All Prisoners")
    JArray.addStr(actionArrayObj, "[Prison] Refresh Cell Options")
    JArray.addStr(actionArrayObj, "[Prison] Pre-Assign Cell to Prisoner")
    JArray.addStr(actionArrayObj, "[Prison] Reindex PrisonerList")
    JArray.addStr(actionArrayObj, "[Prison] Imprison Nearby Actors")
    JArray.addStr(actionArrayObj, "[Prison] Imprison Selected Actor")
    JArray.addStr(actionArrayObj, "[Prison] Check Prisoners AI Status")
    JArray.addStr(actionArrayObj, "[Prison] Show Prison Container")
    JArray.addStr(actionArrayObj, "[Prison] Show Prisoner Inventory")
    JArray.addStr(actionArrayObj, "[Prison] Show Prison Markers")
    JArray.addStr(actionArrayObj, "[Prison] Show Cells")
    JArray.addStr(actionArrayObj, "[Prison] Show Cell Doors")
    JArray.addStr(actionArrayObj, "[Prison] Return Prisoner Belongings")
    JArray.addStr(actionArrayObj, "[Prison] Strip Prisoner")
    JArray.addStr(actionArrayObj, "[Prison] Strip Prisoner to Underwear")
    JArray.addStr(actionArrayObj, "[Prison] Clothe Prisoner")
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

    elseif (actionToPerform == "[Actor] Log Selected Actor State Variables")
        Action_LogActorStateVariables(uilib)

    elseif (actionToPerform == "[Actor] Delete Selected Actor State")
        Action_DeleteActorState(uilib)

    elseif (actionToPerform == "Check Item Stolen")
        Action_CheckItemStolen(uilib)

    elseif (actionToPerform == "[Prison] Verify Jail Cells Integrity")
        Action_VerifyJailCellsIntegrity(uilib)

    elseif (actionToPerform == "Distance between two Objects")
        Action_DistanceBetweenTwoObjects(uilib)

    elseif (actionToPerform == "Play Animation on Selected Actor")
        Action_PlayAnimationOnActor(uilib)

    elseif (actionToPerform == "[Monitoring] Apply RPB_Actor on Actor")
        Action_MonitoringApplyActorScript(uilib)

    elseif (actionToPerform == "[Monitoring] Remove RPB_Actor from Actor")
        Action_MonitoringRemoveActorScript(uilib)

    elseif (actionToPerform == "[Monitoring] Attach RPB_BountyDecayable on Actor")
        Action_MonitoringApplyBountyScript(uilib)

    elseif (actionToPerform == "[Monitoring] Detach RPB_BountyDecayable from Actor")
        Action_MonitoringRemoveBountyScript(uilib)

    elseif (actionToPerform == "[Bounty] Set Bounty for Selected Actor")
        Action_SetBountyForActor(uilib)

    elseif (actionToPerform == "[Bounty] Set Violent Bounty for Selected Actor")
        Action_SetBountyForActor(uilib, true)

    elseif (actionToPerform == "[Bounty] Set Bounty for Prisoner")
        Action_SetBountyForPrisoner(uilib)

    elseif (actionToPerform == "[Prison] Configure Prison in Slot")
        Action_ConfigurePrisonInSlot(uilib)

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

    elseif (actionToPerform == "[Arrest] Arrest Selected Actor with Selected Captor (Teleport Prisoner)")
        Action_ArrestSelectedActor(uilib, false, true)

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

    elseif (actionToPerform == "[Prison] Show Prison Markers")
        Action_ShowPrisonMarkers(uilib)

    elseif (actionToPerform == "[Prison] Show Cells")
        Action_ShowCells(uilib)

    elseif (actionToPerform == "[Prison] Show Cell Doors")
        Action_ShowCellDoors(uilib)

    elseif (actionToPerform == "[Prison] Return Prisoner Belongings")
        Action_ReturnPrisonerBelongings(uilib)

    elseif (actionToPerform == "[Prison] Strip Prisoner")
        Action_StripPrisoner(uilib)

    elseif (actionToPerform == "[Prison] Strip Prisoner to Underwear")
        Action_StripPrisoner(uilib, true)

    elseif (actionToPerform == "[Prison] Clothe Prisoner")
        Action_ClothePrisoner(uilib)

    elseif (actionToPerform == "[Prison] Set Prisoner State Property")
        Action_SetPrisonerStateProperty(uilib)

    elseif(actionToPerform == "[Prison] Imprison Nearby Actors")
        Action_ImprisonNearbyActors(uilib)

    elseif (actionToPerform == "[Arrest] Add Selected Actor to Current Arrest")
        Action_AddSelectedActorToArrest(uilib)

    elseif (actionToPerform == "[Prison] Initialize Prisons")
        Action_InitializePrisons(uilib)

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

function Action_LogActorStateVariables(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    string category = uilib.ShowInput("State Category")

    int actorObject = RPB_StorageVars.GetObjectHandleOnForm(selectedActor, category)

    Debug("Actions::Action_LogActorStateVariables", "Object Handle ("+ category +"): " + GetContainerList(actorObject))
endFunction

function Action_DeleteActorState(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison)

    if (prisoner == none)
        return none
    endif

    selectedActor = prisoner.GetActor()

    string category = uilib.ShowInput("State Category")

    int actorObject = RPB_StorageVars.GetObjectHandleOnForm(selectedActor, category)
    Debug("Actions::Action_DeleteActorState", "(Before) Object Handle ("+ category +"): " + GetContainerList(actorObject))

    RPB_StorageVars.DeleteCategoryOnForm(selectedActor, category)
    actorObject = RPB_StorageVars.GetObjectHandleOnForm(selectedActor, category)
    Debug("Actions::Action_DeleteActorState", "(After) Object Handle ("+ category +"): " + GetContainerList(actorObject))
endFunction

function Action_CheckItemStolen(RPB_UIInterface uilib)
    ObjectReference selectedReference = Game.GetCurrentConsoleRef()
    Debug("Actions::Action_CheckItemStolen", "Is item stolen: " + selectedReference.IsOffLimits())
endFunction

function Action_VerifyJailCellsIntegrity(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList( \ 
        abNotEmpty = false, \
        abShowPrisonerCount = false \
    )

    if (prison == none)
        return none
    endif

    Form[] cells = prison.JailCells

    if (cells == none)
        return none
    endif

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell
        ; Fire the test event to verify the integrity of the cell
        Debug("["+ jailCell +"] JailCell::OnCellAttach", "Cell: (ID: " + jailCell.ID + ") (" + jailCell + ") (Markers: "+ jailCell.InteriorMarkers +") (Prison: "+ jailCell.Prison.Name +") (Prisoners: "+ jailCell.Prisoners +") (CellDoor: "+ jailCell.CellDoor +")")
        i += 1
    endWhile
endFunction

function Action_DistanceBetweenTwoObjects(RPB_UIInterface uilib)
    ObjectReference obj1 = Game.GetCurrentConsoleRef()
    ObjectReference obj2 = none

    string inputFormID = uilib.ShowInput("Input FormID for 2nd Object")
    int formIdHex = RPB_Utility.HexStringToInt(inputFormID)
    obj2 = Game.GetFormEx(formIdHex) as ObjectReference

    string obj1Name = obj1.GetBaseObject().GetName()
    string obj2Name = obj2.GetBaseObject().GetName()
    float distanceBetweenObjects = obj1.GetDistance(obj2)
    string msg = "Distance between " + obj1Name + " and " + obj2Name + " is " + distanceBetweenObjects
    Debug.MessageBox(msg)
    Debug("Actions::Action_DistanceBetweenObjects", \ 
        msg + \
        "obj1: " + obj1 + \ 
        "obj2: " + obj2 + \ 
        "inputFormID: " + inputFormID \ 
    )
endFunction

function Action_PlayAnimationOnActor(RPB_UIInterface uilib)
    Actor selectedActor     = Game.GetCurrentConsoleRef() as Actor
    string actorName        = selectedActor.GetBaseObject().GetName()
    string animationToPlay  = uilib.ShowInput(actorName + " - Play Animation")

    Debug.SendAnimationEvent(selectedActor, animationToPlay)
    Debug("Actions::Action_PlayAnimationOnActor", "Playing " + animationToPlay + " on Actor " + actorName)
endFunction

function Action_MonitoringApplyActorScript(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    if (selectedActor == none)
        return
    endif

    RPB_Actor.ApplyEffect(selectedActor)
endFunction

function Action_MonitoringRemoveActorScript(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    if (selectedActor == none)
        return
    endif

    RPB_Actor.RemoveEffect(selectedActor)
endFunction

function Action_MonitoringApplyBountyScript(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    if (selectedActor == none)
        return
    endif

    RPB_BountyDecayable.Attach(selectedActor)
endFunction

function Action_MonitoringRemoveBountyScript(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    if (selectedActor == none)
        return
    endif

    RPB_BountyDecayable.Detach(selectedActor)
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

function Action_SetBountyForPrisoner(RPB_UIInterface uilib, bool abViolentBounty = false)
    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison)

    if (prisoner == none)
        return none
    endif

    int bountyToSet = uilib.ShowInput("Setting Bounty for " + prisoner.GetActor()) as int
    prisoner.RegisterForTrackedStats()
    prisoner.SetCrimeGold(bountyToSet)

    DebugWithArgs("Actions::Action_SetBountyForActor", "abViolentBounty: " + YesNo(abViolentBounty), "Set " + prisoner.GetActor() + "'s Bounty to " + bountyToSet)
endFunction

function Action_ConfigurePrisonInSlot(RPB_UIInterface uilib)
    Alias[] prisonSlots = API.PrisonManager.GetAliases()
    string builtSlots = ""

    int i = 0
    while (i < prisonSlots.Length)
        Debug("Actions::Action_ConfigurePrisonInSlot", "PrisonSlots["+ i +"] ID: " + (prisonSlots[i] as RPB_Prison).ID)
        builtSlots += "Slot " + i + " (ID: "+ (prisonSlots[i] as RPB_Prison).ID +")"
        if (i < prisonSlots.Length)
            builtSlots += ","
        endif
        i += 1
    endWhile

    string selectedSlot = uilib.ShowStringList("Select Slot", builtSlots)
    int slotNumber = StringUtil.Substring(selectedSlot, StringUtil.Find(selectedSlot, " ") + 1, StringUtil.GetLength(selectedSlot)) as int
    Debug("Actions::Action_ConfigurePrisonInSlot", "slotNumber: "+ slotNumber)
    Debug("Actions::Action_ConfigurePrisonInSlot", "NthAlias(8): "+ API.PrisonManager.GetNthAlias(8))

    ; int rootObject      = RPB_Data.GetRootObject("Bruma") ; JMap&
    ; int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&

    ; Location prisonLocation = RPB_Prison.Global_GetPropertyOfTypeForm(prisonObject, "Location") as Location
    ; string prisonName       = RPB_Prison.Global_GetPropertyOfTypeString(prisonObject, "Name")
    ; Faction prisonFaction   = RPB_Data.Hold_GetCrimeFaction(rootObject)

    ; RPB_Prison prisonSlot = API.PrisonManager.GetNthAlias(slotNumber) as RPB_Prison
    API.PrisonManager.InitializePrisonInSlot("The Rift", slotNumber)
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

    Alias[] brumaPrisons = API.PrisonManager.GetPrisonsForHold("Bruma")
    Debug("Actions::Action_PreAssignCellToPrisoner", "Bruma Prisons: " + brumaPrisons)


    if (selectedActor == none)
        return
    endif

    RPB_Prison prison = uilib.ShowPrisonList(false)

    if (prison == none)
        return none
    endif

    RPB_JailCell jailCell = uilib.ShowCellList(prison)

    ; RPB_CellDoor configuredCellDoor = jailCell.GetRootPropertyOfTypeFormArray("Cell Doors")[0] as RPB_CellDoor
    ; RPB_CellDoor configuredCellDoorTest = jailCell.GetRootPropertyOfTypeFormArrayTest("Cell Doors")[0] as RPB_CellDoor
    ; RPB_CellDoor configuredCellDoorTest1 = jailCell.GetRootPropertyOfTypeFormArrayTest("Cell Doors")[0] as RPB_CellDoor
    ; RPB_JailCell cellTest = jailCell
    RPB_JailCell cellTest = Game.GetFormEx(0x36897) as RPB_JailCell
    ; RPB_JailCell cellTest2 = Game.GetFormEx(0x36897) as RPB_JailCell
    Form f2 = GetFormFromMod(0x3879)
    RPB_CellDoor cellDoor = Game.GetFormEx(0x5e921) as RPB_CellDoor

    bool __hasDecayableLock = cellDoor.GetPropertyOfTypeBool("Lock//Decay Options//Wear Thresholds")
    ; bool testExists = JValue.hasPath(cellDoor.GetRootObject(), ".Lock.Decay Options.Wear Thresholds")
    bool testExists = RPB_Data.HasProperty(cellDoor.GetSerializableRootObject(), "Lock//Decay Options//Wear Thresholds")

    ; Debug("["+ cellTest.ID +"] Actions::Action_PreAssignCellToPrisoner", "Object: " + GetContainerList(cellTest.GetDataObject()))
    ; Debug("["+ cellTest.ID +"] Actions::Action_PreAssignCellToPrisoner", "Root Object: " + GetContainerList(cellTest.GetRootObject()))
    Debug("["+ cellTest.ID +"] ["+ cellDoor.GetFormID() +"] Actions::Action_PreAssignCellToPrisoner", "__hasDecayableLock: " + __hasDecayableLock)
    Debug("["+ cellTest.ID +"] ["+ cellDoor.GetFormID() +"] Actions::Action_PreAssignCellToPrisoner", "testExists: " + testExists)
    ; return
    ; Debug("["+ cellTest.ID +"] Actions::Action_PreAssignCellToPrisoner", "cellTest: " + cellTest)


    string[] subCategories = new string[1]
    subCategories[0] = "Decay Options"
    ; string stringProperty   = cellDoor.GetOptionOfTypeString("Min. Lock Level", "Lock", subCategories)
    ; string stringProperty2  = RPB_Data.GetPropertyOfTypeString(cellDoor.JailCell.GetDataObject(), cellDoor + "//Lock//Decay Options//Min. Lock Level") 
    string stringPropertyCell  = RPB_Data.GetPropertyOfTypeString(prison.GetDataObject(), "Cells//" + cellTest + "//Cell Doors//"+ cellDoor +"//Lock//Decay Options//Min. Lock Level")
    string stringPropertyCell2  = RPB_Data.GetPropertyOfTypeString(jailCell.GetSerializableRootObject(), "//Cell Doors//"+ cellDoor +"//Lock//Decay Options//Min. Lock Level")
    ; string stringProperty3  = cellDoor.GetOptionOfTypeStringNew("Lock//Decay Options//Min. Lock Level")
    string[] decayOptions   = RPB_Data.GetPropertyOfTypeStringArray(cellTest.GetSerializableRootObject(), "Cell Doors//" + cellDoor + "//Lock//Gata")
    ; string[] decayOptions   = RPB_Data.GetPropertyOfTypeStringArray(prison.GetDataObject(), "Cells//" + cellTest + "//Cell Doors//"+ cellDoor + "//Lock//Decay Options")
    ; Debug("Actions::Action_PreAssignCellToPrisoner", "stringProperty: " + stringProperty)
    ; Debug("Actions::Action_PreAssignCellToPrisoner", "stringProperty2: " + stringProperty2)
    ; Debug("Actions::Action_PreAssignCellToPrisoner", "stringProperty3: " + stringProperty3)
    Debug("Actions::Action_PreAssignCellToPrisoner", "stringPropertyCell: " + stringPropertyCell)
    Debug("Actions::Action_PreAssignCellToPrisoner", "stringPropertyCell2: " + stringPropertyCell2)
    Debug("Actions::Action_PreAssignCellToPrisoner", "decayOptions: " + decayOptions)

    return

    ; Form cellTestFromString     = GetFormFromString(cellTest)
    ; Form cellDoorTestFromString = GetFormFromString(cellDoor)
    ; return

    ; Form f = RPB_Data.GetFormFromString(cellTest)
    ; Debug("Actions::Action_PreAssignCellToPrisoner", "f: " + f)
    ; return
    ; Form[] testForms = RPB_Data.GetPropertyOfTypeFormArray(prison.GetDataObject(), "Cells//" + cellTest + "//Exterior")
    ; Form[] testForms = RPB_Data.GetPropertyOfTypeFormArray(prison.GetDataObject(), "Cells")
    ; Form[] testForms = jailCell.GetRootPropertyOfTypeFormArrayTest("Exterior")
    ; string lockLevel = jailCell.GetRootPropertyOfTypeString("Cell Doors//" + cellDoor + "//Lock//Level")

    ; string lockLevel = RPB_Data.GetPropertyOfTypeString(prison.GetDataObject(), "Cells//" + cellTest + "//Cell Doors//"+ cellDoor +"//TestString")
    string arrayTestElement = RPB_Data.GetPropertyOfTypeString(prison.GetDataObject(), "Cells//" + cellTest + "//Cell Doors//"+ cellDoor +"//Array//[0]")
    string[] arrayTest = RPB_Data.GetPropertyOfTypeStringArray(prison.GetDataObject(), "Cells//" + cellTest + "//Cell Doors//"+ cellDoor +"//Array")
    string[] arrayTest2 = RPB_Data.GetPropertyOfTypeStringArray(prison.GetDataObject(), "Cells//" + cellTest + "//Cell Doors//"+ cellDoor +"//Array//[2]")
    ; string[] arrayTest3 = RPB_Data.GetPropertyOfTypeStringArray(prison.GetDataObject(), "Cells//" + cellTest + "//Cell Doors//"+ cellDoor +"//Array//[2][0]")
    ; int[] arrayTest3 = RPB_Data.GetPropertyOfTypeIntegerArray(prison.GetDataObject(), "Cells//" + cellTest + "//Cell Doors//"+ cellDoor +"//Array//[3]")

    ; Debug("Actions::Action_PreAssignCellToPrisoner", "testForms: " + testForms)
    Debug("Actions::Action_PreAssignCellToPrisoner", "arrayTestElement: " + arrayTestElement)
    Debug("Actions::Action_PreAssignCellToPrisoner", "arrayTest: " + arrayTest)
    Debug("Actions::Action_PreAssignCellToPrisoner", "arrayTest2: " + arrayTest2)
    ; Debug("Actions::Action_PreAssignCellToPrisoner", "arrayTest3: " + arrayTest3)
    ; Debug("Actions::Action_PreAssignCellToPrisoner", "["+ jailCell.ID +"] configuredCellDoorTest1: " + configuredCellDoorTest1)

    ; RPB_StorageVars.SetFormOnForm("Assigned Prison Cell", selectedActor, jailCell, "Jail")
    ; Debug("Actions::Action_PreAssignCellToPrisoner", "Assigned " + jailCell.ID + " to " + selectedActor.GetBaseObject().GetName())
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
            prisonBySelectedPrisoner.SendReleaseRequest(selectedPrisoner)

            ; DebugParams(selectedPrisoner + "," + selectedPrisoner2, "selectedPrisoner, selectedPrisoner2", "Actions::Action_ReleasePrisoner")
            Debug("Actions::Action_ReleasePrisoner", "selectedPrisoner: " + selectedPrisoner + ", Actor: " + selectedPrisoner.GetActor())
            return
        endif
    endif

    ; Otherwise, proceed as normal and show the dropdown for the Prison & Prisoners

    RPB_Prison prison = uilib.ShowPrisonList()

    Debug("Actions::Action_ReleasePrisoner", "prison: " + prison)

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison, asListTitle = "Release Prisoner")

    if (prisoner == none)
        return none
    endif
    
    prison.SendReleaseRequest(prisoner)
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
    RPB_Prisoner prisoner   = prison.AwaitPrisonerReference(selectedActor)

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
    float startBench = StartBenchmark()
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor

    GlobalVariable RPB_Surrender = RPB_Utility.RPB_ArrestGlobal("No Dialogue")
    RPB_Surrender.SetValueInt(1)

    Actor guard = none

    if (abShowCaptorInputField)
        int formId = PO3_SKSEFunctions.StringToInt(uilib.ShowInput("Captor Form ID", "0x10C06D"))
        guard = Game.GetFormEx(formId) as Actor
    else
        guard = RPB_Utility.GetNearbyGuardForFactionFromRef(selectedActor)
    endif

    if (!guard)
        API.Config.NotifyArrest("There isn't any nearby guard to perform the Arrest!")
        return
    endif

    string arrestType = API.Arrest.ARREST_TYPE_TELEPORT_TO_CELL

    if (abEscortArrestee)
        arrestType = uilib.ShowStringList("Select Escort Location", \ 
            API.Arrest.ARREST_TYPE_ESCORT_TO_JAIL + "," + \
            API.Arrest.ARREST_TYPE_ESCORT_TO_CELL \
        )
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
    
    API.Arrest.ArrestActor(guard, selectedActor, arrestType)
    EndBenchmark(startBench, "Actions::Action_ArrestSelectedActor")
endFunction

function Action_AddSelectedActorToArrest(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    RPB_SceneManager sceneManager = API.SceneManager

    ; BindAliasTo(sceneManager.GetEscortee(1), selectedActor)
endFunction

function Action_InitializePrisons(RPB_UIInterface uilib)
    string[] holds = API.Config.Holds
    int i = 0
    while (i < holds.Length)
        API.PrisonManager.InitializePrison(holds[i])
        i += 1
    endWhile
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
    endif

    API.Arrest.ArrestActorForFaction(crimeFaction, selectedActor, API.Arrest.ARREST_TYPE_TELEPORT_TO_CELL)
endFunction

function Action_ImprisonSelectedActor(RPB_UIInterface uilib)
    Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    if (selectedActor == none)
        selectedActor == Game.GetPlayer()
    endif

    RPB_Prison prison = uilib.ShowPrisonList(abNotEmpty = false, abShowCity = true, abShowHold = false, abShowPrisonerCount = false, asListTitle = "Send " + selectedActor.GetBaseObject().GetName() + " to Prison")

    if (!prison)
        return
    endif

    RPB_Prisoner prisoner = prison.MakePrisoner(selectedActor)

    if (!prisoner)
        Debug("Actions::Action_ImprisonSelectedActor", "[Prison ID: "+ prison.ID +"] ["+ prison.UUID +"] Prisoners: "+ prison.Prisoners.GetKeys())
        return
    endif

    ; Set showable options in prisoner info menu
    prisoner.ShowReleaseTime          = true
    prisoner.ShowSentence             = true
    prisoner.ShowTimeServed           = true
    prisoner.ShowTimeLeftInSentence   = true
    prisoner.ShowBounty               = true

    prisoner.SetBelongingsContainer()
    ; prisoner.UndetermineSentence()
    prisoner.SetSentence(10)

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
        LogNoType("["+ prisoner.Name +"] "+ tabs + prisoner.GetActor() +"\t{ AI: " + YesNo(prisoner.HasAI()) + " | In Cell: "+ YesNo(prisoner.IsInCell) +" | " + prisoner.JailCell.ID +" ("+ prisoner.JailCell + " [Package: "+ prisoner.CellPackage.GetName() +"]) | " + "Location: "+ prisoner.GetCurrentCell() +"}")
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

function Action_ShowPrisonMarkers(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList(false, true, abShowPrisonerCount = false)

    if (prison == none)
        return none
    endif

    string selectedMarkerType = uilib.ShowStringList("Select Marker Type", \ 
        "<No Marker>," + \
        "Release (Escort)," + \
        "Release (Teleport)," + \ 
        "Jail (Escort)," + \ 
        "Jail (Teleport)," + \
        "Search (Frisking)," + \
        "Search (Stripping)" \
    )

    if (selectedMarkerType == "<No Marker>")
        return none
    endif

    int subOptionStartIndex = StringUtil.Find(selectedMarkerType, "(") + 1
    int subOptionEndIndex   = StringUtil.Find(selectedMarkerType, ")")
    int spaceBeforeParenthesisOffset = 2

    string mainOption   = StringUtil.Substring(selectedMarkerType, 0, subOptionStartIndex - spaceBeforeParenthesisOffset)
    string subOption    = StringUtil.Substring(selectedMarkerType, subOptionStartIndex, subOptionEndIndex - subOptionStartIndex)

    string propertyPath = "Markers//" + mainOption + "//" + subOption
    Form[] availableMarkersOfType = prison.GetPropertyOfTypeFormArray(propertyPath)

    Debug("Actions::Action_ShowPrisonMarkers", "mainOption: " + mainOption + ", subOption: " + subOption + ", propertyPath: " + propertyPath + ", availableMarkersOfType: " + availableMarkersOfType + ", subOptionStartIndex: " + subOptionStartIndex)

    ObjectReference selectedMarker = uilib.ShowFormArrayList("Select "+ mainOption + "//" + subOption +" Marker", availableMarkersOfType) as ObjectReference
    Debug("Actions::Action_ShowPrisonMarkers", "selectedMarker: "+ selectedMarker)

    string selectedActionOnMarker = uilib.ShowStringList("Do What?", \ 
        "<Nothing>," + \
        "Teleport to Marker," + \
        "Teleport Selected NPC to Marker" \ 
    )

    if (selectedActionOnMarker == "<Nothing>")
        return none

    elseif (selectedActionOnMarker == "Teleport to Marker")
        Actor ref = Game.GetForm(0x14) as Actor
        ref.MoveTo(selectedMarker)

    elseif (selectedActionOnMarker == "Teleport Selected NPC to Marker")
        Actor ref = Game.GetCurrentConsoleRef() as Actor
        ref.MoveTo(selectedMarker)
    endif
endFunction

function Action_ShowCells(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList(false)

    if (prison == none)
        return none
    endif

    Debug("Actions::Action_ShowCells", "Cells: " + prison.GetJailCells())
    Debug("Actions::Action_ShowCells", "Cells Children: " + prison.Children("Cells"))

    RPB_JailCell selectedJailCell = uilib.ShowCellList(prison)

endFunction

function Action_ShowCellDoors(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList(false)
    Debug("Actions::Action_ShowCellDoors", "prison: " + prison + ", name: " + prison.Name + ", hold: " + prison.Hold)
    prison.SetupCells()

    if (prison == none)
        return none
    endif

    RPB_JailCell jailCell = uilib.ShowCellList(prison)

    if (jailCell == none)
        return none
    endif

    RPB_CellDoor cellDoor = uilib.ShowCellDoorList(jailCell, "Cell Doors for " + jailCell.ID)
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

    self.Prisoner_Strip(prisoner, abStripToUnderwear)
endFunction

function Action_ClothePrisoner(RPB_UIInterface uilib)
    RPB_Prison prison = uilib.ShowPrisonList()

    if (prison == none)
        return none
    endif

    RPB_Prisoner prisoner = uilib.ShowPrisonerList(prison, asListTitle = "Clothe Prisoner")

    if (prisoner == none)
        return none
    endif

    prisoner.Clothe()
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


; ==========================================================
;                          Functions
; ==========================================================

function Prisoner_Strip(RPB_Prisoner apPrisoner, bool abKeepUnderwear = false)
    if (abKeepUnderwear)
        Armor underwearTop      = apPrisoner.GetUnderwear("Top")
        Armor underwearBottom   = apPrisoner.GetUnderwear("Bottom")
        bool hasUnderwear = false

        DebugWithArgs("["+ apPrisoner.Name +"] Prisoner::Test_Strip", "abKeepUnderwear: " + abKeepUnderwear, "Top: " + underwearTop + ", Bottom: " + underwearBottom)

        apPrisoner.UnequipAll()
        apPrisoner.RemoveAllItems()

        if (underwearTop)
            apPrisoner.EquipItem(underwearTop)
            hasUnderwear = true
        endif

        if (underwearBottom)
            apPrisoner.EquipItem(underwearBottom)
            hasUnderwear = true
        endif

        Debug("["+ apPrisoner.Name +"] Prisoner::Test_Strip", "Stripped " + apPrisoner.Name + " to underwear.", hasUnderwear)
        Debug("["+ apPrisoner.Name +"] Prisoner::Test_Strip", "Stripped " + apPrisoner.Name + " naked. (does not have underwear)", !hasUnderwear)
    else
        apPrisoner.UnequipAll()
        apPrisoner.RemoveAllItems()
        Debug("["+ apPrisoner.Name +"] Prisoner::Test_Strip", "Stripped " + apPrisoner.Name + " naked.")
    endif
endFunction