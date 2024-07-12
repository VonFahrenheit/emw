; -- SPRITE 00: HAPPY SLIME --
	; palset
	!Tweaker_Palset				= 4	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(HappySlime)


; -- SPRITE 01: GOOMBA SLAVE --
	; palset
	!Tweaker_Palset				= 3	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 1	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 1
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(GoombaSlave)


; -- SPRITE 02: REX --
	; palset
	!Tweaker_Palset				= 2	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 1	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 1	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $C0	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 1
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Rex)


; -- SPRITE 03: HAMMER REX --
	; palset
	!Tweaker_Palset				= 4	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 1	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 1	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $C0	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 1
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	%TweakerData()
	%AddToList(HammerRex)


; -- SPRITE 04: AGGRO REX --
	; palset
	!Tweaker_Palset				= 3	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 2	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 5	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 1	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 2	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $D0	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(AggroRex)


; -- Sprite 05: CONJUREX --
	; palset
	!Tweaker_Palset				= 4	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 1	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 1	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 1
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Conjurex)


; -- SPRITE 06: WIZREX --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 5	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(Wizrex)


; -- SPRITE 07: PROJECTILE --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 2	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Projectile)


; -- SPRITE 08: CAPTAIN WARRIOR --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 6	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 1
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(CaptainWarrior)


; -- SPRITE 09: TAR CREEPER --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 6	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 1	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 1	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(TarCreeper)


; -- SPRITE 0A: UNUSED --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 1
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(ShopObject)	; slot 0A actually unused


; -- SPRITE 0B: MOLE WIZARD --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(MoleWizard)


; -- SPRITE 0C: MINI MOLE --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 3	; 0-31, see list
	!Tweaker_ObjectClipping			= 6	; 0-15, see list
	!Tweaker_Weight				= 1	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 1	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 1	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(MiniMole)


; -- SPRITE 0D: PLANT HEAD --
	; palset
	!Tweaker_Palset				= 3	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 5	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(PlantHead)


; -- SPRITE 0E: NPC --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 3	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(NPC)


; -- SPRITE 0F: BLOCK --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(Block)


; -- SPRITE 10: KINGKING --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 7	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(KingKing)


; -- SPRITE 11: SIGN --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 2	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 1
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Sign)


; -- SPRITE 12: LAKITU LOVERS --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 5	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(LakituLovers)


; -- SPRITE 13: UNUSED --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(ShopObject)		; actually unused


; -- SPRITE 14: UNUSED --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(ShopObject)		; actually unused


; -- SPRITE 15: UNUSED --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(ShopObject)		; actually unused


; -- SPRITE 16: THIF --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 2	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Thif)


; -- SPRITE 17: THIF --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 2	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Thif)


; -- SPRITE 18: KOMPOSITE KOOPA --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 6	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(KompositeKoopa)


; -- SPRITE 19: BIRDO --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 5	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Birdo)


; -- SPRITE 1A: BIRDO EGG --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 2	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 1
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Birdo_Egg)


; -- SPRITE 1B: BUMPER --
	; palset
	!Tweaker_Palset				= 4	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 2	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Bumper)


; -- SPRITE 1C: MONKEY --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Monkey)


; -- SPRITE 1D: MONKEY --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Monkey)


; -- SPRITE 1E: TERRAIN PLATFORM --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 7	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(TerrainPlatform)


; -- SPRITE 1F: TERRAIN PLATFORM --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 7	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(TerrainPlatform)


; -- SPRITE 20: LAVA LORD --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 7	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(LavaLord)


; -- SPRITE 21: COIN GOLEM --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 7	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(CoinGolem)


; -- SPRITE 22: YOSHI COIN --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 1	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(YoshiCoin)


; -- SPRITE 23: GREEN ELITE KOOPA --
	; palset
	!Tweaker_Palset				= 4	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 5	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 1	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 1	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(EliteKoopa_Green)


; -- SPRITE 24: RED ELITE KOOPA --
	; palset
	!Tweaker_Palset				= 3	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 5	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(EliteKoopa_Red)


; -- SPRITE 25: BLUE ELITE KOOPA --
	; palset
	!Tweaker_Palset				= 2	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 5	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(EliteKoopa_Blue)


; -- SPRITE 26: YELLOW ELITE KOOPA --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 5	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(EliteKoopa_Yellow)


; -- SPRITE 27: BOO HOO --
	; palset
	!Tweaker_Palset				= 6	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 0	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(BooHoo)


