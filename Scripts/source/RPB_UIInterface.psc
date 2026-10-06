scriptname RPB_UIInterface extends ObjectReference

;/
@references:
    UILIB_1 UILib
    RPB_API API
@functions:
    int function ShowList(string asTitle = "", string[] asOptions, int aiStartIndex = 0, int aiDefaultIndex = 0)
    string function ShowList_ReturnElement(string asTitle = "", string[] asOptions, int aiStartIndex = 0, int aiDefaultIndex = 0)
    string function ShowInput(string asTitle = "", string asInitialText = "")
    bool function WasCancelled()
    string function ShowStringList(string asTitle = "", string asOptions, string asOptionSeparator = ",", int aiStartIndex = 0, int aiDefaultIndex = 0)
    Form function ShowFormArrayList(string asListTitle = "", Form[] akOptions)
    string function ShowHoldList(bool abMustHaveArrestees = false, bool abSkipListOnSingleResult = false, string asListTitle = "Select Hold")
    RPB_Arrestee function ShowArresteeList(string asArrestHold, string asListTitle = "Select Arrestee")
    RPB_Captor function ShowCaptorList(string asArrestHold, string asListTitle = "Select Captor")
    RPB_Prison function ShowPrisonList(bool abNotEmpty = true, bool abSkipListOnSingleResult = false, bool abShowCity = true, bool abShowHold = false, bool abShowPrisonerCount = true, string asListTitle = "Select Prison")
    RPB_Prisoner function ShowPrisonerList(RPB_Prison apPrison, bool abOnlyImprisoned = false, string asListTitle = "Select Prisoner")
    RPB_JailCell function ShowCellList(RPB_Prison apPrison, bool abOnlyEmpty = false, bool abOnlyGenderExclusive = false, string asListTitle = "Select Cell")
    RPB_CellDoor function ShowCellDoorList(RPB_JailCell akCell, string asListTitle = "Select Cell Door")
    Form function ShowPrisonContainerList(RPB_Prison apPrison, string asListTitle = "Select Container")
@events:
/;

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

;/
    How SkyUILib's menus close (its swfs, 2026-10-06):
    - the list: Enter (or a click) marks a line, Tab closes the menu and sends back the marked line; with none marked, the
      line it opened marked (@aiDefaultIndex). There's no separate cancel: Tab with nothing marked is the cancel, and the
      Default button (Ready Weapon) marks the default line again. A list whose first line isn't already a "<No ...>" line
      gets a "<Cancel>" line on top, marked when it opens, so closing it without a choice returns nothing: the dev menu's
      arrest went ahead after a cancel (its escort list opened on Escort to Jail), and a test list ran its first line;
    - the text box: Enter accepts, Tab cancels, but its result alone doesn't say which, so I listen for the cancel keys
      while it's open (listening during a list read every Tab, the list's only close key, as a cancel).
    WasCancelled() says whether the last menu was closed without a choice.
/;
bool __menuCancelled

bool function WasCancelled()
    return __menuCancelled
endFunction

int function __TweenMenuKey()
    return Input.GetMappedKey("Tween Menu")
endFunction

function __WatchCancelKeys(bool abOn)
    int tween = __TweenMenuKey()
    if (abOn)
        __menuCancelled = false
        RegisterForKey(0x0F)  ; Tab
        RegisterForKey(0x01)  ; Esc
        RegisterForKey(0x115) ; gamepad B
        if (tween > 0)
            RegisterForKey(tween)
        endif
    else
        ; The key event comes in before the menu's close event, but it's a separate event: a moment for it to land
        Utility.WaitMenuMode(0.05)
        UnregisterForKey(0x0F)
        UnregisterForKey(0x01)
        UnregisterForKey(0x115)
        if (tween > 0)
            UnregisterForKey(tween)
        endif
    endif
endFunction

event OnKeyDown(int aiKeyCode)
    if (aiKeyCode == 0x0F || aiKeyCode == 0x01 || aiKeyCode == 0x115 || aiKeyCode == __TweenMenuKey())
        __menuCancelled = true
    endif
endEvent

; The marked line's index; closed without a choice, @aiDefaultIndex (my lists open on their "<No ...>" line, index 0)
int function ShowList(string asTitle = "", string[] asOptions, int aiStartIndex = 0, int aiDefaultIndex = 0)
    int selectedIndex = UILib.ShowList(asTitle, asOptions, aiStartIndex, aiDefaultIndex)
    __menuCancelled = selectedIndex < 0 || (selectedIndex == aiDefaultIndex && asOptions.Length > aiDefaultIndex && StringUtil.GetNthChar(asOptions[aiDefaultIndex], 0) == "<")
    return selectedIndex
endFunction

; The marked line, or "" when closed without a choice
string function ShowList_ReturnElement(string asTitle = "", string[] asOptions, int aiStartIndex = 0, int aiDefaultIndex = 0)
    if (asOptions.Length == 0)
        __menuCancelled = true
        return ""
    endif
    if (StringUtil.GetNthChar(asOptions[0], 0) == "<")
        int index = self.ShowList(asTitle, asOptions, aiStartIndex, aiDefaultIndex)
        if (__menuCancelled || index < 0 || index >= asOptions.Length)
            return ""
        endif
        return asOptions[index]
    endif

    ; A "<Cancel>" line on top, marked when it opens; the cursor still starts on @aiStartIndex's line
    int withCancel = FastArray("<string>")
    FastArray_AddString(withCancel, "<Cancel>")
    FastArray_AddFromArray(withCancel, FastArray_FromStringArray(asOptions))
    int marked = UILib.ShowList(asTitle, FastArray_ToStringArray(withCancel), aiStartIndex + 1, 0)
    __menuCancelled = marked <= 0 || marked > asOptions.Length
    if (__menuCancelled)
        return ""
    endif
    return asOptions[marked - 1]
