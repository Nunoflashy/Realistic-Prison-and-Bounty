scriptname RPB_UIInterface extends ObjectReference

import RPB_Utility
import RPB_Memory

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

    int formNames = FastArray("<string>")
    FastArray_AddString(formNames, "<No Form>")

    int arrSize = akOptions.Length

    int i = 0
    while (i < arrSize)
        string formLine = akOptions[i] + ": " + akOptions[i].GetName()
        FastArray_AddString(formNames, formLine)
        i += 1
    endWhile

    string[] listOptions = FastArray_ToStringArray(formNames)
    int index = self.ShowList(asListTitle, listOptions) - 1
    if (index == -1)
        return none
    endif

    return akOptions[index]
endFunction

string function ShowHoldList(bool abMustHaveArrestees = false, bool abSkipListOnSingleResult = false, string asListTitle = "Select Hold")
    string[] holds = API.Config.Holds

    int holdsArr = FastArray("<string>")
    FastArray_AddString(holdsArr, "<No Hold>")

    if (abMustHaveArrestees)
        RPB_ArresteeList arrestees  = API.Arrest.Arrestees

        int i = 0
        while (i < arrestees.Count)
            RPB_Arrestee arrestee = arrestees.AtIndex(i)
            string hold = arrestee.Hold
            bool holdHasArrestee = FastArray_FindString(holdsArr, hold) != -1
            if (!holdHasArrestee)
                FastArray_AddString(holdsArr, hold)
            endif
    
            i += 1
        endWhile
    else
        FastArray_AddFromArray(holdsArr, FastArray_FromStringArray(holds))
    endif

    if (FastArray_Size(holdsArr) == 2 && abSkipListOnSingleResult) ; Skip List (Only one result and <No Hold>)
        return holdsOutput[1]
    endif

    string[] holdsOutput = FastArray_ToStringArray(holdsArr)
    string selectedHold  = self.ShowList_ReturnElement(asListTitle, holdsOutput)

    if (selectedHold == "<No Hold>")
        return none
    endif

    return selectedHold
endFunction

RPB_Arrestee function ShowArresteeList(string asArrestHold, string asListTitle = "Select Arrestee")
    RPB_Arrest arrest = API.Arrest
    int arresteesArr = FastArray("<string>")
    int arresteesIds = FastArray("<int>")

    FastArray_AddString(arresteesArr, "<No Arrestee>")

    RPB_ArresteeList arrestees = arrest.Arrestees
    int i = 0
    while (i < arrestees.Count)
        RPB_Arrestee arrestee = arrestees.AtIndex(i)

        if (arrestee.Hold == asArrestHold)
            string arresteeLine = arrestee.Name
            FastArray_AddString(arresteesArr, arresteeLine)
            FastArray_AddInt(arresteesIds, arrestee.GetFormID())
        endif
        i += 1
    endWhile

    string[] arresteesNamesArray = FastArray_ToStringArray(arresteesArr)
    int index = self.ShowList(asListTitle, arresteesNamesArray, 0, 0) - 1
    if (index == -1)
        return none
    endif

    int formId = FastArray_GetInt(arresteesIds, index)
    return arrestees.AtKey(Game.GetForm(formId) as Actor)
endFunction

RPB_Captor function ShowCaptorList(string asArrestHold, string asListTitle = "Select Captor")

endFunction

RPB_Prison function ShowPrisonList(bool abNotEmpty = true, bool abSkipListOnSingleResult = false, bool abShowCity = true, bool abShowHold = false, bool abShowPrisonerCount = true, string asListTitle = "Select Prison")
    RPB_PrisonManager prisonManager = API.PrisonManager
    int prisonCount = prisonManager.PrisonSlots
    int activePrisonCount = 0

    int prisonNames = FastArray("<string>")
    int prisonIds   = FastArray("<string>")

    FastArray_AddString(prisonNames, "<No Prison>")

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

                FastArray_AddString(prisonNames, prisonLine)
                FastArray_AddString(prisonIds, prison.UUID)
                activePrisonCount += 1
            endif
            Debug("UI::ShowPrisonList", "[Alias Name: "+ prison.GetName() +"] [ID: "+ prison.ID +"] [UUID: "+ prison.UUID +"] [Name: "+ prison.Name +"]")
        endif
        i += 1
    endWhile
    
    if (activePrisonCount == 0)
        return none
    endif

    if (activePrisonCount == 1 && abSkipListOnSingleResult) ; Skip List (Only one result and <No Prison>)
        string uuid = FastArray_GetString(prisonIds, 0)
        return prisonManager.GetPrisonByUUID(uuid)
    endif

    string[] prisonNamesArray = FastArray_ToStringArray(prisonNames)
    int index = self.ShowList(asListTitle, prisonNamesArray, 0, 0) - 1
    if (index == -1)
        return none
    endif

    string uuid = FastArray_GetString(prisonIds, index)
    return prisonManager.GetPrisonByUUID(uuid)
