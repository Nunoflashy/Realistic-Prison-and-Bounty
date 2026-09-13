scriptname RPB_PackageGroup extends Quest

import RPB_Utility
import RPB_Memory

; ==========================================================
;                      Script References
; ==========================================================

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

RPB_Logger property Logger
    RPB_Logger function get()
        return API.Logger
    endFunction
endProperty

; ==========================================================
;                         Properties
; ==========================================================

bool property Initialized
    bool function get()
        return (Name != "" && GroupType != "" && self.IsRunning())
    endFunction
endProperty

int property Identifier
    int function get()
        return self.GetFormID()
    endFunction
endProperty

string __name
string property Name
    string function get()
        return __name
    endFunction
endProperty

string __groupType
string property GroupType
    string function get()
        return __groupType
    endFunction
endProperty

int __availablePackageCount
int property AvailablePackageCount
    int function get()
        return __availablePackageCount
    endFunction
endProperty

int property TotalPackageCount
    int function get()
        return self.GetNumAliases()
    endFunction
endProperty


; ==========================================================
;                          ctor
; ==========================================================

;/
    Handles the configuration of this Package Group.

    string  @asPackageGroupName: The name of the package group, as defined by the FormID in the CK.
    string  @asGroupType: The type of packages that this Package Group holds.
/;
RPB_PackageGroup function PackageGroup(string asPackageGroupName, string asGroupType)
    __name          = asPackageGroupName
    __groupType     = asGroupType

    return self
endFunction

; ==========================================================
;                         public
; ==========================================================

;/
    Retrieves a Package from the Package Group.
    Optionally, retrieving a specific size of the package.

    returns (ReferenceAlias): The actual package ReferenceAlias (with an AI Package bound to it).
/;
ReferenceAlias function GetPackage()
    if (!Initialized)
        Logger.SendError("Could not initialize Package Group, unable to retrieve Package! (Identifier: "+ self +")", "PackageGroup::GetPackage")
        return none
    endif

    return __getNextAvailablePackage()
endFunction

function BindPackage(ReferenceAlias apPackage, ObjectReference akDestination)
    if (!Initialized)
        Logger.SendError("Could not initialize Package Group, unable to bind Package! (Identifier: "+ self +")", "PackageGroup::BindPackage")
        return none
    endif

    BindAliasTo(apPackage, akDestination)
    __decrementAvailablePackageCount()
endFunction

function BindAvailablePackage(ObjectReference akDestination)
    if (!Initialized)
        Logger.SendError("Could not initialize Package Group, unable to bind Package! (Identifier: "+ self +")", "PackageGroup::BindAvailablePackage")
        return none
    endif

    ReferenceAlias availablePackage = self.GetPackage()
    BindAliasTo(availablePackage, akDestination)
    __decrementAvailablePackageCount()
endFunction

function UnbindPackage(ReferenceAlias apPackage)
    if (!Initialized)
        Logger.SendError("Could not initialize Package Group, unable to unbind Package! (Identifier: "+ self +")", "PackageGroup::UnbindPackage")
        return none
    endif

    UnbindAlias(apPackage)
    __incrementAvailablePackageCount()
endFunction

; ==========================================================
;                         private
; ==========================================================

ReferenceAlias function __getPackageByName(string asPackageName)
    return self.GetAliasByName(asPackageName) as ReferenceAlias
endFunction

ReferenceAlias function __getPackageByIndex(int aiPackageIndex)
    return self.GetNthAlias(aiPackageIndex) as ReferenceAlias
endFunction

ReferenceAlias function __getNextAvailablePackage()
    int i = 0
    while (i < TotalPackageCount)
        string packageName = __getPackageNameFormatted(i)
        ReferenceAlias currentPackage = __getPackageByName(packageName)

        if (currentPackage.GetReference() == none)
            DebugWithArgs("("+ Name +") (private) PackageGroup::GetNextAvailablePackage", GroupType, "Retrieving Package: " + packageName)
            return currentPackage
        endif
        i += 1
    endWhile
endFunction

string function __getPackageNameFormatted(int aiPackageIndex)
    if (aiPackageIndex >= 100)
        return GroupType + "_0" + aiPackageIndex

    elseif (aiPackageIndex >= 10)
        return GroupType + "_00" + aiPackageIndex

    else
        return GroupType + "_000" + aiPackageIndex
    endif
endFunction

function __incrementAvailablePackageCount(int aiBy = 1)
    __availablePackageCount += aiBy
endFunction

function __decrementAvailablePackageCount(int aiBy = 1)
    __availablePackageCount -= aiBy
endFunction