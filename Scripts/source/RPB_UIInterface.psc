scriptname RPB_UIInterface extends ObjectReference

import RPB_Utility

UILIB_1 property UILib
    UILIB_1 function get()
        return (self as Form) as UILIB_1
    endFunction
endProperty

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

; ==========================================================
;                          UI Base
; ==========================================================

int function ShowList(string asTitle = "", string[] asOptions, int aiStartIndex = 0, int aiDefaultIndex = 0)
    return UILib.ShowList(asTitle, asOptions, aiStartIndex, aiDefaultIndex)
endFunction

string function ShowList_ReturnElement(string asTitle = "", string[] asOptions, int aiStartIndex = 0, int aiDefaultIndex = 0)
    int selectedIndex = UILib.ShowList(asTitle, asOptions, aiStartIndex, aiDefaultIndex)
    return asOptions[selectedIndex]
endFunction

string function ShowInput(string asTitle = "", string asInitialText = "")
    return UILib.ShowTextInput(asTitle, asInitialText)
endFunction

; ==========================================================
;                         UI Functions
; ==========================================================

string function ShowStringList(string asTitle = "", string asOptions, string asOptionSeparator = ",", int aiStartIndex = 0, int aiDefaultIndex = 0)
    string[] options = StringUtil.Split(asOptions, asOptionSeparator)

    int selectedIndex = UILib.ShowList(asTitle, options, aiStartIndex, aiDefaultIndex)
    return options[selectedIndex]
endFunction

Form function ShowFormArrayList(string asListTitle = "", Form[] akOptions)
    if (akOptions == none)
        return none
    endif

    int formNames = JArray.object()
    JArray.addStr(formNames, "<No Form>")

    int arrSize = akOptions.Length

    int i = 0
    while (i < arrSize)
        string formLine = akOptions[i] + ": " + akOptions[i].GetName()
        JArray.addStr(formNames, formLine)
        i += 1
    endWhile

    string[] listOptions = JArray.asStringArray(formNames)
    int index = self.ShowList(asListTitle, listOptions) - 1
    if (index == -1)
        return none
    endif

    return akOptions[index]
endFunction

string function ShowHoldList(bool abMustHaveArrestees = false, bool abSkipListOnSingleResult = false, string asListTitle = "Select Hold")
    string[] holds = API.Config.Holds

    int holdsArr = JArray.object()
    JArray.addStr(holdsArr, "<No Hold>")

    if (abMustHaveArrestees)
        RPB_ArresteeList arrestees  = API.Arrest.Arrestees

        int i = 0
        while (i < arrestees.Count)
            RPB_Arrestee arrestee = arrestees.AtIndex(i)
            string hold = arrestee.Hold
            bool holdHasArrestee = JArray.findStr(holdsArr, hold) != -1
            if (!holdHasArrestee)
                JArray.addStr(holdsArr, hold)
            endif
    
            i += 1
        endWhile
    else
        JArray.addFromArray(holdsArr, JArray.objectWithStrings(holds))
    endif

    if (JArray.count(holdsArr) == 2 && abSkipListOnSingleResult) ; Skip List (Only one result and <No Hold>)
        return holdsOutput[1]
    endif

    string[] holdsOutput = JArray.asStringArray(holdsArr)
    string selectedHold  = self.ShowList_ReturnElement(asListTitle, holdsOutput)

    if (selectedHold == "<No Hold>")
        return none
    endif

    return selectedHold
endFunction

RPB_Arrestee function ShowArresteeList(string asArrestHold, string asListTitle = "Select Arrestee")
    RPB_Arrest arrest = API.Arrest
    int arresteesArr = JArray.object()
    int arresteesIds = JArray.object()

    JArray.addStr(arresteesArr, "<No Arrestee>")

    RPB_ArresteeList arrestees = arrest.Arrestees
    int i = 0
    while (i < arrestees.Count)
        RPB_Arrestee arrestee = arrestees.AtIndex(i)

        if (arrestee.Hold == asArrestHold)
            string arresteeLine = arrestee.Name
            JArray.addStr(arresteesArr, arresteeLine)
            JArray.addInt(arresteesIds, arrestee.GetFormID())
        endif
        i += 1
    endWhile

    string[] arresteesNamesArray = JArray.asStringArray(arresteesArr)
    int index = self.ShowList(asListTitle, arresteesNamesArray, 0, 0) - 1
    if (index == -1)
        return none
    endif

    int formId = JArray.getInt(arresteesIds, index)
    return arrestees.AtKey(Game.GetForm(formId) as Actor)