; -- SPRITE 28: GIGA THWOMP --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 7	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 1
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(GigaThwomp)


; -- SPRITE 29: FLAME PILLAR --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 0	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(FlamePillar)


; -- SPRITE 2A: BIG MAX --
	; palset
	!Tweaker_Palset				= 3	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 1	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(BigMax)


; -- SPRITE 2B: PORTAL --
	; palset
	!Tweaker_Palset				= 4	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 0	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 1
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Portal)


; -- SPRITE 2C: FLYING REX --
	; palset
	!Tweaker_Palset				= 7	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 3	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 2	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(FlyingRex)


; -- SPRITE 2D: ULTRA FUZZY --
	; palset
	!Tweaker_Palset				= 6	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 0	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(UltraFuzzy)


; -- SPRITE 2E: SHIELD BEARER --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 2	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(ShieldBearer)


; -- SPRITE 2F: ELEVATOR --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 7	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(Elevator)


; -- SPRITE 30: CHEST --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 2	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 1
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(Chest)


; -- SPRITE 31: EPIC BLOCK --
	; palset
	!Tweaker_Palset				= 5	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 6	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(EpicBlock)


; -- SPRITE 32: SHOP OBJECT --
	; palset
	!Tweaker_Palset				= 1	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 0	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 1
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(ShopObject)


; -- SPRITE 33: UNUSED --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 0	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 3	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(ShopObject)		; actually unused


; -- SPRITE 34: DENSE REX --
	; palset
	!Tweaker_Palset				= 7	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= 1	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 4	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 3	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 2	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $C0	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 0
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 0
	; damage resistances
	!Tweaker_KnockbackImmunity		= 0
	!Tweaker_SilverPowImmunity		= 0
	!Tweaker_StarImmunity			= 0
	!Tweaker_ProjectileImmunity		= 0
	!Tweaker_MeleeAttackImmunity		= 0
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 0
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(Rex_Dense)


; -- SPRITE 35: CHIMNEY SMOKE --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= $1F	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 0	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 1
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(SmokeyBoy)


; -- SPRITE 36: AIRSHIP DISPLAY --
	; palset
	!Tweaker_Palset				= 0	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= $1F	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 0	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 1
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 0
	%TweakerData()
	%AddToList(AirshipDisplay)


; -- SPRITE 37: LIGHTNING BOLT --
	; palset
	!Tweaker_Palset				= 2	; 0-7, see list
	; size
	!Tweaker_SpriteClipping			= $1F	; 0-31, see list
	!Tweaker_ObjectClipping			= 0	; 0-15, see list
	!Tweaker_Weight				= 0	; 0-7
	; behavior
	!Tweaker_WallBehavior			= 0	; 0-3, 0 = ignore wall, 1 = turn away from wall, 2 = jump at wall, 3 = turn + invert x speed at wall
	!Tweaker_LedgeBehavior			= 0	; 0-3, 0 = ignore ledge, 1 = turn away from ledge, 2 = jump at ledge, 3 = ledge acts as wall
	!Tweaker_JumpHeight			= $00	; speed value, must be a multiple of 8 (usually negative)
	!Tweaker_CanClimbWall			= 0
	!Tweaker_TurnWhenTouchedByPlayer	= 0
	!Tweaker_TurnWhenTouchedByOtherSprite	= 0
	!Tweaker_CarryableItem			= 0
	!Tweaker_CantBePickedUpWhenKicked	= 0
	; terrain
	!Tweaker_DisableTerrain			= 0
	!Tweaker_DisableLayer23			= 0
	!Tweaker_DisableWaterSplash		= 0
	!Tweaker_TreatLavaAsWater		= 0
	; interaction
	!Tweaker_DisablePlayerInteraction	= 0
	!Tweaker_DisableSpriteInteraction	= 1
	!Tweaker_ProcessInteractionEveryFrame	= 0
	!Tweaker_SpikySurface			= 0
	!Tweaker_GhostMode			= 1
	; damage resistances
	!Tweaker_KnockbackImmunity		= 1
	!Tweaker_SilverPowImmunity		= 1
	!Tweaker_StarImmunity			= 1
	!Tweaker_ProjectileImmunity		= 1
	!Tweaker_MeleeAttackImmunity		= 1
	; despawn protection
	!Tweaker_LevelInitDespawnProtection	= 1
	!Tweaker_OffScreenDespawnProtection	= 1
	%TweakerData()
	%AddToList(Lightning)



