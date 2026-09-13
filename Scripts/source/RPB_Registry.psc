scriptname RPB_Registry hidden

import RPB_Utility
import RPB_Memory

function RegisterContent(string asRegistrant, int apContentData) global
    StaticStorage_SetObjectInPath(".registry.registrants." + asRegistrant, apContentData, createMissingKeys = true)
endFunction

int function GetContent(string asRegistrant) global
    return StaticStorage_GetObjectInPath(".registry.registrants." + asRegistrant)
endFunction

bool function HasContent(string asKey, string asRegistrant = "") global
    if (asRegistrant != "")
        return FastMap_HasKey(GetContent(asRegistrant), asKey)
    endif

    int registrants = GetRegistrants()

    int i = 0
    while (i < FastMap_Size(registrants))
        string registrantKey = FastMap_GetNthKey(registrants, i)
        int registrant = FastMap_GetObject(registrants, registrantKey)

        if (registrant && FastMap_HasKey(registrant, asKey))
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

string function AsPresetRegistrantKey(string asRegistrant) global
    return "PRESET." + asRegistrant
endFunction

bool function HasPresetRegistrant(string asRegistrant) global
    return GetContent(AsPresetRegistrantKey(asRegistrant)) != 0
endFunction

int function GetRegistrants() global
    return StaticStorage_GetObjectInPath(".registry.registrants")
endFunction

string function ListContent(string asRegistrant) global
    return GetContainerList(GetContent(asRegistrant))
endFunction