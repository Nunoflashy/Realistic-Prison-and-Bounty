scriptname RPB_Recovery hidden

;/
@functions:
    string function ResetActor(Actor akActor) global
    string function CancelArrest(Actor akActor, string asReason, bool abReturnBelongings = true) global
/;

;/
    Frees @akActor from everything this mod may have left on them, however they got stuck: a prisoner is released where
    they stand (belongings back from the prison's container, outfit, cell package, hostility restore, and whatever is left
    of their arrest), an arrestee's arrest is reverted, a guard loses its Captor and package lock, any Scene still
    playing with them in it ends, and their AI is back on. Every step only acts on what it finds, so it's safe on any mix
    of leftovers and on an actor with nothing left at all.

    This is the manual way out for real gameplay (MCM Check Arrestee / Check Prisoner) and testing (F4), and what the
    tests' teardown uses so a deleted test actor never leaves items in a shared prison container.

    Returns what was done, for a message or a log line ("" when there was nothing to do).
/;
string function ResetActor(Actor akActor) global
    if (!akActor)
        return ""
    endif

    RPB_Arrest arrest = RPB_API.GetArrest()
    RPB_PrisonManager prisonManager = RPB_API.GetPrisonManager()
    RPB_SceneManager sceneManager = RPB_API.GetSceneManager()
    string done = ""

    ; Not in prison yet: cancelled, not released (a release outside prison counted all game time as time jailed)
    RPB_Prison pendingPrison = prisonManager.FindPrisonByPrisoner(akActor)
    if (pendingPrison)
        RPB_Prisoner pendingPrisoner = pendingPrison.Prisoners.AtKey(akActor)
        if (pendingPrisoner && !pendingPrisoner.IsImprisoned)
            done += RPB_Recovery.CancelArrest(akActor, "the actor is being reset")
        endif
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: pending arrest cancel done")
    ; A Scene still playing with them in it would keep driving them (and its guard) after everything below
    if (sceneManager.EndSceneWithActor(akActor, "the actor is being reset"))
        done += "Scene ended; "
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: Scenes done")
    ; Prisoner: released in place, the same release as the prison's own minus the move (this also clears a leftover arrest)
    RPB_Prison prison = prisonManager.FindPrisonByPrisoner(akActor)
    RPB_Prisoner prisonerRef = none
    if (prison)
        prisonerRef = prison.Prisoners.AtKey(akActor)
    endif

if (prisonerRef)
        prison.ReleaseInPlace(prisonerRef)
    done += "released from " + prison.Name + "; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_PrisonerSpell())
        done += "stray Prisoner effect removed; "
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: prisoner done")
    ; Arrestee: whatever the release didn't already clear. Its Captor goes first, if it's still escorting them.
    RPB_Arrestee arresteeRef = arrest.Arrestees.AtKey(akActor)
    if (arresteeRef)
        RPB_Captor captorRef = arresteeRef.Captor
        if (captorRef && captorRef.Arrestee == akActor)
            Actor guard = captorRef.GetActor()
            captorRef.Destroy()
            RPB_Recovery.__FreeGuard(guard, sceneManager)
            done += "their guard was freed; "
        endif

        arresteeRef.RevertArrest()
        done += "arrest reverted; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_ArresteeSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_ArresteeSpell())
        done += "stray Arrestee effect removed; "
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: arrestee done")
    ; A guard: its own Captor and a package lock left on it
    RPB_Captor ownCaptor = arrest.GetCaptor(akActor)
    if (ownCaptor)
        ownCaptor.Destroy()
        done += "Captor removed; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_CaptorSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_CaptorSpell())
        done += "stray Captor effect removed; "
    endif
    if (RPB_Recovery.__FreeGuard(akActor, sceneManager))
        done += "package lock removed; "
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: captor done")
    ; A pending arrest holds its arrestee with SetRestrained and SetDontMove (the revert above lifts them, this covers an
    ; arrest state that was already gone)
    akActor.SetRestrained(false)
    akActor.SetDontMove(false)
    sceneManager.UnsetPendingHoldOnActor(akActor) ; the pending hold's package alias, if one is recorded
    RPB_Recovery.__Step(akActor, "ResetActor: holds done")
    if (akActor == Game.GetPlayer())
        int calmed = RPB_Utility.CalmGuardsAgainstPlayer()
        if (calmed > 0)
            done += calmed + " guard(s) calmed; "
        endif
        ; A Reset always hands control back: a player left locked by an arrest (AI-driven, movement and menus off)
        ; with no arrest state left got "nothing to reset" and stayed stuck
        RPB_Utility.ReleaseAI(true)
    endif
    if (RPB_Utility.RemoveCuffs(akActor) > 0)
        done += "cuffs removed; "
    endif
    ; A pose left over from an arrest Scene (a looping idle), even when there was no arrest state left to reset
    Debug.SendAnimationEvent(akActor, "IdleForceDefaultState")
    akActor.EnableAI(true)
    akActor.EvaluatePackage()

    RPB_Utility.Debug("Recovery::ResetActor", akActor + ": " + RPB_Utility.string_if(done == "", "nothing to reset", done))
    return done
endFunction

