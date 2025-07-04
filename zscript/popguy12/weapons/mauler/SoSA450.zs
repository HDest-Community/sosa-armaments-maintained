class HDJackMauler : HDWeapon
{
	enum JackMaulerFlags
	{
		JMF_JustUnload = 1,
	}
	
	enum JackMaulerProperties
	{
		JMProp_Flags,
		JMProp_Chamber,
		JMProp_Mag,
		JMProp_Choke,
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override double GunMass()
	{
		return 12 + 0.03 * WeaponStatus[JMProp_Mag];
	}
	override double WeaponBulk()
	{
		double BaseBulk = 200;
		int Mag = WeaponStatus[JMProp_Mag];
		if (Mag >= 0)
		{
			BaseBulk += HDJackMaulerMag.EncMagLoaded + Mag * ENC_SHELLLOADED;
		}
		return BaseBulk;
	}
	override string, double GetPickupSprite() { return WeaponStatus[JMProp_Mag] >= 0 ? "JMWGY0" : "JMWGZ0", 0.55; }
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[JMProp_Chamber] = 2;
		WeaponStatus[JMProp_Mag] = HDJackMaulerMag.MagCapacity;
	}
	override void LoadoutConfigure(string input)
	{		
		int choke=min(getloadoutvar(input,"choke",1),7);
		if(choke>=0)weaponstatus[JMProp_Choke]=choke;
		
		InitializeWepStats(false);
	}

	override string GetHelpText()
	{
		return
		WEPHELP_FIRE.."  Shoot (choke: "..weaponstatus[JMProp_Choke]..")\n"
		..WEPHELP_RELOAD.."  Reload buckshot mag\n"
		//..WEPHELP_ALTRELOAD.."  Reload slug mag\n"
		..WEPHELP_UNLOADUNLOAD
		..WEPHELP_USE.."+"..WEPHELP_RELOAD.."  Reload chamber buckshot\n"
		//..WEPHELP_USE.."+"..WEPHELP_ALTRELOAD.."  Reload chamber slug\n"
		..WEPHELP_MAGMANAGER;
	}

	static double getshotpower(){return frandom(0.9,1.05);}
	static double FireShell(actor caller,int choke=1)
	{
		double spread=24;
		double speedfactor=1.;
		let JMF=HDJackMauler(caller.findinventory("HDJackMauler"));
		if(JMF)choke=JMF.weaponstatus[JMProp_Choke];

		choke=clamp(choke,0,7);
		spread=24-2*choke;
		speedfactor=1.+0.02857*choke;

		double shotpower=getshotpower();
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");
		let p=HDBulletActor.FireBullet(caller,"HDB_00",
			spread:spread,speedfactor:speedfactor,amount:10
		);
		distantnoise.make(p,"world/shotgunfar");
		caller.A_StartSound("JackMaul/Fire", CHAN_WEAPON, volume: 0.9);
		return shotpower;
	}
	
	/*
	static double FireSlug(actor caller){
		double spread=4;
		double speedfactor=1.;
		spread=3.5;

		double shotpower=getshotpower();
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");
		let p=HDBulletActor.FireBullet(caller,"HDB_SLUG",
			spread:spread,speedfactor:1.01
		);
		distantnoise.make(p,"world/shotgunfar");
		//caller.A_StartSound("weapons/greelyshot",CHAN_WEAPON);
		//caller.A_StartSound("weapons/greelyblast",9,CHANF_DEFAULT,0.1);
		return shotpower;
	}
	*/
	/*
	action void A_FireJMF()
	{
		let JMF=HDJackMauler(caller.findinventory("HDJackMauler"));
		let BuckMag = HDJackMaulerMag
		let SlugMag = HDJackMaulerMagSlug
	}
	action void A_FireJMFBuck()*/
	action void A_FireJMF()
	{
		double shotpower=invoker.FireShell(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-0.8,0.8),-1.8);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[JMProp_CHAMBER]=1;
		//invoker.shotpower=shotpower;
	}
	/*
	action void A_FireJMFSlug()
	{
		double shotpower=invoker.FireSlug(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-0.8,0.8),-2);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[JMProp_CHAMBER]=1;
		//invoker.shotpower=shotpower;
	}
	*/
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (sb.HudLevel == 1)
		{
			int NextMagLoaded = sb.GetNextLoadMag(HDMagAmmo(hpl.findinventory("HDJackMaulerMag")));
			if (NextMagLoaded >= HDJackMaulerMag.MagCapacity)
			{
				sb.DrawImage("JMMGA0", (-46, -3),sb. DI_SCREEN_CENTER_BOTTOM, scale: (2.0, 2.0));
			}
			else if (NextMagLoaded <= 0)
			{
				sb.DrawImage("JMMGB0", (-46, -3), sb.DI_SCREEN_CENTER_BOTTOM, alpha: NextMagLoaded ? 0.6 : 1.0, scale: (2.0, 2.0));
			}
			else
			{
				sb.DrawBar("JMMGNORM", "JMMGGREY", NextMagLoaded, HDJackMaulerMag.MagCapacity, (-46, -3), -1, sb.SHADER_VERT, sb.DI_SCREEN_CENTER_BOTTOM);
			}
			sb.DrawNum(hpl.CountInv("HDJackMaulerMag"), -43, -8, sb.DI_SCREEN_CENTER_BOTTOM);
		}
		sb.DrawWepNum(hdw.WeaponStatus[JMProp_Mag], HDJackMaulerMag.MagCapacity);

		if (hdw.WeaponStatus[JMProp_Chamber] == 2)
		{
			sb.DrawRect(-19, -11, 3, 1);
		}
	}

	override void DrawSightPicture(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl, bool sightbob, vector2 bob, double fov, bool scopeview, actor hpc, string whichdot)
	{
		int cx, cy, cw, ch;
		int ScaledYOffset = 48;
		int ScaledWidth = 89;

		[cx, cy, cw, ch] = Screen.GetClipRect();
		sb.SetClipRect(-16 + bob.x, -4 + bob.y, 32, 16, sb.DI_SCREEN_CENTER);
		vector2 bob2 = bob * 2;
		bob2.y = clamp(bob2.y, -8, 8);
		sb.DrawImage("JMWFRONT", bob2, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, alpha: 0.9);
		sb.SetClipRect(cx, cy, cw, ch);
		sb.DrawImage("JMWBACK", (0, -7) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP);
	}

	override void DropOneAmmo(int amt)
	{
		if (owner)
		{
			amt = clamp(amt, 1, 10);
			if (owner.CheckInventory("HDShellAmmo", 1))
			{
				owner.A_DropInventory("HDShellAmmo", amt * 30);
			}
			else
			{
				owner.A_DropInventory("HDJackMaulerMag", amt);
			}
		}
	}

	override string PickupMessage()
	{
		string StringChoke = WeaponStatus[JMProp_Flags] & JMProp_Choke ? "Choke:" ..weaponstatus[JMProp_Choke] : "";
		return String.Format("You picked up the %sSoSA-450A1 'Mauler' 12GA LMG.", StringChoke);
	}

	Default
	{
		-HDWEAPON.FITSINBACKPACK
		Weapon.SelectionOrder 300;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority 1.5;
		HDWeapon.BarrelSize 30, 0.5, 2;
		Scale 0.4;
		Inventory.PickupMessage "You picked up the %sSoSA-450A1 'Mauler' 12GA LMG.";
		Tag "SoSA-450A1 'Mauler' 12GA LMG";
		HDWeapon.Refid "jm0";
		//+hdweapon.dontdisarm
		//+hdweapon.dontnull
	}

	States
	{
		droop:
			TNT1 A 1{
				if(pitch<frandom(5,8)&&(!gunbraced())){
					if(countinv("IsMoving")>2 && countinv("PowerStrength")<1){    
						A_MuzzleClimb(frandom(-0.1,0.1),
						frandom(0.1,clamp(1-pitch,0.1,0.3)));
					}else{
						A_MuzzleClimb(frandom(-0.06,0.06),
						frandom(0.1,clamp(1-pitch,0.06,0.12)));
					}
				}
			}loop;
		Spawn:
			JMWG Y 0 NoDelay A_JumpIf(invoker.WeaponStatus[JMProp_Mag] >= 0, 2);
			JMWG Z 0;
			JMWG # -1;
			Stop;
		Ready:
			JMWG A 1 A_WeaponReady(WRF_ALL);
			Goto ReadyEnd;
		Select0:
			JMWG A 0 A_Overlay(2,"droop");
			Goto Select0BFG;
		Deselect0:
			JMWG A 0;
			Goto Deselect0BFG;
		User3:
			JMWG A 0 A_MagManager("HDJackMaulerMag");
			Goto Ready;

		AltFire:
			Goto ChamberManual;

		Fire:
			TNT1 A 0
			{
				if (invoker.WeaponStatus[JMProp_Chamber] < 2)
				{
					SetWeaponState("ChamberManual");
					return;
				}
			}
			JMWF A 1 BRIGHT Offset(0, 36)
			{
				A_FireJMF();
				A_ZoomRecoil(0.995);
			}
			JMWF B 1 BRIGHT Offset(0, 35);
			JMWF C 1 BRIGHT Offset(0, 34);
			JMWG A 1
						{
				if (invoker.WeaponStatus[JMProp_Chamber] == 1)
				{
					A_SpawnItemEx("HDSpentShell",
					cos(pitch)*8,0,height-10-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*5,
					vel.y+cos(pitch)*sin(angle-random(86,90))*5,
					vel.z+sin(pitch)*random(4,6),
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
					);
					invoker.WeaponStatus[JMProp_Chamber] = 0;
				}

				if (invoker.WeaponStatus[JMProp_Mag] <= 0)
				{
					SetWeaponState("Nope");
				}
				else
				{
					A_Light0();
					invoker.WeaponStatus[JMProp_Chamber] = 2;
					invoker.WeaponStatus[JMProp_Mag]--;
				}
			}
			Goto Ready;

		Unload:
			JMWG A 0
			{
				invoker.WeaponStatus[JMProp_Flags] |= JMF_JustUnload;
				if (invoker.WeaponStatus[JMProp_Mag] >= 0)
				{
					SetWeaponState("UnMag");
				}
				else if (invoker.WeaponStatus[JMProp_Chamber] > 0)
				{
					SetWeaponState("UnloadChamber");
				}
			}
			Goto Nope;
		UnloadChamber:
			JMWG A 1 A_JumpIf(invoker.WeaponStatus[JMProp_Chamber] == 0, "Nope");
			JMWG A 4 Offset(2, 34)
			{
				A_StartSound("JackMaul/BoltPull", 8);
			}
			JMWG A 8 Offset(1, 36)
			{
				class<Actor> Which = invoker.WeaponStatus[JMProp_Chamber] > 1 ? "HDShellAmmo" : "HDSpentshell";
				invoker.WeaponStatus[JMProp_Chamber] = 0;
				A_SpawnItemEx(which, cos(pitch) * 10, 0, height - 8 - sin(pitch) * 10, vel.x, vel.y, vel.z, 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
			}
			JMWG A 2 Offset(0, 34);
			Goto ReadyEnd;

		Reload:
			JMWG A 0
			{
				invoker.WeaponStatus[JMProp_Flags] &=~ JMF_JustUnload;
				bool NoMags = HDMagAmmo.NothingLoaded(self, "HDJackMaulerMag");
				if (invoker.WeaponStatus[JMProp_Mag] >= HDJackMaulerMag.MagCapacity)
				{
					SetWeaponState("Nope");
				}
				else if (invoker.WeaponStatus[JMProp_Mag] <= 0 && (PressingUse() || NoMags))
				{
					if (CheckInventory("HDShellAmmo", 1))
					{
						SetWeaponState("LoadChamber");
					}
					else
					{
						SetWeaponState("Nope");
					}
				}
				else if (NoMags)
				{
					SetWeaponState("Nope");
				}
				int MagAmount = invoker.WeaponStatus[JMProp_Mag];
				if (MagAmount == -1)
				{
					SetWeaponState("LoadmagSkipUn");
					return;
				}
			}
			Goto UnMag;
		LoadChamber:
			JMWG A 0 A_JumpIf(invoker.WeaponStatus[JMProp_Chamber] > 0, "Nope");
			JMWG A 0 A_JumpIf(!CheckInventory("HDShellAmmo", 1), "Nope");
			JMWG A 1 Offset(0, 34) A_StartSound("weapons/pocket", 9);
			JMWG A 1 Offset(2, 36);
			JMWG A 1 Offset(2, 44);
			JMWG A 1 Offset(5, 54);
			JMWG A 2 Offset(7, 60);
			JMWG A 6 Offset(8, 70);
			JMWG A 5 Offset(8, 77)
			{
				if (CheckInventory("HDShellAmmo", 1))
				{
					A_TakeInventory("HDShellAmmo", 1, TIF_NOTAKEINFINITE);
					invoker.WeaponStatus[JMProp_Chamber] = 2;
					A_StartSound("weapons/smgchamber", 8);
				}
				else
				{
					A_SetTics(4);
				}
			}
			JMWG A 3 Offset(9, 74);
			JMWG A 2 Offset(5, 70);
			JMWG A 1 Offset(5, 64);
			JMWG A 1 Offset(5, 52);
			JMWG A 1 Offset(5, 42);
			JMWG A 1 Offset(2, 36);
			JMWG A 2 Offset(0, 34);
			Goto Nope;

		UnMag:
			JMWG A 1 Offset(0, 34);
			JMWG A 1 Offset(5, 38);
			JMWG A 1 Offset(10, 42);
			JMWG A 4 Offset(20, 46)
			{
				A_StartSound("weapons/rifleclick", 8);
				A_MuzzleClimb(0.3, 0.4);
			}
			JMWG A 4 Offset(20, 46) A_MuzzleClimb(0.3, 0.4);
			JMWG A 4 Offset(23, 48) A_MuzzleClimb(0.3, 0.4);
			JMWG A 4 Offset(24, 47) A_MuzzleClimb(0.3, 0.4);
			JMWG A 4 Offset(23, 48)
			{
				A_StartSound("weapons/rifleload", 8);
				A_MuzzleClimb(0.3, 0.4);
			}
			JMWG A 4 Offset(26, 52)
			{
				A_StartSound("JackMaul/MagOut", 8, CHANF_OVERLAP);
				A_MuzzleClimb(0.3, 0.4);
			}
			JMWG A 4 Offset(26, 54) A_MuzzleClimb(0.3, 0.4);
			JMWG A 0
			{
				
				int MagAmount = invoker.WeaponStatus[JMProp_Mag];
				if (MagAmount == -1)
				{
					SetWeaponState("MagOut");
					return;
				}

				invoker.WeaponStatus[JMProp_Mag] = -1;
				if ((!PressingUnload() && !PressingReload()) || A_JumpIfInventory("HDJackMaulerMag", 0, "Null"))
				{
					HDMagAmmo.SpawnMag(self, "HDJackMaulerMag", MagAmount);
					SetWeaponState("MagOut");
				}
				else
				{
					HDMagAmmo.GiveMag(self, "HDJackMaulerMag", MagAmount);
					A_StartSound("weapons/pocket", 9);
					SetWeaponState("PocketMag");
				}
			}
		PocketMag:
			JMWG AAAAAA 5 Offset(26, 54) A_MuzzleClimb(frandom(0.2, -0.8),frandom(-0.2, 0.4));
		MagOut:
			JMWG A 0
			{
				if (invoker.WeaponStatus[JMProp_Flags] & JMF_JustUnload)
				{
					SetWeaponState("ReloadEnd");
				}
				else
				{
					SetWeaponState("LoadMag");
				}
			}

		LoadMag:
			JMWG A 0 A_StartSound("weapons/pocket", 9);
			JMWG A 6 Offset(26, 54) A_MuzzleClimb(frandom(0.2, -0.8), frandom(-0.2, 0.4));
			JMWG A 7 Offset(26, 52) A_MuzzleClimb(frandom(0.2, -0.8), frandom(-0.2, 0.4));
			JMWG A 10 Offset(24, 50);
			JMWG A 3 Offset(24, 48)
			{
				let Mag = HDMagAmmo(FindInventory("HDJackMaulerMag"));
				if (Mag)
				{
					invoker.WeaponStatus[JMProp_Mag] = Mag.TakeMag(true);
					A_StartSound("JackMaul/MagIn", 8, CHANF_OVERLAP);
				}
			}
			Goto ReloadEnd;

		LoadMagSkipUn:
			JMWG A 1 Offset(0, 34);
			JMWG A 1 Offset(5, 38);
			JMWG A 1 Offset(10, 42);
			JMWG A 1 Offset(20, 46);
			JMWG A 1 Offset(20, 46) A_MuzzleClimb(0.3, 0.4);
			JMWG A 1 Offset(23, 48) A_MuzzleClimb(0.3, 0.4);
			JMWG A 1 Offset(24, 47) A_MuzzleClimb(0.3, 0.4);
			JMWG A 1 Offset(23, 48);
			JMWG A 1 Offset(26, 52);
			JMWG A 1 Offset(26, 54) A_MuzzleClimb(0.3, 0.4);
			JMWG AAAAAA 3 Offset(26, 54) A_MuzzleClimb(frandom(0.2, -0.8),frandom(-0.2, 0.4));
			goto LoadMag;

		ReloadEnd:
			JMWG A 4 Offset(30, 52);
			JMWG A 3 Offset(20, 46);
			JMWG A 2 Offset(10, 42);
			JMWG A 2 Offset(5, 38);
			JMWG A 1 Offset(0, 34);
			Goto ChamberManual;

		ChamberManual:
			JMWG A 0 A_JumpIf(invoker.WeaponStatus[JMProp_Mag] <= 0 || invoker.WeaponStatus[JMProp_Chamber] == 2, "Nope");
			JMWG A 2 Offset(2, 34);
			JMWG A 4 Offset(3, 38) A_StartSound("JackMaul/BoltPull", 8, CHANF_OVERLAP);
			JMWG A 5 Offset(4, 44)
			{
				if (invoker.WeaponStatus[JMProp_Chamber] == 1)
				{
					A_SpawnItemEx("HDSpentshell", cos(pitch) * 10, 0, height - 10 - sin(pitch) * 10, vel.x, vel.y, vel.z, 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
					invoker.WeaponStatus[JMProp_Chamber] = 0;
				}

				A_WeaponBusy();
				invoker.WeaponStatus[JMProp_Mag]--;
				invoker.WeaponStatus[JMProp_Chamber] = 2;
			}
			JMWG A 2 Offset(3, 38);
			JMWG A 2 Offset(2, 34);
			JMWG A 2 Offset(0, 32);
			Goto Nope;
	}
}

class JackMaulerRandom : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				let wpn = HDJackMauler(Spawn("HDJackMauler", pos, ALLOW_REPLACE));
				if (!wpn)
				{
					return;
				}
				HDF.TransferSpecials(self,wpn,HDF.TS_ALL);
				wpn.special = special;
				wpn.weaponstatus[wpn.JMProp_Choke]=random(0,7);
				wpn.InitializeWepStats(false);
				
				for (int i = 0; i < 5; ++i)
				{
					wpn.Args[i] = Args[i];
				}
			}
			Stop;
	}
}

