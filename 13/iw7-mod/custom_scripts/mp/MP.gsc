#include scripts\mp\utility;

init() {
	thread onPlayerConnect();
}
perks =
[
	"specialty_expanded_minimap",
	"specialty_blindeye",
	"specialty_blastshield",
	"specialty_dexterity",
	"specialty_ghost",
	"specialty_overclock",
	"specialty_stun_resistance",
	"specialty_hardline",
	"specialty_momentum",
	"specialty_tracker",
	"specialty_coldblooded",
	"specialty_scavenger",
	"specialty_sprintfire",
	"specialty_bullet_outline",
	"specialty_empimmune",
	"specialty_marksman",
	"specialty_engineer",
	"specialty_quieter"
];
onPlayerConnect() 
{
	for(;;) 
	{
		level waitTill("connected",player);
		player thread onplayerkilled();
		player thread onPlayerSpawned();
		player thread onPlayerChangeKit();
	}
}
onPlayerSpawned() 
{
	self endOn("disconnect");
	for(;;)
	{
		self waitTill("spawned_player");
		self iPrintlnBold("^:欢迎来到超好玩的服务器,QQ群456665285");
		if(self.pers["deaths"]>3)
			return;
	}
}
onPlayerChangeKit()
{
	traits["archetype_assassin"]=["specialty_superpack","specialty_sixth_sense","specialty_ftlslide"];
	traits["archetype_assault"]=["specialty_boom","specialty_scavenger_eqp"];
	traits["archetype_engineer"]=["specialty_equipment_ping","specialty_personal_trophy","specialty_rugged_eqp"];
	traits["archetype_heavy"]=["specialty_regenfaster","specialty_man_at_arms","specialty_ground_pound"];
	traits["archetype_scout"]=["specialty_rush","specialty_afterburner","specialty_dodge"];
	traits["archetype_sniper"]=["specialty_mark_targets","specialty_rearguard","specialty_ads_awareness"];
	for(;;)
	{
		self waittill("changed_kit");
		foreach(trait in traits[self.loadoutarchetype])
			giveperk(trait);
	}
}
onplayerkilled()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("killed_enemy");
		if(self.pers["cur_kill_streak"]==25)
		{
			scripts\mp\killstreaks\killstreaks::awardkillstreak("nuke", self);
			self scripts\mp\hud_message::showkillstreaksplash("nuke");
			return;
		}
		else if(self.pers["cur_kill_streak"] > 20 )
			self thread scripts\mp\hud_message::showsplash("nuke_kill", (25 - self.pers["cur_kill_streak"]));
			
		if(self.pers["cur_kill_streak"]>8)
			continue;
		newperks = [];
		foreach(perk in perks)
		{
			if(!_hasperk(perk))
				newperks[newperks.size] = perk;
		}
		if(self.pers["cur_kill_streak"]==8)
			foreach(newperk in newperks)
				self giveperk(newperk);
		else if (newperks.size > 0)
		{
		    newperk = newperks[randomInt(newperks.size)];
		    self giveperk(newperk);
		}
	}
}