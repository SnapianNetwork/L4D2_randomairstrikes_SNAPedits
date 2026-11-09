if ("ChCh_RandomAirStrikes" in this && this.ChCh_RandomAirStrikes != null && ("Cleanup" in this.ChCh_RandomAirStrikes)) {
	this.ChCh_RandomAirStrikes.Cleanup(true);
}

ChCh_RandomAirStrikes <- {
	LeavingTime = null
	StrikeTryNum = 0
	LastStrikeTime = null
	_disposed = false

	NextStrikeTime = 0
	NextCheckTime = 0
	RoundStartTime = 0

	LastCleanupTime = -1000.0

	SettingsFileName = "random_airstrikes/Settings.cfg"
	AltSettingsFileName = "random_airstrikes/settings.cfg"
	ActiveSettingsFileName = "random_airstrikes/Settings.cfg"
	LastSettingsRaw = null
	LastAppliedDelay = null
	MissingSettingsChecks = 0

	ActiveEntities = []
	NextEntityPruneTime = 0

		Settings = {
		// Allowed gamemodes and maps.
		allowed_gamemodes = ["coop", "realism"]
		disallowed_maps = ["c1m1_hotel", "c1m3_mall", "c1m4_atrium", "c5m4_quarter", "c8m2_subway", "c8m4_interior", "c10m2_drainage", "c11m4_terminal", "c12m5_cornfield"]

		// How often you want an airstrike to occur.
		one_in_what_chance = 20

		// (airstrike_behavior = 1 only) How far you want airstrikes to be.
		nav_percent_dist_variance = 5

		// Misc
		air_strike_delay = 75
		drop_bomb = 1
		summon_horde = 0
		explode_radius = 500
		explode_dmg = 200

		// 1 = Default (mean pairwise survivor distance +/- nav_percent_dist_variance percent)
		// 2 = ANY nav area
		// 3 = ANY common/special infected/Witch/Tank,
		// 4 = ANY common/special infected/Witch/Tank PLUS survivors
		airstrike_behavior = 1

		// 1 = Skip sky/ceiling scans for the chosen target (allows indoor airstrikes)
		ignore_interior = 0

		// Airstrike types
		airstrike_jet = 1
		airstrike_meteor = 1
		airstrike_car = 1
		airstrike_smart = 1
		// This can be annoying - off by default.
		airstrike_smart2 = 0
		airstrike_nuke = 1
		airstrike_napalm = 1
		airstrike_barrage = 1
		airstrike_clusterbomb = 1
		airstrike_nuke2 = 1
		airstrike_supplydrop = 1
		airstrike_supplydrop2 = 1
		airstrike_supplydrop3 = 1
		airstrike_supplydrop4 = 1
		airstrike_mysterymolotov = 1
		airstrike_artillerybarrage = 1
		airstrike_artillerybarrage2 = 1
		airstrike_boomer = 1

		// Airstrike type settings
		supplydrop2_min_items = 3
		supplydrop2_max_items = 6

		supplydrop4_crate_health = 150

		smart2_target_radius = 3000
		smart2_speed = 50000
		smart2_max_flight_time = 30

		napalm_line_length = 500
		napalm_fires_per_bomb = 1
		napalm_fire_spread = 150

		barrage_missile_count = 4

		clusterbomb_density = 3
		clusterbomb_spacing = 600

		mysterymolotov_drop_height = 4200
		mysterymolotov_fire_count = 2
		mysterymolotov_fire_spread = 220

		artillery_min_projectiles = 3
		artillery_max_projectiles = 5
		artillery_launch_distance = 5000
		artillery_launch_height = 5000
		artillery_spread_radius = 600
		artillery_shell_interval = 4

		artillery2_rounds = 3
		artillery2_shell_interval = 3
		artillery2_projectile_speed = 1100
		artillery2_launch_distance = 4000
		artillery2_launch_height = 1500
		artillery2_spread_radius = 600

		boomer_drop_height = 1200
	}

	DefaultSettings = null

	RockModels = [
		"models/props/cs_militia/militiarock01.mdl",
		"models/lostcoast/props_wasteland/rock_coast01a.mdl",
		"models/props_wasteland/rock_moss04.mdl"
	]

	SupplyDropItems = [
		"models/props_junk/wood_crate001a.mdl",
		"models/props_junk/wood_crate002a.mdl",
		"models/props_junk/gascan001a.mdl",
		"models/props_junk/propanecanister001a.mdl",
		"weapon_first_aid_kit",
		"weapon_upgradepack_explosive",
		"weapon_upgradepack_incendiary"
	]

	SupplyDrop4SmallCrateModel = "models/props_crates/supply_crate01.mdl"
	SupplyDrop4LongCrateModel = "models/props_crates/supply_crate02.mdl"

	SupplyDrop4CrateModels = [
		"models/props_crates/supply_crate01.mdl",
		"models/props_crates/supply_crate02.mdl"
	]

	SupplyDrop4SmallWeapons = [
		"weapon_pistol",
		"weapon_pistol_magnum"
	]

	SupplyDrop4SmallMeleeWeapons = [
		"crowbar",
		"frying_pan",
		"machete",
		"tonfa"
	]

	SupplyDrop4LongWeapons = [
		"weapon_rifle",
		"weapon_rifle_desert",
		"weapon_rifle_ak47",
		"weapon_rifle_sg552",
		"weapon_rifle_m60",
		"weapon_hunting_rifle",
		"weapon_sniper_military",
		"weapon_sniper_scout",
		"weapon_sniper_awp",
		"weapon_chainsaw"
	]

	SupplyDrop4LongMeleeWeapons = [
		"baseball_bat",
		"cricket_bat",
		"electric_guitar",
		"fireaxe",
		"golfclub",
		"guitar",
		"katana",
		"pitchfork",
		"shovel"
	]

	SupplyDrop4Weapons = [
		"weapon_pistol",
		"weapon_pistol_magnum",
		"weapon_rifle",
		"weapon_rifle_desert",
		"weapon_rifle_ak47",
		"weapon_rifle_sg552",
		"weapon_rifle_m60",
		"weapon_hunting_rifle",
		"weapon_sniper_military",
		"weapon_sniper_scout",
		"weapon_sniper_awp",
		"weapon_chainsaw"
	]

	SupplyDrop4MeleeWeapons = [
		"crowbar",
		"frying_pan",
		"machete",
		"tonfa",
		"baseball_bat",
		"cricket_bat",
		"electric_guitar",
		"fireaxe",
		"golfclub",
		"guitar",
		"katana",
		"pitchfork",
		"shovel"
	]

	ParticleEffects = [
		"fire_medium_02_nosmoke",
		"molotov_explosion",
		"fireworks_explosion_02",
		"gas_explosion_ground_fire",
		"gas_explosion_main",
		"fluidExplosion_frames",
		"explosion_silo",
		"weapon_grenadelauncher",
		"gas_explosion_chunks_02",
		"RPG_Smoke"
	]

	CarAmbientLoopSounds = [
		"ambient/fire/fire_big_loop1.wav",
		"ambient/fire/fire_med_loop1.wav",
		"ambient/fire/fire_small_loop2.wav",
		"vehicles/car_alarm/car_alarm_loop1.wav"
	]

	function CloneSettingsTable(src) {
		local copy = {}
		foreach(key, val in src) {
			if (type(val) == "array") {
				local arr = []
				for (local i = 0; i < val.len(); i++) {
					arr.push(val[i])
				}
				copy[key] <- arr
			} else {
				copy[key] <- val
			}
		}
		return copy
	}

	function ReadSettingsFile() {
		local content = FileToString(SettingsFileName)
		if (content != null) {
			ActiveSettingsFileName = SettingsFileName
			return content
		}
		content = FileToString(AltSettingsFileName)
		if (content != null) {
			ActiveSettingsFileName = AltSettingsFileName
			return content
		}
		return null
	}

	function StripUtf8Bom(text) {
		if (text != null && text.len() >= 3 && (text[0] & 0xFF) == 0xEF && (text[1] & 0xFF) == 0xBB && (text[2] & 0xFF) == 0xBF) {
			return text.slice(3)
		}
		return text
	}

	function SerializeSettings() {
		local sData = "{"
		foreach(key, val in Settings) {
			if (type(val) == "string") {
				val = "\"" + val + "\""
			} else if (type(val) == "array") {
				local newValue = "["
				for (local i = 0; i < val.len(); i++) {
					if (type(val[i]) == "string") {
						newValue += "\"" + val[i] + "\""
					} else {
						newValue += val[i].tostring()
					}
					if (i < val.len() - 1) {
						newValue += ", "
					}
				}
				newValue += "]"
				val = newValue
			}
			sData += "\n\t" + key + " = " + val
		}
		sData += "\n}"
		StringToFile(ActiveSettingsFileName, sData)
		return sData
	}

	function SanitizeSettings() {
		if (DefaultSettings == null) {
			DefaultSettings = CloneSettingsTable(Settings)
		}

		foreach(key, defVal in DefaultSettings) {
			if (!(key in Settings) || Settings[key] == null) {
				if (type(defVal) == "array") {
					local arr = []
					for (local i = 0; i < defVal.len(); i++) arr.push(defVal[i])
					Settings[key] <- arr
				} else {
					Settings[key] <- defVal
				}
				continue
			}

			local val = Settings[key]
			local defType = type(defVal)

			if (defType == "array") {
				if (type(val) != "array") {
					local arr = []
					for (local i = 0; i < defVal.len(); i++) arr.push(defVal[i])
					Settings[key] = arr
				}
			} else if (defType == "integer" || defType == "float") {
				if (type(val) == "bool") {
					val = val ? 1 : 0
				} else if (type(val) == "string") {
					try {
						val = (val.find(".") != null) ? val.tofloat() : val.tointeger()
					} catch (e) {
						val = defVal
					}
				} else if (type(val) != "integer" && type(val) != "float") {
					val = defVal
				}
				Settings[key] = val
			}
		}

		local behavior = Settings.airstrike_behavior
		if (type(behavior) != "integer" && type(behavior) != "float") {
			behavior = 1
		}
		behavior = behavior.tointeger()
		if (behavior < 1 || behavior > 4) behavior = 1
		Settings.airstrike_behavior = behavior

		Settings.ignore_interior = (Settings.ignore_interior == 1 || Settings.ignore_interior == true) ? 1 : 0

		if (Settings.one_in_what_chance < 1) Settings.one_in_what_chance = 1
		if (Settings.nav_percent_dist_variance < 0) Settings.nav_percent_dist_variance = 0
		if (Settings.air_strike_delay < 0) Settings.air_strike_delay = 0
		if (Settings.explode_radius < 0) Settings.explode_radius = 0
		if (Settings.explode_dmg < 0) Settings.explode_dmg = 0
		if (Settings.barrage_missile_count < 1) Settings.barrage_missile_count = 1
		if (Settings.barrage_missile_count > 50) Settings.barrage_missile_count = 50
		if (Settings.clusterbomb_density < 1) Settings.clusterbomb_density = 1
		if (Settings.clusterbomb_density > 8) Settings.clusterbomb_density = 8
		if (Settings.clusterbomb_spacing < 0) Settings.clusterbomb_spacing = 0
		if (Settings.napalm_fires_per_bomb < 0) Settings.napalm_fires_per_bomb = 0
		if (Settings.napalm_fires_per_bomb > 25) Settings.napalm_fires_per_bomb = 25
		if (Settings.napalm_line_length < 0) Settings.napalm_line_length = 0
		if (Settings.napalm_fire_spread < 0) Settings.napalm_fire_spread = 0
		if (Settings.supplydrop2_min_items < 1) Settings.supplydrop2_min_items = 1
		if (Settings.supplydrop2_min_items > 50) Settings.supplydrop2_min_items = 50
		if (Settings.supplydrop2_max_items < Settings.supplydrop2_min_items) {
			Settings.supplydrop2_max_items = Settings.supplydrop2_min_items
		}
		if (Settings.supplydrop2_max_items > 50) Settings.supplydrop2_max_items = 50
		if (Settings.supplydrop4_crate_health < 1) Settings.supplydrop4_crate_health = 1
		if (Settings.supplydrop4_crate_health > 5000) Settings.supplydrop4_crate_health = 5000
		if (Settings.smart2_target_radius < 500) Settings.smart2_target_radius = 500
		if (Settings.smart2_target_radius > 100000) Settings.smart2_target_radius = 100000
		if (Settings.smart2_speed < 60) Settings.smart2_speed = 60
		if (Settings.smart2_speed > 900) Settings.smart2_speed = 900
		if (Settings.smart2_max_flight_time < 5) Settings.smart2_max_flight_time = 5
		if (Settings.smart2_max_flight_time > 120) Settings.smart2_max_flight_time = 120

		if (Settings.mysterymolotov_drop_height < 300) Settings.mysterymolotov_drop_height = 300
		if (Settings.mysterymolotov_drop_height > 3000) Settings.mysterymolotov_drop_height = 3000
		if (Settings.mysterymolotov_fire_count < 1) Settings.mysterymolotov_fire_count = 1
		if (Settings.mysterymolotov_fire_count > 12) Settings.mysterymolotov_fire_count = 12
		if (Settings.mysterymolotov_fire_spread < 0) Settings.mysterymolotov_fire_spread = 0
		if (Settings.mysterymolotov_fire_spread > 600) Settings.mysterymolotov_fire_spread = 600

		Settings.artillery_min_projectiles = Settings.artillery_min_projectiles.tointeger()
		Settings.artillery_max_projectiles = Settings.artillery_max_projectiles.tointeger()
		if (Settings.artillery_min_projectiles < 3) Settings.artillery_min_projectiles = 3
		if (Settings.artillery_min_projectiles > 20) Settings.artillery_min_projectiles = 20
		if (Settings.artillery_max_projectiles < Settings.artillery_min_projectiles) {
			Settings.artillery_max_projectiles = Settings.artillery_min_projectiles
		}
		if (Settings.artillery_max_projectiles > 20) Settings.artillery_max_projectiles = 20
		if (Settings.artillery_launch_distance < 400) Settings.artillery_launch_distance = 400
		if (Settings.artillery_launch_distance > 4000) Settings.artillery_launch_distance = 4000
		if (Settings.artillery_launch_height < 150) Settings.artillery_launch_height = 150
		if (Settings.artillery_launch_height > 1500) Settings.artillery_launch_height = 1500
		if (Settings.artillery_spread_radius < 0) Settings.artillery_spread_radius = 0
		if (Settings.artillery_spread_radius > 1200) Settings.artillery_spread_radius = 1200
		if (Settings.artillery_shell_interval < 0.05) Settings.artillery_shell_interval = 0.05
		if (Settings.artillery_shell_interval > 2.0) Settings.artillery_shell_interval = 2.0

		Settings.artillery2_rounds = Settings.artillery2_rounds.tointeger()
		if (Settings.artillery2_rounds < 1) Settings.artillery2_rounds = 1
		if (Settings.artillery2_rounds > 20) Settings.artillery2_rounds = 20
		if (Settings.artillery2_shell_interval < 0.1) Settings.artillery2_shell_interval = 0.1
		if (Settings.artillery2_shell_interval > 30.0) Settings.artillery2_shell_interval = 30.0
		if (Settings.artillery2_projectile_speed < 100) Settings.artillery2_projectile_speed = 100
		if (Settings.artillery2_projectile_speed > 10000) Settings.artillery2_projectile_speed = 10000
		if (Settings.artillery2_launch_distance < 400) Settings.artillery2_launch_distance = 400
		if (Settings.artillery2_launch_distance > 10000) Settings.artillery2_launch_distance = 10000
		if (Settings.artillery2_launch_height < 150) Settings.artillery2_launch_height = 150
		if (Settings.artillery2_launch_height > 10000) Settings.artillery2_launch_height = 10000
		if (Settings.artillery2_spread_radius < 0) Settings.artillery2_spread_radius = 0
		if (Settings.artillery2_spread_radius > 3000) Settings.artillery2_spread_radius = 3000

		if (Settings.boomer_drop_height < 300) Settings.boomer_drop_height = 300
		if (Settings.boomer_drop_height > 4000) Settings.boomer_drop_height = 4000
	}

	function SyncCooldownWithDelay() {
		if (LastAppliedDelay == null) {
			LastAppliedDelay = Settings.air_strike_delay
			return
		}
		if (Settings.air_strike_delay != LastAppliedDelay) {
			LastAppliedDelay = Settings.air_strike_delay
			if (LastStrikeTime != null) {
				NextStrikeTime = LastStrikeTime + Settings.air_strike_delay
			} else if (NextStrikeTime > Time() + Settings.air_strike_delay) {
				NextStrikeTime = Time() + Settings.air_strike_delay
			}
		}
	}

	function ParseSettings(isAutoRefresh = false) {
		if (DefaultSettings == null) {
			DefaultSettings = CloneSettingsTable(Settings)
		}

		local file = ReadSettingsFile()

		if (file != null) {
			MissingSettingsChecks = 0
			local cleanText = StripUtf8Bom(file)

			try {
				local tData = compilestring("return (\n" + cleanText + "\n)")()
				if (type(tData) != "table") {
					throw "Settings root must be a table"
				}

				local updated = CloneSettingsTable(DefaultSettings)
				local hasMissingKey = false
				foreach(key, val in updated) {
					if (key in tData) {
						updated[key] = tData[key]
					} else {
						hasMissingKey = true
					}
				}

				Settings = updated
				SanitizeSettings()

				if (hasMissingKey && !isAutoRefresh) {
					LastSettingsRaw = SerializeSettings()
				} else {
					LastSettingsRaw = file
				}

				SyncCooldownWithDelay()

				if (isAutoRefresh) {
					printl("[Random Air Strikes] Reloaded updated settings from ems/" + ActiveSettingsFileName)
				}
			} catch (error) {
				if (isAutoRefresh) {

					LastSettingsRaw = file
					printl("[Random Air Strikes] Warning: Failed to parse ems/" + ActiveSettingsFileName + " (" + error + "); keeping active settings until fixed.")
				} else {
					LastSettingsRaw = SerializeSettings()
				}
			}
		} else {
			if (isAutoRefresh) {

				MissingSettingsChecks += 1
				if (MissingSettingsChecks < 2) {
					return
				}
				MissingSettingsChecks = 0
				Settings = CloneSettingsTable(DefaultSettings)
				SanitizeSettings()
				LastSettingsRaw = SerializeSettings()
				SyncCooldownWithDelay()
				printl("[Random Air Strikes] Settings file removed; restored defaults to ems/" + ActiveSettingsFileName)
			} else {
				SanitizeSettings()
				LastSettingsRaw = SerializeSettings()
				LastAppliedDelay = Settings.air_strike_delay
			}
		}
	}

	function RefreshSettingsIfChanged() {
		local file = ReadSettingsFile()
		if (file == LastSettingsRaw) {
			if (file != null) {
				MissingSettingsChecks = 0
			}

			SanitizeSettings()
			SyncCooldownWithDelay()
			return false
		}

		ParseSettings(true)
		return true
	}

	function IsRecentEntityCleanup(window = 2.0) {
		return (Time() - LastCleanupTime) < window
	}

	function RegisterTempEntity(ent) {
		if (ent != null && ent.IsValid()) {
			ActiveEntities.push(ent)
		}
		return ent
	}

	function PruneTempEntities() {
		local alive = []
		for (local i = 0; i < ActiveEntities.len(); i++) {
			local ent = ActiveEntities[i]
			if (ent != null && ent.IsValid()) {
				alive.push(ent)
			}
		}
		ActiveEntities = alive
	}

	function StopEntityFireSoundsLocal(ent) {
		if (ent == null || !ent.IsValid()) return
		foreach(snd in CarAmbientLoopSounds) {

			StopAmbientSoundOn(snd, ent)
			StopAmbientSoundOn(snd, ent)
			StopAmbientSoundOn(snd, ent)
			StopSoundOn(snd, ent)
		}
		StopSoundOn("General.BurningObject", ent)
	}

	function BroadcastStopCarSounds(ent) {
		if (ent == null || !ent.IsValid()) return

		local savedOrigin = ent.GetOrigin()
		StopEntityFireSoundsLocal(ent)

		if (!ent.IsPlayer() && ent.GetMoveParent() == null) {
			local visited = []
			local player = null
			while (player = Entities.FindByClassname(player, "player")) {
				if (!player.IsValid()) continue
				local pPos = player.EyePosition()
				local covered = false
				for (local k = 0; k < visited.len(); k++) {
					if ((visited[k] - pPos).LengthSqr() <= 65536.0) {
						covered = true
						break
					}
				}
				if (!covered) {
					visited.push(pPos)
					ent.SetOrigin(pPos)
					StopEntityFireSoundsLocal(ent)
				}
			}
			ent.SetOrigin(savedOrigin)
		}
	}

	function CancelExCarTimersForEntity(car, carIndex) {
		local timerTables = []
		if ("AddTimerss" in getroottable() && ::AddTimerss != null && ("TimersList" in ::AddTimerss) && type(::AddTimerss.TimersList) == "table") {
			timerTables.push(::AddTimerss.TimersList)
		}
		if ("VSLib" in getroottable() && ::VSLib != null && ("Timers" in ::VSLib) && ::VSLib.Timers != null && ("TimersList" in ::VSLib.Timers) && type(::VSLib.Timers.TimersList) == "table") {
			timerTables.push(::VSLib.Timers.TimersList)
		}

		foreach(list in timerTables) {
			local toDelete = []
			foreach(idx, entry in list) {
				if (type(entry) == "table" && ("_params" in entry) && type(entry._params) == "table") {
					local p = entry._params
					local match = false
					if (("CarID" in p) && p.CarID == carIndex) {
						match = true
					} else if (car != null && ("Victim" in p) && p.Victim == car) {
						match = true
					}
					if (match) {
						toDelete.push(idx)
					}
				}
			}
			for (local i = 0; i < toDelete.len(); i++) {
				if (toDelete[i] in list) {
					delete list[toDelete[i]]
				}
			}
		}
	}

	function CleanExCarAttachments(car, carIndex, lockSlot = false) {
		if ("ExCarYammy" in getroottable() && ::ExCarYammy != null) {
			if (lockSlot) {
				::ExCarYammy.NoFireSound[carIndex] <- 1::ExCarYammy.CarBOOM[carIndex] <- 1
			}
			if (("ParticleArgs" in ::ExCarYammy) && (carIndex in ::ExCarYammy.ParticleArgs)) {
				local part = ::ExCarYammy.ParticleArgs[carIndex]
				if (part != null && part.IsValid()) {
					StopEntityFireSoundsLocal(part)
					DoEntFire("!self", "ClearParent", "", 0.0, null, part)
					DoEntFire("!self", "Stop", "", 0.0, null, part)
					DoEntFire("!self", "Kill", "", 0.05, null, part)
				}::ExCarYammy.ParticleArgs[carIndex] <- null
			}
		}

		if (car != null && car.IsValid()) {
			DoEntFire("!self", "IgniteLifetime", "0", 0.0, null, car)

			local flame = null
			while (flame = Entities.FindByClassname(flame, "entityflame")) {
				if (flame.IsValid() && flame.GetMoveParent() == car) {
					StopEntityFireSoundsLocal(flame)
					DoEntFire("!self", "ClearParent", "", 0.0, null, flame)
					DoEntFire("!self", "Kill", "", 0.05, null, flame)
				}
			}

			local carName = car.GetName()
			if (carName != null && carName != "") {
				local named = null
				while (named = Entities.FindByName(named, carName)) {
					if (named.IsValid() && named != car) {
						StopEntityFireSoundsLocal(named)
						DoEntFire("!self", "ClearParent", "", 0.0, null, named)
						if (named.GetClassname() == "info_particle_system") {
							DoEntFire("!self", "Stop", "", 0.0, null, named)
						}
						DoEntFire("!self", "Kill", "", 0.05, null, named)
					}
				}
			}

			local nearProp = null
			while (nearProp = Entities.FindByClassnameWithin(nearProp, "prop_physics", car.GetOrigin(), 256.0)) {
				if (nearProp.IsValid() && nearProp != car && nearProp.GetMoveParent() == car) {
					StopEntityFireSoundsLocal(nearProp)
					DoEntFire("!self", "ClearParent", "", 0.0, null, nearProp)
					DoEntFire("!self", "Kill", "", 0.05, null, nearProp)
				}
			}
		}
	}

	function ResetExCarSlot(carIndex) {
		if (carIndex < 0) return
		if ("ExCarYammy" in getroottable() && ::ExCarYammy != null) {
			if ("CarArgs" in ::ExCarYammy)::ExCarYammy.CarArgs[carIndex] <- 0
			if ("LowWreck" in ::ExCarYammy)::ExCarYammy.LowWreck[carIndex] <- 0
			if ("MidWreck" in ::ExCarYammy)::ExCarYammy.MidWreck[carIndex] <- 0
			if ("HighWreck" in ::ExCarYammy)::ExCarYammy.HighWreck[carIndex] <- 0
			if ("CritWreck" in ::ExCarYammy)::ExCarYammy.CritWreck[carIndex] <- 0
			if ("CarBOOM" in ::ExCarYammy)::ExCarYammy.CarBOOM[carIndex] <- 0
			if ("AutoExArgs" in ::ExCarYammy)::ExCarYammy.AutoExArgs[carIndex] <- 0
			if ("NoFireSound" in ::ExCarYammy)::ExCarYammy.NoFireSound[carIndex] <- 0
			if ("ParticleArgs" in ::ExCarYammy)::ExCarYammy.ParticleArgs[carIndex] <- null
		}
	}

	function HideAndFreezeCarForDespawn(car) {
		if (car == null || !car.IsValid()) return
		car.__KeyValueFromInt("rendermode", 10)
		car.__KeyValueFromString("rendercolor", "0 0 0 0")
		car.__KeyValueFromInt("disableshadows", 1)
		car.__KeyValueFromInt("solid", 0)
		NetProps.SetPropInt(car, "m_MoveType", 0)
		NetProps.SetPropInt(car, "m_Glow.m_iGlowType", 0)
		NetProps.SetPropInt(car, "m_Glow.m_bFlashing", 0)
		if ("HasProp" in NetProps && NetProps.HasProp(car, "m_nSolidType")) {
			NetProps.SetPropInt(car, "m_nSolidType", 0)
		}
		DoEntFire("!self", "DisableMotion", "", 0.0, null, car)
		DoEntFire("!self", "DisableCollision", "", 0.0, null, car)
	}

	function KillTrackedEntities() {

		LastCleanupTime = Time()

		for (local i = 0; i < ActiveEntities.len(); i++) {
			local ent = ActiveEntities[i]
			if (ent != null && ent.IsValid()) {
				local entIdx = ent.GetEntityIndex()
				CancelExCarTimersForEntity(ent, entIdx)
				CleanExCarAttachments(ent, entIdx, true)
				BroadcastStopCarSounds(ent)
				ResetExCarSlot(entIdx)
				ent.Kill()
			}
		}
		ActiveEntities = []
	}

	function Cleanup(killEntities = true) {
		_disposed = true

		if ("g_MapScript" in getroottable() && g_MapScript != null) {
			if ("__ChCh_UpdateFunc" in g_MapScript && g_MapScript.__ChCh_UpdateFunc != null) {
				if ("ScriptedMode_RemoveUpdate" in g_MapScript) {
					g_MapScript.ScriptedMode_RemoveUpdate(g_MapScript.__ChCh_UpdateFunc)
				}
				g_MapScript.__ChCh_UpdateFunc = null
			}
		}

		if ("GameEventCallbacks" in getroottable() && type(::GameEventCallbacks) == "table") {
			foreach(eventName, listeners in ::GameEventCallbacks) {
				if (type(listeners) == "array") {
					for (local i = listeners.len() - 1; i >= 0; i--) {
						local target = listeners[i]
						if (type(target) == "weakref") {
							target = target.ref()
						}
						if (target == null || target == this || ("_disposed" in target && target._disposed)) {
							listeners.remove(i)
						}
					}
				}
			}
		}

		if (killEntities) {
			KillTrackedEntities()
		} else {
			ActiveEntities = []
		}
	}

	function GetOrInitNavCache() {
		local mapName = Director.GetMapName()
		if ("__ChCh_NavCache" in g_MapScript && g_MapScript.__ChCh_NavCache != null) {
			local existing = g_MapScript.__ChCh_NavCache
			if (existing.mapName == mapName && ("allNavs" in existing)) {
				return existing
			}
		}

		local rawTable = {}
		NavMesh.GetAllAreas(rawTable)

		local rawNavs = []
		foreach(nav in rawTable) {
			if (nav != null && nav.IsValid() && !nav.IsDegenerate()) {
				rawNavs.push(nav)
			}
		}

		local cache = {
			mapName = mapName,
			rawNavs = rawNavs,
			allNavs = [],
			hasValidFlow = false,
			cursor = 0,
			ready = (rawNavs.len() == 0)
		}
		g_MapScript.__ChCh_NavCache <- cache
		return cache
	}

	function ShouldScanSkyAboveTarget() {
		local value = Settings.ignore_interior
		if (value == 1 || value == true) return false
		return true
	}

	function HasSkyClearance(point, minClearance = 450.0) {
		if (!ShouldScanSkyAboveTarget()) return true
		local traceTable = {
			start = point + Vector(0, 0, 10),
			end = point + Vector(0, 0, 2000),
			hit = false,
			ignore = null,
			mask = 16395
		}
		if (TraceLine(traceTable) && traceTable.hit) {
			if ((traceTable.pos - point).Length() < minClearance) {
				return false
			}
		}
		return true
	}

	function GetSurfaceBelow(point, probeSteps = 6, stepHeight = 1000.0) {
		local probeStartZ = point.z + 50.0
		for (local i = 0; i < probeSteps; i++) {
			local probe = {
				start = Vector(point.x, point.y, probeStartZ),
				end = Vector(point.x, point.y, point.z - 4000.0),
				hit = false,
				ignore = null,
				mask = 16395
			}
			if (!TraceLine(probe) || !probe.hit) {
				return null
			}
			if (probe.pos.z > probeStartZ - 1.0) {

				probeStartZ += stepHeight
				continue
			}
			return probe.pos.z
		}
		return null
	}

	function ResolveAircraftSlotPos(basePos, slotPos, minClearance = 450.0) {
		local resolved = slotPos

		local surfaceZ = GetSurfaceBelow(slotPos)
		if (surfaceZ != null && resolved.z - surfaceZ < minClearance) {
			resolved = Vector(resolved.x, resolved.y, surfaceZ + minClearance)
		}

		if (ShouldScanSkyAboveTarget()) {
			local headRoom = {
				start = resolved,
				end = resolved + Vector(0, 0, minClearance),
				hit = false,
				ignore = null,
				mask = 16395
			}
			if (TraceLine(headRoom) && headRoom.hit) {
				return Vector(basePos.x, basePos.y, resolved.z)
			}
		}
		return resolved
	}

	function GetFlowPercentSafe(pos, useAlternate = false) {
		try {
			local flow = GetFlowPercentForPosition(pos, useAlternate)
			if (flow == null) return null
			flow = flow.tofloat()
			if (flow < 0.0) return null
			return flow
		} catch (error) {
			return null
		}
	}

	function StepNavCache(budget = 250) {
		local cache = GetOrInitNavCache()
		if (cache.ready) return cache

		if (Time() < RoundStartTime + 1.0 && GetLivingSurvivors().len() == 0) {
			return cache
		}

		local total = cache.rawNavs.len()
		local endIdx = cache.cursor + budget
		if (endIdx > total) endIdx = total

		while (cache.cursor < endIdx) {
			local nav = cache.rawNavs[cache.cursor]
			cache.cursor += 1

			if (nav == null || !nav.IsValid()) continue

			local center = nav.GetCenter()
			local flow = GetFlowPercentSafe(center, false)
			if (flow == null) flow = GetFlowPercentSafe(center, true)
			if (flow != null && flow > 1.0) cache.hasValidFlow = true
			if (flow == null) flow = 0.0

			cache.allNavs.push({
				nav = nav,
				center = center,
				flow = flow
			})
		}

		if (cache.cursor >= total) {
			cache.allNavs.sort(function(a, b) {
				if (a.flow < b.flow) return -1
				if (a.flow > b.flow) return 1
				return 0
			})
			cache.rawNavs = []
			cache.ready = true
		}

		return cache
	}

	function GetNavEntries() {
		local cache = GetOrInitNavCache()
		if (cache.ready) return cache.allNavs

		local entries = []
		foreach(nav in cache.rawNavs) {
			if (nav == null || !nav.IsValid()) continue
			entries.push({
				nav = nav,
				center = nav.GetCenter(),
				flow = null
			})
		}
		return entries
	}

	function GetNavFromEntry(entry) {
		if (entry == null) return null
		if (type(entry) == "table" && ("nav" in entry)) return entry.nav
		return entry
	}

	function GetNavCenter(entry) {
		if (entry == null) return null
		if (type(entry) == "table" && ("center" in entry) && entry.center != null) {
			return entry.center
		}
		local nav = GetNavFromEntry(entry)
		if (nav == null || !nav.IsValid()) return null
		return nav.GetCenter()
	}

	function PickRandomNavSpot(navs) {
		local count = navs.len()
		if (count == 0) return null

		local start = RandomInt(0, count - 1)
		for (local i = 0; i < count; i++) {
			local nav = GetNavFromEntry(navs[(start + i) % count])
			if (nav != null && nav.IsValid()) return nav.FindRandomSpot()
		}
		return null
	}

	function PickNearestNavSpot(navs, point) {
		local best = null
		local bestDistance = null
		foreach(entry in navs) {
			local nav = GetNavFromEntry(entry)
			if (nav == null || !nav.IsValid()) continue
			local center = GetNavCenter(entry)
			if (center == null) continue
			local distance = (center - point).Length()
			if (bestDistance == null || distance < bestDistance) {
				bestDistance = distance
				best = entry
			}
		}
		if (best == null) return null
		return PickRandomNavSpot([best])
	}

	function GetEntityTeam(ent) {
		try {
			local team = ent.GetTeam()
			if (team != null) {
				team = team.tointeger()
				if (team == 2 || team == 3) return team
			}
		} catch (error) {}
		try {
			local team = NetProps.GetPropInt(ent, "m_iTeamNum")
			if (team != null) return team.tointeger()
		} catch (error) {}
		return -1
	}

	function IsGhostPlayer(ent) {
		try {
			return ent.IsGhost() ? true : false
		} catch (error) {
			return false
		}
	}

	function CollectEntityTargets(includeSurvivors) {
		local candidates = []
		local infectedClasses = [
			"infected", "witch", "tank", "charger", "hunter",
			"smoker", "boomer", "jockey", "spitter"
		]

		foreach(cls in infectedClasses) {
			local ent = null
			while (ent = Entities.FindByClassname(ent, cls)) {
				if (ent != null && ent.IsValid() && ent.GetHealth() > 0) {
					candidates.push(ent)
				}
			}
		}

		local ent = null
		while (ent = Entities.FindByClassname(ent, "player")) {
			if (ent == null || !ent.IsValid()) continue
			if (ent.IsDead() || ent.IsDying()) continue
			if (ent.GetHealth() <= 0) continue

			if (ent.IsSurvivor()) {
				if (includeSurvivors) candidates.push(ent)
				continue
			}
			if (GetEntityTeam(ent) != 3 || IsGhostPlayer(ent)) continue
			candidates.push(ent)
		}

		return candidates
	}

	function GetSurvivorOrigins(survivors) {
		local origins = []
		foreach(survivor in survivors) {
			if (survivor != null && survivor.IsValid()) origins.push(survivor.GetOrigin())
		}
		return origins
	}

	function ComputeSurvivorCenter(origins) {
		local center = Vector(0, 0, 0)
		foreach(origin in origins) center += origin
		if (origins.len() > 0) center = center * (1.0 / origins.len())
		return center
	}

	function ComputeMeanPairwiseDistance(origins) {
		local totalDistance = 0.0
		local pairs = 0
		for (local i = 0; i < origins.len(); i++) {
			for (local j = i + 1; j < origins.len(); j++) {
				totalDistance += (origins[i] - origins[j]).Length()
				pairs++
			}
		}
		return (pairs > 0) ? (totalDistance / pairs) : 0.0
	}

	function PickDefaultNavSpot(navs, survivors) {
		local origins = GetSurvivorOrigins(survivors)
		if (origins.len() == 0 || navs.len() == 0) return null

		local center = ComputeSurvivorCenter(origins)
		local meanPairwise = ComputeMeanPairwiseDistance(origins)

		if (meanPairwise <= 0.0) return PickNearestNavSpot(navs, center)

		local variance = Settings.nav_percent_dist_variance
		if (variance < 0) variance = 0
		local halfBand = meanPairwise * variance / 100.0
		local minDistance = meanPairwise - halfBand
		if (minDistance < 0.0) minDistance = 0.0
		local maxDistance = meanPairwise + halfBand

		local candidates = []
		foreach(entry in navs) {
			local nav = GetNavFromEntry(entry)
			if (nav == null || !nav.IsValid()) continue
			local navCenter = GetNavCenter(entry)
			if (navCenter == null) continue
			local distance = (navCenter - center).Length()
			if (distance >= minDistance && distance <= maxDistance) candidates.push(entry)
		}
		if (candidates.len() > 0) return PickRandomNavSpot(candidates)

		local totalFlow = 0.0
		local flowCount = 0
		foreach(origin in origins) {
			local flow = GetFlowPercentSafe(origin, true)
			if (flow != null) {
				totalFlow += flow
				flowCount++
			}
		}
		if (flowCount == 0) return null

		local averageFlow = totalFlow / flowCount
		local minFlow = averageFlow - variance
		local maxFlow = averageFlow + variance
		local flowCandidates = []
		foreach(entry in navs) {
			local nav = GetNavFromEntry(entry)
			if (nav == null || !nav.IsValid()) continue
			local flow = null
			if (type(entry) == "table" && ("flow" in entry)) flow = entry.flow
			if (flow == null) {
				local navCenter = GetNavCenter(entry)
				if (navCenter != null) flow = GetFlowPercentSafe(navCenter, true)
			}
			if (flow == null) continue
			if (flow >= minFlow && flow <= maxFlow) flowCandidates.push(entry)
		}
		if (flowCandidates.len() > 0) return PickRandomNavSpot(flowCandidates)
		return null
	}

	function GetLivingSurvivors() {
		local survivors = []
		local player = null
		while (player = Entities.FindByClassname(player, "player")) {
			if (player.IsValid() && player.IsSurvivor() && !player.IsDead() && !player.IsDying()) {
				survivors.push(player)
			}
		}
		return survivors
	}

	function GetEnabledMethods() {
		local enabledModes = []
		if (Settings.airstrike_jet >= 1) enabledModes.push(1)
		if (Settings.airstrike_meteor >= 1) enabledModes.push(2)
		if (Settings.airstrike_car >= 1) enabledModes.push(3)
		if (Settings.airstrike_smart >= 1) enabledModes.push(4)
		if (Settings.airstrike_smart2 >= 1) enabledModes.push(13)
		if (Settings.airstrike_nuke >= 1) enabledModes.push(5)
		if (Settings.airstrike_napalm >= 1) enabledModes.push(6)
		if (Settings.airstrike_barrage >= 1) enabledModes.push(7)
		if (Settings.airstrike_clusterbomb >= 1) enabledModes.push(8)
		if (Settings.airstrike_nuke2 >= 1) enabledModes.push(9)
		if (Settings.airstrike_supplydrop >= 1) enabledModes.push(10)
		if (Settings.airstrike_supplydrop2 >= 1) enabledModes.push(11)
		if (Settings.airstrike_supplydrop4 >= 1) enabledModes.push(14)
		if (Settings.airstrike_mysterymolotov >= 1) enabledModes.push(15)
		if (Settings.airstrike_artillerybarrage >= 1) enabledModes.push(16)
		if (Settings.airstrike_artillerybarrage2 >= 1) enabledModes.push(17)
		if (Settings.airstrike_boomer >= 1) enabledModes.push(18)
		return enabledModes
	}

	function CanPickSupplyDrop3() {
		return (Settings.airstrike_supplydrop3 >= 1 && Settings.airstrike_supplydrop >= 1 && Settings.airstrike_supplydrop2 >= 1)
	}

	function PickAirStrikeMode() {
		local enabledModes = GetEnabledMethods()
		if (enabledModes.len() == 0) {
			return null
		}

		if (CanPickSupplyDrop3() && RandomInt(1, 100) == 1) {
			return 12
		}

		return enabledModes[RandomInt(0, enabledModes.len() - 1)]
	}

	function IfBeginAirStrike() {
		local selfRef = DirectorScript.ChCh_RandomAirStrikes
		if (selfRef._disposed) {
			return
		}

		selfRef.StepNavCache(250)

		local now = Time()
		if (now < selfRef.NextCheckTime) {
			return
		}
		selfRef.NextCheckTime = now + 1.0

		selfRef.RefreshSettingsIfChanged()

		if (now >= selfRef.NextEntityPruneTime) {
			selfRef.NextEntityPruneTime = now + 15.0
			selfRef.PruneTempEntities()
		}

		if (selfRef.Settings.allowed_gamemodes.find(Director.GetGameModeBase()) != null && selfRef.Settings.disallowed_maps.find(Director.GetMapName()) == null) {

			if (Director.HasAnySurvivorLeftSafeArea() && selfRef.LeavingTime == null) {
				selfRef.LeavingTime = now
			}

			if (Director.HasAnySurvivorLeftSafeArea() && !Director.IsFinaleWon() && !Director.IsPlayingIntro() && selfRef.LeavingTime != null) {
				if (now.tointeger() >= selfRef.LeavingTime.tointeger()) {
					if (now >= selfRef.NextStrikeTime) {
						if (RandomInt(1, selfRef.Settings.one_in_what_chance) == 1) {
							if (selfRef.GetEnabledMethods().len() > 0) {
								selfRef.DoAirStrike()
							}
						}
					}
				}
			}
		}
	}

	function GetNearToSurvsSpot() {
		local behavior = Settings.airstrike_behavior
		if (type(behavior) != "integer" && type(behavior) != "float") {
			behavior = 1
		} else {
			behavior = behavior.tointeger()
		}
		if (behavior < 1 || behavior > 4) behavior = 1

		if (behavior == 3 || behavior == 4) {
			local candidates = CollectEntityTargets(behavior == 4)
			if (candidates.len() == 0) return null
			local chosen = candidates[RandomInt(0, candidates.len() - 1)]
			return (chosen != null && chosen.IsValid()) ? chosen.GetOrigin() : null
		}

		local navs = GetNavEntries()
		if (navs.len() == 0) return null

		if (behavior == 2) return PickRandomNavSpot(navs)

		return PickDefaultNavSpot(navs, GetLivingSurvivors())
	}

	function GetHighestPointFromSomewhere(where) {

		return HasSkyClearance(where, 450.0) ? where : null
	}

	function AttachProjectileTrail(missile, effectName) {
		if (!missile || !missile.IsValid()) return null

		local resolvedEffect = effectName
		if (resolvedEffect == null || resolvedEffect == "") {
			resolvedEffect = "molotov_explosion"
		}
		if (resolvedEffect == "molotov_explosion") {

			return null
		}

		local trail = SpawnEntityFromTable("info_particle_system", {
			origin = missile.GetOrigin(),
			effect_name = resolvedEffect,
			start_active = 1,
			flag_as_weather = 0
		})
		if (trail && trail.IsValid()) {
			RegisterTempEntity(trail)
		}
		return trail
	}

	function UpdateProjectileTrail(trail, worldPos) {
		if (trail && trail.IsValid()) {
			trail.SetOrigin(worldPos)
		}
	}

	function SpawnMeteorTrailParticle(where) {
		local fx = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
			origin = where,
			angles = "0 0 0",
			effect_name = "molotov_explosion",
			start_active = 1,
			flag_as_weather = 0
		}))
		if (fx && fx.IsValid()) {
			DoEntFire("!self", "Stop", "", 0.8, null, fx)
			DoEntFire("!self", "Kill", "", 1.0, null, fx)
		}
		return fx
	}

	function SpawnProjectileTrailPuff(where, effectName = "RPG_Smoke", lifeTime = 1.4) {
		local fx = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
			origin = where,
			angles = "0 0 0",
			effect_name = effectName,
			start_active = 1,
			flag_as_weather = 0
		}))
		if (fx && fx.IsValid()) {
			DoEntFire("!self", "Stop", "", lifeTime, null, fx)
			DoEntFire("!self", "Kill", "", lifeTime + 0.5, null, fx)
		}
		return fx
	}

	function SpawnFireworksBurst(where) {
		local curTime = Time()
		local fxName = "airstrike_fw_fx_" + curTime.tostring() + "_" + RandomInt(0, 99999).tostring()
		local fx = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
			targetname = fxName,
			cpoint1 = fxName,
			origin = where,
			angles = "90 0 0",
			effect_name = "fireworks_explosion_02",
			start_active = 1,
			flag_as_weather = 0
		}))
		if (fx && fx.IsValid()) {

			NetProps.SetPropFloat(fx, "m_flStartTime", curTime - 1.95)
			DoEntFire("!self", "Stop", "", 4.5, null, fx)
			DoEntFire("!self", "Kill", "", 5.0, null, fx)
		}
		return fx
	}

	function CleanupProjectileEntities(missile, trail, finalPos = null) {
		if (trail && trail.IsValid()) {
			if (finalPos != null) {
				trail.SetOrigin(finalPos)
			} else if (missile && missile.IsValid()) {
				trail.SetOrigin(missile.GetOrigin())
			}
			DoEntFire("!self", "Stop", "", 0.0, null, trail)
			DoEntFire("!self", "Kill", "", 1.5, null, trail)
		}
		if (missile && missile.IsValid()) {
			missile.__KeyValueFromInt("rendermode", 10)
			DoEntFire("!self", "Kill", "", 0.05, null, missile)
		}
	}

	function PlayJetFlybySound() {
		local snd = "animation/jets/jet_by_0" + RandomInt(1, 2).tostring() + "_mono.wav"
		EmitAmbientSoundOn(snd, 1.0, 0, RandomInt(95, 105), Entities.First())
	}

	function ScheduleJetFlybySound(delay) {
		if (delay <= 0.0) {
			PlayJetFlybySound()
			return
		}
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = Vector(0, 0, 0)
		}))
		if (!timer || !timer.IsValid()) return

		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()
		scope.fireTime <- Time() + delay
		scope.JetSoundThink <- function() {
			local rem = fireTime - Time()
			if (rem > 0.01) return rem
			if ("ChCh_RandomAirStrikes" in DirectorScript && !DirectorScript.ChCh_RandomAirStrikes._disposed) {
				DirectorScript.ChCh_RandomAirStrikes.PlayJetFlybySound()
			}
			self.Kill()
			return null
		}
		AddThinkToEnt(timer, "JetSoundThink")
	}

	function CreateNapalmFire(where, attacker = null, extraDelay = 0.0) {
		local gascan = SpawnEntityFromTable("prop_physics", {
			targetname = "napalm_gascan_" + Time().tostring() + "_" + RandomInt(0, 99999),
			model = "models/props_junk/gascan001a.mdl",
			origin = where + Vector(0, 0, 5),
			angles = Vector(0, 0, 0),
			disableshadows = 1,
			spawnflags = 0
		})

		if (gascan && gascan.IsValid()) {
			RegisterTempEntity(gascan)
			gascan.ValidateScriptScope()
			gascan.__KeyValueFromInt("rendermode", 10)
			NetProps.SetPropInt(gascan, "m_MoveType", 0)
			NetProps.SetPropInt(gascan, "m_Glow.m_iGlowType", 3)
			NetProps.SetPropInt(gascan, "m_Glow.m_glowColorOverride", 1)

			local scope = gascan.GetScriptScope()
			scope.gasRef <- gascan
			scope.attackerRef <- attacker
			scope.detonateTime <- Time() + 0.15 + extraDelay

			scope.GascanDetonateThink <- function() {
				local rem = detonateTime - Time()
				if (rem > 0.01) {
					return rem
				}
				if (gasRef && gasRef.IsValid()) {
					local att = attackerRef
					if (!att || !att.IsValid()) {
						att = Entities.First()
					}
					gasRef.TakeDamage(999.9, 0, att)
				}
				return null
			}

			AddThinkToEnt(gascan, "GascanDetonateThink")
		}
	}

	function CreateNapalmFireCluster(centerPos, spreadRadius, fireCount, attacker = null) {
		for (local i = 0; i < fireCount; i++) {
			local offsetX = RandomFloat(-spreadRadius, spreadRadius)
			local offsetY = RandomFloat(-spreadRadius, spreadRadius)
			local firePos = centerPos + Vector(offsetX, offsetY, 0)

			local groundTrace = {
				start = firePos + Vector(0, 0, 50),
				end = firePos - Vector(0, 0, 200),
				hit = false,
				ignore = null
			}

			if (TraceLine(groundTrace) && groundTrace.hit) {
				firePos = groundTrace.pos + Vector(0, 0, 2)
			}

			CreateNapalmFire(firePos, attacker, i * 0.05)
		}
	}

	function GetAirstrikeThrower() {
		local survivors = GetLivingSurvivors()
		if (survivors.len() > 0) return survivors[RandomInt(0, survivors.len() - 1)]
		return Entities.First()
	}

	function HasInfernoNear(pos, radius) {
		local fire = null
		while (fire = Entities.FindByClassnameWithin(fire, "inferno", pos, radius)) {
			if (fire != null && fire.IsValid()) return true
		}
		return false
	}

	function SpawnMolotovProjectile(where, velocity) {
		local thrower = GetAirstrikeThrower()
		local molotov = SpawnEntityFromTable("molotov_projectile", {
			targetname = "airstrike_molotov_" + Time().tostring() + "_" + RandomInt(0, 99999).tostring(),
			origin = where,
			angles = Vector(RandomInt(0, 360), RandomInt(0, 360), RandomInt(0, 360)),
			model = "models/w_models/weapons/w_eq_molotov.mdl"
		})
		if (molotov == null || !molotov.IsValid()) return null

		try {
			molotov.SetModel("models/w_models/weapons/w_eq_molotov.mdl")
		} catch (error) {}
		try {
			NetProps.SetPropEntity(molotov, "m_hThrower", thrower)
		} catch (error) {}
		try {
			NetProps.SetPropEntity(molotov, "m_hOwnerEntity", thrower)
		} catch (error) {}
		try {
			NetProps.SetPropInt(molotov, "m_bIsLive", 1)
		} catch (error) {}
		try {
			NetProps.SetPropInt(molotov, "m_iTeamNum", 2)
		} catch (error) {}
		try {
			NetProps.SetPropFloat(molotov, "m_flElasticity", 0.0)
		} catch (error) {}
		try {
			molotov.__KeyValueFromString("gravity", "1.0")
		} catch (error) {}
		try {
			molotov.SetVelocity(velocity)
		} catch (error) {
			molotov.ApplyAbsVelocityImpulse(velocity)
		}
		return molotov
	}

	function SpawnMysteryMolotovBurst(where) {
		local burst = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
			origin = where,
			angles = "0 0 0",
			effect_name = "molotov_explosion",
			start_active = 1,
			flag_as_weather = 0
		}))
		if (burst && burst.IsValid()) {
			DoEntFire("!self", "Stop", "", 3.0, null, burst)
			DoEntFire("!self", "Kill", "", 3.5, null, burst)
		}

		local groundFire = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
			origin = where,
			effect_name = "gas_explosion_ground_fire",
			start_active = 1,
			flag_as_weather = 0
		}))
		if (groundFire && groundFire.IsValid()) {
			DoEntFire("!self", "Stop", "", 10.0, null, groundFire)
			DoEntFire("!self", "Kill", "", 10.5, null, groundFire)
		}

		local soundtarget = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = where
		}))
		if (soundtarget && soundtarget.IsValid()) {
			EmitAmbientSoundOn("weapons/molotov/molotov_detonate_3.wav", 1.0, 120, RandomInt(95, 105), soundtarget)
			EmitAmbientSoundOn("weapons/molotov/fire_ignite_2.wav", 0.8, 110, RandomInt(95, 105), soundtarget)
			DoEntFire("!self", "Kill", "", 12.0, null, soundtarget)
		}

		if (Settings.summon_horde >= 1) {
			EntFire("worldspawn", "RunScriptCode", "Director.ResetMobTimer()", RandomFloat(3, 4), null)
		}
	}

	function LaunchMysteryMolotov(startPos, endPos, delayTime) {
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		if (!timer || !timer.IsValid()) return

		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.startPos <- startPos
		scope.endPos <- endPos
		scope.spawnTime <- Time() + delayTime
		scope.spawned <- false
		scope.molotov <- null
		scope.lastPos <- startPos
		scope.nextTrailTime <- 0.0
		scope.deadline <- 0.0
		scope.burstDone <- false
		scope.checkTime <- 0.0

		scope.MysteryMolotovThink <- function() {
			local now = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes
			if (sys == null || sys._disposed) {
				self.Kill()
				return null
			}

			if (!spawned) {
				local rem = spawnTime - now
				if (rem > 0.01) return rem
				spawned = true

				local dropVelocity = Vector(RandomFloat(-45.0, 45.0), RandomFloat(-45.0, 45.0), -250.0)
				molotov = sys.RegisterTempEntity(sys.SpawnMolotovProjectile(startPos, dropVelocity))
				sys.SpawnMeteorTrailParticle(startPos)
				nextTrailTime = now + 0.1
				deadline = now + 8.0
				return 0.03
			}

			if (molotov != null && molotov.IsValid()) {
				lastPos = molotov.GetOrigin()
				if (now >= nextTrailTime) {
					sys.SpawnMeteorTrailParticle(lastPos)
					nextTrailTime = (now - nextTrailTime > 0.5) ? (now + 0.1) : (nextTrailTime + 0.1)
				}
				if (now >= deadline) {

					molotov.Kill()
					molotov = null
				}
				if (molotov != null) return 0.03
			}

			if (!burstDone) {
				burstDone = true
				local burstPos = ((lastPos - endPos).Length() > 400.0) ? endPos : lastPos
				sys.SpawnMysteryMolotovBurst(burstPos)
				checkTime = now + 0.35
				return 0.35
			}
			if (now < checkTime) return 0.1

			local needFallback = ((lastPos - endPos).Length() > 180.0) || !sys.HasInfernoNear(endPos, 250.0)
			if (needFallback) {
				sys.CreateNapalmFire(endPos, null, 0.0)
				sys.CreateNapalmFireCluster(
					endPos,
					sys.Settings.mysterymolotov_fire_spread.tofloat(),
					sys.Settings.mysterymolotov_fire_count.tointeger(),
					null
				)
			}

			self.Kill()
			return null
		}

		AddThinkToEnt(timer, "MysteryMolotovThink")
	}

	function ResolveArtilleryLaunchPos(targetPos, distance, height) {
		for (local attempt = 0; attempt < 8; attempt++) {
			local a = RandomFloat(0.0, 6.28318)
			local horiz = Vector(cos(a), sin(a), 0)
			local candidate = targetPos + (horiz * distance)

			local surfaceZ = GetSurfaceBelow(Vector(candidate.x, candidate.y, targetPos.z + height + 600.0))
			local z = targetPos.z + height
			if (surfaceZ != null && z < surfaceZ + 200.0) z = surfaceZ + 200.0

			local launchPos = Vector(candidate.x, candidate.y, z)
			if (HasSkyClearance(launchPos, 200.0)) return launchPos
		}

		return Vector(targetPos.x, targetPos.y, targetPos.z + height)
	}

	function LaunchArtilleryShell(startPos, endPos, timeToImpact, arcHeight) {
		local flightDuration = 1.2
		local waitTime = timeToImpact - flightDuration
		if (waitTime < 0) waitTime = 0
		if (flightDuration > timeToImpact) flightDuration = timeToImpact
		if (flightDuration <= 0.001) flightDuration = 0.05

		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		if (!timer || !timer.IsValid()) return

		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.startPos <- startPos
		scope.endPos <- endPos
		scope.spawnTime <- Time() + waitTime
		scope.flightDuration <- flightDuration
		scope.arcHeight <- arcHeight
		scope.shell <- null
		scope.trail <- null
		scope.spawned <- false

		scope.ArtilleryShellThink <- function() {
			local now = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes
			if (sys == null || sys._disposed) {
				self.Kill()
				return null
			}

			if (!spawned) {
				local rem = spawnTime - now
				if (rem > 0.01) return rem
				spawned = true

				shell = sys.RegisterTempEntity(SpawnEntityFromTable("prop_dynamic_override", {
					targetname = "airstrike_artillery_shell_" + now.tostring() + "_" + RandomInt(0, 99999).tostring(),
					origin = startPos,
					angles = "0 0 0",
					model = "models/w_models/weapons/w_HE_grenade.mdl",
					disableshadows = 1,
					solid = 0
				}))
				trail = sys.AttachProjectileTrail(shell, "RPG_Smoke")

				local muzzle = sys.RegisterTempEntity(SpawnEntityFromTable("info_target", {
					origin = startPos
				}))
				if (muzzle && muzzle.IsValid()) {
					EmitAmbientSoundOn("weapons/grenade_launcher/grenadefire/grenade_launcher_fire_1.wav", 0.45, 100, RandomInt(95, 110), muzzle)
					DoEntFire("!self", "Kill", "", 2.0, null, muzzle)
				}
				return 0.03
			}

			if (shell != null && shell.IsValid()) {
				local pct = (now - spawnTime) / flightDuration
				if (pct >= 1.0) {
					sys.NukeThePlace(endPos, "0 0 0", 16)
					sys.CleanupProjectileEntities(shell, trail, endPos)
					self.Kill()
					return null
				}

				local newPos = startPos + ((endPos - startPos) * pct)
				newPos = newPos + Vector(0, 0, arcHeight * 4.0 * pct * (1.0 - pct))
				shell.SetOrigin(newPos)
				sys.UpdateProjectileTrail(trail, newPos)

				local ang = shell.GetAngles()
				local p = ang.Pitch() + 12
				local y = ang.Yaw() + 9
				local r = ang.Roll() + 16
				shell.__KeyValueFromString("angles", p + " " + y + " " + r)
			} else if (now < spawnTime + flightDuration) {

				return 0.1
			} else {

				sys.CleanupProjectileEntities(null, trail, endPos)
				sys.NukeThePlace(endPos, "0 0 0", 16)
				self.Kill()
				return null
			}

			return 0.03
		}

		AddThinkToEnt(timer, "ArtilleryShellThink")
	}

	function LaunchArtilleryBarrage2Shell(startPos, endPos, spawnDelay, projectileSpeed, arcHeight) {
		if (spawnDelay < 0.0) spawnDelay = 0.0
		if (projectileSpeed < 100.0) projectileSpeed = 100.0

		local effectiveDist = (endPos - startPos).Length() + (arcHeight * 2.0)
		local flightDuration = effectiveDist / projectileSpeed
		if (flightDuration < 0.25) flightDuration = 0.25

		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		if (!timer || !timer.IsValid()) return

		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.startPos <- startPos
		scope.endPos <- endPos
		scope.spawnTime <- Time() + spawnDelay
		scope.flightDuration <- flightDuration
		scope.arcHeight <- arcHeight
		scope.shell <- null
		scope.trail <- null
		scope.nextTrailTime <- 0.0
		scope.spawned <- false

		scope.ArtilleryBarrage2ShellThink <- function() {
			local now = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes
			if (sys == null || sys._disposed) {
				if (trail && trail.IsValid()) DoEntFire("!self", "Kill", "", 0.0, null, trail)
				if (shell && shell.IsValid()) DoEntFire("!self", "Kill", "", 0.0, null, shell)
				self.Kill()
				return null
			}

			if (!spawned) {
				local rem = spawnTime - now
				if (rem > 0.01) return rem
				spawned = true

				shell = sys.RegisterTempEntity(SpawnEntityFromTable("prop_dynamic_override", {
					targetname = "airstrike_artillery2_shell_" + now.tostring() + "_" + RandomInt(0, 99999).tostring(),
					origin = startPos,
					angles = "0 0 0",
					model = "models/w_models/weapons/w_HE_grenade.mdl",
					disableshadows = 1,
					solid = 0
				}))

				sys.SpawnProjectileTrailPuff(startPos, "RPG_Smoke")
				nextTrailTime = now + 0.1

				local muzzle = sys.RegisterTempEntity(SpawnEntityFromTable("info_target", {
					origin = startPos
				}))
				if (muzzle && muzzle.IsValid()) {
					EmitAmbientSoundOn("weapons/grenade_launcher/grenadefire/grenade_launcher_fire_1.wav", 0.75, 130, RandomInt(78, 90), muzzle)
					DoEntFire("!self", "Kill", "", 2.5, null, muzzle)
				}
				return 0.03
			}

			if (shell != null && shell.IsValid()) {
				local pct = (now - spawnTime) / flightDuration
				if (pct >= 1.0) {
					sys.SpawnProjectileTrailPuff(endPos, "RPG_Smoke")
					sys.NukeThePlace(endPos, "0 0 0", 17)
					sys.CleanupProjectileEntities(shell, trail, endPos)
					self.Kill()
					return null
				}

				local newPos = startPos + ((endPos - startPos) * pct)
				newPos = newPos + Vector(0, 0, arcHeight * 4.0 * pct * (1.0 - pct))
				shell.SetOrigin(newPos)

				if (now >= nextTrailTime) {
					sys.SpawnProjectileTrailPuff(newPos, "RPG_Smoke")
					nextTrailTime = (now - nextTrailTime > 0.5) ? (now + 0.1) : (nextTrailTime + 0.1)
				}

				local ang = shell.GetAngles()
				local p = ang.Pitch() + 5
				local y = ang.Yaw() + 4
				local r = ang.Roll() + 6
				shell.__KeyValueFromString("angles", p + " " + y + " " + r)
			} else if (now < spawnTime + flightDuration) {
				return 0.1
			} else {
				sys.CleanupProjectileEntities(null, trail, endPos)
				sys.NukeThePlace(endPos, "0 0 0", 17)
				self.Kill()
				return null
			}

			return 0.03
		}

		AddThinkToEnt(timer, "ArtilleryBarrage2ShellThink")
	}

	function IsBoomerEntity(ent) {
		if (ent == null || !ent.IsValid()) return false
		local cls = ent.GetClassname()
		if (cls == "boomer") return true
		if (cls != "player") return false
		if (ent.IsSurvivor() || ent.IsDead()) return false
		try {
			return (NetProps.GetPropInt(ent, "m_zombieClass") == 2)
		} catch (error) {}
		return GetEntityTeam(ent) == 3
	}

	function FindNearestBoomer(pos, radius) {
		local best = null
		local bestDist = radius + 1.0

		local boomer = null
		while (boomer = Entities.FindByClassnameWithin(boomer, "boomer", pos, radius)) {
			if (!boomer.IsValid()) continue
			local dist = (boomer.GetOrigin() - pos).Length()
			if (dist < bestDist) {
				bestDist = dist
				best = boomer
			}
		}
		if (best != null) return best

		local player = null
		while (player = Entities.FindByClassnameWithin(player, "player", pos, radius)) {
			if (!IsBoomerEntity(player)) continue
			local dist = (player.GetOrigin() - pos).Length()
			if (dist < bestDist) {
				bestDist = dist
				best = player
			}
		}
		return best
	}

	function AcquireSkyBoomer(startPos, endPos) {
		local boomer = FindNearestBoomer(startPos, 800.0)
		if (boomer == null) {
			boomer = FindNearestBoomer(endPos, 800.0)
			if (boomer != null) {
				boomer.SetOrigin(startPos)
				boomer.SetVelocity(Vector(0, 0, -100))
			}
		}
		return boomer
	}

	function LaunchSkyBoomer(startPos, endPos, spawnDelay = 0.0) {
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		if (!timer || !timer.IsValid()) return

		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.startPos <- startPos
		scope.endPos <- endPos
		scope.spawnTime <- Time() + spawnDelay
		scope.boomer <- null
		scope.spawned <- false
		scope.searchUntil <- 0.0
		scope.deadline <- 0.0

		scope.SkyBoomerThink <- function() {
			local now = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes
			if (sys == null || sys._disposed) {
				if (boomer != null && boomer.IsValid()) boomer.Kill()
				self.Kill()
				return null
			}

			if (!spawned) {
				local rem = spawnTime - now
				if (rem > 0.01) return rem
				spawned = true
				searchUntil = now + 1.5
				deadline = now + 22.0

				if ("ZSpawn" in getroottable()) {
					ZSpawn({
						type = 2,
						pos = startPos,
						ang = QAngle(0, 0, 0)
					})
				}
				boomer = sys.AcquireSkyBoomer(startPos, endPos)
				if (boomer != null) sys.RegisterTempEntity(boomer)
				return 0.05
			}

			if (boomer == null) {
				if (now > searchUntil) {
					printl("[Random Air Strikes] Boomer drop failed: no boomer to drop.")
					self.Kill()
					return null
				}
				boomer = sys.AcquireSkyBoomer(startPos, endPos)
				if (boomer != null) sys.RegisterTempEntity(boomer)
				return 0.05
			}

			if (!boomer.IsValid() || boomer.GetHealth() <= 0) {

				self.Kill()
				return null
			}

			local origin = boomer.GetOrigin()
			local vel = boomer.GetVelocity()
			local landed = false

			local traceDown = {
				start = origin + Vector(0, 0, 6),
				end = origin - Vector(0, 0, 26),
				ignore = boomer,
				hit = false
			}
			if (TraceLine(traceDown) && traceDown.hit) landed = true

			if (!landed && (startPos.z - origin.z) > 50.0 && vel != null && vel.z > -20.0) {
				landed = true
			}

			if (landed) {

				boomer.Kill()
				self.Kill()
				return null
			}

			if (now >= deadline) {

				boomer.Kill()
				self.Kill()
				return null
			}

			return 0.03
		}

		AddThinkToEnt(timer, "SkyBoomerThink")
	}

	function SpawnClusterBombExplosion(centerPos, density, spacing) {
		if (density <= 0) return

		local soundtarget = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = centerPos
		}))
		if (soundtarget && soundtarget.IsValid()) {
			EmitAmbientSoundOn("ambient/explosions/explode_1.wav", 1.0, 140, RandomInt(90, 110), soundtarget)
			DoEntFire("!self", "Kill", "", 5.0, null, soundtarget)
		}

		local controller = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = centerPos
		}))
		if (!controller || !controller.IsValid()) return

		controller.ValidateScriptScope()
		local scope = controller.GetScriptScope()
		scope.centerPos <- centerPos
		scope.density <- density
		scope.spacing <- spacing
		scope.halfGrid <- (density - 1) / 2.0
		scope.totalCount <- density * density
		scope.currentIdx <- 0
		scope.pendingTanks <- []

		scope.ClusterRippleThink <- function() {
			local sys = DirectorScript.ChCh_RandomAirStrikes

			for (local k = pendingTanks.len() - 1; k >= 0; k--) {
				local entry = pendingTanks[k]
				local t = entry.ent
				if (t == null || !t.IsValid()) {
					pendingTanks.remove(k)
				} else if (entry.stage == 0) {
					entry.stage = 1
					t.TakeDamage(9999.0, 0, Entities.First())
				} else if (entry.stage == 1) {
					entry.stage = 2
					DoEntFire("!self", "Break", "", 0.0, t, t)
				} else {
					t.Kill()
					pendingTanks.remove(k)
				}
			}

			if (currentIdx < totalCount) {
				local i = currentIdx / density
				local j = currentIdx % density
				currentIdx += 1

				local offsetX = (i - halfGrid) * spacing
				local offsetY = (j - halfGrid) * spacing
				local tankPos = centerPos + Vector(offsetX, offsetY, 0)

				local groundTrace = {
					start = tankPos + Vector(0, 0, 100),
					end = tankPos - Vector(0, 0, 1000),
					hit = false,
					ignore = null
				}
				if (TraceLine(groundTrace) && ("startsolid" in groundTrace) && groundTrace.startsolid) {
					groundTrace = {
						start = tankPos + Vector(0, 0, 600),
						end = tankPos - Vector(0, 0, 1000),
						hit = false,
						ignore = null
					}
					TraceLine(groundTrace)
				}
				if (groundTrace.hit && !(("startsolid" in groundTrace) && groundTrace.startsolid)) {
					tankPos = groundTrace.pos + Vector(0, 0, 5)
				}

				local tank = SpawnEntityFromTable("prop_physics", {
					targetname = "clusterbomb_propane_" + Time().tostring() + "_" + currentIdx,
					model = "models/props_junk/propanecanister001a.mdl",
					origin = tankPos,
					angles = Vector(0, RandomInt(0, 360), 0),
					minhealthdmg = 0,
					disableshadows = 1,
					spawnflags = 0
				})

				if (tank && tank.IsValid()) {
					sys.RegisterTempEntity(tank)
					tank.__KeyValueFromInt("rendermode", 10)
					NetProps.SetPropInt(tank, "m_fEffects", 32)
					NetProps.SetPropInt(tank, "m_CollisionGroup", 1)
					NetProps.SetPropInt(tank, "m_MoveType", 0)
					NetProps.SetPropInt(tank, "m_Glow.m_iGlowType", 0)
					pendingTanks.push({
						ent = tank,
						stage = 0
					})
				}
			}

			if (currentIdx >= totalCount && pendingTanks.len() == 0) {
				self.Kill()
				return null
			}
			return 0.05
		}

		AddThinkToEnt(controller, "ClusterRippleThink")
	}

	function LaunchClusterBombProjectile(startPos, endPos, timeToImpact, explosionAngles, modelName, particleName) {
		local halfwayTime = timeToImpact / 2.0
		local halfwayPos = startPos + (endPos - startPos) * 0.5

		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.startPos <- startPos
		scope.endPos <- endPos
		scope.halfwayPos <- halfwayPos
		scope.targetPos <- endPos

		scope.spawnTime <- Time() + 3.0
		scope.halfwayTime <- halfwayTime
		scope.explosionAngles <- explosionAngles
		scope.mdlName <- modelName
		scope.partName <- (particleName != null && particleName != "") ? particleName : "molotov_explosion"
		scope.missile <- null
		scope.trail <- null
		scope.spawned <- false
		scope.hasDisappeared <- false
		scope.disappearTime <- 0.0
		scope.explosionTriggered <- false
		scope.nextMeteorTrailTime <- 0.0

		scope.ClusterBombThink <- function() {
			local curTime = Time()
			local rem = spawnTime - curTime
			if (rem > 0.01) {
				return rem
			}

			local sys = DirectorScript.ChCh_RandomAirStrikes
			local elapsed = curTime - spawnTime

			if (!spawned) {
				local missileName = "clusterbomb_proj_" + curTime.tostring() + "_" + RandomInt(0, 9999).tostring()
				missile = sys.RegisterTempEntity(SpawnEntityFromTable("prop_dynamic", {
					targetname = missileName,
					origin = startPos,
					angles = "90 0 0",
					model = mdlName,
					disableshadows = 1,
					solid = 0
				}))
				trail = sys.AttachProjectileTrail(missile, partName)
				if (partName == "molotov_explosion") {
					sys.SpawnMeteorTrailParticle(startPos)
					nextMeteorTrailTime = curTime + 0.1
				}
				spawned = true
				return 0.03
			}

			if (!hasDisappeared) {
				if (missile && missile.IsValid()) {
					local pct = elapsed / halfwayTime

					if (pct >= 1.0) {
						missile.SetOrigin(halfwayPos)
						local disappearPos = halfwayPos
						sys.SpawnFireworksBurst(disappearPos)

						local soundtarget = sys.RegisterTempEntity(SpawnEntityFromTable("info_target", {
							origin = disappearPos
						}))
						if (soundtarget && soundtarget.IsValid()) {
							EmitAmbientSoundOn("weapons/hegrenade/explode3.wav", 0.8, 100, RandomInt(120, 140), soundtarget)
							DoEntFire("!self", "Kill", "", 2.0, null, soundtarget)
						}

						sys.CleanupProjectileEntities(missile, trail, disappearPos)
						missile = null
						trail = null
						hasDisappeared = true
						disappearTime = curTime
						return 1.0
					}

					local moveVec = halfwayPos - startPos
					local newPos = startPos + (moveVec * pct)
					missile.SetOrigin(newPos)
					sys.UpdateProjectileTrail(trail, newPos)

					if (partName == "molotov_explosion") {
						if (curTime >= nextMeteorTrailTime) {
							sys.SpawnMeteorTrailParticle(newPos)
							nextMeteorTrailTime = (curTime - nextMeteorTrailTime > 0.5) ? (curTime + 0.1) : (nextMeteorTrailTime + 0.1)
						}
					}
				} else {
					sys.CleanupProjectileEntities(null, trail, halfwayPos)
					trail = null
					hasDisappeared = true
					disappearTime = curTime
					return 1.0
				}
			} else if (!explosionTriggered) {
				local waitCluster = 1.0 - (curTime - disappearTime)
				if (waitCluster > 0.01) {
					return waitCluster
				}
				local density = sys.Settings.clusterbomb_density
				local spacing = sys.Settings.clusterbomb_spacing
				sys.SpawnClusterBombExplosion(targetPos, density, spacing)
				explosionTriggered = true
				self.Kill()
				return null
			} else {
				self.Kill()
				return null
			}

			return 0.03
		}

		AddThinkToEnt(timer, "ClusterBombThink")
	}

	function LaunchCarDrop(spawnPos, delayTime) {
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = spawnPos
		}))
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.spawnPos <- spawnPos
		scope.spawnTime <- Time() + delayTime
		scope.spawned <- false
		scope.carRef <- null
		scope.carIndex <- -1
		scope.carScopeRef <- null
		scope.cleanupRequested <- false
		scope.tankSilenced <- false
		scope.extinguishHandled <- false
		scope.despawnStage <- 0
		scope.orphanStage <- 0
		scope.orphanNextTime <- 0.0
		scope.reclaimedEnt <- null

		scope.CarDropThink <- function() {
			local now = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes

			if (!spawned) {
				local rem = spawnTime - now
				if (rem > 0.01) {
					return rem
				}

				local car = SpawnEntityFromTable("prop_physics", {
					targetname = "airstrike_car_" + now.tostring() + "_" + RandomInt(0, 99999),
					origin = spawnPos,
					angles = Vector(RandomInt(0, 360), RandomInt(0, 360), RandomInt(0, 360)),
					model = "models/props_vehicles/cara_95sedan.mdl",
					disableshadows = 1
				})

				spawned = true

				if (!car || !car.IsValid()) {
					self.Kill()
					return null
				}

				sys.RegisterTempEntity(car)
				carRef = car
				carIndex = car.GetEntityIndex()

				sys.CancelExCarTimersForEntity(car, carIndex)
				sys.CleanExCarAttachments(null, carIndex, false)
				sys.ResetExCarSlot(carIndex)
				sys.BroadcastStopCarSounds(car)

				if ("ExCarYammy" in getroottable() && ::ExCarYammy != null) {
					local maxHP = ::ExCarYammy.maxcarhp::ExCarYammy.CarArgs[carIndex] <- maxHP * 0.95

					if ("ExCarYam" in getroottable() && ::ExCarYam != null && ("HitCar" in ::ExCarYam)) {
						::ExCarYam.HitCar({
							Victim = car,
							New_DamageDone = 1,
							Inflictor = car,
							Attacker = car
						})
					}
				}

				car.ValidateScriptScope()
				local carScope = car.GetScriptScope()
				carScopeRef = carScope
				carScope.carRef <- car
				carScope.cleanupTime <- now + 100.0
				local controllerScope = scope
				carScope.CleanupCar <- function() {
					controllerScope.cleanupRequested = true
				}

				return 0.25
			}

			if (orphanStage > 0) {
				local waitOrphan = orphanNextTime - now
				if (waitOrphan > 0.01) {
					return waitOrphan
				}

				if (orphanStage == 1) {
					local occ = EntIndexToHScript(carIndex)
					if (occ != null && occ.IsValid()) {
						sys.BroadcastStopCarSounds(occ)
					} else {
						local extras = []
						for (local s = 0; s < 32; s++) {
							local probe = SpawnEntityFromTable("info_target", {
								origin = spawnPos
							})
							if (probe == null || !probe.IsValid()) break
							if (probe.GetEntityIndex() == carIndex) {
								probe.__KeyValueFromInt("rendermode", 10)
								reclaimedEnt = sys.RegisterTempEntity(probe)
								break
							}
							extras.push(probe)
						}
						for (local k = 0; k < extras.len(); k++) {
							if (extras[k] != null && extras[k].IsValid()) extras[k].Kill()
						}
						if (reclaimedEnt != null && reclaimedEnt.IsValid()) {
							sys.BroadcastStopCarSounds(reclaimedEnt)
						}
					}
					orphanStage = 2
					orphanNextTime = now + 0.1
					return 0.1
				}

				if (reclaimedEnt != null && reclaimedEnt.IsValid()) {
					sys.BroadcastStopCarSounds(reclaimedEnt)
					reclaimedEnt.Kill()
					reclaimedEnt = null
				} else {
					local occ2 = EntIndexToHScript(carIndex)
					if (occ2 != null && occ2.IsValid()) {
						sys.BroadcastStopCarSounds(occ2)
					}
				}
				sys.ResetExCarSlot(carIndex)
				self.Kill()
				return null
			}

			if (despawnStage == 0) {
				if (carRef == null || !carRef.IsValid()) {
					sys.CancelExCarTimersForEntity(null, carIndex)
					sys.CleanExCarAttachments(null, carIndex, false)
					sys.ResetExCarSlot(carIndex)
					local occNow = EntIndexToHScript(carIndex)
					if (occNow != null && occNow.IsValid()) {
						sys.BroadcastStopCarSounds(occNow)
					}
					orphanStage = 1
					orphanNextTime = now + 1.05
					return 0.1
				}

				if ("ExCarYammy" in getroottable() && ::ExCarYammy != null) {
					if (!tankSilenced && ("NoFireSound" in ::ExCarYammy) && (carIndex in ::ExCarYammy.NoFireSound) && ::ExCarYammy.NoFireSound[carIndex] == 1) {
						tankSilenced = true
						sys.BroadcastStopCarSounds(carRef)
					}
					if (!extinguishHandled && ("CarBOOM" in ::ExCarYammy) && (carIndex in ::ExCarYammy.CarBOOM) && ::ExCarYammy.CarBOOM[carIndex] == 1) {
						local activePart = (("ParticleArgs" in ::ExCarYammy) && (carIndex in ::ExCarYammy.ParticleArgs)) ? ::ExCarYammy.ParticleArgs[carIndex] : null
						if (activePart == null || !activePart.IsValid()) {
							extinguishHandled = true
							DoEntFire("!self", "IgniteLifetime", "0", 0.0, null, carRef)
							sys.BroadcastStopCarSounds(carRef)
						}
					}
				}

				local cPos = carRef.GetOrigin()
				local outOfWorld = (cPos.z < -2500.0 || cPos.z > 14000.0 || cPos.x < -14000.0 || cPos.x > 14000.0 || cPos.y < -14000.0 || cPos.y > 14000.0)
				local dueTime = (carScopeRef != null && ("cleanupTime" in carScopeRef)) ? carScopeRef.cleanupTime : (spawnTime + 100.0)

				if (!cleanupRequested && !outOfWorld && now < dueTime) {
					return 0.25
				}

				despawnStage = 1
			}

			if (carRef == null || !carRef.IsValid()) {
				sys.CancelExCarTimersForEntity(null, carIndex)
				sys.CleanExCarAttachments(null, carIndex, false)
				sys.ResetExCarSlot(carIndex)
				self.Kill()
				return null
			}

			if (despawnStage == 1) {
				sys.CancelExCarTimersForEntity(carRef, carIndex)
				sys.CleanExCarAttachments(carRef, carIndex, true)
				sys.HideAndFreezeCarForDespawn(carRef)
				sys.BroadcastStopCarSounds(carRef)
				despawnStage = 2
				return 0.1
			}

			if (despawnStage == 2) {
				sys.CancelExCarTimersForEntity(carRef, carIndex)
				sys.BroadcastStopCarSounds(carRef)
				despawnStage = 3
				return 0.1
			}

			sys.BroadcastStopCarSounds(carRef)
			sys.ResetExCarSlot(carIndex)
			carRef.Kill()
			carRef = null
			self.Kill()
			return null
		}

		AddThinkToEnt(timer, "CarDropThink")
	}

	function LaunchSupplyDrop(spawnPos, delayTime) {
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = spawnPos
		}))
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.spawnPos <- spawnPos
		scope.spawnTime <- Time() + delayTime
		scope.spawned <- false

		scope.SupplyDropThink <- function() {
			local rem = spawnTime - Time()
			if (rem > 0.01) {
				return rem
			}

			if (!spawned) {
				local items = DirectorScript.ChCh_RandomAirStrikes.SupplyDropItems
				local item = items[RandomInt(0, items.len() - 1)]

				if (item.find(".mdl") != null) {
					SpawnEntityFromTable("prop_physics", {
						targetname = "airstrike_supply_" + Time().tostring(),
						origin = spawnPos,
						angles = Vector(RandomInt(0, 360), RandomInt(0, 360), RandomInt(0, 360)),
						model = item,
						disableshadows = 1
					})
				} else {
					SpawnEntityFromTable(item, {
						origin = spawnPos,
						angles = Vector(0, RandomInt(0, 360), 0)
					})
				}

				spawned = true
				self.Kill()
				return null
			}
			return null
		}

		AddThinkToEnt(timer, "SupplyDropThink")
	}

	function LaunchSupplyDrop4(spawnPos, delayTime) {
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = spawnPos
		}))
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.spawnPos <- spawnPos
		scope.spawnTime <- Time() + delayTime

		scope.SupplyCrateDropThink <- function() {
			local rem = spawnTime - Time()
			if (rem > 0.01) {
				return rem
			}
			DirectorScript.ChCh_RandomAirStrikes.SpawnSupplyDrop4Crate(spawnPos)
			self.Kill()
			return null
		}

		AddThinkToEnt(timer, "SupplyCrateDropThink")
	}

	function SpawnSupplyDrop4Crate(where, isSmall = null) {
		if (SupplyDrop4CrateModels.len() == 0) return null

		if (isSmall == null) {
			isSmall = (RandomInt(0, 1) == 0)
		} else if (type(isSmall) == "string") {
			isSmall = (isSmall.find("supply_crate01") != null)
		}

		local crateMdl = isSmall ? SupplyDrop4SmallCrateModel : SupplyDrop4LongCrateModel

		local crate = SpawnEntityFromTable("prop_physics", {
			targetname = "airstrike_supply4_" + Time().tostring() + "_" + RandomInt(0, 99999).tostring(),
			origin = where,
			angles = Vector(RandomInt(-10, 10), RandomInt(0, 360), RandomInt(-10, 10)),
			model = crateMdl,
			disableshadows = 1
		})
		if (crate == null || !crate.IsValid()) return null
		RegisterTempEntity(crate)

		local crateHealth = Settings.supplydrop4_crate_health
		if (crateHealth < 1) crateHealth = 1
		crate.SetMaxHealth(crateHealth)
		crate.SetHealth(crateHealth)

		local watcher = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = where
		}))
		if (watcher == null || !watcher.IsValid()) return crate

		watcher.ValidateScriptScope()
		local scope = watcher.GetScriptScope()
		scope.crateRef <- crate
		scope.crateMaxHealth <- crateHealth
		scope.isSmall <- isSmall
		scope.armed <- false
		scope.earliestArmTime <- Time() + 0.5
		scope.armDeadline <- Time() + 8.0
		scope.lastOrigin <- where

		scope.SupplyCrateWatchThink <- function() {
			local sys = DirectorScript.ChCh_RandomAirStrikes

			if (crateRef == null || !crateRef.IsValid()) {

				if (!sys.IsRecentEntityCleanup()) {
					sys.SpawnSupplyDrop4Weapon(lastOrigin + Vector(0, 0, 8), isSmall)
				}
				self.Kill()
				return null
			}

			lastOrigin = crateRef.GetOrigin()

			if (!armed) {

				local now = Time()
				local settled = (crateRef.GetVelocity().Length() < 40.0)
				if (now < earliestArmTime || (!settled && now < armDeadline)) {
					return 0.1
				}
				if (sys.MakeSupplyDrop4CrateBreakable(crateRef, crateMaxHealth)) {
					armed = true
				} else {

					self.Kill()
					return null
				}
				return 0.1
			}

			if (crateRef.GetHealth() <= 0) {
				sys.SpawnSupplyDrop4Weapon(lastOrigin + Vector(0, 0, 8), isSmall)
				self.Kill()
				return null
			}

			return 0.1
		}

		AddThinkToEnt(watcher, "SupplyCrateWatchThink")
		return crate
	}

	function MakeSupplyDrop4CrateBreakable(crate, health) {
		if (crate == null || !crate.IsValid()) return false
		if (health < 1) health = 1
		crate.SetMaxHealth(health)
		crate.SetHealth(health)
		try {
			NetProps.SetPropInt(crate, "m_takedamage", 2)
		} catch (error) {
			printl("[Random Air Strikes] Supply crate could not be made breakable: " + error)
			return false
		}
		return true
	}

	function SetRandomSupplyDropWeaponAmmo(weapon, classname) {
		if (weapon == null || !weapon.IsValid()) return

		local clipSize = 0
		local reserveSize = 0
		switch (classname) {
			case "weapon_pistol":
				clipSize = 15;
				reserveSize = 120;
				break
			case "weapon_pistol_magnum":
				clipSize = 8;
				reserveSize = 0;
				break
			case "weapon_rifle":
				clipSize = 50;
				reserveSize = 360;
				break
			case "weapon_rifle_desert":
				clipSize = 60;
				reserveSize = 360;
				break
			case "weapon_rifle_ak47":
				clipSize = 40;
				reserveSize = 360;
				break
			case "weapon_rifle_sg552":
				clipSize = 50;
				reserveSize = 360;
				break
			case "weapon_rifle_m60":
				clipSize = 150;
				reserveSize = 0;
				break
			case "weapon_hunting_rifle":
				clipSize = 15;
				reserveSize = 150;
				break
			case "weapon_sniper_military":
				clipSize = 30;
				reserveSize = 180;
				break
			case "weapon_sniper_scout":
				clipSize = 15;
				reserveSize = 90;
				break
			case "weapon_sniper_awp":
				clipSize = 20;
				reserveSize = 90;
				break
			case "weapon_chainsaw":
				clipSize = 20;
				reserveSize = 0;
				break
		}
		if (clipSize <= 0) return

		try {
			NetProps.SetPropInt(weapon, "m_iClip1", RandomInt(1, clipSize))
			if (reserveSize > 0) {
				NetProps.SetPropInt(weapon, "m_iExtraPrimaryAmmo", RandomInt(0, reserveSize))
			}
		} catch (error) {

		}
	}

	function SpawnSupplyDrop4Weapon(where, isSmall = null) {
		if (isSmall == null) {
			isSmall = (RandomInt(0, 1) == 0)
		} else if (type(isSmall) == "string") {
			isSmall = (isSmall.find("supply_crate01") != null)
		}

		local weaponList = isSmall ? SupplyDrop4SmallWeapons : SupplyDrop4LongWeapons
		local meleeList = isSmall ? SupplyDrop4SmallMeleeWeapons : SupplyDrop4LongMeleeWeapons

		if (weaponList.len() == 0) {
			weaponList = SupplyDrop4Weapons
		}
		if (meleeList.len() == 0) {
			meleeList = SupplyDrop4MeleeWeapons
		}
		if (weaponList.len() == 0) return null

		local pick = weaponList[RandomInt(0, weaponList.len() - 1)]
		local angles = Vector(0, RandomInt(0, 360), 0)

		if (pick == "melee") {
			if (meleeList.len() == 0) {
				pick = isSmall ? "weapon_pistol_magnum" : "weapon_rifle"
			} else {

				return SpawnEntityFromTable("weapon_melee", {
					origin = where,
					angles = angles,
					melee_weapon = meleeList[RandomInt(0, meleeList.len() - 1)]
				})
			}
		}

		local weapon = SpawnEntityFromTable(pick, {
			origin = where,
			angles = angles
		})
		SetRandomSupplyDropWeaponAmmo(weapon, pick)
		return weapon
	}

	function SpawnSupplyDrop3Explosion(where) {
		if (SupplyDropItems.len() == 0) return

		local selectedItem = SupplyDropItems[RandomInt(0, SupplyDropItems.len() - 1)]

		SpawnFireworksBurst(where)

		local fx2 = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
			origin = where,
			effect_name = "gas_explosion_chunks_02",
			start_active = 1,
			flag_as_weather = 0
		}))
		if (fx2 && fx2.IsValid()) {
			DoEntFire("!self", "Stop", "", 6.0, null, fx2)
			DoEntFire("!self", "Kill", "", 6.5, null, fx2)
		}

		local soundtarget = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = where
		}))
		if (soundtarget && soundtarget.IsValid()) {
			EmitAmbientSoundOn("weapons/hegrenade/explode3.wav", 1.0, 120, RandomInt(95, 110), soundtarget)
			local boomnum = RandomInt(1, 3).tostring()
			EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 0.85, 130, RandomInt(100, 115), soundtarget)
			DoEntFire("!self", "Kill", "", 5.0, null, soundtarget)
		}

		local targetCount = 100
		local activeEnts = 0
		local probe = null
		while (probe = Entities.Next(probe)) {
			activeEnts += 1
		}
		local maxSafeToSpawn = 2000 - activeEnts
		if (maxSafeToSpawn < 0) maxSafeToSpawn = 0
		if (targetCount > maxSafeToSpawn) targetCount = maxSafeToSpawn
		if (targetCount <= 0) return

		local controller = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = where
		}))
		if (!controller || !controller.IsValid()) return

		controller.ValidateScriptScope()
		local scope = controller.GetScriptScope()
		scope.centerPos <- where
		scope.baseOrigin <- where + Vector(0, 0, 24)
		scope.selectedItem <- selectedItem
		scope.isPropModel <- (selectedItem.find(".mdl") != null)
		scope.totalToSpawn <- targetCount
		scope.spawnedCount <- 0
		scope.batchSize <- 10

		scope.SupplyDrop3BurstThink <- function() {
			local curTime = Time()
			local endBatch = spawnedCount + batchSize
			if (endBatch > totalToSpawn) endBatch = totalToSpawn

			while (spawnedCount < endBatch) {
				local idx = spawnedCount
				spawnedCount += 1

				local angle = (idx * 2.39996) + RandomFloat(-0.2, 0.2)
				local dx = cos(angle)
				local dy = sin(angle)
				local spawnRadius = RandomFloat(20.0, 85.0)
				local spawnHeight = 20.0 + ((idx % 10) * 12.0)
				local spawnOrigin = centerPos + Vector(dx * spawnRadius, dy * spawnRadius, spawnHeight)

				local clearanceTrace = {
					start = baseOrigin,
					end = spawnOrigin,
					hit = false,
					ignore = null
				}
				if (TraceLine(clearanceTrace) && clearanceTrace.hit) {
					spawnOrigin = baseOrigin + ((clearanceTrace.pos - baseOrigin) * 0.65)
				}

				local itemEnt = null
				if (isPropModel) {
					itemEnt = SpawnEntityFromTable("prop_physics", {
						targetname = "airstrike_supply3_" + curTime.tostring() + "_" + idx,
						origin = spawnOrigin,
						angles = Vector(RandomInt(0, 360), RandomInt(0, 360), RandomInt(0, 360)),
						model = selectedItem,
						disableshadows = 1
					})
				} else {
					itemEnt = SpawnEntityFromTable(selectedItem, {
						origin = spawnOrigin,
						angles = Vector(0, RandomInt(0, 360), 0),
						disableshadows = 1
					})
				}

				if (itemEnt && itemEnt.IsValid()) {
					local horizSpeed = RandomFloat(90.0, 380.0)
					local upSpeed = RandomFloat(160.0, 360.0)
					itemEnt.ApplyAbsVelocityImpulse(Vector(dx * horizSpeed, dy * horizSpeed, upSpeed))
				}
			}

			if (spawnedCount >= totalToSpawn) {
				self.Kill()
				return null
			}
			return 0.03
		}

		AddThinkToEnt(controller, "SupplyDrop3BurstThink")
	}

	function LaunchSlowMissile(startPos, endPos, delayTime, flightDuration, strikeMode = 9, particleName = "molotov_explosion") {
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.startPos <- startPos
		scope.endPos <- endPos
		scope.spawnTime <- Time() + delayTime
		scope.flightDuration <- flightDuration
		scope.strikeMode <- strikeMode
		scope.partName <- (particleName != null && particleName != "") ? particleName : "molotov_explosion"
		scope.spawned <- false
		scope.missile <- null
		scope.trail <- null
		scope.nextMeteorTrailTime <- 0.0

		scope.SlowDropThink <- function() {
			local curTime = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes

			if (!spawned) {
				local rem = spawnTime - curTime
				if (rem > 0.01) {
					return rem
				}
				local missileName = "nuke2_missile_" + curTime.tostring() + "_" + RandomInt(0, 9999).tostring()
				missile = sys.RegisterTempEntity(SpawnEntityFromTable("prop_dynamic", {
					targetname = missileName,
					origin = startPos,
					angles = "90 0 0",
					model = "models/missiles/f18_agm65maverick.mdl",
					disableshadows = 1,
					solid = 0
				}))
				trail = sys.AttachProjectileTrail(missile, partName)
				if (strikeMode == 2 || partName == "molotov_explosion") {
					sys.SpawnMeteorTrailParticle(startPos)
					nextMeteorTrailTime = curTime + 0.1
				}
				spawned = true
				return 0.03
			}

			if (missile && missile.IsValid()) {
				local elapsedTime = curTime - spawnTime

				if (elapsedTime >= flightDuration) {
					if (strikeMode == 12) {
						sys.SpawnSupplyDrop3Explosion(endPos)
					} else {
						sys.NukeThePlace(endPos, "0 0 0", 9)
					}
					sys.CleanupProjectileEntities(missile, trail, endPos)
					self.Kill()
					return null
				}

				local pct = elapsedTime / flightDuration
				local newPos = startPos + ((endPos - startPos) * pct)
				missile.SetOrigin(newPos)
				sys.UpdateProjectileTrail(trail, newPos)

				if (strikeMode == 2 || partName == "molotov_explosion") {
					if (curTime >= nextMeteorTrailTime) {
						sys.SpawnMeteorTrailParticle(newPos)
						nextMeteorTrailTime = (curTime - nextMeteorTrailTime > 0.5) ? (curTime + 0.1) : (nextMeteorTrailTime + 0.1)
					}
				}
			} else {
				sys.CleanupProjectileEntities(null, trail)
				self.Kill()
				return null
			}

			return 0.03
		}
		AddThinkToEnt(timer, "SlowDropThink")
	}

	function LaunchProjectile(startPos, endPos, timeToImpact, explosionAngles, modelName, particleName, tumble, travelDuration = 0.25, strikeMode = 1) {
		local flightDuration = travelDuration
		local waitTime = timeToImpact - flightDuration
		if (waitTime < 0) {
			waitTime = 0
			flightDuration = timeToImpact
		}
		if (flightDuration <= 0.001) {
			flightDuration = 0.05
		}

		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.startPos <- startPos
		scope.endPos <- endPos
		scope.targetZ <- endPos.z
		scope.spawnTime <- Time() + waitTime
		scope.flightDuration <- flightDuration
		scope.explosionAngles <- explosionAngles
		scope.mdlName <- modelName
		scope.partName <- (particleName != null && particleName != "") ? particleName : "molotov_explosion"
		scope.shouldTumble <- tumble
		scope.missile <- null
		scope.trail <- null
		scope.spawned <- false
		scope.strikeMode <- strikeMode
		scope.nextMeteorTrailTime <- 0.0

		scope.MissileThink <- function() {
			local curTime = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes

			if (!spawned) {
				local rem = spawnTime - curTime
				if (rem > 0.01) {
					return rem
				}
				local missileName = "proj_" + curTime.tostring() + "_" + RandomInt(0, 9999).tostring()
				missile = sys.RegisterTempEntity(SpawnEntityFromTable("prop_dynamic_override", {
					targetname = missileName,
					origin = startPos,
					angles = "90 0 0",
					model = mdlName,
					disableshadows = 1,
					solid = 0
				}))
				if (!shouldTumble && strikeMode == 7 && missile && missile.IsValid()) {
					missile.SetForwardVector(endPos - startPos)
				}
				trail = sys.AttachProjectileTrail(missile, partName)
				if (strikeMode == 2 || partName == "molotov_explosion") {
					sys.SpawnMeteorTrailParticle(startPos)
					nextMeteorTrailTime = curTime + 0.1
				}
				spawned = true
				return 0.03
			}

			if (missile && missile.IsValid()) {
				local progressTime = curTime - spawnTime

				if (shouldTumble) {
					local ang = missile.GetAngles()
					local p = ang.Pitch() + 10
					local y = ang.Yaw() + 15
					local r = ang.Roll() + 5
					missile.__KeyValueFromString("angles", p + " " + y + " " + r)
				}

				if (progressTime >= flightDuration || missile.GetOrigin().z <= targetZ) {
					sys.NukeThePlace(endPos, explosionAngles, strikeMode)
					sys.CleanupProjectileEntities(missile, trail, endPos)
					self.Kill()
					return null
				}

				local pct = progressTime / flightDuration
				if (pct > 1.0) pct = 1.0

				local moveVec = endPos - startPos
				local newPos = startPos + (moveVec * pct)

				missile.SetOrigin(newPos)
				sys.UpdateProjectileTrail(trail, newPos)

				if (strikeMode == 2 || partName == "molotov_explosion") {
					if (curTime >= nextMeteorTrailTime) {
						sys.SpawnMeteorTrailParticle(newPos)
						nextMeteorTrailTime = (curTime - nextMeteorTrailTime > 0.5) ? (curTime + 0.1) : (nextMeteorTrailTime + 0.1)
					}
				}
			} else {
				sys.CleanupProjectileEntities(null, trail)
				self.Kill()
				return null
			}

			return 0.03
		}

		AddThinkToEnt(timer, "MissileThink")
	}

	function ResolveHomingExplosionPos(rawPos, safeFromPos, travelDir, ignoreEnt) {
		local backPos = rawPos - (travelDir * 16.0)
		local backTrace = {
			start = safeFromPos,
			end = backPos,
			hit = false,
			ignore = ignoreEnt,
			mask = 16395
		}
		if (TraceLine(backTrace) && backTrace.hit) {
			if (("startsolid" in backTrace) && backTrace.startsolid) {
				return rawPos
			}
			return backTrace.pos + (travelDir * 2.0)
		}
		return backPos
	}

	function LaunchHomingProjectile(startPos, initialTargetPos, spawnDelay, modelName, particleName, strikeMode = 4) {
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		local dir = initialTargetPos - startPos
		local len = dir.Length()
		if (len > 0.001) {
			dir = dir * (1.0 / len)
		} else {
			dir = Vector(0, 0, -1)
		}

		scope.startPos <- startPos
		scope.initialTargetPos <- initialTargetPos
		scope.currentPos <- startPos
		scope.spawnTime <- Time() + spawnDelay
		scope.mdlName <- modelName
		scope.partName <- (particleName != null && particleName != "") ? particleName : "molotov_explosion"
		scope.missile <- null
		scope.trail <- null
		scope.spawned <- false
		scope.clearedSpawnSolid <- false
		scope.strikeMode <- strikeMode
		scope.nextMeteorTrailTime <- 0.0

		scope.speed <- 35.0
		scope.turnRate <- 0.22
		scope.velocity <- dir
		scope.cachedTarget <- null
		scope.nextTargetScanTime <- 0.0

		scope.HomingThink <- function() {
			local curTime = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes

			if (!spawned) {
				local rem = spawnTime - curTime
				if (rem > 0.01) {
					return rem
				}
				local missileName = "homing_proj_" + curTime.tostring() + "_" + RandomInt(0, 9999).tostring()
				missile = sys.RegisterTempEntity(SpawnEntityFromTable("prop_dynamic_override", {
					targetname = missileName,
					origin = startPos,
					angles = "90 0 0",
					model = mdlName,
					disableshadows = 1,
					solid = 0
				}))
				if (missile && missile.IsValid()) {
					missile.SetForwardVector(velocity)
				}
				trail = sys.AttachProjectileTrail(missile, partName)
				if (strikeMode == 2 || partName == "molotov_explosion") {
					sys.SpawnMeteorTrailParticle(startPos)
					nextMeteorTrailTime = curTime + 0.1
				}
				spawned = true
				return 0.03
			}

			if (missile && missile.IsValid()) {
				local flightElapsed = curTime - spawnTime

				local needRescan = (curTime >= nextTargetScanTime) || (cachedTarget == null) || !cachedTarget.IsValid()
				if (!needRescan) {
					local cls = cachedTarget.GetClassname()
					if (cls == "player") {
						if (cachedTarget.IsDead() || cachedTarget.IsDying() || (!cachedTarget.IsSurvivor() && cachedTarget.IsGhost())) {
							needRescan = true
						}
					} else if (cachedTarget.GetHealth() <= 0) {
						needRescan = true
					}
				}

				if (needRescan) {
					nextTargetScanTime = curTime + 0.2
					cachedTarget = null

					local searchRadius = 1500.0
					local maxDistSq = searchRadius * searchRadius
					local bestVisDistSq = maxDistSq
					local bestVisTarget = null
					local bestAnyDistSq = maxDistSq
					local bestAnyTarget = null

					local classesToScan = ["infected", "witch", "player"]
					for (local c = 0; c < classesToScan.len(); c++) {
						local clsName = classesToScan[c]
						local ent = null
						while (ent = Entities.FindByClassnameWithin(ent, clsName, currentPos, searchRadius)) {
							if (!ent.IsValid()) continue
							if (clsName == "player") {
								if (ent.IsDead() || ent.IsDying() || (!ent.IsSurvivor() && ent.IsGhost())) continue
							} else if (ent.GetHealth() <= 0) {
								continue
							}

							local tOrigin = ent.GetOrigin() + Vector(0, 0, 36)
							local dSq = (tOrigin - currentPos).LengthSqr()
							if (dSq < bestAnyDistSq) {
								bestAnyDistSq = dSq
								bestAnyTarget = ent
							}
							if (dSq < bestVisDistSq) {
								local losTrace = {
									start = currentPos,
									end = tOrigin,
									hit = false,
									ignore = missile,
									mask = 16395
								}
								if (!TraceLine(losTrace) || !losTrace.hit) {
									bestVisDistSq = dSq
									bestVisTarget = ent
								}
							}
						}
					}

					cachedTarget = (bestVisTarget != null) ? bestVisTarget : bestAnyTarget
				}

				if (cachedTarget != null && cachedTarget.IsValid()) {
					local targetCenter = cachedTarget.GetOrigin() + Vector(0, 0, 36)
					local toTarget = targetCenter - currentPos
					local tLen = toTarget.Length()
					if (tLen > 0.001) {
						local targetDir = toTarget * (1.0 / tLen)

						local effTurn = turnRate + (flightElapsed * 0.10)
						if (tLen < 300.0 && effTurn < 0.55) {
							effTurn = 0.55
						}
						if (effTurn > 0.65) {
							effTurn = 0.65
						}
						velocity = velocity + (targetDir - velocity) * effTurn
					}
				} else {
					local fallbackVec = initialTargetPos - currentPos
					if (currentPos.z > initialTargetPos.z + 32.0 && fallbackVec.LengthSqr() > 2500.0) {
						local fLen = fallbackVec.Length()
						fallbackVec = fallbackVec * (1.0 / fLen)
						velocity = velocity + (fallbackVec - velocity) * 0.15
					} else {
						local diveDir = Vector(velocity.x * 0.25, velocity.y * 0.25, -1.0)
						local dLen = diveDir.Length()
						diveDir = diveDir * (1.0 / dLen)
						velocity = velocity + (diveDir - velocity) * 0.15
					}
				}

				local vLen = velocity.Length()
				if (vLen > 0.001) {
					velocity = velocity * (1.0 / vLen)
				}

				local step = velocity * speed
				local nextPos = currentPos + step

				local trace = {
					start = currentPos,
					end = nextPos,
					hit = false,
					ignore = missile,
					mask = 1174421515
				}

				local didHit = TraceLine(trace) && trace.hit
				local isStartSolid = didHit && ("startsolid" in trace) && trace.startsolid

				if (!clearedSpawnSolid) {
					if (!isStartSolid) {
						clearedSpawnSolid = true
					} else if (nextPos.z <= initialTargetPos.z + 24.0) {
						local fallbackDetonate = initialTargetPos + Vector(0, 0, 16)
						sys.NukeThePlace(fallbackDetonate, "0 0 0", strikeMode)
						sys.CleanupProjectileEntities(missile, trail, fallbackDetonate)
						self.Kill()
						return null
					} else {

						didHit = false
					}
				}

				if (didHit) {
					if (("enthit" in trace) && trace.enthit != null && trace.enthit.IsValid() && trace.enthit.GetClassname() == "infected") {
						trace.enthit.TakeDamage(sys.Settings.explode_dmg.tofloat(), 64, missile)
					}
					local detonatePos = sys.ResolveHomingExplosionPos(trace.pos, currentPos, velocity, missile)
					sys.NukeThePlace(detonatePos, "0 0 0", strikeMode)
					sys.CleanupProjectileEntities(missile, trail, detonatePos)
					self.Kill()
					return null
				}

				if (cachedTarget != null && cachedTarget.IsValid()) {
					local targetCenter = cachedTarget.GetOrigin() + Vector(0, 0, 36)
					local seg = nextPos - currentPos
					local segLenSq = seg.LengthSqr()
					local tProj = 0.0
					if (segLenSq > 0.0001) {
						tProj = (targetCenter - currentPos).Dot(seg) / segLenSq
						if (tProj < 0.0) tProj = 0.0
						if (tProj > 1.0) tProj = 1.0
					}
					local closestPt = currentPos + (seg * tProj)
					if ((targetCenter - closestPt).LengthSqr() <= 2304.0) {
						if (cachedTarget.GetClassname() == "infected") {
							cachedTarget.TakeDamage(sys.Settings.explode_dmg.tofloat(), 64, missile)
						}
						local detonatePos = sys.ResolveHomingExplosionPos(closestPt, currentPos, velocity, missile)
						sys.NukeThePlace(detonatePos, "0 0 0", strikeMode)
						sys.CleanupProjectileEntities(missile, trail, detonatePos)
						self.Kill()
						return null
					}
				}

				currentPos = nextPos
				missile.SetOrigin(currentPos)
				missile.SetForwardVector(velocity)
				sys.UpdateProjectileTrail(trail, currentPos)

				if (strikeMode == 2 || partName == "molotov_explosion") {
					if (curTime >= nextMeteorTrailTime) {
						sys.SpawnMeteorTrailParticle(currentPos)
						nextMeteorTrailTime = (curTime - nextMeteorTrailTime > 0.5) ? (curTime + 0.1) : (nextMeteorTrailTime + 0.1)
					}
				}

				if (flightElapsed >= 10.0) {
					if (currentPos.z >= -3000.0) {
						sys.NukeThePlace(currentPos, "0 0 0", strikeMode)
					}
					sys.CleanupProjectileEntities(missile, trail, currentPos)
					self.Kill()
					return null
				}
				if (currentPos.z < -3000.0) {
					sys.CleanupProjectileEntities(missile, trail, currentPos)
					self.Kill()
					return null
				}
			} else {
				sys.CleanupProjectileEntities(null, trail)
				self.Kill()
				return null
			}

			return 0.03
		}

		AddThinkToEnt(timer, "HomingThink")
	}

	function NormalizeVec(v) {
		if (v == null) return Vector(0, 0, 0)
		local len = v.Length()
		if (len > 0.0001) {
			return v * (1.0 / len)
		}
		return Vector(0, 0, 0)
	}

	function ProbeClearFraction(fromPos, dir, dist, ignoreEnt) {
		local probe = {
			start = fromPos,
			end = fromPos + (dir * dist),
			hit = false,
			ignore = ignoreEnt,
			mask = 16395
		}
		if (TraceLine(probe) && probe.hit) {
			if (("startsolid" in probe) && probe.startsolid) {
				return 0.0
			}
			local traveled = (probe.pos - fromPos).Length()
			local frac = traveled / dist
			if (frac < 0.0) frac = 0.0
			if (frac > 1.0) frac = 1.0
			return frac
		}
		return 1.0
	}

	function HasClearLine(fromPos, toPos, ignoreEnt) {
		local traceLine = {
			start = fromPos,
			end = toPos,
			hit = false,
			ignore = ignoreEnt,
			mask = 16395
		}
		if (!TraceLine(traceLine)) return true
		return !traceLine.hit
	}

	function GetSmart2AimPoint(ent) {
		if (ent == null || !ent.IsValid()) return null
		local cls = ent.GetClassname()
		if (cls == "player") {
			return ent.GetOrigin() + Vector(0, 0, 52)
		}
		if (cls == "witch") {
			return ent.GetOrigin() + Vector(0, 0, 44)
		}
		return ent.GetOrigin() + Vector(0, 0, 40)
	}

	function IsValidSmart2Target(ent) {
		if (ent == null || !ent.IsValid()) return false
		local cls = ent.GetClassname()
		if (cls == "player") {
			if (ent.IsDead() || ent.IsDying()) return false

			local team = NetProps.GetPropInt(ent, "m_iTeamNum")
			if (team != 2 && team != 3) return false
			if (team == 3 && ent.IsGhost()) return false
			return true
		}
		if (cls == "infected" || cls == "witch" || cls == "tank" || cls == "charger" || cls == "hunter") {
			if (ent.GetHealth() <= 0) return false
			return true
		}
		return false
	}

	function PickSmart2Target(fromPos, maxRadius = 3000.0) {
		if (maxRadius < 500.0) maxRadius = 500.0
		local candidates = []
		local classesToScan = ["infected", "witch", "player", "tank", "charger", "hunter"]

		for (local c = 0; c < classesToScan.len(); c++) {
			local clsName = classesToScan[c]
			local ent = null
			local scans = 0
			while (ent = Entities.FindByClassnameWithin(ent, clsName, fromPos, maxRadius)) {
				if (IsValidSmart2Target(ent)) {
					candidates.push(ent)
				}
				scans += 1
				if (scans >= 256) break
			}
		}

		if (candidates.len() == 0) {
			for (local c = 0; c < classesToScan.len(); c++) {
				local clsName = classesToScan[c]
				local ent = null
				local scans = 0
				while (ent = Entities.FindByClassname(ent, clsName)) {
					if (IsValidSmart2Target(ent)) {
						candidates.push(ent)
					}
					scans += 1
					if (scans >= 512) break
				}
			}
		}

		if (candidates.len() == 0) return null
		return candidates[RandomInt(0, candidates.len() - 1)]
	}

	function PickSmart2TravelDir(fromPos, desiredDir, aimPos, curVelocity, ignoreEnt, commitDir = null) {
		local probeDist = 240.0
		local wantDir = NormalizeVec(desiredDir)
		local prevDir = NormalizeVec(curVelocity)

		local baseFlat = Vector(wantDir.x, wantDir.y, 0)
		if (baseFlat.LengthSqr() < 0.0001) {
			baseFlat = Vector(prevDir.x, prevDir.y, 0)
		}
		if (baseFlat.LengthSqr() < 0.0001) {
			baseFlat = Vector(1, 0, 0)
		}
		baseFlat = NormalizeVec(baseFlat)

		local candidates = []
		candidates.push(wantDir)
		if (commitDir != null) {
			candidates.push(commitDir)
		}

		local yawOffsets = [18, -18, 40, -40, 62, -62, 90, -90, 118, -118, 145, -145, 180]
		foreach(yaw in yawOffsets) {
			local rad = yaw * 0.0174532925
			local c = cos(rad)
			local s = sin(rad)
			local rotX = (baseFlat.x * c) - (baseFlat.y * s)
			local rotY = (baseFlat.x * s) + (baseFlat.y * c)

			candidates.push(NormalizeVec(Vector(rotX, rotY, wantDir.z)))

			candidates.push(NormalizeVec(Vector(rotX, rotY, 0)))
		}

		candidates.push(NormalizeVec(Vector(baseFlat.x * 0.7, baseFlat.y * 0.7, 1.0)))
		candidates.push(NormalizeVec(Vector(baseFlat.x * 0.7, baseFlat.y * 0.7, -1.0)))
		candidates.push(NormalizeVec(Vector(-baseFlat.x, -baseFlat.y, 0.85)))
		candidates.push(NormalizeVec(Vector(-baseFlat.x, -baseFlat.y, -0.85)))

		local bestDir = null
		local bestScore = -99999.0
		foreach(cand in candidates) {
			local frac = ProbeClearFraction(fromPos, cand, probeDist, ignoreEnt)
			local score = frac * 12.0
			score += cand.Dot(wantDir) * 4.0
			score += cand.Dot(prevDir) * 1.5
			if (commitDir != null) {
				score += cand.Dot(commitDir) * 6.0
			}
			if (frac >= 0.999) {
				score += 1.5
			}
			if (frac < 0.25) {
				score -= 6.0
			}

			if (frac >= 0.85 && aimPos != null) {
				local reach = fromPos + (cand * (probeDist * 0.85))
				if (HasClearLine(reach, aimPos, ignoreEnt)) {
					score += 5.0
				}
			}
			if (score > bestScore) {
				bestScore = score
				bestDir = cand
			}
		}

		if (bestDir == null) {
			bestDir = wantDir
		}
		return bestDir
	}

	function PickSmart2EscapeDir(fromPos, aimPos, ignoreEnt) {
		local probeDist = 320.0
		local toAim = NormalizeVec(aimPos - fromPos)
		local dirs = [
			Vector(1, 0, 0), Vector(-1, 0, 0),
			Vector(0, 1, 0), Vector(0, -1, 0),
			Vector(0.7071, 0.7071, 0), Vector(-0.7071, 0.7071, 0),
			Vector(0.7071, -0.7071, 0), Vector(-0.7071, -0.7071, 0),
			Vector(0, 0, 1), Vector(0, 0, -1)
		]

		local bestDir = Vector(0, 0, 1)
		local bestScore = -99999.0
		foreach(d in dirs) {
			local frac = ProbeClearFraction(fromPos, d, probeDist, ignoreEnt)
			local score = frac * 10.0 + d.Dot(toAim) * 2.0
			if (score > bestScore) {
				bestScore = score
				bestDir = d
			}
		}
		return bestDir
	}

	function LaunchSmart2Projectile(startPos, spawnDelay, modelName, particleName, strikeMode = 13) {
		local timer = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = startPos
		}))
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()

		scope.startPos <- startPos
		scope.spawnTime <- Time() + spawnDelay
		scope.mdlName <- modelName
		scope.partName <- (particleName != null && particleName != "") ? particleName : "molotov_explosion"
		scope.strikeMode <- strikeMode

		scope.timerEnt <- timer
		scope.missile <- null
		scope.trail <- null
		scope.spawned <- false
		scope.spawnSolidPhase <- true
		scope.nextMeteorTrailTime <- 0.0

		scope.currentPos <- startPos
		scope.travelDir <- Vector(0, 0, -1)
		scope.velocity <- Vector(0, 0, -1)
		scope.target <- null
		scope.targetAim <- startPos
		scope.lastKnownTargetPos <- startPos

		scope.flightStartTime <- 0.0
		scope.lastThinkTime <- 0.0
		scope.nextProbeTime <- 0.0
		scope.nextLosTime <- 0.0
		scope.nextTargetScanTime <- 0.0
		scope.hasLos <- false
		scope.forceProbe <- true

		scope.stuckCheckTime <- 0.0
		scope.stuckCheckPos <- startPos
		scope.stuckCount <- 0
		scope.escapeUntil <- 0.0
		scope.escapeDir <- Vector(0, 0, -1)
		scope.wallFollowDir <- Vector(0, 0, -1)
		scope.wallFollowUntil <- 0.0
		scope.bounceCount <- 0
		scope.maxFlightTime <- 30.0
		scope.noTargetTime <- 0.0

		scope.Smart2Detonate <- function(pos, sys) {
			local detPos = pos

			local groundTrace = {
				start = detPos + Vector(0, 0, 24),
				end = detPos - Vector(0, 0, 96),
				hit = false,
				ignore = missile,
				mask = 16395
			}
			if (TraceLine(groundTrace) && groundTrace.hit) {
				detPos = Vector(groundTrace.pos.x, groundTrace.pos.y, groundTrace.pos.z + 4.0)
			}
			sys.NukeThePlace(detPos, "0 0 0", strikeMode)
			sys.CleanupProjectileEntities(missile, trail, detPos)
			if (timerEnt && timerEnt.IsValid()) {
				DoEntFire("!self", "Kill", "", 0.0, null, timerEnt)
			}
		}

		scope.Smart2Think <- function() {
			local curTime = Time()
			local sys = DirectorScript.ChCh_RandomAirStrikes

			if (sys == null || sys._disposed) {
				if (trail && trail.IsValid()) DoEntFire("!self", "Kill", "", 0.0, null, trail)
				if (missile && missile.IsValid()) DoEntFire("!self", "Kill", "", 0.0, null, missile)
				self.Kill()
				return null
			}

			if (!spawned) {
				local rem = spawnTime - curTime
				if (rem > 0.01) {
					return rem
				}

				local missileName = "smart2_proj_" + curTime.tostring() + "_" + RandomInt(0, 99999).tostring()
				missile = sys.RegisterTempEntity(SpawnEntityFromTable("prop_dynamic_override", {
					targetname = missileName,
					origin = startPos,
					angles = "90 0 0",
					model = mdlName,
					disableshadows = 1,
					solid = 0
				}))

				spawned = true
				flightStartTime = curTime
				lastThinkTime = curTime
				stuckCheckTime = curTime + 1.0
				stuckCheckPos = startPos
				maxFlightTime = sys.Settings.smart2_max_flight_time.tofloat()
				if (maxFlightTime < 5.0) maxFlightTime = 5.0

				target = sys.PickSmart2Target(startPos, sys.Settings.smart2_target_radius.tofloat())
				if (target != null && target.IsValid()) {
					targetAim = sys.GetSmart2AimPoint(target)
					if (targetAim == null) targetAim = startPos
					lastKnownTargetPos = targetAim
					velocity = sys.NormalizeVec(targetAim - startPos)
					if (velocity.LengthSqr() < 0.5) {
						velocity = Vector(0, 0, -1)
					}
					noTargetTime = 0.0
				} else {

					target = null
					velocity = sys.NormalizeVec(Vector(RandomFloat(-0.3, 0.3), RandomFloat(-0.3, 0.3), -1.0))
					noTargetTime = curTime
				}
				travelDir = velocity
				currentPos = startPos

				if (missile && missile.IsValid()) {
					missile.SetOrigin(currentPos)
					missile.SetForwardVector(velocity)
				}
				trail = sys.AttachProjectileTrail(missile, partName)
				if (strikeMode == 2 || partName == "molotov_explosion") {
					sys.SpawnMeteorTrailParticle(startPos)
					nextMeteorTrailTime = curTime + 0.1
				}
				return 0.03
			}

			if (missile == null || !missile.IsValid()) {
				sys.CleanupProjectileEntities(null, trail)
				self.Kill()
				return null
			}

			local dt = curTime - lastThinkTime
			if (dt <= 0.0 || dt > 0.15) {
				dt = 0.03
			}
			lastThinkTime = curTime

			if (target != null && target.IsValid() && sys.IsValidSmart2Target(target)) {
				targetAim = sys.GetSmart2AimPoint(target)
				if (targetAim != null) {
					lastKnownTargetPos = targetAim
				}
			} else {
				if (target != null && target.IsValid()) {
					local deadAim = sys.GetSmart2AimPoint(target)
					if (deadAim != null) lastKnownTargetPos = deadAim
				}
				target = null

				if (curTime >= nextTargetScanTime) {
					nextTargetScanTime = curTime + 0.5
					target = sys.PickSmart2Target(currentPos, sys.Settings.smart2_target_radius.tofloat())
					if (target != null && target.IsValid()) {
						targetAim = sys.GetSmart2AimPoint(target)
						if (targetAim != null) lastKnownTargetPos = targetAim
						noTargetTime = 0.0
					} else {
						target = null
						if (noTargetTime <= 0.0) noTargetTime = curTime
					}
					forceProbe = true
				}
			}

			local aimPoint = lastKnownTargetPos
			if (target != null && target.IsValid() && targetAim != null) {
				aimPoint = targetAim
			}

			local toAim = aimPoint - currentPos
			local distToTarget = toAim.Length()
			local desiredDir = sys.NormalizeVec(toAim)
			if (desiredDir.LengthSqr() < 0.5) {
				desiredDir = travelDir
			}

			local speed = sys.Settings.smart2_speed.tofloat()
			if (speed < 60.0) speed = 60.0

			if (curTime >= nextLosTime) {
				nextLosTime = curTime + 0.2
				hasLos = sys.HasClearLine(currentPos, aimPoint, missile)
			}

			local moveDir = travelDir
			local commitDir = null
			if (curTime < wallFollowUntil) {
				commitDir = wallFollowDir
			}

			if (hasLos && target != null) {

				moveDir = desiredDir
				travelDir = desiredDir
				forceProbe = false
				wallFollowUntil = 0.0
				commitDir = null
			} else if (forceProbe || curTime >= nextProbeTime) {
				nextProbeTime = curTime + 0.12
				forceProbe = false
				moveDir = sys.PickSmart2TravelDir(currentPos, desiredDir, aimPoint, velocity, missile, commitDir)
				travelDir = moveDir

				wallFollowDir = moveDir
				wallFollowUntil = curTime + 1.6
			}

			if (curTime >= stuckCheckTime) {
				local movedSq = (currentPos - stuckCheckPos).LengthSqr()
				if (movedSq < 8100.0) {
					stuckCount += 1
					escapeDir = sys.PickSmart2EscapeDir(currentPos, aimPoint, missile)
					escapeUntil = curTime + 0.7
					moveDir = escapeDir
					travelDir = escapeDir
					velocity = escapeDir
					forceProbe = true
					nextProbeTime = curTime
					wallFollowUntil = 0.0
				} else {
					stuckCount = 0
				}
				stuckCheckPos = currentPos
				stuckCheckTime = curTime + 1.0
			}

			if (curTime < escapeUntil) {
				moveDir = escapeDir
				velocity = sys.NormalizeVec(velocity + (escapeDir - velocity) * 0.9)
			} else {

				local turn = 0.30
				if (distToTarget < 450.0) turn = 0.45
				if (distToTarget < 180.0) turn = 0.65
				velocity = sys.NormalizeVec(velocity + (moveDir - velocity) * turn)
			}
			if (velocity.LengthSqr() < 0.5) {
				velocity = moveDir
			}

			local nextPos = currentPos + (velocity * (speed * dt))

			local trace = {
				start = currentPos,
				end = nextPos,
				hit = false,
				ignore = missile,
				mask = 16395
			}
			local didHit = TraceLine(trace) && trace.hit
			local isStartSolid = didHit && (("startsolid" in trace) && trace.startsolid)

			local skipHit = false
			if (spawnSolidPhase) {
				if (!isStartSolid) {
					spawnSolidPhase = false
				} else {

					skipHit = true
					if ((curTime - flightStartTime) > 3.0) {
						Smart2Detonate(currentPos, sys)
						return null
					}
				}
			}

			if (didHit && !skipHit) {
				bounceCount += 1

				currentPos = trace.pos - (velocity * 3.0)
				nextPos = currentPos
				velocity = sys.PickSmart2TravelDir(currentPos, desiredDir, aimPoint, velocity, missile, commitDir)
				travelDir = velocity
				wallFollowDir = velocity
				wallFollowUntil = curTime + 1.6
				forceProbe = true
				nextProbeTime = curTime
			} else {

				local targetReached = false
				if (target != null && target.IsValid() && targetAim != null) {
					local aimDistSq = (targetAim - nextPos).LengthSqr()
					if (aimDistSq <= 1024.0) {
						targetReached = true
					} else if (aimDistSq <= 6400.0) {
						targetReached = sys.HasClearLine(nextPos, targetAim, missile)
					}

					if (!targetReached && ((targetAim - currentPos).LengthSqr() <= 16384.0)) {
						targetReached = sys.HasClearLine(currentPos, targetAim, missile)
					}
				}

				if (targetReached) {
					Smart2Detonate(targetAim, sys)
					return null
				}

				if (target == null) {
					if (noTargetTime > 0.0 && (curTime - noTargetTime) >= 6.0) {
						Smart2Detonate(currentPos, sys)
						return null
					}
					if ((lastKnownTargetPos - nextPos).LengthSqr() <= 6400.0) {
						Smart2Detonate(lastKnownTargetPos, sys)
						return null
					}
				}

				currentPos = nextPos
			}

			missile.SetOrigin(currentPos)
			missile.SetForwardVector(velocity)
			sys.UpdateProjectileTrail(trail, currentPos)

			if (strikeMode == 2 || partName == "molotov_explosion") {
				if (curTime >= nextMeteorTrailTime) {
					sys.SpawnMeteorTrailParticle(currentPos)
					nextMeteorTrailTime = (curTime - nextMeteorTrailTime > 0.5) ? (curTime + 0.1) : (nextMeteorTrailTime + 0.1)
				}
			}

			if ((curTime - flightStartTime) >= maxFlightTime) {
				Smart2Detonate(currentPos, sys)
				return null
			}
			if (currentPos.z < -3000.0) {
				sys.CleanupProjectileEntities(missile, trail, currentPos)
				self.Kill()
				return null
			}

			return 0.03
		}

		AddThinkToEnt(timer, "Smart2Think")
	}

	function NukeThePlace(where, angless, currentMode = 1) {
		local finalRadius = Settings.explode_radius
		local finalDmg = Settings.explode_dmg

		if (currentMode == 16) {
			finalDmg = (finalDmg * 0.6).tointeger()
			finalRadius = (finalRadius * 0.6).tointeger()
			if (finalDmg < 1) finalDmg = 1
			if (finalRadius < 1) finalRadius = 1
		}

		local soundtarget = RegisterTempEntity(SpawnEntityFromTable("info_target", {
			origin = where
		}))

		if (currentMode == 6) {
			local napalmPart1 = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "gas_explosion_ground_fire",
				start_active = 1,
				flag_as_weather = 0
			}))

			local napalmPart2 = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "molotov_explosion",
				start_active = 1,
				flag_as_weather = 0
			}))

			if (napalmPart1 && napalmPart1.IsValid()) {
				DoEntFire("!self", "Stop", "", 16.0, null, napalmPart1)
				DoEntFire("!self", "Kill", "", 16.1, null, napalmPart1)
			}
			if (napalmPart2 && napalmPart2.IsValid()) {
				DoEntFire("!self", "Stop", "", 16.0, null, napalmPart2)
				DoEntFire("!self", "Kill", "", 16.1, null, napalmPart2)
			}

			if (soundtarget && soundtarget.IsValid()) {
				EmitAmbientSoundOn("weapons/molotov/fire_ignite_2.wav", 1.0, 120, RandomInt(95, 105), soundtarget)
				local boomnum = RandomInt(1, 3).tostring()
				EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 0.7, 100, RandomInt(95, 105), soundtarget)
			}

			finalDmg = (finalDmg * 0.5).tointeger()
			finalRadius = (finalRadius * 0.7).tointeger()

			local firesPerBomb = Settings.napalm_fires_per_bomb
			local fireSpread = Settings.napalm_fire_spread
			CreateNapalmFireCluster(where, fireSpread, firesPerBomb, null)

		} else if (currentMode == 9) {
			local p1 = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where,
				effect_name = "gas_explosion_main",
				start_active = 1
			}))
			if (p1 && p1.IsValid()) {
				DoEntFire("!self", "Stop", "", 7.0, null, p1)
				DoEntFire("!self", "Kill", "", 8.0, null, p1)
			}

			for (local i = 1; i <= 4; i++) {
				local p2 = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
					origin = where + Vector(0, 0, 500 * i),
					effect_name = "fluidExplosion_frames",
					start_active = 1
				}))
				if (p2 && p2.IsValid()) {
					DoEntFire("!self", "Stop", "", 3.5, null, p2)
					DoEntFire("!self", "Kill", "", 4.0, null, p2)
				}
			}

			local p3 = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where + Vector(0, 0, 1200),
				effect_name = "explosion_silo",
				start_active = 1
			}))
			if (p3 && p3.IsValid()) {
				DoEntFire("!self", "Stop", "", 3.0, null, p3)
				DoEntFire("!self", "Kill", "", 3.5, null, p3)
			}

			if (soundtarget && soundtarget.IsValid()) {
				EmitAmbientSoundOn("animation/tanker_explosion.wav", 1.0, 150, 90, soundtarget)
			}
			finalRadius = finalRadius * 3
			finalDmg = finalDmg * 3

			local pushRadius = 800
			local force = 1500.0
			local classesToPush = ["player", "witch", "infected", "prop_physics"]

			foreach(cls in classesToPush) {
				local ent = null
				local pushedCount = 0
				while (ent = Entities.FindByClassnameWithin(ent, cls, where, pushRadius)) {
					if (ent.IsValid()) {
						if (cls == "player" && (!ent.IsSurvivor() && ent.IsGhost())) {
							continue
						}
						local dir = ent.GetOrigin() - where
						local dLen = dir.Length()
						if (dLen > 0.001) {
							dir = dir * (1.0 / dLen)
						} else {
							dir = Vector(1, 0, 0)
						}
						ent.ApplyAbsVelocityImpulse(Vector(dir.x * force, dir.y * force, 400))

						pushedCount += 1
						if (cls == "prop_physics" && pushedCount >= 30) break
						if (cls == "infected" && pushedCount >= 60) break
					}
				}
			}

		} else if (currentMode == 5 || currentMode == 2) {

			local nukeParticle = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "gas_explosion_main",
				start_active = 1,
				flag_as_weather = 0
			}))

			if (nukeParticle && nukeParticle.IsValid()) {
				DoEntFire("!self", "Stop", "", 10.0, null, nukeParticle)
				DoEntFire("!self", "Kill", "", 11.0, null, nukeParticle)
			}

			if (soundtarget && soundtarget.IsValid()) {
				EmitAmbientSoundOn("animation/tanker_explosion.wav", 1.0, 150, 100, soundtarget)
			}

			finalRadius = finalRadius * 2
		} else if (currentMode == 17) {
			local nukeParticle = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "gas_explosion_main",
				start_active = 1,
				flag_as_weather = 0
			}))
			local chunksParticle = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "gas_explosion_chunks_02",
				start_active = 1,
				flag_as_weather = 0
			}))

			if (nukeParticle && nukeParticle.IsValid()) {
				DoEntFire("!self", "Stop", "", 10.0, null, nukeParticle)
				DoEntFire("!self", "Kill", "", 11.0, null, nukeParticle)
			}
			if (chunksParticle && chunksParticle.IsValid()) {
				DoEntFire("!self", "Stop", "", 8.0, null, chunksParticle)
				DoEntFire("!self", "Kill", "", 8.5, null, chunksParticle)
			}

			if (soundtarget && soundtarget.IsValid()) {
				EmitAmbientSoundOn("animation/tanker_explosion.wav", 1.0, 150, RandomInt(95, 105), soundtarget)
				EmitAmbientSoundOn("weapons/grenade_launcher/grenadefire/grenade_launcher_explode_2.wav", 0.5, 120, RandomInt(85, 95), soundtarget)
			}

			finalRadius = finalRadius * 2
		} else {
			local expPart1 = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "weapon_grenadelauncher",
				start_active = 1,
				flag_as_weather = 0
			}))
			local expPart2 = RegisterTempEntity(SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "gas_explosion_chunks_02",
				start_active = 1,
				flag_as_weather = 0
			}))

			if (expPart1 && expPart1.IsValid()) {
				DoEntFire("!self", "Stop", "", 5.0, null, expPart1)
				DoEntFire("!self", "Kill", "", 5.5, null, expPart1)
			}
			if (expPart2 && expPart2.IsValid()) {
				DoEntFire("!self", "Stop", "", 8.0, null, expPart2)
				DoEntFire("!self", "Kill", "", 8.5, null, expPart2)
			}

			if (soundtarget && soundtarget.IsValid()) {
				local boomnum = RandomInt(1, 3).tostring()
				EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 1.0, 120, RandomInt(95, 105), soundtarget)
				EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 1.0, 120, RandomInt(95, 105), soundtarget)
				if (currentMode == 16) {
					EmitAmbientSoundOn("weapons/grenade_launcher/grenadefire/grenade_launcher_explode_2.wav", 0.45, 110, RandomInt(95, 110), soundtarget)
				}
			}
		}

		local boom = SpawnEntityFromTable("env_explosion", {
			origin = where,
			angles = angless,
			iMagnitude = finalDmg,
			iRadiusOverride = finalRadius,
			spawnflags = 68
		})
		if (boom && boom.IsValid()) {
			DoEntFire("!self", "Explode", "", 0.0, null, boom)
			DoEntFire("!self", "Kill", "", 0.1, null, boom)
		}

		local player = null
		while (player = Entities.FindByClassnameWithin(player, "player", where, finalRadius)) {
			if (player.IsValid() && !player.IsDead() && (player.IsSurvivor() || !player.IsGhost())) {
				player.Stagger(where)
			}
		}

		if (Settings.summon_horde >= 1 && currentMode != 16 && currentMode != 17) {
			EntFire("worldspawn", "RunScriptCode", "Director.ResetMobTimer()", RandomFloat(3, 4), null)
		}
		if (soundtarget && soundtarget.IsValid()) {
			DoEntFire("!self", "Kill", "", 12.0, null, soundtarget)
		}
	}

	function DoAirStrike(forcedMode = null) {
		local mode = (forcedMode != null) ? forcedMode : PickAirStrikeMode()
		if (mode == null) {
			return
		}

		local strikepos = null
		for (local attempt = 0; attempt < 5; attempt++) {
			StrikeTryNum = attempt
			local spot = GetNearToSurvsSpot()

			if (spot != null) {
				strikepos = GetHighestPointFromSomewhere(spot)
				if (strikepos != null) {
					break
				}
			}
		}

		if (strikepos == null) {
			NextStrikeTime = Time() + 5.0
			StrikeTryNum = 0
			return
		}

		if (mode == 8) {
			local jetZ = strikepos.z + 1000
			local traceUp = {
				start = strikepos + Vector(0, 0, 10),
				end = strikepos + Vector(0, 0, 3000),
				hit = false,
				ignore = null,
				mask = 16395
			}

			if (ShouldScanSkyAboveTarget() && TraceLine(traceUp) && traceUp.hit) {
				local ceilingZ = traceUp.pos.z
				if (ceilingZ < jetZ) jetZ = ceilingZ
			}
			if (jetZ < strikepos.z + 500) jetZ = strikepos.z + 500

			local angles = "0 " + RandomInt(0, 360).tostring() + " 0"
			local plane = RegisterTempEntity(SpawnEntityFromTable("prop_dynamic", {
				origin = Vector(strikepos.x, strikepos.y, jetZ),
				angles = angles,
				model = "models/f18/f18.mdl",
				fademindist = -1,
				fademaxdist = 0,
				disableshadows = 1,
				solid = 0
			}))

			local animIdx = RandomInt(1, 5)
			local planimation = "flyby" + animIdx.tostring()
			local boomtime = (animIdx >= 3) ? 3.2 : 2.6

			if (plane && plane.IsValid()) {
				EntityOutputs.AddOutput(plane, "OnAnimationDone", "!self", "Kill", "", 0.0, 1)
				DoEntFire("!self", "SetAnimation", planimation, 0.0, null, plane)
			}

			ScheduleJetFlybySound(boomtime - 1.0)

			if (Settings.drop_bomb >= 1) {
				local impactTime = boomtime + RandomFloat(0.2, 0.5)

				LaunchClusterBombProjectile(
					Vector(strikepos.x, strikepos.y, jetZ),
					strikepos,
					impactTime,
					angles,
					"models/missiles/f18_agm65maverick.mdl",
					"molotov_explosion"
				)
			}
		} else if (mode == 7) {
			local jetZ = strikepos.z + 1000
			local traceUp = {
				start = strikepos + Vector(0, 0, 10),
				end = strikepos + Vector(0, 0, 3000),
				hit = false,
				ignore = null,
				mask = 16395
			}

			local ceilingZ = null
			if (ShouldScanSkyAboveTarget() && TraceLine(traceUp) && traceUp.hit) {
				ceilingZ = traceUp.pos.z - 250
				if (ceilingZ < jetZ) jetZ = ceilingZ
			}

			local minJetZ = strikepos.z + 600
			if (ceilingZ != null && minJetZ > ceilingZ + 150) minJetZ = ceilingZ + 150
			if (jetZ < minJetZ) jetZ = minJetZ

			local angleInt = RandomInt(0, 360)
			local angles = "0 " + angleInt.tostring() + " 0"
			local angleRad = angleInt * 3.14159 / 180.0
			local fwdVec = Vector(cos(angleRad), sin(angleRad), 0)
			local rightVec = Vector(cos(angleRad + 1.5708), sin(angleRad + 1.5708), 0)

			local formationOffsets = [0, -800, 800]
			local formationLag = [0, -400, -400]
			local basePos = Vector(strikepos.x, strikepos.y, jetZ)
			local planeSpawns = []

			for (local i = 0; i < 3; i++) {
				local offsetPos = basePos + (rightVec * formationOffsets[i]) + (fwdVec * formationLag[i])

				local slotPos = ResolveAircraftSlotPos(basePos, offsetPos, 450.0)
				planeSpawns.push(slotPos)

				local plane = RegisterTempEntity(SpawnEntityFromTable("prop_dynamic", {
					origin = slotPos,
					angles = angles,
					model = "models/f18/f18.mdl",
					fademindist = -1,
					fademaxdist = 0,
					disableshadows = 1,
					solid = 0
				}))

				if (plane && plane.IsValid()) {
					EntityOutputs.AddOutput(plane, "OnAnimationDone", "!self", "Kill", "", 0.0, 1)
					DoEntFire("!self", "SetAnimation", "flyby1", 0.0, null, plane)
					DoEntFire("!self", "SetPlaybackRate", "0.5", 0.01, null, plane)
				}
			}

			local boomtime = 5.0
			ScheduleJetFlybySound(4.5)
			ScheduleJetFlybySound(5.0)

			if (Settings.drop_bomb >= 1) {
				local missileCount = Settings.barrage_missile_count
				if (missileCount < 1) missileCount = 1
				local duration = 2.0
				local interval = duration / missileCount
				local startDropTime = (boomtime - 0.5) - 1.0

				for (local i = 0; i < missileCount; i++) {
					local planeIdx = i % 3
					local planeBasePos = planeSpawns[planeIdx]

					local backOffset = 800 - (i * 100)

					local slopeStartPos = ResolveAircraftSlotPos(planeBasePos, planeBasePos + (fwdVec * backOffset), 150.0)

					local forwardSpread = (i * 150) - (missileCount * 75)
					local sideSpread = RandomInt(-150, 150)
					local impactPos = strikepos + (fwdVec * forwardSpread) + (rightVec * sideSpread)

					local groundTrace = {
						start = impactPos + Vector(0, 0, 500),
						end = impactPos - Vector(0, 0, 1000),
						hit = false,
						ignore = null
					}
					if (TraceLine(groundTrace) && groundTrace.hit) impactPos = groundTrace.pos

					local impactTime = startDropTime + (i * interval)

					LaunchProjectile(
						slopeStartPos,
						impactPos,
						impactTime,
						angles,
						"models/missiles/f18_agm65maverick.mdl",
						"molotov_explosion",
						false,
						0.5,
						mode
					)
				}
			}
		} else if (mode == 1 || mode == 3 || mode == 4 || mode == 5 || mode == 9 || mode == 10 || mode == 11 || mode == 12 || mode == 13 || mode == 14) {
			local jetZ = strikepos.z + 1000
			local traceUp = {
				start = strikepos + Vector(0, 0, 10),
				end = strikepos + Vector(0, 0, 3000),
				hit = false,
				ignore = null,
				mask = 16395
			}

			if (ShouldScanSkyAboveTarget() && TraceLine(traceUp) && traceUp.hit) {
				local possibleZ = traceUp.pos.z - 250
				if (possibleZ < jetZ) jetZ = possibleZ
			}
			if (jetZ < strikepos.z + 300) jetZ = strikepos.z + 300

			local isCargoPlane = (mode == 3 || mode == 9 || mode == 10 || mode == 11 || mode == 12 || mode == 14)
			local planeMdl = isCargoPlane ? "models/props_vehicles/c130.mdl" : "models/f18/f18.mdl"

			local planeAngleInt = RandomInt(0, 360)
			local angles = "0 " + planeAngleInt.tostring() + " 0"
			local plane = RegisterTempEntity(SpawnEntityFromTable("prop_dynamic", {
				origin = Vector(strikepos.x, strikepos.y, jetZ),
				angles = angles,
				model = planeMdl,
				fademindist = -1,
				fademaxdist = 0,
				disableshadows = 1,
				solid = 0
			}))

			local planimation = ""
			local boomtime = 2.6

			if (isCargoPlane) {
				planimation = "airport_intro_flyby"
				boomtime = 6.0
				EmitAmbientSoundOn("animation/plane_flyover_short.wav", 0.2, 0, 100, Entities.First())
			} else {
				local animIdx = RandomInt(1, 5)
				planimation = "flyby" + animIdx.tostring()
				if (animIdx >= 3) boomtime = 3.2
				ScheduleJetFlybySound(boomtime - 1.0)
			}

			if (plane && plane.IsValid()) {
				EntityOutputs.AddOutput(plane, "OnAnimationDone", "!self", "Kill", "", 0.0, 1)
				DoEntFire("!self", "SetAnimation", planimation, 0.0, null, plane)
			}

			if (Settings.drop_bomb >= 1) {
				if (mode == 1 || mode == 5) {
					local impactTime = boomtime + RandomFloat(0.2, 0.5)
					LaunchProjectile(
						Vector(strikepos.x, strikepos.y, jetZ),
						strikepos,
						impactTime,
						angles,
						"models/missiles/f18_agm65maverick.mdl",
						"molotov_explosion",
						false,
						0.25,
						mode
					)
				} else if (mode == 3) {
					LaunchCarDrop(
						Vector(strikepos.x, strikepos.y, jetZ - 50),
						boomtime
					)
				} else if (mode == 9 || mode == 12) {
					LaunchSlowMissile(
						Vector(strikepos.x, strikepos.y, jetZ - 50),
						strikepos,
						boomtime,
						3.0,
						mode
					)
				} else if (mode == 10) {
					LaunchSupplyDrop(
						Vector(strikepos.x, strikepos.y, jetZ - 50),
						boomtime
					)
				} else if (mode == 14) {

					LaunchSupplyDrop4(
						Vector(strikepos.x, strikepos.y, jetZ - 50),
						boomtime
					)
				} else if (mode == 11) {
					local minI = Settings.supplydrop2_min_items
					local maxI = Settings.supplydrop2_max_items
					local count = RandomInt(minI, maxI)
					local spacing = 300.0

					local rad = planeAngleInt * 3.14159 / 180.0
					local dir = Vector(cos(rad), sin(rad), 0)

					local totalLen = (count - 1) * spacing
					local startPos2D = strikepos - (dir * (totalLen / 2.0))
					local startTime = boomtime - ((count * 0.3) / 2.0)

					for (local i = 0; i < count; i++) {
						local dropSpot2D = startPos2D + (dir * (i * spacing))
						local dropPos = Vector(dropSpot2D.x, dropSpot2D.y, jetZ - 50)
						local delay = startTime + (i * 0.3)

						if (delay < 0.1) delay = 0.1

						LaunchSupplyDrop(dropPos, delay)
					}
				} else if (mode == 13) {

					local spawnDelay = boomtime - 0.5
					local missileStartZ = jetZ
					local traceCeiling = {
						start = strikepos + Vector(0, 0, 16),
						end = Vector(strikepos.x, strikepos.y, jetZ),
						hit = false,
						ignore = null,
						mask = 16395
					}
					if (ShouldScanSkyAboveTarget() && TraceLine(traceCeiling) && traceCeiling.hit) {
						missileStartZ = traceCeiling.pos.z - 25.0
					}
					local preferredZ = strikepos.z + 450.0
					if (preferredZ < missileStartZ) {
						missileStartZ = preferredZ
					}
					if (missileStartZ < strikepos.z + 20.0) {
						missileStartZ = strikepos.z + 20.0
					}
					LaunchSmart2Projectile(
						Vector(strikepos.x, strikepos.y, missileStartZ),
						spawnDelay,
						"models/missiles/f18_agm65maverick.mdl",
						"molotov_explosion",
						mode
					)
				} else {
					local spawnDelay = boomtime - 0.5
					local missileStartZ = jetZ
					local traceCeiling = {
						start = strikepos + Vector(0, 0, 16),
						end = Vector(strikepos.x, strikepos.y, jetZ),
						hit = false,
						ignore = null,
						mask = 16395
					}
					if (ShouldScanSkyAboveTarget() && TraceLine(traceCeiling) && traceCeiling.hit) {
						missileStartZ = traceCeiling.pos.z - 25.0
						if (missileStartZ < strikepos.z + 20.0) {
							missileStartZ = strikepos.z + 20.0
						}
					}
					LaunchHomingProjectile(
						Vector(strikepos.x, strikepos.y, missileStartZ),
						strikepos,
						spawnDelay,
						"models/missiles/f18_agm65maverick.mdl",
						"molotov_explosion",
						mode
					)
				}
			}
		} else if (mode == 6) {
			local jetZ = strikepos.z + 1000
			local traceUp = {
				start = strikepos + Vector(0, 0, 10),
				end = strikepos + Vector(0, 0, 3000),
				hit = false,
				ignore = null,
				mask = 16395
			}

			if (ShouldScanSkyAboveTarget() && TraceLine(traceUp) && traceUp.hit) {
				local possibleZ = traceUp.pos.z - 250
				if (possibleZ < jetZ) jetZ = possibleZ
			}
			if (jetZ < strikepos.z + 300) jetZ = strikepos.z + 300

			local planeAngle = RandomInt(0, 360)
			local angles = "0 " + planeAngle.tostring() + " 0"

			local plane = RegisterTempEntity(SpawnEntityFromTable("prop_dynamic", {
				origin = Vector(strikepos.x, strikepos.y, jetZ),
				angles = angles,
				model = "models/f18/f18.mdl",
				fademindist = -1,
				fademaxdist = 0,
				disableshadows = 1,
				solid = 0
			}))

			local animIdx = RandomInt(1, 5)
			local planimation = "flyby" + animIdx.tostring()
			local boomtime = (animIdx >= 3) ? 3.2 : 2.6

			if (plane && plane.IsValid()) {
				EntityOutputs.AddOutput(plane, "OnAnimationDone", "!self", "Kill", "", 0.0, 1)
				DoEntFire("!self", "SetAnimation", planimation, 0.0, null, plane)
			}

			ScheduleJetFlybySound(boomtime - 1.0)

			if (Settings.drop_bomb >= 1) {
				local perpAngleRad = (planeAngle + 90) * 3.14159 / 180.0
				local lineDir = Vector(cos(perpAngleRad), sin(perpAngleRad), 0)

				local bombCount = RandomInt(3, 4)
				local lineLength = Settings.napalm_line_length.tofloat()

				local spacing = lineLength / (bombCount - 1).tofloat()
				local startOffset = -lineLength / 2.0

				for (local i = 0; i < bombCount; i++) {
					local offset = startOffset + (spacing * i)
					local targetPos = strikepos + (lineDir * offset)

					local groundTrace = {
						start = targetPos + Vector(0, 0, 100),
						end = targetPos - Vector(0, 0, 500),
						hit = false,
						ignore = null
					}
					if (TraceLine(groundTrace) && groundTrace.hit) {
						targetPos = groundTrace.pos
					}

					local impactTime = boomtime + RandomFloat(0.1, 0.3) + (i * 0.2)

					LaunchProjectile(
						Vector(targetPos.x, targetPos.y, jetZ),
						targetPos,
						impactTime,
						angles,
						"models/missiles/f18_agm65maverick.mdl",
						"fire_medium_02_nosmoke",
						false,
						0.35,
						6
					)
				}
			}
		} else if (mode == 2) {
			if (Settings.drop_bomb >= 1) {
				local height = 1500
				local dist = 1200

				local bestStartVec = null
				local bestDistSq = 0

				for (local i = 0; i < 8; i++) {
					local angleRad = RandomFloat(0, 3.14159 * 2)
					local candidateVec = Vector(
						strikepos.x + (cos(angleRad) * dist),
						strikepos.y + (sin(angleRad) * dist),
						strikepos.z + height
					)

					local traceCheck = {
						start = strikepos,
						end = candidateVec,
						hit = false,
						ignore = null
					}
					local actualStart = candidateVec

					if (ShouldScanSkyAboveTarget() && TraceLine(traceCheck) && traceCheck.hit) {
						local dir = candidateVec - strikepos
						local len = dir.Length()
						local normDir = Vector(0, 0, 1)
						if (len > 0.01) {
							normDir = Vector(dir.x / len, dir.y / len, dir.z / len)
						}
						actualStart = traceCheck.pos - (normDir * 50)
					}

					local dx = actualStart.x - strikepos.x
					local dy = actualStart.y - strikepos.y
					local dSq = (dx * dx) + (dy * dy)

					if (dSq > bestDistSq) {
						bestDistSq = dSq
						bestStartVec = actualStart
					}
				}

				if (bestStartVec == null) {
					bestStartVec = strikepos + Vector(0, 0, height)
				}

				local minHeightAboveTarget = 1000
				if (bestStartVec.z < strikepos.z + minHeightAboveTarget) {
					bestStartVec = Vector(
						strikepos.x + RandomFloat(-1000, 1000),
						strikepos.y + RandomFloat(-1000, 1000),
						strikepos.z + minHeightAboveTarget
					)
				}

				local rockIdx = RandomInt(0, RockModels.len() - 1)
				local rockMdl = RockModels[rockIdx]

				LaunchProjectile(
					bestStartVec,
					strikepos,
					5.0,
					"0 0 0",
					rockMdl,
					"molotov_explosion",
					true,
					2.5,
					mode
				)
			}
		} else if (mode == 15) {
			local dropHeight = Settings.mysterymolotov_drop_height.tofloat()
			local jetZ = strikepos.z + dropHeight
			local traceUp = {
				start = strikepos + Vector(0, 0, 10),
				end = strikepos + Vector(0, 0, 3000),
				hit = false,
				ignore = null,
				mask = 16395
			}

			if (ShouldScanSkyAboveTarget() && TraceLine(traceUp) && traceUp.hit) {
				local ceilingZ = traceUp.pos.z - 150.0
				if (jetZ > ceilingZ) jetZ = ceilingZ
			}
			if (jetZ < strikepos.z + 300.0) jetZ = strikepos.z + 300.0

			local impactPos = strikepos
			local groundTrace = {
				start = strikepos + Vector(0, 0, 100),
				end = strikepos - Vector(0, 0, 800),
				hit = false,
				ignore = null
			}
			if (TraceLine(groundTrace) && groundTrace.hit) {
				impactPos = groundTrace.pos + Vector(0, 0, 2)
			}

			if (Settings.drop_bomb >= 1) {

				local startPos = Vector(
					impactPos.x + RandomFloat(-60.0, 60.0),
					impactPos.y + RandomFloat(-60.0, 60.0),
					jetZ
				)
				LaunchMysteryMolotov(startPos, impactPos, 1.0)
			}
		} else if (mode == 16) {
			if (Settings.drop_bomb >= 1) {
				local minShells = Settings.artillery_min_projectiles.tointeger()
				local maxShells = Settings.artillery_max_projectiles.tointeger()
				if (minShells < 3) minShells = 3
				if (minShells > 20) minShells = 20
				if (maxShells < minShells) maxShells = minShells
				if (maxShells > 20) maxShells = 20

				local shellCount = RandomInt(minShells, maxShells)
				local launchPos = ResolveArtilleryLaunchPos(
					strikepos,
					Settings.artillery_launch_distance.tofloat(),
					Settings.artillery_launch_height.tofloat()
				)
				local spread = Settings.artillery_spread_radius.tofloat()
				local interval = Settings.artillery_shell_interval.tofloat()

				for (local i = 0; i < shellCount; i++) {

					local shellStart = launchPos + Vector(
						RandomFloat(-120.0, 120.0),
						RandomFloat(-120.0, 120.0),
						RandomFloat(-30.0, 30.0)
					)

					local a = RandomFloat(0.0, 6.28318)
					local r = RandomFloat(0.0, spread)
					local impactPos = strikepos + Vector(cos(a) * r, sin(a) * r, 0)

					local groundTrace = {
						start = impactPos + Vector(0, 0, 400),
						end = impactPos - Vector(0, 0, 1200),
						hit = false,
						ignore = null
					}
					if (TraceLine(groundTrace) && groundTrace.hit) {
						impactPos = groundTrace.pos + Vector(0, 0, 4)
					}

					LaunchArtilleryShell(
						shellStart,
						impactPos,
						1.2 + (i * interval),
						RandomFloat(180.0, 320.0)
					)
				}

				if (Settings.summon_horde >= 1) {
					EntFire("worldspawn", "RunScriptCode", "Director.ResetMobTimer()", 3.0 + (shellCount * interval), null)
				}
			}
		} else if (mode == 17) {
			if (Settings.drop_bomb >= 1) {
				local roundCount = Settings.artillery2_rounds.tointeger()
				if (roundCount < 1) roundCount = 1
				if (roundCount > 20) roundCount = 20

				local launchPos = ResolveArtilleryLaunchPos(
					strikepos,
					Settings.artillery2_launch_distance.tofloat(),
					Settings.artillery2_launch_height.tofloat()
				)
				local spread = Settings.artillery2_spread_radius.tofloat()
				local interval = Settings.artillery2_shell_interval.tofloat()
				local speed = Settings.artillery2_projectile_speed.tofloat()
				if (speed < 100.0) speed = 100.0
				local lastImpactTime = 0.0

				for (local i = 0; i < roundCount; i++) {
					local shellStart = launchPos + Vector(
						RandomFloat(-120.0, 120.0),
						RandomFloat(-120.0, 120.0),
						RandomFloat(-30.0, 30.0)
					)

					local a = RandomFloat(0.0, 6.28318)
					local r = RandomFloat(0.0, spread)
					local impactPos = strikepos + Vector(cos(a) * r, sin(a) * r, 0)

					local groundTrace = {
						start = impactPos + Vector(0, 0, 400),
						end = impactPos - Vector(0, 0, 1200),
						hit = false,
						ignore = null,
						mask = 16395
					}
					if (TraceLine(groundTrace) && ("startsolid" in groundTrace) && groundTrace.startsolid) {
						groundTrace = {
							start = impactPos + Vector(0, 0, 800),
							end = impactPos - Vector(0, 0, 1200),
							hit = false,
							ignore = null,
							mask = 16395
						}
						TraceLine(groundTrace)
					}
					if (groundTrace.hit && !(("startsolid" in groundTrace) && groundTrace.startsolid)) {
						impactPos = groundTrace.pos + Vector(0, 0, 4)
					} else if (("startsolid" in groundTrace) && groundTrace.startsolid) {
						impactPos = strikepos + Vector(0, 0, 4)
					}

					local spawnDelay = i * interval
					local arcHeight = RandomFloat(280.0, 450.0)
					local estFlight = ((impactPos - shellStart).Length() + (arcHeight * 2.0)) / speed
					if (estFlight < 0.25) estFlight = 0.25
					if (spawnDelay + estFlight > lastImpactTime) {
						lastImpactTime = spawnDelay + estFlight
					}

					LaunchArtilleryBarrage2Shell(
						shellStart,
						impactPos,
						spawnDelay,
						speed,
						arcHeight
					)
				}

				if (Settings.summon_horde >= 1) {
					EntFire("worldspawn", "RunScriptCode", "Director.ResetMobTimer()", lastImpactTime + 2.0, null)
				}
			}
		} else if (mode == 18) {
			if (Settings.drop_bomb >= 1) {
				local dropHeight = Settings.boomer_drop_height.tofloat()
				local skyZ = strikepos.z + dropHeight

				local traceUp = {
					start = strikepos + Vector(0, 0, 10),
					end = strikepos + Vector(0, 0, dropHeight + 500.0),
					hit = false,
					ignore = null,
					mask = 16395
				}
				if (ShouldScanSkyAboveTarget() && TraceLine(traceUp) && traceUp.hit) {
					local ceilingZ = traceUp.pos.z - 100.0
					if (skyZ > ceilingZ) skyZ = ceilingZ
				}
				if (skyZ < strikepos.z + 300.0) skyZ = strikepos.z + 300.0

				local startPos = Vector(
					strikepos.x + RandomFloat(-100.0, 100.0),
					strikepos.y + RandomFloat(-100.0, 100.0),
					skyZ
				)

				LaunchSkyBoomer(startPos, strikepos, 0.35)
			}
		}

		LastStrikeTime = Time()
		NextStrikeTime = LastStrikeTime + Settings.air_strike_delay
		LastAppliedDelay = Settings.air_strike_delay
		StrikeTryNum = 0
	}

	function PrecacheAllAssets() {
		local models = [
			"models/f18/f18.mdl",
			"models/missiles/f18_agm65maverick.mdl",
			"models/props_vehicles/c130.mdl",
			"models/props_junk/gascan001a.mdl",
			"models/props_junk/wood_crate001a.mdl",
			"models/props_junk/wood_crate002a.mdl",
			"models/props_crates/supply_crate01.mdl",
			"models/props_crates/supply_crate02.mdl",
			"models/props_junk/propanecanister001a.mdl",
			"models/props_vehicles/cara_95sedan.mdl",
			"models/props_vehicles/cara_95sedan_wrecked.mdl",
			"models/w_models/weapons/w_eq_molotov.mdl",
			"models/w_models/weapons/w_HE_grenade.mdl"
		]
		foreach(mdl in models) {
			if (!IsModelPrecached(mdl)) PrecacheModel(mdl)
		}
		foreach(mdl in RockModels) {
			if (!IsModelPrecached(mdl)) PrecacheModel(mdl)
		}

		local sounds = [
			"animation/plane_flyover_short.wav",
			"weapons/molotov/fire_ignite_2.wav",
			"weapons/hegrenade/explode3.wav",
			"animation/jets/jet_by_01_mono.wav",
			"animation/jets/jet_by_02_mono.wav",
			"ambient/explosions/explode_1.wav",
			"ambient/explosions/explode_2.wav",
			"ambient/explosions/explode_3.wav",
			"animation/tanker_explosion.wav",
			"weapons/molotov/molotov_detonate_3.wav",
			"weapons/molotov/fire_loop_1.wav",
			"weapons/grenade_launcher/grenadefire/grenade_launcher_fire_1.wav",
			"weapons/grenade_launcher/grenadefire/grenade_launcher_explode_2.wav"
		]
		foreach(snd in sounds) {
			if (!IsSoundPrecached(snd)) PrecacheSound(snd)
		}
		foreach(snd in CarAmbientLoopSounds) {
			if (!IsSoundPrecached(snd)) PrecacheSound(snd)
		}

		if ("PrecacheEntityFromTable" in getroottable()) {
			foreach(fx in ParticleEffects) {
				PrecacheEntityFromTable({
					classname = "info_particle_system",
					effect_name = fx,
					start_active = "0",
					origin = Vector(0, 0, 0),
					angles = Vector(0, 0, 0)
				})
			}
		}
	}

	function OnGameEvent_round_start(params) {
		if (_disposed) return

		KillTrackedEntities()
		LeavingTime = null
		StrikeTryNum = 0
		LastStrikeTime = null
		NextStrikeTime = 0
		NextCheckTime = 0
		RoundStartTime = Time()
		RefreshSettingsIfChanged()

		PrecacheAllAssets()

		GetOrInitNavCache()

		if ("__ChCh_UpdateFunc" in g_MapScript && g_MapScript.__ChCh_UpdateFunc != null) {
			if ("ScriptedMode_RemoveUpdate" in g_MapScript) {
				g_MapScript.ScriptedMode_RemoveUpdate(g_MapScript.__ChCh_UpdateFunc)
			}
		}
		g_MapScript.__ChCh_UpdateFunc <- IfBeginAirStrike
		g_MapScript.ScriptedMode_AddUpdate(IfBeginAirStrike)
	}

	function OnGameEvent_player_left_safe_area(params) {
		if (_disposed) return

		if (LeavingTime == null) {
			LeavingTime = Time()
		}
	}
}

__CollectEventCallbacks(ChCh_RandomAirStrikes, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
ChCh_RandomAirStrikes.ParseSettings();