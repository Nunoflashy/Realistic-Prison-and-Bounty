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

string function ShowHoldList(string asListTitle = "Select Hold")
    string[] holds = API.Config.Holds

    int holdsArr = JArray.object()
    JArray.addStr(holdsArr, "<No Hold>")

    ; int i = 0
    ; while (i < holds.Length)
    ;     JArray.addStr(holdsArr, holds[i])
    ;     i += 1
    ; endWhile
    JArray.addFromArray(holdsArr, JArray.objectWithStrings(holds))
    string[] holdsOutput = JArray.asStringArray(holdsArr)
    string selectedHold  = self.ShowList_ReturnElement(asListTitle, holdsOutput)

    if (selectedHold == "<No Hold>")
        return none
    endif

    return selectedHold
endFunction

RPB_Prison function ShowPrisonList(bool abNotEmpty = true, string asListTitle = "Select Prison")
    RPB_PrisonManager prisonManager = API.PrisonManager
    int prisonNames = JArray.object()
    int prisonCount = prisonManager.PrisonSlots
    int activePrisonCount = 0

    int prisonIds = JArray.object()

    JArray.addStr(prisonNames, "<No Prison>")

    int i = 0
    while (i < prisonCount)
        RPB_Prison prison = prisonManager.GetPrisonByID(i)
        int prisonerCount = prison.Prisoners.Count
        if ((prisonerCount > 0 && abNotEmpty) || !abNotEmpty)
            string prisonName = prison.Name
            string prisonHold = prison.Hold
            string prisonCity = prison.City
            string prisonLine = "("+ string_if(prisonCity as bool, prisonCity, prisonHold) +") " + prisonName + " - " + prisonerCount + " Prisoners"
            JArray.addStr(prisonNames, prisonLine)
            JArray.addInt(prisonIds, prison.ID)
            activePrisonCount += 1
        endif
        i += 1
    endWhile
    
    if (activePrisonCount == 0)
        return none
    endif

    string[] prisonNamesArray = JArray.asStringArray(prisonNames)

    int index = self.ShowList(asListTitle, prisonNamesArray, 0, 0) - 1
    if (index == -1)
        return none
    endif

    int id = JArray.getInt(prisonIds, index)
    return prisonManager.GetPrisonByID(id)
endFunction

RPB_Prisoner function ShowPrisonerList(RPB_Prison apPrison, bool abOnlyImprisoned = false, string asListTitle = "Select Prisoner")
    float startBench = StartBenchmark()
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
    while (i < prisoners.GetSize())
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
    EndBenchmark(startBench, "Actions::ShowPrisonerList")



    int index = self.ShowList(asListTitle, prisonerNamesAsArray, 0, 0) - 1
    if (index == -1)
        return none
    endif

    RPB_Prisoner selectedPrisoner = prisoners.AtIndex(index)
    return selectedPrisoner
endFunction