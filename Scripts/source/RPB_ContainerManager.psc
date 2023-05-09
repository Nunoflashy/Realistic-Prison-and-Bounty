scriptname RPB_ContainerManager extends Quest

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

int function CreateMap(string containerKey)
    int _container = JMap.object()
    JValue.retain(_container)
    JMap.setObj(__internalContainers, containerKey, _container)
    Debug(self, "ContainerManager::CreateMap", "Created new map with id: " + _container)
    
    return _container
endFunction

int function CreateIntegerMap(string containerKey)
    int _container = JIntMap.object()
    JValue.retain(_container)
    JMap.setObj(__internalContainers, containerKey, _container)
    
    return _container
endFunction

int function CreateFormMap(string containerKey)
    int _container = JFormMap.object()
    JValue.retain(_container)
    JMap.setObj(__internalContainers, containerKey, _container)
    
    return _container
endFunction

int function CreateArray(string containerKey)
    int _container = JArray.object()
    JValue.retain(_container)
    JMap.setObj(__internalContainers, containerKey, _container)
    
    return _container
endFunction

function SetBool(string containerKey, string paramKey, bool value)
    int _container = JMap.getObj(__internalContainers, containerKey)
    JMap.setInt(_container, paramKey, value as int)
endFunction

function SetInt(string containerKey, string paramKey, int value)
    int _container = JMap.getObj(__internalContainers, containerKey)
    JMap.setInt(_container, paramKey, value)
endFunction

function SetFloat(string containerKey, string paramKey, float value)
    int _container = JMap.getObj(__internalContainers, containerKey)
    JMap.setFlt(_container, paramKey, value)
endFunction

function SetString(string containerKey, string paramKey, string value)
    int _container = JMap.getObj(__internalContainers, containerKey)
    JMap.setStr(_container, paramKey, value)
endFunction

function SetForm(string containerKey, string paramKey, Form value)
    int _container = JMap.getObj(__internalContainers, containerKey)
    JMap.setForm(_container, paramKey, value)
endFunction

; Temporary, probably
function SetObject(string containerKey, string paramKey, int value)
    int _container = JMap.getObj(__internalContainers, containerKey)
    JMap.setObj(_container, paramKey, value)
endFunction

bool function GetBool(string containerKey, string paramKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    return JMap.getInt(_container, paramKey) as bool
endFunction

int function GetInt(string containerKey, string paramKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    return JMap.getInt(_container, paramKey)
endFunction

float function GetFloat(string containerKey, string paramKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    return JMap.getFlt(_container, paramKey)
endFunction

string function GetString(string containerKey, string paramKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    return JMap.getStr(_container, paramKey)
endFunction

Form function GetForm(string containerKey, string paramKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    return JMap.getForm(_container, paramKey)
endFunction

int function GetObject(string containerKey, string paramKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    return JMap.getObj(_container, paramKey)
endFunction

bool function HasKey(string containerKey, string paramKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    return JMap.hasKey(_container, paramKey)
endFunction

function RemoveElement(string containerKey, string paramKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    JMap.removeKey(_container, paramKey)
endFunction

function ClearContainer(string containerKey)
    int _container = JMap.getObj(__internalContainers, containerKey)
    JMap.clear(_container)
endFunction

int function GetContainer(string containerName)
    int _container = JMap.getObj(__internalContainers, containerName)
    return _container
endFunction

event OnInit()
    __internalContainers = JMap.object()
    JValue.retain(__internalContainers)
    RealisticPrisonAndBounty_Util.Debug(self, "ContainerManager::OnInit", "Container Manager has been initialized.")
endEvent

int __internalContainers ; JMap