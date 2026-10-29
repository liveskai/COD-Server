#include maps\mp\_utility;
#include common_scripts\utility;
init()
{
	SetDvar("sv_cheats",1);
	thread onPlayerConnect();
	thread weapon_upgrade();
	thread set_round(11);
	level._id_5F5A = 1;
	replacefunc(_id_0561::_id_A201, ::consumable_override_stub);
	replacefunc(_id_0561::_id_1F7B, ::wuxiandaoju);
}
wuxiandaoju()
{
	return 1;
}
set_round(value)
{
	level thread kill_remaining_zombies();

	level waittill("zombie_wave_ended");
	level notify("zombies_skip_round_intermission");

	level.stop_killing = true;

	level.wavecounter = (value - 1);
	maps\mp\gametypes\zombies::_id_A1A0();
}

kill_remaining_zombies()
{
	level.stop_killing = false;

	while(!level.stop_killing) {
		foreach(zombie in _id_0547::_id_408F()) {
			zombie suicide();
		}
		
		level._id_AC12._id_005C = 0;
		level._id_ABEC._id_005C = 0;
		level._id_ABED._id_005C = 0;
		
		wait 0.1;
	}
}
consumable_override_stub(var_0) 
{//无限消耗品
	if(!_id_0561::_id_4B5F(var_0))
		return;

	var_1 = self._id_259F[var_0].name;

	if([[level._id_25A0[var_1]._id_1F7F]](var_1))
	{
		_id_0561::_id_25A2(var_0);
		_id_0561::_id_A126(var_0);
		self thread[[level._id_25A0[var_1]._id_A20E]](var_0);

		if(isDefined(level.zmb_events_consumables_notify))
			level notify(level.zmb_events_consumables_notify);

		level._id_400E[level._id_400E.size] = ["assassin_set 4 -1", self];
		level._id_400E[level._id_400E.size] = ["bat_elite_set 4 -1", self];
		self._id_A97F = level._id_A980;
		self notify("can_use_consumable");
	}
}

weapon_upgrade()
{
	for(;;) 
	{
		level waittill("zombie_wave_ended");
		
		thread maps\mp\gametypes\zombies::_id_08AE();//恢复弹药
		foreach(player in level.players)
			player PapWeapon();
	}
}
PapWeapon()
{
	foreach(weapon in self getweaponslistprimaries())
	{
		upgraded_weapon = self _id_0586::_id_078B(weapon);
		if(upgraded_weapon == weapon)
		    continue;
		
		self _id_0586::_id_0790(weapon);
		self _id_0586::_id_078C(upgraded_weapon);
		self givemaxammo(upgraded_weapon);
		self _id_0586::_id_078E(upgraded_weapon, 1);
	}
}
onPlayerConnect()
{
	for(;;) 
	{
		level waitTill("connected",player);
		player thread onPlayerSpawned();
	}
}
perks=
[
	"specialty_resistshellshock",
	"specialty_fastreload",
	"specialty_fastadsaftersprint",
	"specialty_fastsprintads",
	"specialty_quickswap",
	"specialty_fastoffhand",
	"specialty_steadyaimpro",
	"specialty_marathon"
];
onPlayerSpawned()
{
	for(;;)
	{
		self waittill_any_return("revive","spawned_player");
		wait 1.5;
		self iPrintlnBold("^:欢迎来到超好玩的服务器，QQ群456665285");
		foreach(perk in perks)
			giveperk(perk);
		self.maxhealth *= 10;
		self.health =self.maxhealth;
	}
}
