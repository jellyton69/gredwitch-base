AddCSLuaFile()

local GRED_SVAR = { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY }

CreateConVar("gred_sv_easyuse"					,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_maxforcefield_range"		, "5000", GRED_SVAR)
CreateConVar("gred_sv_12mm_he_impact"			,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_7mm_he_impact"			,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_fragility"				,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_shockwave_unfreeze"		,  "0"  , GRED_SVAR)
CreateConVar("gred_sv_tracers"					,  "5"  , GRED_SVAR)
CreateConVar("gred_sv_oldrockets"				,  "0"  , GRED_SVAR)
CreateConVar("gred_jets_speed"					,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_healthslider"				, "100" , GRED_SVAR)
CreateConVar("gred_sv_enablehealth"				,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_enableenginehealth"		,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_fire_effect"				,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_multiple_fire_effects"	,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_bullet_dmg"				,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_bullet_radius"			,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_soundspeed_divider"		,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_decals"					,  "1"  , GRED_SVAR)
CreateConVar("gred_sv_arti_spawnaltitude"		, "1000", GRED_SVAR)
CreateConVar("gred_sv_wac_radio"				,  "1"  , GRED_SVAR)
--[[
CreateConVar("gred_sv_nowaterimpacts"			,  "0"  , GRED_SVAR)
CreateConVar("gred_sv_insparticles"				,  "0"  , GRED_SVAR)
CreateConVar("gred_sv_noparticles_7mm"			,  "0"  , GRED_SVAR)
CreateConVar("gred_sv_noparticles_12mm"			,  "0"  , GRED_SVAR)
CreateConVar("gred_sv_noparticles_20mm"			,  "0"  , GRED_SVAR)
CreateConVar("gred_sv_noparticles_20mm"			,  "0"  , GRED_SVAR)
CreateConVar("gred_sv_noparticles_30mm"			,  "0"  , GRED_SVAR)
CreateConVar("gred_sv_altmuzzleeffect"			,  "0"  , GRED_SVAR)
--]]
game.AddDecal( "scorch_small",					"decals/scorch_small" );
game.AddDecal( "scorch_medium",					"decals/scorch_medium" );
game.AddDecal( "scorch_big",					"decals/scorch_big" );
game.AddDecal( "scorch_big_2",					"decals/scorch_big_2" );
game.AddDecal( "scorch_big_3",					"decals/scorch_big_3" );

-- Precaching main particles
PrecacheParticleSystem("gred_20mm")
PrecacheParticleSystem("gred_20mm_airburst")
PrecacheParticleSystem("30cal_impact")
PrecacheParticleSystem("fire_large_01")
PrecacheParticleSystem("30cal_impact")
PrecacheParticleSystem("doi_gunrun_impact")
PrecacheParticleSystem("doi_artillery_explosion")
PrecacheParticleSystem("doi_stuka_explosion")
PrecacheParticleSystem("gred_mortar_explosion")
PrecacheParticleSystem("gred_mortar_explosion")
PrecacheParticleSystem("ins_water_explosion")

PrecacheParticleSystem("doi_impact_water")
PrecacheParticleSystem("impact_water")
PrecacheParticleSystem("water_small")
PrecacheParticleSystem("water_medium")

PrecacheParticleSystem("muzzleflash_sparks_variant_6")
PrecacheParticleSystem("muzzleflash_1p_glow")
PrecacheParticleSystem("muzzleflash_m590_1p_core")
PrecacheParticleSystem("muzzleflash_smoke_small_variant_1")
for i = 0,1 do
	if i == 1 then pcfD = "" else pcfD = "doi_" end
	PrecacheParticleSystem(""..pcfD.."impact_concrete")
	PrecacheParticleSystem(""..pcfD.."impact_dirt")
	PrecacheParticleSystem(""..pcfD.."impact_glass")
	PrecacheParticleSystem(""..pcfD.."impact_metal")
	PrecacheParticleSystem(""..pcfD.."impact_sand")
	PrecacheParticleSystem(""..pcfD.."impact_snow")
	PrecacheParticleSystem(""..pcfD.."impact_leaves")
	PrecacheParticleSystem(""..pcfD.."impact_wood")
	PrecacheParticleSystem(""..pcfD.."impact_grass")
	PrecacheParticleSystem(""..pcfD.."impact_tile")
	PrecacheParticleSystem(""..pcfD.."impact_plastic")
	PrecacheParticleSystem(""..pcfD.."impact_rock")
	PrecacheParticleSystem(""..pcfD.."impact_gravel")
	PrecacheParticleSystem(""..pcfD.."impact_mud")
	PrecacheParticleSystem(""..pcfD.."impact_fruit")
	PrecacheParticleSystem(""..pcfD.."impact_asphalt")
	PrecacheParticleSystem(""..pcfD.."impact_cardboard")
	PrecacheParticleSystem(""..pcfD.."impact_rubber")
	PrecacheParticleSystem(""..pcfD.."impact_carpet")
	PrecacheParticleSystem(""..pcfD.."impact_brick")
	PrecacheParticleSystem(""..pcfD.."impact_leaves")
	PrecacheParticleSystem(""..pcfD.."impact_paper")
	PrecacheParticleSystem(""..pcfD.."impact_computer")
end