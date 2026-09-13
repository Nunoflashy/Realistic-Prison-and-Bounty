scriptname RPB_ActorScript extends RPB_ActorBase

import RPB_Utility
import RPB_Memory

; ==========================================================
;                           Class
; ==========================================================

string function typeName() ; virtual
    return "RPB_ActorScript"
endFunction

; ==========================================================
;                          Properties
; ==========================================================

; RPB_Actor __actorState
; RPB_Actor property ActorState
;     RPB_Actor function get()
;         if (__actorState)
;             return __actorState
;         endif

;         __actorState = RPB_Actor.GetActorStateReference(this)

;         if (!__actorState)
;             ; API.EventManager.SendError("Could not find ActorState for Actor " + this + " (RPB_Actor was not bound!)", "BountyDecayable::ActorState")
;             throw(ResourceNotFoundException("Could not find State for Actor " + this + " (RPB_Actor was not bound!)"), "ActorScript::ActorState")
;             return none
;         endif

;         __actorState.ApplyScriptState(self)
;         return __actorState
;     endFunction
; endProperty

string property ScriptID
    string function get()
        return this + "<"+ typeName() +">"
    endFunction
endProperty

RPB_Actor __actorState
RPB_Actor property ActorState
    RPB_Actor function get()
        if (__actorState)
            return __actorState
        endif

        __actorState = RPB_Actor.GetActorStateReference(this)

        if (!__actorState)
            throw(InvalidStateException("Could not find State for Actor " + this + " (RPB_Actor was not bound!)"), "ActorScript::ActorState")
            return none
        endif

        return __actorState
    endFunction
endProperty

; ==========================================================

function __construct() ; virtual
endFunction

function __delete()
    ; Delete Log
    ; int i = 0
    ; while (i < FastArray_Size(propertyIds))
    ;     int obj = FastArray_GetInt(propertyIds, i)
    ;     Debug("ActorScript::__delete", "Deleting script property for " + ScriptID + " (object_id: " + obj + ") (data: "+ GetContainerList(obj) +")")
    ;     i += 1
    ; endWhile

    DeleteWithIdentifier(self.ScriptID)
    ; Delete(propertyMap)

    ; Check Deletion Log
    ; i = 0
    ; while (i < FastArray_Size(propertyIds))
    ;     int obj = FastArray_GetInt(propertyIds, i)
    ;     Debug("ActorScript::__delete", "Checking script property for " + ScriptID + " (object_id: " + obj + ") (data: "+ GetContainerList(obj) +")")
    ;     i += 1
    ; endWhile
endFunction

; ==========================================================
;                        Event Handlers
; ==========================================================

event OnAttachScript() ; virtual
endEvent

event OnDetachScript() ; virtual
endEvent

event OnInitialize()
    __construct()

    if (ActorState)
        ActorState.ApplyScriptState(self)
    endif

    self.OnAttachScript()
endEvent

event OnDestroy()
    __delete()

    if (ActorState)
        ActorState.RemoveScriptState(self)    
    endif

    self.OnDetachScript()
endEvent

; ==========================================================
;                          Management
; ==========================================================

;/
    Attaches the script specified by @className to the specified Actor.

    Actor   @akActor: The Actor to attach this script to.
    string  @className: The name of the script to attach.

    @throws InvalidParamException: Thrown when @akActor or @className is not valid.
    @throws ResourceNotFoundException: Thrown when the script specified by @className is not found.
/;
function AttachOfType(Actor akActor, string className) global
    if (!akActor || className == "")
        throw(InvalidParamException("Could not attach script " + className + " to Actor " + akActor + "!" + \
            string_if (akActor == none, " (No Actor) ", "") + \
            string_if (className == "", " (No Script)", "") \
        ), "ActorScript::AttachOfType")
        return
    endif

    Spell spellToAttach = GetScriptSpell(className)

    if (spellToAttach == none)
        throw(ResourceNotFoundException("Could not attach script " + className + " to Actor " + akActor + "! (Spell not found)"), "ActorScript::AttachOfType")
        return
    endif

    bool isScriptAttached = akActor.HasSpell(spellToAttach)

    if (!isScriptAttached)
        akActor.AddSpell(spellToAttach, false) ; Attaches the script
        Debug("ActorScript::AttachOfType", "Attached script " + className + " to Actor " + akActor)
    endif

    RPB_API.GetSelf().EventManager.SendWarning("Tried to attach script " + className + " to Actor " + akActor + " but it was already attached!", "ActorScript::AttachOfType", isScriptAttached)
endFunction

;/
    Detaches the script specified by @className from the specified Actor.

    Actor   @akActor: The Actor to detach this script from.
    string  @className: The name of the script to detach.

    @throws InvalidParamException: Thrown when @akActor or @className is not valid.
    @throws ResourceNotFoundException: Thrown when the script specified by @className is not found.
/;
function DetachOfType(Actor akActor, string className) global
    if (!akActor || className == "")
        throw(InvalidParamException("Could not detach script " + className + " from Actor " + akActor + "!" + \
            string_if (akActor == none, " (No Actor) ", "") + \
            string_if (className == "", " (No Script)", "") \
        ), "ActorScript::DetachOfType")
        return
    endif

    Spell spellToDetach = GetScriptSpell(className)

    if (spellToDetach == none)
        throw(ResourceNotFoundException("Could not detach script " + className + " from Actor " + akActor + "! (Spell not found)"), "ActorScript::DetachOfType")
        return
    endif

    bool isScriptAttached = akActor.HasSpell(spellToDetach)

    if (spellToDetach && isScriptAttached)
        akActor.RemoveSpell(spellToDetach) ; Detaches the script
        Debug("ActorScript::DetachOfType", "Detached script " + className + " from Actor " + akActor)
    endif

    RPB_API.GetSelf().EventManager.SendWarning("Tried to detach script " + className + " from Actor " + akActor + " but it was not attached!", "ActorScript::DetachOfType", !isScriptAttached)
endFunction

; ==========================================================
;                           Memory
; ==========================================================

;/ private /; int propertyMap ; FastMap<string, FastMap<T, U>>
;/ private /; int propertyIds ; FastArray<int>

int function CreateScriptProperty(int object, int objectFn)
    if (object)
        return object
    endif

    object = Object_CreateIfNotExists(object, objectFn)

    if (!object)
        throw(NullReferenceException("Could not create script property for "+ ScriptID +"! (Object factory is null)"), "ActorScript::CreateScriptProperty")
        return 0
    endif

    Debug("ActorScript::CreateScriptProperty", "Created script property for " + ScriptID + " (object_id: " + object + ") (persisting in memory)")

    propertyIds = Object_CreateIfNotExists(propertyIds, FastArray("<int>"))
    PersistObjectInMemory(propertyIds, self.ScriptID) ; TODO: Refactor to only persist once, same for below

    FastArray_AddInt(propertyIds, object)

    int persisted = PersistObjectInMemory(object, self.ScriptID)

    if (!persisted)
        throw(MemoryException("Could not create script property for "+ ScriptID +"! (Failed to persist object in memory)"), "ActorScript::CreateScriptProperty")
        return 0
    endif

    return persisted
endFunction

function SetProperty(string key, string value)
    propertyMap = Object_CreateIfNotExists(propertyMap, FastMap("<string>", retain = true))
endFunction

; ==========================================================
;                      Spell Management
; ==========================================================

Spell function GetScriptSpell(string className) global
    if (className == RPB_BountyDecayable.className())
        return RPB_BountyDecayable.ScriptSpell()
    endif

    return none
endFunction