endFunction

RPB_Captor function ShowCaptorList(string asArrestHold, string asListTitle = "Select Captor")

endFunction

RPB_Prison function ShowPrisonList(bool abNotEmpty = true, bool abSkipListOnSingleResult = false, bool abShowCity = true, bool abShowHold = false, bool abShowPrisonerCount = true, string asListTitle = "Select Prison")
    RPB_PrisonManager prisonManager = API.PrisonManager
    int prisonNames = JArray.object()
    int prisonCount = prisonManager.PrisonSlots
    int activePrisonCount = 0

    int prisonIds = JArray.object()

    JArray.addStr(prisonNames, "<No Prison>")

    int i = 0
    while (i < prisonCount)
        RPB_Prison prison = prisonManager.GetNthPrison(i)
        if (prison)
            int prisonerCount = prison.Prisoners.Count
            if ((prisonerCount > 0 && abNotEmpty) || !abNotEmpty)
                string prisonLine = ""

                if (abShowHold && ((prison.City != prison.Hold) || !abShowCity))
                    prisonLine += "["+ prison.Hold +"]"
                endif

                if (abShowCity)
                    prisonLine += string_if (prisonLine != "", " ("+ prison.City +") ", "("+ prison.City +") ")
                endif

                prisonLine += prison.Name

                if (abShowPrisonerCount)
                    prisonLine += " - " + prisonerCount + " Prisoners"
                endif

                JArray.addStr(prisonNames, prisonLine)
                JArray.addStr(prisonIds, prison.UUID)
                activePrisonCount += 1
            endif
        endif
        i += 1
    endWhile
    
    if (activePrisonCount == 0)
        return none
    endif

    if (activePrisonCount == 1 && abSkipListOnSingleResult) ; Skip List (Only one result and <No Prison>)
        string uuid = JArray.getStr(prisonIds, 0)
        return prisonManager.GetPrisonByUUID(uuid)
    endif

    string[] prisonNamesArray = JArray.asStringArray(prisonNames)
    int index = self.ShowList(asListTitle, prisonNamesArray, 0, 0) - 1
    if (index == -1)
        return none
    endif

    string uuid = JArray.getStr(prisonIds, index)
    return prisonManager.GetPrisonByUUID(uuid)
endFunction

RPB_Prisoner function ShowPrisonerList(RPB_Prison apPrison, bool abOnlyImprisoned = false, string asListTitle = "Select Prisoner")
    RPB_Prison prison = apPrison
    
    if (!prison)
        return none
    endif

    RPB_PrisonerList prisoners = prison.Prisoners
    int activePrisonerCount = 0

    int prisonerNames = JArray.object()
    JArray.addStr(prisonerNames, "<No Prisoner>")
    Debug("Actions::ShowPrisonerList", "Prisoners: " + prisoners.GetKeys())

    int i = 0
    while (i < prisoners.Count)
        RPB_Prisoner prisoner = prisoners.AtIndex(i)
        if ((abOnlyImprisoned && prisoner.IsImprisoned) || !abOnlyImprisoned)
            string prisonerName = prisoner.Name
            ; string sentenceFormatted = prison.GetSentenceFormatted(prisoner)
            ; string prisonerLine = "("+ prisoner.GetSex(true) +") " + prisoner.Name + " - " + prisoner.JailCell.ID + " | Sentence: " + sentenceFormatted
            string prisonerLine = "("+ prisoner.GetSex(true) +") " + prisonerName + " - " + prisoner.JailCell.ID
            JArray.addStr(prisonerNames, prisonerLine)
            activePrisonerCount += 1
        endif
        i += 1
    endWhile


    if (activePrisonerCount == 0)
        return none
    endif
 
    string[] prisonerNamesAsArray = JArray.asStringArray(prisonerNames)

    int index = self.ShowList(asListTitle, prisonerNamesAsArray, 0, 0) - 1
    if (index == -1)
        return none
    endif

    RPB_Prisoner selectedPrisoner = prisoners.AtIndex(index)
    return selectedPrisoner
endFunction