endFunction

; The text accepted, or "" when cancelled
string function ShowInput(string asTitle = "", string asInitialText = "")
    __WatchCancelKeys(true)
    string text = UILib.ShowTextInput(asTitle, asInitialText)
    __WatchCancelKeys(false)
    if (__menuCancelled)
        return ""
    endif
    return text
endFunction

; ==========================================================
;                         UI Functions
; ==========================================================

string function ShowStringList(string asTitle = "", string asOptions, string asOptionSeparator = ",", int aiStartIndex = 0, int aiDefaultIndex = 0)
    string[] options = StringUtil.Split(asOptions, asOptionSeparator)
    return self.ShowList_ReturnElement(asTitle, options, aiStartIndex, aiDefaultIndex)
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
        ; An arrestee RPB found frozen is left out (his hold is a call into him); he's on RPB - Stats' Frozen NPCs page
        int frozenMap = RPB_Utility.FrozenGuardsForScan()

        int i = 0
        while (i < arrestees.Count)
            if (!(frozenMap && RPB_Utility.IsListedFrozen(frozenMap, arrestees.ActorAtIndexNoCall(i))))
                RPB_Arrestee arrestee = arrestees.AtIndex(i)
                if (arrestee)
                    string hold = arrestee.Hold
                    bool holdHasArrestee = FastArray_FindString(holdsArr, hold) != -1
                    if (!holdHasArrestee)
                        FastArray_AddString(holdsArr, hold)
                    endif
                endif
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
    int frozenMap = RPB_Utility.FrozenGuardsForScan() ; a frozen arrestee left out (each read below is a call into him)
    int i = 0
    while (i < arrestees.Count)
        RPB_Arrestee arrestee = none
        if (!(frozenMap && RPB_Utility.IsListedFrozen(frozenMap, arrestees.ActorAtIndexNoCall(i))))
            arrestee = arrestees.AtIndex(i)
        endif

        if (arrestee && arrestee.Hold == asArrestHold)
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

    ; A prisoner RPB found frozen is listed by his FormID, with no call into him (his name, sex and cell would each hang the
    ; menu) and can't be opened. Each line keeps its prisoner's index: the list used to pick by the line's position, which
    ; drifted once a prisoner was left out (abOnlyImprisoned)
    int frozenMap = RPB_Utility.FrozenGuardsForScan()
    int lineIndexes = FastArray("<int>")
    FastArray_AddInt(lineIndexes, -1)
    int i = 0
    while (i < prisoners.Count)
        Actor frozenActor = none
        if (frozenMap)
            frozenActor = prisoners.ActorAtIndexNoCall(i)
            if (!RPB_Utility.IsListedFrozen(frozenMap, frozenActor))
                frozenActor = none
            endif
        endif
        RPB_Prisoner prisoner = prisoners.AtIndex(i)
        if (frozenActor)
            FastArray_AddString(prisonerNames, "(frozen until the next load) " + frozenActor)
            FastArray_AddInt(lineIndexes, -2)
            activePrisonerCount += 1
        elseif (prisoner && ((abOnlyImprisoned && prisoner.IsImprisoned) || !abOnlyImprisoned))
            string prisonerName = prisoner.Name
            ; string sentenceFormatted = prison.GetSentenceFormatted(prisoner)
            ; string prisonerLine = "("+ prisoner.GetSex(true) +") " + prisoner.Name + " - " + prisoner.JailCell.ID + " | Sentence: " + sentenceFormatted
            string prisonerLine = "("+ prisoner.GetSex(true) +") " + prisonerName + " - " + prisoner.JailCell.ID
            FastArray_AddString(prisonerNames, prisonerLine)
            FastArray_AddInt(lineIndexes, i)
            activePrisonerCount += 1
        endif
        i += 1
    endWhile


    if (activePrisonerCount == 0)
        return none
    endif

    string[] prisonerNamesAsArray = FastArray_ToStringArray(prisonerNames)

    int line = self.ShowList(asListTitle, prisonerNamesAsArray, 0, 0)
    int[] indexes = FastArray_ToIntArray(lineIndexes)
    if (line <= 0 || line >= indexes.Length)
        return none
    endif
    if (indexes[line] == -2)
        Debug.Notification("That prisoner is frozen: nothing can be read from him until the next load")
        return none
    endif

    RPB_Prisoner selectedPrisoner = prisoners.AtIndex(indexes[line])
    return selectedPrisoner
endFunction

; The NPCs RPB found frozen this session, by their stored names (no call into any of them); none if cancelled
Actor function ShowFrozenList(string asListTitle = "Select Frozen NPC")
    Form[] frozen = RPB_Utility.FrozenActorsMarked()
    if (!frozen || frozen.Length == 0)
        return none
    endif
    string[] lines = Utility.CreateStringArray(frozen.Length + 1)
    lines[0] = "<None>"
    int i = 0
    while (i < frozen.Length)
        Actor frozenActor = frozen[i] as Actor
        string role = " (" + JMap.getStr(RPB_Utility.FrozenReport(frozenActor), "role") + ")"
        string name = RPB_Utility.ActorNameNoCall(frozenActor)
        if (name == "")
            lines[i + 1] = RPB_Utility.FormIdNoCall(frozenActor) + role
        else
            lines[i + 1] = name + role + " - " + RPB_Utility.FormIdNoCall(frozenActor)
        endif
        i += 1
    endWhile
    int line = self.ShowList(asListTitle, lines, 0, 0)
    if (line <= 0 || line > frozen.Length)
        return none
    endif
    return frozen[line - 1] as Actor
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