;/
    Cancels @akActor's arrest: they're free, as if it never happened. For an arrest that can't go on and has nobody to
    take it over - its guard died, or a fight broke out before the cuffs went on. Their Scenes end without their end
    events, the arrest is reverted (hold lifted, uncuffed, bounty back), a prisoner not yet in prison is cancelled without
    a release (Prison.CancelImprisonment), their guard is freed, and their hostility comes back at once, so guards react to
    them again instead of ignoring them. An actor already imprisoned is left alone (that's a release, not a cancel).
    @abReturnBelongings false: a stripped prisoner's things stay in the belongings chest (nobody left to hand them over).

    Returns what was done ("" when there was nothing to do).
/;
string function CancelArrest(Actor akActor, string asReason, bool abReturnBelongings = true) global
    if (!akActor)
        return ""
    endif

    RPB_Arrest arrest = RPB_API.GetArrest()
    RPB_PrisonManager prisonManager = RPB_API.GetPrisonManager()
    RPB_SceneManager sceneManager = RPB_API.GetSceneManager()

    RPB_Prison prison = prisonManager.FindPrisonByPrisoner(akActor)
    RPB_Prisoner prisonerRef = none
    if (prison)
        prisonerRef = prison.Prisoners.AtKey(akActor)
    endif
    if (prisonerRef && prisonerRef.IsImprisoned)
        RPB_Utility.Info("Not cancelling the arrest of " + akActor + " (" + asReason + "): already imprisoned")
        return ""
    endif

    string done = ""
    ; First: the snapshot lives in the actor's "Jail" storage, which cancelling the prisoner below wipes (a freed bandit
    ; stayed neutral, and guards ignored it)
    if (RPB_Utility.RestoreNeutralizedHostility(akActor) > 0)
        done += "hostility restored; "
    endif

    if (sceneManager.EndSceneWithActor(akActor, asReason))
        done += "Scene ended; "
    endif
    RPB_Recovery.__Step(akActor, "CancelArrest: hostility and Scenes done")

    RPB_Arrestee arresteeRef = arrest.Arrestees.AtKey(akActor)
    RPB_Recovery.__Step(akActor, "CancelArrest: arrestee looked up (" + arresteeRef + ")")
    if (arresteeRef)
        ; The guard's side (his Captor, his package lock) on its own stack (Arrest.ReleaseCaptorOf): looking the Captor up
        ; calls into him, and a frozen guard held this cancel there (148's teardown: the player left cuffed). The guard is
        ; read from my storage, which doesn't call him.
        Actor guard = arresteeRef.GetCaptorActor()
        if (guard)
            int handle = ModEvent.Create("RPB_ReleaseCaptor")
            if (handle)
                ModEvent.PushForm(handle, guard)
                ModEvent.PushForm(handle, akActor)
                ModEvent.PushBool(handle, true)
                ModEvent.Send(handle)
                done += "guard release sent; "
            endif
        endif
        RPB_Recovery.__Step(akActor, "CancelArrest: reverting the arrest")
        arresteeRef.RevertArrest()
        done += "arrest reverted; "
    endif

    RPB_Recovery.__Step(akActor, "CancelArrest: captor and arrest done")

    if (prisonerRef)
        prison.CancelImprisonment(prisonerRef, asReason, abReturnBelongings)
        done += "imprisonment cancelled; "
    endif
    RPB_Recovery.__Step(akActor, "CancelArrest: imprisonment done")

    akActor.SetRestrained(false)
    akActor.SetDontMove(false)
    sceneManager.UnsetPendingHoldOnActor(akActor)
    if (RPB_Utility.RemoveCuffs(akActor) > 0)
        done += "cuffs removed; "
    endif
    ; The confrontation's pose ("Hands Behind Back" is a looping idle) outlives the Scene ended above: a fight before the
    ; cuffs left the player holding it, free to go but stuck in the pose
    Debug.SendAnimationEvent(akActor, "IdleForceDefaultState")
    RPB_Recovery.__Step(akActor, "CancelArrest: holds and cuffs done")
    if (akActor == Game.GetPlayer())
        RPB_Utility.ReleaseAI(true)
        ; A surrender keeps the forced arrest dialogue off until BeginArrest's end: an arrest cancelled before that would
        ; leave it off for good
        RPB_Arrest.EnableForcedArrestDialogue()
    else
        akActor.EnableAI(true)
    endif
    akActor.EvaluatePackage()
    RPB_Recovery.__Step(akActor, "CancelArrest: AI and controls released")

    RPB_Utility.Info("Arrest of " + akActor.GetDisplayName() + " " + akActor + " cancelled (" + asReason + "): " + RPB_Utility.string_if(done == "", "nothing left to undo", done))
    return done
endFunction

; A step mark (DEBUG only, built only then): a reset that never finished (126's teardown) left no trace of where it stopped
function __Step(Actor akActor, string asStep) global
    if (RPB_Utility.IsDebuggingEnabled())
        RPB_Utility.Debug("Recovery", akActor + ": " + asStep)
    endif
endFunction

; Removes a package lock left on @akGuard. Only when one is recorded: UnsetPackageLockOnActor() on an actor without one
; resolves alias id 0, which is one of the Scene aliases, and would unbind it.
bool function __FreeGuard(Actor akGuard, RPB_SceneManager apSceneManager) global
    if (!akGuard || !RPB_StorageVars.GetIntOnReference("Package Lock", akGuard))
        return false
    endif

    apSceneManager.UnsetPackageLockOnActor(akGuard)
    if (!akGuard.IsDead()) ; nothing to evaluate on a corpse (the handover of a dead guard hung around here once)
        akGuard.EvaluatePackage()
    endif
    return true
endFunction
