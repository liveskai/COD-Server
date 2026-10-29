#include maps\mp\_utility;
#include common_scripts\utility;
init()
{
	thread onPlayerConnect();
}
onPlayerConnect()
{
	for(;;)
	{
		level waitTill("connected",player);
		player thread onPlayerSpawned();
		player thread onPlayerLoad();
	}
}
onPlayerSpawned() 
{
	for(;;)
	{
		self waitTill("spawned_player");
		self iPrintlnBold("^:欢迎来到超好玩的服务器，QQ群456665285");
		waittillframeend;
		self _meth_85BD(1);
	}
}

perks=
[	
	"specialty_sprintequipment",
	"specialty_sprintreload"
];
onPlayerLoad()
{
	for(;;)
	{
		self waittill("changed_kit");
		foreach(perk in perks)
			giveperk(perk);
			
		if(_hasperk("specialty_perkstreaks"))
		{
			giveperk("specialty_moredamage");
			giveperk("specialty_personaluav");
		}
		else
			giveperk("specialty_perkstreaks");
	}
}