; TODO: Implement logic for @abOnlyEmpty and @abOnlyGenderExclusive
RPB_JailCell function ShowCellList(RPB_Prison apPrison, bool abOnlyEmpty = false, bool abOnlyGenderExclusive = false, string asListTitle = "Select Cell")
    RPB_Prison prison = apPrison
    
    if (!prison)
        return none
    endif

    Form[] prisonCells = prison.JailCells
    int cellIds = JArray.object()
    JArray.addStr(cellIds, "<No Cell>")

    int i = 0
    while (i < prisonCells.Length)
        RPB_JailCell jailCell = prisonCells[i] as RPB_JailCell
        string cellLine = ""

        if (jailCell.IsFemaleOnly)
            cellLine += string_if (jailCell.HasMales(), "[F?]", "[F] ")

        elseif (jailCell.IsMaleOnly)
            cellLine += string_if (jailCell.HasFemales(), "[M?]", "[M] ")
        endif

        cellLine += jailCell.ID
        cellLine += " - " + jailCell.PrisonerCount + "/" + jailCell.MaxPrisoners

        if (!jailcell.IsGenderExclusive && jailCell.HasMales(true))
            cellLine += " (M)"
        
        elseif (!jailcell.IsGenderExclusive && jailCell.HasFemales(true))
            cellLine += " (F)"
        endif

        if (jailCell.IsOvercrowded)
            cellLine += " (Overcrowded)"

        elseif (jailCell.IsFull)
            cellLine += " (Full)"

        elseif (jailCell.IsEmpty)
            cellLine += " (Empty)"
        endif

        JArray.addStr(cellIds, cellLine)
        i += 1
    endWhile

    string[] cellIdsArray = JArray.asStringArray(cellIds)

    int index = self.ShowList(asListTitle, cellIdsArray) - 1
    if (index == -1)
        return none
    endif

    RPB_JailCell selectedCell = prisonCells[index] as RPB_JailCell
    return selectedCell
endFunction

RPB_CellDoor function ShowCellDoorList(RPB_JailCell akCell, string asListTitle = "Select Cell Door")
    if (akCell == none)
        return none
    endif

    Form[] cellDoors = akCell.GetPropertyOfTypeFormArray("Cell Doors")

    int cellDoorIds = JArray.object()
    JArray.addStr(cellDoorIds, "<No Cell Door>")

    int i = 0
    while (i < cellDoors.Length)
        RPB_CellDoor cellDoor = cellDoors[i] as RPB_CellDoor
        string cellDoorLine = (cellDoor as string) + " - " + cellDoor.CurrentLockLevel + " ("+ cellDoor.GetOpenStateAsString() +")"
        JArray.addStr(cellDoorIds, cellDoorLine)
        i += 1
    endWhile

    string[] cellDoorIdsArray = JArray.asStringArray(cellDoorIds)

    int index = self.ShowList(asListTitle, cellDoorIdsArray) - 1
    if (index == -1)
        return none
    endif

    return cellDoors[index] as RPB_CellDoor
endFunction

Form function ShowPrisonContainerList(RPB_Prison apPrison, string asListTitle = "Select Container")
    if (apPrison == none)
        return none
    endif

    Form[] prisonerBelongingsContainers = apPrison.GetPrisonerContainers("Belongings")
    Form[] prisonerEvidenceContainers   = apPrison.GetPrisonerContainers("Evidence")

    int prisonerBelongingsObj   = JArray.objectWithForms(prisonerBelongingsContainers)
    int prisonerEvidenceObj     = JArray.objectWithForms(prisonerEvidenceContainers)
    int allContainersArr        = JArray.object()
    int containerNames          = JArray.object()
    
    JArray.addFromArray(allContainersArr, prisonerBelongingsObj)
    JArray.addFromArray(allContainersArr, prisonerEvidenceObj)
    JArray.addStr(containerNames, "<No Container>")

    int arrSize = JArray.count(allContainersArr)

    int i = 0
    while (i < arrSize)
        ObjectReference prisonContainerRef = JArray.getForm(allContainersArr, i) as ObjectReference
        string containerName = prisonContainerRef + ": " + prisonContainerRef.GetBaseObject().GetName() + " - " + prisonContainerRef.GetNumItems() + " Items"
        JArray.addStr(containerNames, containerName)
        i += 1
    endWhile

    string[] listOptions = JArray.asStringArray(containerNames)
    int index = self.ShowList(asListTitle, listOptions) - 1
    if (index == -1)
        return none
    endif

    Form selectedContainer = JArray.getForm(allContainersArr, index)

    DebugWithArgs("UI::ShowPrisonContainerList", apPrison.Name, "index: " + index + ", prisonerBelongingsContainers: " + prisonerBelongingsContainers + ", prisonerEvidenceContainers: " + prisonerEvidenceContainers + ", selectedContainer: " + selectedContainer)

    return selectedContainer
endFunction
