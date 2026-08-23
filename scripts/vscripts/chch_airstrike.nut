ChCh_RandomAirStrikes <- {
	LeavingTime = null
	StrikeTryNum = 0

	NextStrikeTime = 0
	NextCheckTime = 0

	Settings = {
		allowed_gamemodes = ["coop", "realism"]
		disallowed_maps = ["c1m1_hotel", "c1m3_mall", "c1m4_atrium", "c5m4_quarter", "c8m2_subway", "c8m4_interior", "c10m2_drainage", "c11m4_terminal", "c12m5_cornfield"]
		one_in_what_chance = 20
		nav_percent_dist_variance = 5
		air_strike_delay = 75
		drop_bomb = 1
		summon_horde = 0
		explode_radius = 500
		explode_dmg = 200
		airstrike_behavior = 0
		// 0 = Default (Near survivors), 1 = Any Nav Mesh, 2 = Any Infected (Including Indoors)

		// Individual airstrike method toggles (1 = enabled, 0 = disabled)
		airstrike_jet = 1
		airstrike_meteor = 1
		airstrike_car = 1
		airstrike_smart = 1
		airstrike_nuke = 1
		airstrike_napalm = 1
		airstrike_barrage = 1
		airstrike_clusterbomb = 1
		airstrike_nuke2 = 1
		airstrike_supplydrop = 1
		airstrike_supplydrop2 = 1

		// Supply Drop 2 Settings
		supplydrop2_min_items = 3
		supplydrop2_max_items = 6

		// Napalm-specific settings
		napalm_line_length = 500
		napalm_fires_per_bomb = 1
		napalm_fire_spread = 150

		// Barrage-specific settings
		barrage_missile_count = 4

		// Cluster bomb-specific settings
		clusterbomb_density = 3
		clusterbomb_spacing = 600
	}

	// Internal list of rock models
	RockModels = [
		"models/props/cs_militia/militiarock01.mdl",
		"models/lostcoast/props_wasteland/rock_coast01a.mdl",
		"models/props_wasteland/rock_moss04.mdl"
	]

	// Internal list for Supply Drops
	SupplyDropItems = [
		"models/props_junk/wood_crate001a.mdl",
		"models/props_junk/wood_crate002a.mdl",
		"models/props_junk/gascan001a.mdl",
		"models/props_junk/propanecanister001a.mdl",
		"weapon_first_aid_kit",
		"weapon_upgradepack_explosive",
		"weapon_upgradepack_incendiary"
	]

	function ParseSettings() {
		local SettingsFileName = "random_airstrikes/Settings.cfg"
		local file = FileToString(SettingsFileName)

		local tData;
		local function SerializeSettings() {
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
			StringToFile(SettingsFileName, sData)
		}
		if (tData = file) {
			try {
				tData = compilestring("return " + tData)()
				local hasMissingKey = false
				foreach(key, val in Settings) {
					if (key in tData) {
						Settings[key] = tData[key]
					} else if (!hasMissingKey) {
						hasMissingKey = true
					}
				}
				if (hasMissingKey) {
					SerializeSettings()
				}
			} catch (error) {
				SerializeSettings()
			}
		} else {
			SerializeSettings();
		}
	}

	function GetEnabledMethods() {
		local enabledModes = [];
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_jet == 1) enabledModes.push(1);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_meteor == 1) enabledModes.push(2);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_car == 1) enabledModes.push(3);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_smart == 1) enabledModes.push(4);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_nuke == 1) enabledModes.push(5);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_napalm == 1) enabledModes.push(6);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_barrage == 1) enabledModes.push(7);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_clusterbomb == 1) enabledModes.push(8);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_nuke2 == 1) enabledModes.push(9);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_supplydrop == 1) enabledModes.push(10);
		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_supplydrop2 == 1) enabledModes.push(11);
		return enabledModes;
	}

	function IfBeginAirStrike() {
		if (Time() < DirectorScript.ChCh_RandomAirStrikes.NextCheckTime) {
			return;
		}
		DirectorScript.ChCh_RandomAirStrikes.NextCheckTime = Time() + 1.0;

		if (DirectorScript.ChCh_RandomAirStrikes.Settings.allowed_gamemodes.find(Director.GetGameModeBase()) != null && DirectorScript.ChCh_RandomAirStrikes.Settings.disallowed_maps.find(Director.GetMapName()) == null) {

			if (Director.HasAnySurvivorLeftSafeArea() && DirectorScript.ChCh_RandomAirStrikes.LeavingTime == null) {
				DirectorScript.ChCh_RandomAirStrikes.LeavingTime = Time();
			}

			if (Director.HasAnySurvivorLeftSafeArea() && !Director.IsFinaleWon() && !Director.IsPlayingIntro() && DirectorScript.ChCh_RandomAirStrikes.LeavingTime != null) {
				if (Time().tointeger() >= (DirectorScript.ChCh_RandomAirStrikes.LeavingTime.tointeger() + 0)) {

					if (Time() >= DirectorScript.ChCh_RandomAirStrikes.NextStrikeTime) {
						if (RandomInt(1, DirectorScript.ChCh_RandomAirStrikes.Settings.one_in_what_chance) == 1) {
							if (DirectorScript.ChCh_RandomAirStrikes.GetEnabledMethods().len() > 0) {
								DirectorScript.ChCh_RandomAirStrikes.DoAirStrike()
							}
						}
					}
				}
			}
		}
	}

	function GetNearToSurvsSpot() {
		local behavior = DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_behavior;

		if (behavior == 2) {
			local candidates = []
			local ent = null

			local limit = 0
			while (ent = Entities.FindByClassname(ent, "infected")) {
				if (ent.IsValid() && ent.GetHealth() > 0) candidates.push(ent)
				limit++;
				if (limit > 100) break;
			}
			ent = null;
			limit = 0;
			while (ent = Entities.FindByClassname(ent, "witch")) {
				if (ent.IsValid() && ent.GetHealth() > 0) candidates.push(ent)
				limit++;
				if (limit > 20) break;
			}
			ent = null;
			limit = 0;
			while (ent = Entities.FindByClassname(ent, "player")) {
				if (ent.IsValid() && !ent.IsSurvivor() && !ent.IsDead() && !ent.IsDying() && !ent.IsGhost()) candidates.push(ent)
				limit++;
				if (limit > 30) break;
			}

			if (candidates.len() > 0) {
				local chosen = candidates[RandomInt(0, candidates.len() - 1)]
				return chosen.GetOrigin()
			}
			return null
		}

		local allnavs = {}
		NavMesh.GetAllAreas(allnavs)

		if (behavior == 1) {
			local navList = []
			foreach(nav in allnavs) {
				navList.push(nav)
			}
			if (navList.len() > 0) {
				return navList[RandomInt(0, navList.len() - 1)].FindRandomSpot()
			}
			return null
		}

		local survivors = []
		local player = null
		while (player = Entities.FindByClassname(player, "player")) {
			if (player.IsSurvivor() && !player.IsDead() && !player.IsDying()) {
				survivors.push(player)
			}
		}

		if (survivors.len() == 0) return null

		local randomSurv = survivors[RandomInt(0, survivors.len() - 1)]
		local randomSurvFlow = GetFlowPercentForPosition(randomSurv.GetOrigin(), true)
		local variance = DirectorScript.ChCh_RandomAirStrikes.Settings.nav_percent_dist_variance
		local candidates = []

		foreach(nav in allnavs) {
			local area = nav.FindRandomSpot()
			local areaFlow = GetFlowPercentForPosition(area, true)
			if (areaFlow == null) areaFlow = 0
			if (areaFlow <= randomSurvFlow + variance && areaFlow >= randomSurvFlow - variance) {
				candidates.push(area)
			}
		}

		if (candidates.len() > 0) {
			return candidates[RandomInt(0, candidates.len() - 1)]
		}

		return null
	}

	function GetHighestPointFromSomewhere(where) {
		local traceTable = {
			start = where + Vector(0, 0, 10)
			end = where + Vector(0, 0, 2000)
			ignore = null
		}
		if (TraceLine(traceTable)) {
			if (traceTable.hit) {
				local height = (traceTable.pos - where).Length()

				if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_behavior != 2 && height < 450) {
					return null
				}
			}
		}
		return where
	}

	function CreateNapalmFire(where, attacker = null) {
		local gascan = SpawnEntityFromTable("prop_physics", {
			targetname = "napalm_gascan_" + Time().tostring() + "_" + RandomInt(0, 99999),
			model = "models/props_junk/gascan001a.mdl",
			origin = where + Vector(0, 0, 5),
			angles = Vector(0, 0, 0),
			disableshadows = 1,
			spawnflags = 0
		});

		if (gascan && gascan.IsValid()) {
			gascan.ValidateScriptScope();
			gascan.__KeyValueFromInt("rendermode", 10);
			NetProps.SetPropInt(gascan, "m_MoveType", 0);
			NetProps.SetPropInt(gascan, "m_Glow.m_iGlowType", 3);
			NetProps.SetPropInt(gascan, "m_Glow.m_glowColorOverride", 1);

			local scope = gascan.GetScriptScope();
			scope.gasRef <- gascan;
			scope.attackerRef <- attacker;
			scope.spawnTime <- Time();

			scope.GascanDetonateThink <- function() {
				if (Time() - spawnTime >= 0.15) {
					if (gasRef && gasRef.IsValid()) {
						local att = attackerRef;
						if (!att || !att.IsValid()) {
							att = Entities.First();
						}
						gasRef.TakeDamage(999.9, 0, att);
					}
					return null;
				}
				return 0.03;
			}

			AddThinkToEnt(gascan, "GascanDetonateThink");
		}
	}

	function CreateNapalmFireCluster(centerPos, spreadRadius, fireCount, attacker = null) {
		for (local i = 0; i < fireCount; i++) {
			local offsetX = RandomFloat(-spreadRadius, spreadRadius);
			local offsetY = RandomFloat(-spreadRadius, spreadRadius);
			local firePos = centerPos + Vector(offsetX, offsetY, 0);

			local groundTrace = {
				start = firePos + Vector(0, 0, 50),
				end = firePos - Vector(0, 0, 200),
				ignore = null
			};

			if (TraceLine(groundTrace) && groundTrace.hit) {
				firePos = groundTrace.pos + Vector(0, 0, 2);
			}

			local delay = i * 0.05;

			if (delay > 0) {
				local posX = firePos.x;
				local posY = firePos.y;
				local posZ = firePos.z;
				EntFire("worldspawn", "RunScriptCode",
					"DirectorScript.ChCh_RandomAirStrikes.CreateNapalmFire(Vector(" + posX + "," + posY + "," + posZ + "), null)",
					delay, null);
			} else {
				DirectorScript.ChCh_RandomAirStrikes.CreateNapalmFire(firePos, attacker);
			}
		}
	}

	function SpawnClusterBombExplosion(centerPos, density, spacing) {
		local halfGrid = (density - 1) / 2.0;
		local propaneTanks = [];

		for (local i = 0; i < density; i++) {
			for (local j = 0; j < density; j++) {
				local offsetX = (i - halfGrid) * spacing;
				local offsetY = (j - halfGrid) * spacing;
				local tankPos = centerPos + Vector(offsetX, offsetY, 0);

				local groundTrace = {
					start = tankPos + Vector(0, 0, 100),
					end = tankPos - Vector(0, 0, 500),
					ignore = null
				};
				if (TraceLine(groundTrace) && groundTrace.hit) {
					tankPos = groundTrace.pos + Vector(0, 0, 5);
				}

				local tank = SpawnEntityFromTable("prop_physics", {
					targetname = "clusterbomb_propane_" + Time().tostring() + "_" + i + "_" + j,
					model = "models/props_junk/propanecanister001a.mdl",
					origin = tankPos,
					angles = Vector(0, RandomInt(0, 360), 0),
					spawnflags = 0
				});

				if (tank && tank.IsValid()) {
					tank.ValidateScriptScope();
					tank.__KeyValueFromInt("rendermode", 10);
					NetProps.SetPropInt(tank, "m_MoveType", 0);
					propaneTanks.push(tank);
				}
			}
		}

		local delay = 0.0;
		foreach(tank in propaneTanks) {
			if (tank && tank.IsValid()) {
				local tankIdx = tank.GetEntityIndex();
				EntFire("worldspawn", "RunScriptCode",
					"local t = EntIndexToHScript(" + tankIdx + "); if(t && t.IsValid()) t.TakeDamage(999.9, 0, Entities.First());",
					delay, null);
				delay += 0.03;
			}
		}

		local soundtarget = SpawnEntityFromTable("info_target", {
			origin = centerPos
		});
		EmitAmbientSoundOn("ambient/explosions/explode_1.wav", 1.0, 140, RandomInt(90, 110), soundtarget);
		EntFire("worldspawn", "RunScriptCode", "EntIndexToHScript(" + soundtarget.GetEntityIndex() + ").Kill()", 5.0, null);
	}

	function LaunchClusterBombProjectile(startPos, endPos, timeToImpact, explosionAngles, modelName, particleName) {
		local halfwayTime = timeToImpact / 2.0;
		local halfwayPos = startPos + (endPos - startPos) * 0.5;

		local timer = SpawnEntityFromTable("info_target", {
			origin = startPos
		});
		timer.ValidateScriptScope();
		local scope = timer.GetScriptScope();

		scope.startPos <- startPos;
		scope.endPos <- endPos;
		scope.halfwayPos <- halfwayPos;
		scope.targetPos <- endPos;

		scope.spawnTime <- Time() + 3.0;

		scope.halfwayTime <- halfwayTime;
		scope.explosionAngles <- explosionAngles;
		scope.mdlName <- modelName;
		scope.partName <- particleName;
		scope.missile <- null;
		scope.spawned <- false;
		scope.hasDisappeared <- false;
		scope.disappearTime <- 0.0;
		scope.explosionTriggered <- false;

		scope.ClusterBombThink <- function() {
			local curTime = Time();

			if (curTime < spawnTime) {
				return 0.1;
			}

			local elapsed = curTime - spawnTime;

			if (!spawned) {
				local missileName = "clusterbomb_proj_" + curTime.tostring() + "_" + RandomInt(0, 9999).tostring();
				missile = SpawnEntityFromTable("prop_dynamic", {
					targetname = missileName,
					origin = startPos,
					angles = "90 0 0",
					model = mdlName,
					solid = 0
				});
				missile.ValidateScriptScope();
				spawned = true;
				return 0.03;
			}

			if (!hasDisappeared) {
				if (missile && missile.IsValid()) {
					local pct = elapsed / halfwayTime;

					local fire = SpawnEntityFromTable("info_particle_system", {
						origin = missile.GetOrigin(),
						effect_name = partName,
						start_active = 1
					});
					DoEntFire("!self", "Kill", "", 0.5, null, fire);

					if (pct >= 1.0) {
						local disappearPos = missile.GetOrigin();
						local fireworksParticle = SpawnEntityFromTable("info_particle_system", {
							origin = disappearPos,
							angles = "90 0 0",
							effect_name = "fireworks_explosion_02",
							start_active = 1,
							flag_as_weather = 0
						});
						DoEntFire("!self", "Stop", "", 3.0, null, fireworksParticle);
						DoEntFire("!self", "Kill", "", 3.1, null, fireworksParticle);

						local soundtarget = SpawnEntityFromTable("info_target", {
							origin = disappearPos
						});
						EmitAmbientSoundOn("weapons/hegrenade/explode3.wav", 0.8, 100, RandomInt(120, 140), soundtarget);
						DoEntFire("!self", "Kill", "", 2.0, null, soundtarget);

						missile.Kill();
						hasDisappeared = true;
						disappearTime = curTime;
						return 0.03;
					}

					local moveVec = halfwayPos - startPos;
					local newPos = startPos + (moveVec * pct);
					missile.SetOrigin(newPos);
				}
			} else if (!explosionTriggered) {
				if (curTime - disappearTime >= 1.0) {
					local density = DirectorScript.ChCh_RandomAirStrikes.Settings.clusterbomb_density;
					local spacing = DirectorScript.ChCh_RandomAirStrikes.Settings.clusterbomb_spacing;
					DirectorScript.ChCh_RandomAirStrikes.SpawnClusterBombExplosion(targetPos, density, spacing);
					explosionTriggered = true;
					self.Kill();
					return null;
				}
			} else {
				self.Kill();
				return null;
			}

			return 0.03;
		}

		AddThinkToEnt(timer, "ClusterBombThink");
	}

	function LaunchCarDrop(spawnPos, delayTime) {
		local timer = SpawnEntityFromTable("info_target", {
			origin = spawnPos
		});
		timer.ValidateScriptScope();
		local scope = timer.GetScriptScope();

		scope.spawnPos <- spawnPos;
		scope.spawnTime <- Time() + delayTime;
		scope.spawned <- false;

		scope.CarDropThink <- function() {
			if (!spawned && Time() >= spawnTime) {
				local car = SpawnEntityFromTable("prop_physics", {
					targetname = "airstrike_car_" + Time().tostring(),
					origin = spawnPos,
					angles = Vector(RandomInt(0, 360), RandomInt(0, 360), RandomInt(0, 360)),
					model = "models/props_vehicles/cara_95sedan.mdl"
				});

				if (car && car.IsValid()) {
					if ("ExCarYammy" in getroottable()) {
						local carIndex = car.GetEntityIndex();
						local maxHP = ::ExCarYammy.maxcarhp;::ExCarYammy.CarArgs[carIndex] <- maxHP * 0.95;

						if ("ExCarYam" in getroottable() && "HitCar" in ::ExCarYam) {
							::ExCarYam.HitCar({
								Victim = car,
								New_DamageDone = 1,
								Inflictor = car,
								Attacker = car
							});
						}
					}

					car.ValidateScriptScope();
					local carScope = car.GetScriptScope();
					carScope.carRef <- car;

					carScope.CleanupCar <- function() {
						if (carRef && carRef.IsValid()) {
							StopSoundOn("ambient/fire/fire_small_loop2.wav", carRef);
							StopSoundOn("ambient/fire/fire_med_loop1.wav", carRef);
							StopSoundOn("ambient/fire/fire_big_loop1.wav", carRef);
							StopSoundOn("vehicles/car_alarm/car_alarm_loop1.wav", carRef);
							carRef.Kill();
						}
					}

					carScope.spawnTime <- Time();
					carScope.CleanupThink <- function() {
						if (Time() - spawnTime >= 100.0) {
							CleanupCar();
							return null;
						}
						return 1.0;
					}
					AddThinkToEnt(car, "CleanupThink");
				}

				spawned = true;
				self.Kill();
				return null;
			}
			return 0.1;
		}

		AddThinkToEnt(timer, "CarDropThink");
	}

	function LaunchSupplyDrop(spawnPos, delayTime) {
		local timer = SpawnEntityFromTable("info_target", {
			origin = spawnPos
		});
		timer.ValidateScriptScope();
		local scope = timer.GetScriptScope();

		scope.spawnPos <- spawnPos;
		scope.spawnTime <- Time() + delayTime;
		scope.spawned <- false;

		scope.SupplyDropThink <- function() {
			if (!spawned && Time() >= spawnTime) {
				local items = DirectorScript.ChCh_RandomAirStrikes.SupplyDropItems;
				local item = items[RandomInt(0, items.len() - 1)];

				if (item.find(".mdl") != null) {
					local dropEnt = SpawnEntityFromTable("prop_physics", {
						targetname = "airstrike_supply_" + Time().tostring(),
						origin = spawnPos,
						angles = Vector(RandomInt(0, 360), RandomInt(0, 360), RandomInt(0, 360)),
						model = item
					});
				} else {
					local dropEnt = SpawnEntityFromTable(item, {
						origin = spawnPos,
						angles = Vector(0, RandomInt(0, 360), 0)
					});
				}

				spawned = true;
				self.Kill();
				return null;
			}
			return 0.1;
		}

		AddThinkToEnt(timer, "SupplyDropThink");
	}

	function LaunchSlowMissile(startPos, endPos, delayTime, flightDuration) {
		local timer = SpawnEntityFromTable("info_target", {
			origin = startPos
		});
		timer.ValidateScriptScope();
		local scope = timer.GetScriptScope();

		scope.startPos <- startPos;
		scope.endPos <- endPos;
		scope.spawnTime <- Time() + delayTime;
		scope.flightDuration <- flightDuration;
		scope.spawned <- false;
		scope.missile <- null;

		scope.SlowDropThink <- function() {
			local curTime = Time();

			if (!spawned) {
				if (curTime >= spawnTime) {
					local missileName = "nuke2_missile_" + curTime.tostring();
					missile = SpawnEntityFromTable("prop_dynamic", {
						targetname = missileName,
						origin = startPos,
						angles = "90 0 0",
						model = "models/missiles/f18_agm65maverick.mdl",
						solid = 0
					});
					missile.ValidateScriptScope();
					spawned = true;
				}
				return 0.03;
			}

			if (missile && missile.IsValid()) {
				local elapsedTime = curTime - spawnTime;

				local fire = SpawnEntityFromTable("info_particle_system", {
					origin = missile.GetOrigin(),
					effect_name = "rock_flying_fire",
					start_active = 1
				});
				DoEntFire("!self", "Kill", "", 0.2, null, fire);

				if (elapsedTime >= flightDuration) {
					DirectorScript.ChCh_RandomAirStrikes.NukeThePlace(endPos, "0 0 0", 9);
					missile.Kill();
					self.Kill();
					return null;
				}

				local pct = elapsedTime / flightDuration;
				local newPos = startPos + ((endPos - startPos) * pct);
				missile.SetOrigin(newPos);

			} else if (spawned) {
				self.Kill();
			}

			return 0.03;
		}
		AddThinkToEnt(timer, "SlowDropThink");
	}

	function LaunchProjectile(startPos, endPos, timeToImpact, explosionAngles, modelName, particleName, tumble, travelDuration = 0.25, strikeMode = 1) {
		local flightDuration = travelDuration;
		local waitTime = timeToImpact - flightDuration;
		if (waitTime < 0) {
			waitTime = 0;
			flightDuration = timeToImpact;
		}

		local timer = SpawnEntityFromTable("info_target", {
			origin = startPos
		});
		timer.ValidateScriptScope();
		local scope = timer.GetScriptScope();

		scope.startPos <- startPos;
		scope.endPos <- endPos;
		scope.targetZ <- endPos.z;
		scope.spawnTime <- Time() + waitTime;
		scope.flightDuration <- flightDuration;
		scope.explosionAngles <- explosionAngles;
		scope.mdlName <- modelName;
		scope.partName <- particleName;
		scope.shouldTumble <- tumble;
		scope.missile <- null;
		scope.spawned <- false;
		scope.strikeMode <- strikeMode;

		scope.MissileThink <- function() {
			local curTime = Time();

			if (!spawned) {
				if (curTime >= spawnTime) {
					local missileName = "proj_" + curTime.tostring() + "_" + RandomInt(0, 9999).tostring();
					missile = SpawnEntityFromTable("prop_dynamic_override", {
						targetname = missileName,
						origin = startPos,
						angles = "90 0 0",
						model = mdlName,
						solid = 0
					});
					missile.ValidateScriptScope();
					spawned = true;
				}
				return 0.03;
			}

			if (missile && missile.IsValid()) {
				local progressTime = curTime - spawnTime;
				local fire = SpawnEntityFromTable("info_particle_system", {
					origin = missile.GetOrigin(),
					effect_name = partName,
					start_active = 1,
					parentname = missile.GetName()
				});
				DoEntFire("!self", "Kill", "", 0.5, null, fire);

				if (shouldTumble) {
					local ang = missile.GetAngles();
					local p = ang.Pitch() + 10;
					local y = ang.Yaw() + 15;
					local r = ang.Roll() + 5;
					missile.__KeyValueFromString("angles", p + " " + y + " " + r);
				} else {
					if (strikeMode == 7) {
						local vel = endPos - startPos;
						missile.SetForwardVector(vel);
					}
				}

				if (progressTime >= flightDuration || missile.GetOrigin().z <= targetZ) {
					DirectorScript.ChCh_RandomAirStrikes.NukeThePlace(endPos, explosionAngles, strikeMode);
					missile.Kill();
					self.Kill();
					return;
				}

				local pct = progressTime / flightDuration;
				if (pct > 1.0) pct = 1.0;

				local moveVec = endPos - startPos;
				local newPos = startPos + (moveVec * pct);

				missile.SetOrigin(newPos);
			} else if (spawned && (!missile || !missile.IsValid())) {
				self.Kill();
			}

			return 0.03;
		}

		AddThinkToEnt(timer, "MissileThink");
	}

	function LaunchHomingProjectile(startPos, initialTargetPos, spawnDelay, modelName, particleName, strikeMode = 4) {
		local timer = SpawnEntityFromTable("info_target", {
			origin = startPos
		});
		timer.ValidateScriptScope();
		local scope = timer.GetScriptScope();

		local dir = initialTargetPos - startPos;
		local len = dir.Length();
		if (len > 0.001) {
			dir = dir * (1.0 / len);
		} else {
			dir = Vector(0, 0, -1);
		}

		scope.startPos <- startPos;
		scope.currentPos <- startPos;
		scope.spawnTime <- Time() + spawnDelay;
		scope.mdlName <- modelName;
		scope.partName <- particleName;
		scope.missile <- null;
		scope.spawned <- false;
		scope.strikeMode <- strikeMode;

		scope.speed <- 35.0;
		scope.turnRate <- 0.15;
		scope.velocity <- dir;

		scope.HomingThink <- function() {
			local curTime = Time();

			if (!spawned) {
				if (curTime >= spawnTime) {
					local missileName = "homing_proj_" + curTime.tostring() + "_" + RandomInt(0, 9999).tostring();
					missile = SpawnEntityFromTable("prop_dynamic_override", {
						targetname = missileName,
						origin = startPos,
						angles = "90 0 0",
						model = mdlName,
						solid = 0
					});
					missile.ValidateScriptScope();
					spawned = true;
					missile.SetForwardVector(velocity);
				}
				return 0.03;
			}

			if (missile && missile.IsValid()) {

				local searchRadius = 1500.0;
				local bestTarget = null;
				local closestDist = searchRadius;

				local ent = null;
				while (ent = Entities.FindByClassnameWithin(ent, "infected", currentPos, searchRadius)) {
					if (ent.IsValid() && ent.GetHealth() > 0) {
						local d = (ent.GetOrigin() - currentPos).Length();
						if (d < closestDist) {
							closestDist = d;
							bestTarget = ent;
						}
					}
				}

				ent = null;
				while (ent = Entities.FindByClassnameWithin(ent, "witch", currentPos, searchRadius)) {
					if (ent.IsValid() && ent.GetHealth() > 0) {
						local d = (ent.GetOrigin() - currentPos).Length();
						if (d < closestDist) {
							closestDist = d;
							bestTarget = ent;
						}
					}
				}

				ent = null;
				while (ent = Entities.FindByClassnameWithin(ent, "player", currentPos, searchRadius)) {
					if (ent.IsValid() && !ent.IsDead() && !ent.IsDying()) {
						local isValidPlayer = true;
						if (!ent.IsSurvivor()) {
							if (ent.IsGhost()) isValidPlayer = false;
						}

						if (isValidPlayer) {
							local d = (ent.GetOrigin() - currentPos).Length();
							if (d < closestDist) {
								closestDist = d;
								bestTarget = ent;
							}
						}
					}
				}

				if (bestTarget != null) {
					local targetDir = (bestTarget.GetOrigin() + Vector(0, 0, 40)) - currentPos;

					local tLen = targetDir.Length();
					if (tLen > 0.001) {
						targetDir = targetDir * (1.0 / tLen);
						velocity = velocity + (targetDir - velocity) * turnRate;
					}
				} else {
					velocity = velocity + (Vector(0, 0, -1) - velocity) * 0.02;
				}

				local vLen = velocity.Length();
				if (vLen > 0.001) {
					velocity = velocity * (1.0 / vLen);
				}

				local step = velocity * speed;
				local nextPos = currentPos + step;

				local trace = {
					start = currentPos,
					end = nextPos,
					ignore = missile,
					mask = 33636363
				};

				if (TraceLine(trace) && trace.hit) {
					local bangAngles = "0 0 0";
					DirectorScript.ChCh_RandomAirStrikes.NukeThePlace(trace.pos, bangAngles, strikeMode);
					missile.Kill();
					self.Kill();
					return;
				}

				currentPos = nextPos;
				missile.SetOrigin(currentPos);
				missile.SetForwardVector(velocity);

				local fire = SpawnEntityFromTable("info_particle_system", {
					origin = currentPos,
					effect_name = partName,
					start_active = 1,
					parentname = missile.GetName()
				});
				DoEntFire("!self", "Kill", "", 0.5, null, fire);

				if (curTime > spawnTime + 10.0 || currentPos.z < -3000) {
					missile.Kill();
					self.Kill();
				}

			} else if (spawned && (!missile || !missile.IsValid())) {
				self.Kill();
			}

			return 0.03;
		}

		AddThinkToEnt(timer, "HomingThink");
	}

	function NukeThePlace(where, angless, currentMode = 1) {
		local finalRadius = DirectorScript.ChCh_RandomAirStrikes.Settings.explode_radius;
		local finalDmg = DirectorScript.ChCh_RandomAirStrikes.Settings.explode_dmg;

		local soundtarget = SpawnEntityFromTable("info_target", {
			origin = where
		})
		soundtarget.ValidateScriptScope()

		if (currentMode == 6) { // Napalm
			local napalmPart1 = SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "gas_explosion_ground_fire",
				start_active = 1,
				flag_as_weather = 0
			})

			local napalmPart2 = SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "weapon_molotov",
				start_active = 1,
				flag_as_weather = 0
			})

			if (napalmPart1.IsValid()) {
				DoEntFire("!self", "Stop", "", 16.0, null, napalmPart1);
				DoEntFire("!self", "Kill", "", 16.1, null, napalmPart1);
			}
			if (napalmPart2.IsValid()) {
				DoEntFire("!self", "Stop", "", 16.0, null, napalmPart2);
				DoEntFire("!self", "Kill", "", 16.1, null, napalmPart2);
			}

			EmitAmbientSoundOn("weapons/molotov/fire_ignite_2.wav", 1.0, 120, RandomInt(95, 105), soundtarget)
			local boomnum = RandomInt(1, 3).tostring()
			EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 0.7, 100, RandomInt(95, 105), soundtarget)

			finalDmg = (finalDmg * 0.5).tointeger();
			finalRadius = (finalRadius * 0.7).tointeger();

			local firesPerBomb = DirectorScript.ChCh_RandomAirStrikes.Settings.napalm_fires_per_bomb;
			local fireSpread = DirectorScript.ChCh_RandomAirStrikes.Settings.napalm_fire_spread;
			DirectorScript.ChCh_RandomAirStrikes.CreateNapalmFireCluster(where, fireSpread, firesPerBomb, null);

		} else if (currentMode == 9) { // C-130 Nuke Mode

			// Base Particle
			local p1 = SpawnEntityFromTable("info_particle_system", {
				origin = where,
				effect_name = "gas_explosion_main",
				start_active = 1
			});
			DoEntFire("!self", "Stop", "", 7.0, null, p1);
			DoEntFire("!self", "Kill", "", 8.0, null, p1);

			// Vertical Column (4 Frames)
			for (local i = 1; i <= 4; i++) {
				local p2 = SpawnEntityFromTable("info_particle_system", {
					origin = where + Vector(0, 0, 500 * i),
					effect_name = "fluidExplosion_frames",
					start_active = 1
				});
				DoEntFire("!self", "Kill", "", 4.0, null, p2);
			}

			local p3 = SpawnEntityFromTable("info_particle_system", {
				origin = where + Vector(0, 0, 1200),
				effect_name = "explosion_silo",
				start_active = 1
			});
			DoEntFire("!self", "Stop", "", 3.0, null, p3);
			DoEntFire("!self", "Kill", "", 3.0, null, p3);

			EmitAmbientSoundOn("animation/tanker_explosion.wav", 1.0, 150, 90, soundtarget);
			finalRadius = finalRadius * 3;
			finalDmg = finalDmg * 3;

			local ent = null;
			local pushRadius = 800;
			local force = 1500.0;
			local classesToPush = ["player", "infected", "witch", "prop_physics"];

			foreach(cls in classesToPush) {
				local ent = null;
				while (ent = Entities.FindByClassnameWithin(ent, cls, where, pushRadius)) {
					if (ent.IsValid()) {
						local dir = ent.GetOrigin() - where;
						dir.Norm();
						local pushVec = Vector(dir.x * force, dir.y * force, 400);

						if (cls == "player") {
							if (ent.IsSurvivor() || !ent.IsGhost()) {
								ent.ApplyAbsVelocityImpulse(pushVec);
							}
						} else {
							ent.ApplyAbsVelocityImpulse(pushVec);
						}
					}
				}
			}

		} else if (currentMode == 5) {
			local nukeParticle = SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "gas_explosion_main",
				start_active = 1,
				flag_as_weather = 0
			})

			DoEntFire("!self", "Stop", "", 10.0, null, nukeParticle)
			DoEntFire("!self", "Kill", "", 11.0, null, nukeParticle)

			EmitAmbientSoundOn("animation/tanker_explosion.wav", 1.0, 150, 100, soundtarget)

			finalRadius = finalRadius * 2;
		} else {
			SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "weapon_grenadelauncher",
				start_active = 1,
				flag_as_weather = 0
			})
			SpawnEntityFromTable("info_particle_system", {
				origin = where,
				angles = angless,
				effect_name = "gas_explosion_chunks_02",
				start_active = 1,
				flag_as_weather = 0
			})

			local boomnum = RandomInt(1, 3).tostring()
			EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 1.0, 120, RandomInt(95, 105), soundtarget)
			EmitAmbientSoundOn("ambient/explosions/explode_" + boomnum + ".wav", 1.0, 120, RandomInt(95, 105), soundtarget)
		}

		local boom = SpawnEntityFromTable("env_explosion", {
			origin = where,
			angles = angless,
			iMagnitude = finalDmg,
			iRadiusOverride = finalRadius,
			spawnflags = 68
		})
		boom.ValidateScriptScope()
		DoEntFire("!self", "Explode", "", 0.0, null, boom)

		local player = null
		while (player = Entities.FindByClassnameWithin(player, "player", where, finalRadius)) {
			player.Stagger(where)
		}

		if (DirectorScript.ChCh_RandomAirStrikes.Settings.summon_horde >= 1) {
			EntFire("worldspawn", "RunScriptCode", "Director.ResetMobTimer()", RandomFloat(3, 4), null)
		}
		EntFire("worldspawn", "RunScriptCode", "EntIndexToHScript(" + soundtarget.GetEntityIndex().tostring() + ").Kill()", 12, null)
	}

	function DoAirStrike() {
		local enabledModes = DirectorScript.ChCh_RandomAirStrikes.GetEnabledMethods();

		if (enabledModes.len() == 0) {
			return;
		}

		local mode = enabledModes[RandomInt(0, enabledModes.len() - 1)];

		local spot = DirectorScript.ChCh_RandomAirStrikes.GetNearToSurvsSpot();

		if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_behavior == 2 && (mode == 10 || mode == 11)) {
			if (RandomInt(1, 100) <= 75) {
				local survivors = []
				local player = null
				while (player = Entities.FindByClassname(player, "player")) {
					if (player.IsSurvivor() && !player.IsDead() && !player.IsDying()) {
						survivors.push(player)
					}
				}

				if (survivors.len() > 0) {
					spot = survivors[RandomInt(0, survivors.len() - 1)].GetOrigin()
				}
			}
		}

		local strikepos = null
		if (spot != null) {
			strikepos = DirectorScript.ChCh_RandomAirStrikes.GetHighestPointFromSomewhere(spot)
		}

		if (strikepos) {
			if (mode == 8) {
				local jetZ = strikepos.z + 1000;
				local traceUp = {
					start = strikepos + Vector(0, 0, 10),
					end = strikepos + Vector(0, 0, 3000),
					ignore = null
				}

				if (TraceLine(traceUp) && traceUp.hit) {
					if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_behavior != 2) {
						local ceilingZ = traceUp.pos.z
						local possibleZ = ceilingZ - 0
						if (possibleZ < jetZ) jetZ = possibleZ
					}
				}
				if (jetZ < strikepos.z + 500) jetZ = strikepos.z + 500

				local angles = "0 " + RandomInt(0, 360).tostring() + " 0"
				local plane = SpawnEntityFromTable("prop_dynamic", {
					origin = Vector(strikepos.x, strikepos.y, jetZ),
					angles = angles,
					model = "models/f18/f18.mdl",
					fademindist = -1,
					fademaxdist = 0,
					solid = 0
				})
				plane.ValidateScriptScope()

				local planimation = "flyby" + RandomInt(1, 5).tostring();
				local boomtime = 2.6;
				if (planimation.slice(5, 6).tointeger() >= 3) boomtime = 3.2;

				EntityOutputs.AddOutput(plane, "OnAnimationDone", "!self", "Kill", "", 0.0, 1)
				DoEntFire("!self", "SetAnimation", planimation, 0.0, null, plane)

				EntFire("worldspawn", "RunScriptCode",
					"EmitAmbientSoundOn(\"animation/jets/jet_by_0\" + RandomInt(1,2).tostring() + \"_mono.wav\", 1.0, 0, RandomInt(95,105), Entities.First())",
					boomtime - 1, null);

				if (DirectorScript.ChCh_RandomAirStrikes.Settings.drop_bomb >= 1) {
					local impactTime = boomtime + RandomFloat(0.2, 0.5);

					DirectorScript.ChCh_RandomAirStrikes.LaunchClusterBombProjectile(
						Vector(strikepos.x, strikepos.y, jetZ),
						strikepos,
						impactTime,
						angles,
						"models/missiles/f18_agm65maverick.mdl",
						"molotov_explosion"
					);
				}
			}
			else if (mode == 7) {
				local jetZ = strikepos.z + 1000;
				local traceUp = {
					start = strikepos + Vector(0, 0, 10),
					end = strikepos + Vector(0, 0, 3000),
					ignore = null
				}

				if (TraceLine(traceUp) && traceUp.hit) {
					if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_behavior != 2) {
						local ceilingZ = traceUp.pos.z
						local possibleZ = ceilingZ - 250
						if (possibleZ < jetZ) jetZ = possibleZ
					}
				}
				if (jetZ < strikepos.z + 300) jetZ = strikepos.z + 300

				local angleInt = RandomInt(0, 360);
				local angles = "0 " + angleInt.tostring() + " 0";
				local angleRad = angleInt * 3.14159 / 180.0;
				local fwdVec = Vector(cos(angleRad), sin(angleRad), 0);
				local rightVec = Vector(cos(angleRad + 1.5708), sin(angleRad + 1.5708), 0);

				local formationOffsets = [0, -800, 800];
				local formationLag = [0, -400, -400];

				for (local i = 0; i < 3; i++) {
					local offsetPos = Vector(strikepos.x, strikepos.y, jetZ) + (rightVec * formationOffsets[i]) + (fwdVec * formationLag[i]);

					local plane = SpawnEntityFromTable("prop_dynamic", {
						origin = offsetPos,
						angles = angles,
						model = "models/f18/f18.mdl",
						fademindist = -1,
						fademaxdist = 0,
						solid = 0
					})
					plane.ValidateScriptScope()

					local planimation = "flyby1";

					EntityOutputs.AddOutput(plane, "OnAnimationDone", "!self", "Kill", "", 0.0, 1)
					DoEntFire("!self", "SetAnimation", planimation, 0.0, null, plane)
					DoEntFire("!self", "SetPlaybackRate", "0.5", 0.01, null, plane)
				}

				local boomtime = 5.0;
				EntFire("worldspawn", "RunScriptCode", "EmitAmbientSoundOn(\"animation/jets/jet_by_0\" + RandomInt(1,2).tostring() + \"_mono.wav\", 1.0, 0, RandomInt(95,105), Entities.First())", 4.5, null);
				EntFire("worldspawn", "RunScriptCode", "EmitAmbientSoundOn(\"animation/jets/jet_by_0\" + RandomInt(1,2).tostring() + \"_mono.wav\", 1.0, 0, RandomInt(95,105), Entities.First())", 5.0, null);

				if (DirectorScript.ChCh_RandomAirStrikes.Settings.drop_bomb >= 1) {
					local missileCount = DirectorScript.ChCh_RandomAirStrikes.Settings.barrage_missile_count;
					local duration = 2.0;
					local interval = duration / missileCount;

					local startDropTime = (boomtime - 0.5) - 1.0;

					for (local i = 0; i < missileCount; i++) {
						local planeIdx = i % 3;
						local planeBasePos = Vector(strikepos.x, strikepos.y, jetZ) + (rightVec * formationOffsets[planeIdx]);

						local backOffset = 800 - (i * 100);
						local slopeStartPos = planeBasePos + (fwdVec * backOffset);

						local forwardSpread = (i * 150) - (missileCount * 75);
						local sideSpread = RandomInt(-150, 150);
						local impactPos = strikepos + (fwdVec * forwardSpread) + (rightVec * sideSpread);

						local groundTrace = {
							start = impactPos + Vector(0, 0, 500),
							end = impactPos - Vector(0, 0, 1000),
							ignore = null
						};
						if (TraceLine(groundTrace) && groundTrace.hit) impactPos = groundTrace.pos;

						local impactTime = startDropTime + (i * interval);
						local travelTime = 0.5;

						DirectorScript.ChCh_RandomAirStrikes.LaunchProjectile(
							slopeStartPos,
							impactPos,
							impactTime,
							angles,
							"models/missiles/f18_agm65maverick.mdl",
							"molotov_explosion",
							false,
							travelTime,
							mode
						);
					}
				}
			}
			// === MODE 1: JET / MODE 3: CAR / MODE 4: SMART / MODE 5: NUKE / MODE 9: NUKE 2 / MODE 10: SUPPLY DROP 1 / MODE 11: SUPPLY DROP 2 ===
			else if (mode == 1 || mode == 3 || mode == 4 || mode == 5 || mode == 9 || mode == 10 || mode == 11) {
				local jetZ = strikepos.z + 1000;
				local traceUp = {
					start = strikepos + Vector(0, 0, 10),
					end = strikepos + Vector(0, 0, 3000),
					ignore = null
				}

				if (TraceLine(traceUp) && traceUp.hit) {
					if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_behavior != 2) {
						local ceilingZ = traceUp.pos.z
						local possibleZ = ceilingZ - 250
						if (possibleZ < jetZ) jetZ = possibleZ
					}
				}
				if (jetZ < strikepos.z + 300) jetZ = strikepos.z + 300

				local planeMdl = "models/f18/f18.mdl";
				if (mode == 3 || mode == 9 || mode == 10 || mode == 11) planeMdl = "models/props_vehicles/c130.mdl";

				local planeAngleInt = RandomInt(0, 360);
				local angles = "0 " + planeAngleInt.tostring() + " 0"
				local plane = SpawnEntityFromTable("prop_dynamic", {
					origin = Vector(strikepos.x, strikepos.y, jetZ),
					angles = angles,
					model = planeMdl,
					fademindist = -1,
					fademaxdist = 0,
					solid = 0
				})
				plane.ValidateScriptScope()

				local planimation = "";
				local boomtime = 2.6;

				if (mode == 3 || mode == 9 || mode == 10 || mode == 11) {
					planimation = "airport_intro_flyby";
					boomtime = 6.0;
					EntFire("worldspawn", "RunScriptCode", "EmitAmbientSoundOn(\"animation/plane_flyover_short.wav\", 0.2, 0, 100, Entities.First())", 0.0, null);
				} else if (mode == 5) {
					planimation = "flyby" + RandomInt(1, 5).tostring();
					if (planimation.slice(5, 6).tointeger() >= 3) boomtime = 3.2;
					EntFire("worldspawn", "RunScriptCode", "EmitAmbientSoundOn(\"animation/jets/jet_by_0\" + RandomInt(1,2).tostring() + \"_mono.wav\", 1.0, 0, RandomInt(95,105), Entities.First())", boomtime - 1, null);
				} else {
					planimation = "flyby" + RandomInt(1, 5).tostring();
					if (planimation.slice(5, 6).tointeger() >= 3) boomtime = 3.2;
					EntFire("worldspawn", "RunScriptCode", "EmitAmbientSoundOn(\"animation/jets/jet_by_0\" + RandomInt(1,2).tostring() + \"_mono.wav\", 1.0, 0, RandomInt(95,105), Entities.First())", boomtime - 1, null);
				}

				EntityOutputs.AddOutput(plane, "OnAnimationDone", "!self", "Kill", "", 0.0, 1)
				DoEntFire("!self", "SetAnimation", planimation, 0.0, null, plane)

				if (DirectorScript.ChCh_RandomAirStrikes.Settings.drop_bomb >= 1) {
					if (mode == 1) {
						local impactTime = boomtime + RandomFloat(0.2, 0.5);
						DirectorScript.ChCh_RandomAirStrikes.LaunchProjectile(
							Vector(strikepos.x, strikepos.y, jetZ),
							strikepos,
							impactTime,
							angles,
							"models/missiles/f18_agm65maverick.mdl",
							"molotov_explosion",
							false,
							0.25,
							mode
						);
					} else if (mode == 5) {
						local travelTime = 0.25;
						local impactTime = boomtime + RandomFloat(0.2, 0.5);

						DirectorScript.ChCh_RandomAirStrikes.LaunchProjectile(
							Vector(strikepos.x, strikepos.y, jetZ),
							strikepos,
							impactTime,
							angles,
							"models/missiles/f18_agm65maverick.mdl",
							"molotov_explosion",
							false,
							travelTime,
							mode
						);
					} else if (mode == 3) {
						DirectorScript.ChCh_RandomAirStrikes.LaunchCarDrop(
							Vector(strikepos.x, strikepos.y, jetZ - 50),
							boomtime
						);
					} else if (mode == 9) {
						DirectorScript.ChCh_RandomAirStrikes.LaunchSlowMissile(
							Vector(strikepos.x, strikepos.y, jetZ - 50),
							strikepos,
							boomtime,
							3.0
						);
					} else if (mode == 10) {
						// Launch Single Supply Drop
						DirectorScript.ChCh_RandomAirStrikes.LaunchSupplyDrop(
							Vector(strikepos.x, strikepos.y, jetZ - 50),
							boomtime
						);
					} else if (mode == 11) {
						// Launch Supply Drop Line (Multi-Item)
						local minI = DirectorScript.ChCh_RandomAirStrikes.Settings.supplydrop2_min_items;
						local maxI = DirectorScript.ChCh_RandomAirStrikes.Settings.supplydrop2_max_items;
						local count = RandomInt(minI, maxI);
						local spacing = 300.0;

						// Calculate vector
						local rad = planeAngleInt * 3.14159 / 180.0;
						local dir = Vector(cos(rad), sin(rad), 0);

						// Start slightly back so the center of the line is near strikepos
						local totalLen = (count - 1) * spacing;
						local startPos2D = strikepos - (dir * (totalLen / 2.0));
						local startTime = boomtime - ((count * 0.3) / 2.0);

						for (local i = 0; i < count; i++) {
							local dropSpot2D = startPos2D + (dir * (i * spacing));
							local dropPos = Vector(dropSpot2D.x, dropSpot2D.y, jetZ - 50);
							local delay = startTime + (i * 0.3);

							if (delay < 0.1) delay = 0.1;

							DirectorScript.ChCh_RandomAirStrikes.LaunchSupplyDrop(dropPos, delay);
						}
					} else {
						local spawnDelay = boomtime - 0.5;
						DirectorScript.ChCh_RandomAirStrikes.LaunchHomingProjectile(
							Vector(strikepos.x, strikepos.y, jetZ),
							strikepos,
							spawnDelay,
							"models/missiles/f18_agm65maverick.mdl",
							"molotov_explosion",
							mode
						);
					}
				}
			}
			// === MODE 6: NAPALM STRIKE ===
			else if (mode == 6) {
				local jetZ = strikepos.z + 1000;
				local traceUp = {
					start = strikepos + Vector(0, 0, 10),
					end = strikepos + Vector(0, 0, 3000),
					ignore = null
				}

				if (TraceLine(traceUp) && traceUp.hit) {
					if (DirectorScript.ChCh_RandomAirStrikes.Settings.airstrike_behavior != 2) {
						local ceilingZ = traceUp.pos.z;
						local possibleZ = ceilingZ - 250;
						if (possibleZ < jetZ) jetZ = possibleZ;
					}
				}
				if (jetZ < strikepos.z + 300) jetZ = strikepos.z + 300;

				local planeAngle = RandomInt(0, 360);
				local angles = "0 " + planeAngle.tostring() + " 0";

				local plane = SpawnEntityFromTable("prop_dynamic", {
					origin = Vector(strikepos.x, strikepos.y, jetZ),
					angles = angles,
					model = "models/f18/f18.mdl",
					fademindist = -1,
					fademaxdist = 0,
					solid = 0
				});
				plane.ValidateScriptScope();

				local planimation = "flyby" + RandomInt(1, 5).tostring();
				local boomtime = 2.6;
				if (planimation.slice(5, 6).tointeger() >= 3) boomtime = 3.2;

				EntityOutputs.AddOutput(plane, "OnAnimationDone", "!self", "Kill", "", 0.0, 1);
				DoEntFire("!self", "SetAnimation", planimation, 0.0, null, plane);

				EntFire("worldspawn", "RunScriptCode",
					"EmitAmbientSoundOn(\"animation/jets/jet_by_0\" + RandomInt(1,2).tostring() + \"_mono.wav\", 1.0, 0, RandomInt(95,105), Entities.First())",
					boomtime - 1, null);

				if (DirectorScript.ChCh_RandomAirStrikes.Settings.drop_bomb >= 1) {
					local perpAngleRad = (planeAngle + 90) * 3.14159 / 180.0;
					local lineDir = Vector(cos(perpAngleRad), sin(perpAngleRad), 0);

					local bombCount = RandomInt(3, 4);
					local lineLength = DirectorScript.ChCh_RandomAirStrikes.Settings.napalm_line_length.tofloat();

					local spacing = lineLength / (bombCount - 1).tofloat();
					local startOffset = -lineLength / 2.0;

					for (local i = 0; i < bombCount; i++) {
						local offset = startOffset + (spacing * i);
						local targetPos = strikepos + (lineDir * offset);

						local groundTrace = {
							start = targetPos + Vector(0, 0, 100),
							end = targetPos - Vector(0, 0, 500),
							ignore = null
						};
						if (TraceLine(groundTrace) && groundTrace.hit) {
							targetPos = groundTrace.pos;
						}

						local impactTime = boomtime + RandomFloat(0.1, 0.3) + (i * 0.2);

						DirectorScript.ChCh_RandomAirStrikes.LaunchProjectile(
							Vector(targetPos.x, targetPos.y, jetZ),
							targetPos,
							impactTime,
							angles,
							"models/missiles/f18_agm65maverick.mdl",
							"fire_medium_02_nosmoke",
							false,
							0.35,
							6
						);
					}
				}
			}
			// === MODE 2: METEOR STRIKE ===
			else if (mode == 2) {
				if (DirectorScript.ChCh_RandomAirStrikes.Settings.drop_bomb >= 1) {
					local height = 1500;
					local dist = 1200;

					local bestStartVec = null;
					local bestDistSq = 0;

					for (local i = 0; i < 8; i++) {
						local angleRad = RandomFloat(0, 3.14159 * 2);
						local candidateVec = Vector(
							strikepos.x + (cos(angleRad) * dist),
							strikepos.y + (sin(angleRad) * dist),
							strikepos.z + height
						);

						local traceCheck = {
							start = strikepos,
							end = candidateVec,
							ignore = null
						};
						local actualStart = candidateVec;

						if (TraceLine(traceCheck) && traceCheck.hit) {
							local dir = candidateVec - strikepos;
							local len = dir.Length();
							local normDir = Vector(0, 0, 1);
							if (len > 0.01) {
								normDir = Vector(dir.x / len, dir.y / len, dir.z / len);
							}
							actualStart = traceCheck.pos - (normDir * 50);
						}

						local dx = actualStart.x - strikepos.x;
						local dy = actualStart.y - strikepos.y;
						local dSq = (dx * dx) + (dy * dy);

						if (dSq > bestDistSq) {
							bestDistSq = dSq;
							bestStartVec = actualStart;
						}
					}

					if (bestStartVec == null) {
						bestStartVec = strikepos + Vector(0, 0, height);
					}

					local minHeightAboveTarget = 1000;
					if (bestStartVec.z < strikepos.z + minHeightAboveTarget) {
						bestStartVec = Vector(
							strikepos.x + RandomFloat(-1000, 1000),
							strikepos.y + RandomFloat(-1000, 1000),
							strikepos.z + minHeightAboveTarget
						);
					}

					local rockIdx = RandomInt(0, DirectorScript.ChCh_RandomAirStrikes.RockModels.len() - 1);
					local rockMdl = DirectorScript.ChCh_RandomAirStrikes.RockModels[rockIdx];
					local impactTime = 5;

					DirectorScript.ChCh_RandomAirStrikes.LaunchProjectile(
						bestStartVec,
						strikepos,
						impactTime,
						"0 0 0",
						rockMdl,
						"molotov_explosion",
						true,
						2.5,
						mode
					);
				}
			}

			DirectorScript.ChCh_RandomAirStrikes.NextStrikeTime = Time() + DirectorScript.ChCh_RandomAirStrikes.Settings.air_strike_delay;
			DirectorScript.ChCh_RandomAirStrikes.StrikeTryNum <- 0
		} else {
			if (DirectorScript.ChCh_RandomAirStrikes.StrikeTryNum <= 4) {
				DirectorScript.ChCh_RandomAirStrikes.DoAirStrike()
				DirectorScript.ChCh_RandomAirStrikes.StrikeTryNum += 1
			} else {
				DirectorScript.ChCh_RandomAirStrikes.NextStrikeTime = Time() + 5.0;
				DirectorScript.ChCh_RandomAirStrikes.StrikeTryNum = 0;
			}
		}
	}
	function OnGameEvent_round_start(params) {
		if (!IsModelPrecached("models/f18/f18.mdl")) {
			PrecacheModel("models/f18/f18.mdl")
		}
		if (!IsModelPrecached("models/missiles/f18_agm65maverick.mdl")) {
			PrecacheModel("models/missiles/f18_agm65maverick.mdl")
		}

		if (!IsModelPrecached("models/props_vehicles/c130.mdl")) {
			PrecacheModel("models/props_vehicles/c130.mdl")
		}
		if (!IsSoundPrecached("animation/plane_flyover_short.wav")) {
			PrecacheSound("animation/plane_flyover_short.wav")
		}

		if (!IsModelPrecached("models/props_junk/gascan001a.mdl")) {
			PrecacheModel("models/props_junk/gascan001a.mdl")
		}
		if (!IsSoundPrecached("weapons/molotov/fire_ignite_2.wav")) {
			PrecacheSound("weapons/molotov/fire_ignite_2.wav")
		}

		if (!IsModelPrecached("models/props_junk/wood_crate001a.mdl")) PrecacheModel("models/props_junk/wood_crate001a.mdl");
		if (!IsModelPrecached("models/props_junk/wood_crate002a.mdl")) PrecacheModel("models/props_junk/wood_crate002a.mdl");

		if (!IsModelPrecached("models/props_junk/propanecanister001a.mdl")) {
			PrecacheModel("models/props_junk/propanecanister001a.mdl")
		}
		if (!IsSoundPrecached("weapons/hegrenade/explode3.wav")) {
			PrecacheSound("weapons/hegrenade/explode3.wav")
		}

		foreach(mdl in DirectorScript.ChCh_RandomAirStrikes.RockModels) {
			if (!IsModelPrecached(mdl)) PrecacheModel(mdl);
		}
		if (!IsModelPrecached("models/props_vehicles/cara_95sedan.mdl")) {
			PrecacheModel("models/props_vehicles/cara_95sedan.mdl")
		}
		if (!IsModelPrecached("models/props_vehicles/cara_95sedan_wrecked.mdl")) {
			PrecacheModel("models/props_vehicles/cara_95sedan_wrecked.mdl")
		}

		if (!IsSoundPrecached("animation/jets/jet_by_01_mono.wav")) {
			PrecacheSound("animation/jets/jet_by_01_mono.wav")
		}
		if (!IsSoundPrecached("animation/jets/jet_by_02_mono.wav")) {
			PrecacheSound("animation/jets/jet_by_02_mono.wav")
		}
		if (!IsSoundPrecached("ambient/explosions/explode_1.wav")) {
			PrecacheSound("ambient/explosions/explode_1.wav")
		}
		if (!IsSoundPrecached("ambient/explosions/explode_2.wav")) {
			PrecacheSound("ambient/explosions/explode_2.wav")
		}
		if (!IsSoundPrecached("ambient/explosions/explode_3.wav")) {
			PrecacheSound("ambient/explosions/explode_3.wav")
		}
		if (!IsSoundPrecached("animation/tanker_explosion.wav")) {
			PrecacheSound("animation/tanker_explosion.wav")
		}

		g_MapScript.ScriptedMode_AddUpdate(IfBeginAirStrike)
	}

	function OnGameEvent_player_left_safe_area(params) {
		if (DirectorScript.ChCh_RandomAirStrikes.LeavingTime == null) {
			DirectorScript.ChCh_RandomAirStrikes.LeavingTime = Time()
		}
	}
}

__CollectEventCallbacks(ChCh_RandomAirStrikes, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
ChCh_RandomAirStrikes.ParseSettings();