class HDJackMaulerMag : HDMagAmmo
{
	override string, string, name, double GetMagSprite(int thismagamt)
	{
		return (thismagamt > 0) ? "JMMGA0" : "JMMGB0", "ESHLC0", "HDShellAmmo", 1.0;
	}

	override void GetItemsThatUseThis()
	{
		ItemsThatUseThis.Push("HDJackMauler");
	}

	const MagCapacity = 100;
	const EncMagEmpty = 40;
	const EncMagLoaded = EncMagEmpty * 1;

	Default
	{
		HDMagAmmo.MaxPerUnit MagCapacity;
		HDMagAmmo.InsertTime 12;
		HDMagAmmo.ExtractTime 8;
		HDMagAmmo.RoundType "HDShellAmmo";
		HDMagAmmo.RoundBulk ENC_SHELLLOADED;
		HDMagAmmo.MagBulk EncMagEmpty;
		Tag "'Mauler' magazine";
		Inventory.PickupMessage "Picked up a 100-round 'Mauler' magazine.";
		HDPickup.RefId "jmb";
		Scale 1.2;
	}

	States
	{
		Spawn:
			JMMG A -1;
			Stop;
		SpawnEmpty:
			JMMG B -1
			{
				bROLLSPRITE = true;
				bROLLCENTER = true;
				roll = randompick(0, 0, 0, 0, 2, 2, 2, 2, 1, 3) * 90;
			}
			Stop;
	}
}
