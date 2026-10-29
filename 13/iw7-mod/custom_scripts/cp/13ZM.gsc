init()
{
	level.pap_max=3;
	thread weapon_upgrade();
	thread onPlayerConnect();
	// thread Game_end();
	SetDvar("director_cut",1);
	SetDvar("sv_cheats",1);
	level.currentwave=11;
	replacefunc(scripts\cp\zombies\zombies_perk_machines::give_tough_perk, ::health);
}
weapon_upgrade()
{
	for(;;)
	{
		level waittill("spawn_wave_done");
		[[level.upgrade_weapons_func]]();
		scripts\cp\loot::give_ammo();
	}
}
health()
{
  level notify("tough_purchased", self);
  self.perk_data["health"].max_health = 1000;
  self.maxhealth = self.perk_data["health"].max_health;
  self.health = self.maxhealth;
  self notify("health_perk_upgrade");
}

Game_end()
{
	level waitTill("game_ended");
	wait 30;
	map_restart();
}
onPlayerConnect()
{
	for(;;) 
	{
		level waitTill("connected", player);
		player thread onPlayerSpawned();
		player thread PlayerText();
		player thread PlayerChat();
	}
}
PlayerText()
{
	texts=
	[
		"^:欢迎来到超好玩的服务器,QQ群456665285",
		"^:无限奔跑，喷气背包，1000血量",
		"^:服务器已启用控制台",
		"^:聊天框输入help查看帮助"
	];
	foreach(text in texts)
	{
		wait 10;
		self iPrintlnBold(text);
	}
}
PlayerChat()
{
	self.thermal=0;
	self.ammo99=0;
	self.toushi=0;
	for(;;)
	{
		self waittill("say", message);
		self CustomPlayer(tolower(message));
	}	
}
CustomPlayer(text)
{
	helptext="^:";
	helptexts=
	[
		"聊天框输入命令以下命令",
		"toushi 透视",
		"999 无限子弹",
		"re 热成像"
	];
	foreach(txt in helptexts)
		helptext+=txt+"\n";
	switch(text)
	{
		case "help":
			self iPrintlnBold(helptext);
			break;
		case "999":
			self thread infinite_ammo_loop();
			break;
		case "re":
			self PlayerGiveThermal();
			break;
		case "toushi":
			self thread toushizmobie();
	}
}
PlayerGiveThermal()
{
	if(self.thermal)
	{
		self thermalvisionoff();
		self.thermal=0;
		return;
	}
	self thermalvisionon();
	self.thermal=1;	
}
infinite_ammo_loop()
{
	self notify("infinite_ammo");
	if(self.ammo99)
	{
		self.ammo99=0;
		scripts\cp\utility::enable_infinite_ammo(0);
		return;
	}
	
	self.ammo99=1;
	self endon("infinite_ammo");
	scripts\cp\utility::enable_infinite_ammo(1);
	for(;;)
	{
		weapon = self getCurrentWeapon();
		self setWeaponAmmoClip(weapon, 999);
		self setWeaponAmmoClip(weapon, 999, "left");
		self setWeaponAmmoClip(weapon, 999, "right");
		self scripts\cp\powers\coop_powers::power_adjustcharges(9, "primary", 9);
		self scripts\cp\powers\coop_powers::power_adjustcharges(9, "secondary", 9);
		wait .2;
	}
}
toushizmobie()
{
	self notify("toushi");
	if(self.toushi)
	{
		self iPrintlnBold("^:关闭透视");
		self.toushi=0;
		return;
	}
	self iPrintlnBold("^:开启透视");
	self.toushi=1;
	self endon("toushi");
	foreach(zmobie in scripts\cp\cp_agent_utils::getAliveAgentsOfTeam("axis"))
		zmobie hudoutlineenableforclient(self, 1, 0, 0);
	for(;;)
	{
		level waittill("agent_spawned", zombie);
		self thread zmobietoushiforplayer(zombie);
	}
}
zmobietoushiforplayer(zombie)
{
	wait 1.5;
	zombie hudoutlineenableforclient(self, 1, 0, 0);
}
perks =
[
	"specialty_marathon",//无限奔跑
	"specialty_fastreload",//快速换弹
	"specialty_quickswap",//快切
	"specialty_sharp_focus",//稳定瞄准
	"specialty_bulletpenetration"//强化穿透
];
onPlayerSpawned()
{
	for(;;)
	{
		self scripts\engine\utility::waittill_any("revive","spawned_player");
		wait 1.5;
		self exo_movement();
		foreach(perk in perks)
			self scripts\cp\utility::giveperk(perk);
	}
}
exo_movement()
{
	self allowdoublejump(1);
	self allowwallrun(1);
	self allowdodge(1);
	self allowMantle(1);
	self.disabledMantle = 0;
}