endFunction

RPB_Prisoner function ShowPrisonerList(RPB_Prison apPrison, bool abOnlyImprisoned = false, string asListTitle = "Select Prisoner")
    RPB_Prison prison = apPrison
    
    if (!prison)
        return none
    endif

    RPB_PrisonerList prisoners = prison.Prisoners
    int activePrisonerCount = 0

    int prisonerNames = FastArray("<string>")
    FastArray_AddString(prisonerNames, "<No Prisoner>")
    Debug("Actions::ShowPrisonerList", "Prisoners: " + prisoners.GetKeys())

    int i = 0
    while (i < prisoners.Count)
        RPB_Prisoner prisoner = prisoners.AtIndex(i)
        if ((abOnlyImprisoned && prisoner.IsImprisoned) || !abOnlyImprisoned)
            string prisonerName = prisoner.Name
            ; string sentenceFormatted = prison.GetSentenceFormatted(prisoner)
            ; string prisonerLine = "("+ prisoner.GetSex(true) +") " + prisoner.Name + " - " + prisoner.JailCell.ID + " | Sentence: " + sentenceFormatted
            string prisonerLine = "("+ prisoner.GetSex(true) +") " + prisonerName + " - " + prisoner.JailCell.ID
            FastArray_AddString(prisonerNames, prisonerLine)
            activePrisonerCount += 1
        endif
        i += 1
    endWhile


    if (activePrisonerCount == 0)
        return none
    endif
 
    string[] prisonerNamesAsArray = FastArray_ToStringArray(prisonerNames)

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
    int cellIds = FastArray("<string>")
    FastArray_AddString(cellIds, "<No Cell>")

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

        FastArray_AddString(cellIds, cellLine)
        i += 1
    endWhile

    string[] cellIdsArray = FastArray_ToStringArray(cellIds)

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

    int cellDoorIds = FastArray("<string>")
    FastArray_AddString(cellDoorIds, "<No Cell Door>")

    int i = 0
    while (i < cellDoors.Length)
        RPB_CellDoor cellDoor = cellDoors[i] as RPB_CellDoor
        string cellDoorLine = (cellDoor as string) + " - " + cellDoor.CurrentLockLevel + " ("+ cellDoor.GetOpenStateAsString() +")"
        FastArray_AddString(cellDoorIds, cellDoorLine)
        i += 1
    endWhile

    string[] cellDoorIdsArray = FastArray_ToStringArray(cellDoorIds)

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

    int prisonerBelongingsObj   = FastArray_FromFormArray(prisonerBelongingsContainers)
    int prisonerEvidenceObj     = FastArray_FromFormArray(prisonerEvidenceContainers)
    int allContainersArr        = FastArray("<object>")
    int containerNames          = FastArray("<string>")
    
    FastArray_AddFromArray(allContainersArr, prisonerBelongingsObj)
    FastArray_AddFromArray(allContainersArr, prisonerEvidenceObj)
    FastArray_AddString(containerNames, "<No Container>")

    int arrSize = FastArray_Size(allContainersArr)

    int i = 0
    while (i < arrSize)
        ObjectReference prisonContainerRef = FastArray_GetForm(allContainersArr, i) as ObjectReference
        string containerName = prisonContainerRef + ": " + prisonContainerRef.GetBaseObject().GetName() + " - " + prisonContainerRef.GetNumItems() + " Items"
        FastArray_AddString(containerNames, containerName)
        i += 1
    endWhile

    string[] listOptions = FastArray_ToStringArray(containerNames)
    int index = self.ShowList(asListTitle, listOptions) - 1
    if (index == -1)
        return none
    endif

    Form selectedContainer = FastArray_GetForm(allContainersArr, index)

    DebugWithArgs("UI::ShowPrisonContainerList", apPrison.Name, "index: " + index + ", prisonerBelongingsContainers: " + prisonerBelongingsContainers + ", prisonerEvidenceContainers: " + prisonerEvidenceContainers + ", selectedContainer: " + selectedContainer)

    return selectedContainer
endFunction
