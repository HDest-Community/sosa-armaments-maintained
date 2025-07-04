// ------------------------------------------------------------
// Pistol
// ------------------------------------------------------------

const SoSA_45A1="s45";

const EMC_M45A1_MAG=20;

const ENC_M45A1_MAG_EMPTY=3;
const ENC_M45A1_MAG_LOADED=0.5;

class SoSA45A1:HDHandgun {
	default{
		+hdweapon.fitsinbackpack
		+hdweapon.reverseguninertia
		scale 0.63;
		weapon.selectionorder 50;
		weapon.slotnumber 2;
		weapon.slotpriority 2;
		weapon.kickback 30;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "%o got capped by %k's sporting gun.";
		inventory.pickupmessage "You got the NORA .45 Revision 1!";
		tag "NORA .45 Revision 1";
		hdweapon.refid SoSA_45A1;
		hdweapon.barrelsize 10,0.5,0.8;
		inventory.maxamount 3;
	}
	override double weaponbulk(){
		int mgg=weaponstatus[PISS_MAG];
		return 30+(mgg<0?0:(ENC_M45A1_MAG_LOADED+mgg*ENC_45ACPLOADED));
	}
	override double gunmass(){
		return 10;
	}
	override void failedpickupunload(){
		failedpickupunloadmag(PISS_MAG,"HD45ACPMag");
	}
	override string,double getpickupsprite(){
		string spr;
		if(weaponstatus[PISS_CHAMBER]<1){
			if(weaponstatus[0]&PISF_SELECTFIRE)spr="D";
			else spr="B";
		}else{
			if(weaponstatus[0]&PISF_SELECTFIRE)spr="C";
			else spr="A";
		}
		return "P3ST"..spr.."0",1.;
	}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD45ACPMag")));
			if(nextmagloaded>=14){
				sb.drawimage("45MGA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.75,0.75));
			}else if(nextmagloaded<1){
				sb.drawimage("45MGB0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(0.75,0.75));
			}else sb.drawbar(
				"45MGA0","45MGB0",
				nextmagloaded,14,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HD45ACPMag"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(hdw.weaponstatus[0]&PISF_SELECTFIRE)sb.drawwepcounter(hdw.weaponstatus[0]&PISF_FIREMODE,
			-22,-10,"RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[PISS_MAG],14);
		if(hdw.weaponstatus[PISS_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..((weaponstatus[0]&PISF_SELECTFIRE)?(WEPHELP_FIREMODE.."  Semi/Auto\n"):"")
		..WEPHELP_RELOAD.."  Reload mag\n"
		..WEPHELP_USE.."+"..WEPHELP_RELOAD.."  Reload chamber\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc,string whichdot
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		vector2 scc;
		vector2 bobb=bob*1.6;

		//if slide is pushed back, throw sights off line
		if(hpl.player.getpsprite(PSP_WEAPON).frame>=2){
			sb.SetClipRect(
				-10+bob.x,-5+bob.y,20,14,
				sb.DI_SCREEN_CENTER
			);
			scc=(0.7,0.8);
			bobb.y=clamp(bobb.y*1.1-3,-10,10);
		}else{
			sb.SetClipRect(
				-8+bob.x,-4+bob.y,16,10,
				sb.DI_SCREEN_CENTER
			);
			scc=(0.6,0.6);
			bobb.y=clamp(bobb.y,-8,8);
		}
		sb.drawimage(
			"f45tsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"b45ksite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HD45ACPAmmo"))owner.A_DropInventory("HD45ACPAmmo",amt*14);
			else owner.A_DropInventory("HD45ACPMag",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HD45ACPAmmo");
		owner.A_TakeInventory("HD45ACPMag");
		owner.A_GiveInventory("HD45ACPMag");
	}
	action void A_CheckPistolHand(){
		if(invoker.wronghand)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("PI2GA0");
	}
	states{
	select0:
		P3SG A 0{
			if(!countinv("NulledWeapon"))invoker.wronghand=false;
			A_TakeInventory("NulledWeapon");
			A_CheckPistolHand();
		}
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### C 0;
		---- A 1 A_Raise();
		---- A 1 A_Raise(30);
		---- A 1 A_Raise(30);
		---- A 1 A_Raise(24);
		---- A 1 A_Raise(18);
		wait;
	deselect0:
		P3SG A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### C 0;
		---- AAA 1 A_Lower();
		---- A 1 A_Lower(18);
		---- A 1 A_Lower(24);
		---- A 1 A_Lower(30);
		wait;

	ready:
		P3SG A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### C 0;
		#### # 0 A_SetCrosshair(21);
		#### # 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	user3:
		---- A 0 A_MagManager("HD45ACPMag");
		goto ready;
	user2:
	firemode:
		---- A 0{
			if(invoker.weaponstatus[0]&PISF_SELECTFIRE)
			invoker.weaponstatus[0]^=PISF_FIREMODE;
			else invoker.weaponstatus[0]&=~PISF_FIREMODE;
		}goto nope;
	altfire:
		---- A 0{
			invoker.weaponstatus[0]&=~PISF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[PISS_CHAMBER]!=2
				&&invoker.weaponstatus[PISS_MAG]>0
			)setweaponstate("chamber_manual");
		}goto nope;
	chamber_manual:
		---- A 0 A_JumpIf(
			!(invoker.weaponstatus[0]&PISF_JUSTUNLOAD)
			&&(
				invoker.weaponstatus[PISS_CHAMBER]==2
				||invoker.weaponstatus[PISS_MAG]<1
			)
			,"nope"
		);
		#### B 3 offset(0,34);
		#### C 4 offset(0,37){
			A_MuzzleClimb(frandom(0.4,0.5),-frandom(0.6,0.8));
			A_StartSound("weapons/45chamber2",8);
			int psch=invoker.weaponstatus[PISS_CHAMBER];
			invoker.weaponstatus[PISS_CHAMBER]=0;
			if(psch==2){
				A_SpawnItemEx("HD45ACPAmmo",cos(pitch*12),0,height-9-sin(pitch)*12,1,2,3,0);
			}else if(psch==1){
				A_SpawnItemEx("HDSpent45ACP",
					cos(pitch)*12,0,height-9-sin(pitch)*12,
					vel.x,vel.y,vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
			if(invoker.weaponstatus[PISS_MAG]>0){
				invoker.weaponstatus[PISS_CHAMBER]=2;
				invoker.weaponstatus[PISS_MAG]--;
			}
		}
		#### B 3 offset(0,35);
		goto nope;
	althold:
	hold:
		goto nope;
	fire:
		---- A 0{
			invoker.weaponstatus[0]&=~PISF_JUSTUNLOAD;
			if(invoker.weaponstatus[PISS_CHAMBER]==2)setweaponstate("shoot");
			else if(invoker.weaponstatus[PISS_MAG]>0)setweaponstate("chamber_manual");
		}goto nope;
	shoot:
		#### B 2{
			if(invoker.weaponstatus[PISS_CHAMBER]==2)A_GunFlash();
		}
		#### C 1{
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
			A_MuzzleClimb(
				-frandom(1.0,1.2),-frandom(1.4,1.8),
				frandom(0.6,0.7),frandom(0.8,1.0)
			);
		}
		#### C 0{
			A_SpawnItemEx("HDSpent45ACP",
					cos(pitch)*8,0,height-11-sin(pitch)*12,
					vel.x+cos(pitch)*cos(angle-random(86,90))*5,
					vel.y+cos(pitch)*sin(angle-random(86,90))*5,
					vel.z+sin(pitch)*random(4,6),
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
					);
			invoker.weaponstatus[PISS_CHAMBER]=0;
			if(invoker.weaponstatus[PISS_MAG]<1){
				A_StartSound("weapons/45dry",8,CHANF_OVERLAP,0.9);
				setweaponstate("nope");
			}
		}
		#### A 1{
			A_WeaponReady(WRF_NOFIRE);
			invoker.weaponstatus[PISS_CHAMBER]=2;
			invoker.weaponstatus[PISS_MAG]--;
			if(
				(invoker.weaponstatus[0]&(PISF_FIREMODE|PISF_SELECTFIRE))
				==(PISF_FIREMODE|PISF_SELECTFIRE)
			){
				let pnr=HDPlayerPawn(self);
				if(
					pnr&&countinv("IsMoving")
					&&pnr.fatigue<12
				)pnr.fatigue++;
				A_GiveInventory("IsMoving",5);
				A_Refire("fire");
			}else A_Refire();
		}goto ready;
	flash:
		P32F A 0 A_JumpIf(invoker.wronghand,2);
		P3SF A 0;
		---- A 1 bright{
			HDFlashAlpha(64);
			A_Light1();
			let bbb=HDBulletActor.FireBullet(self,"HDB_45ACP",spread:2.5,speedfactor:frandom(0.97,1.03));
			if(
				frandom(0,ceilingz-floorz)<bbb.speed*0.3
			)A_AlertMonsters(256);

			invoker.weaponstatus[PISS_CHAMBER]=1;
			A_ZoomRecoil(0.995);
			A_MuzzleClimb(-frandom(0.4,1.2),-frandom(0.4,1.6));
		}
		---- A 0 A_StartSound("weapons/45shoot",CHAN_WEAPON);
		---- A 0 A_Light0();
		stop;
	unload:
		---- A 0{
			invoker.weaponstatus[0]|=PISF_JUSTUNLOAD;
			if(invoker.weaponstatus[PISS_MAG]>=0)setweaponstate("unmag");
		}goto chamber_manual;
	loadchamber:
		---- A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,"nope");
		---- A 2 offset(0,36) A_StartSound("weapons/pocket",9);
		---- A 2 offset(2,40);
		---- A 2 offset(2,50);
		---- A 2 offset(3,60);
		---- A 2 offset(5,90);
		---- A 2 offset(7,80);
		---- A 2 offset(10,90);
		#### C 2 offset(8,96);
		#### C 3 offset(6,88){
			if(countinv("HD45ACPAmmo")){
				A_TakeInventory("HD45ACPAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[PISS_CHAMBER]=2;
				A_StartSound("weapons/45chamber1",8);
			}
		}
		#### B 2 offset(5,76);
		#### B 1 offset(4,64);
		#### B 1 offset(3,56);
		#### B 1 offset(2,48);
		#### B 2 offset(1,38);
		#### B 3 offset(0,34);
		goto readyend;
	reload:
		---- A 0{
			invoker.weaponstatus[0]&=~PISF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"HD45ACPMag");
			if(invoker.weaponstatus[PISS_MAG]>=14)setweaponstate("nope");
			else if(
				invoker.weaponstatus[PISS_MAG]<1
				&&(
					pressinguse()
					||nomags
				)
			){
				if(
					countinv("HD45ACPAmmo")
				)setweaponstate("loadchamber");
				else setweaponstate("nope");
			}else if(nomags)setweaponstate("nope");
		}goto unmag;
	unmag:
		---- A 2 offset(0,34) A_SetCrosshair(21);
		---- A 2 offset(1,38);
		---- A 3 offset(2,42);
		---- A 4 offset(3,46) A_StartSound("weapons/45magremove",8,CHANF_OVERLAP);
		---- A 0{
			int pmg=invoker.weaponstatus[PISS_MAG];
			invoker.weaponstatus[PISS_MAG]=-1;
			if(pmg<0)setweaponstate("magout");
			else if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("HD45ACPMag",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HD45ACPMag",pmg);
				setweaponstate("magout");
			}
			else{
				HDMagAmmo.GiveMag(self,"HD45ACPMag",pmg);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		---- AAA 8 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto magout;
	magout:
		---- A 0{
			if(invoker.weaponstatus[0]&PISF_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag");
		}

	loadmag:
		---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 1 A_StartSound("weapons/pocket",9);
		---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 4;
		---- A 0{
			let mmm=hdmagammo(findinventory("HD45ACPMag"));
			if(mmm){
				invoker.weaponstatus[PISS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/45magclick",8);
			}
		}
		goto reloadend;

	reloadend:
		---- A 2 offset(3,46);
		---- A 1 offset(2,42);
		---- A 1 offset(2,38);
		---- A 1 offset(1,34);
		---- A 0 A_JumpIf(!(invoker.weaponstatus[0]&PISF_JUSTUNLOAD),"chamber_manual");
		goto nope;

	spawn:
		P3ST ABCD -1 nodelay{
			if(invoker.weaponstatus[PISS_CHAMBER]<1){
				if(invoker.weaponstatus[0]&PISF_SELECTFIRE)frame=3;
				else frame=1;
			}else{
				if(invoker.weaponstatus[0]&PISF_SELECTFIRE)frame=2;
				else frame=0;
			}
		}stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[PISS_MAG]=14;
		weaponstatus[PISS_CHAMBER]=2;
	}
	override void loadoutconfigure(string input){
		int selectfire=getloadoutvar(input,"selectfire",1);
		if(!selectfire){
			weaponstatus[0]&=~PISF_SELECTFIRE;
			weaponstatus[0]&=~PISF_FIREMODE;
		}else if(selectfire>0){
			weaponstatus[0]|=PISF_SELECTFIRE;
		}
		if(weaponstatus[0]&PISF_SELECTFIRE){
			int firemode=getloadoutvar(input,"firemode",1);
			if(!firemode)weaponstatus[0]&=~PISF_FIREMODE;
			else if(firemode>0)weaponstatus[0]|=PISF_FIREMODE;
		}
	}
}
enum sosa45status{
	PISF_SELECTFIRE=1,
	PISF_FIREMODE=2,
	PISF_JUSTUNLOAD=4,

	PISS_FLAGS=0,
	PISS_MAG=1,
	PISS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
};

class HD45ACPMag : HDMagAmmo
{
	override string, string, name, double GetMagSprite(int thismagamt)
	{
		return (thismagamt > 0) ? "45MGA0" : "45MGB0", "45BUA0", "HD45ACPAmmo", 1.0;
	}

	override void GetItemsThatUseThis()
	{
		ItemsThatUseThis.Push("SoSA45A1");
	}

	const MagCapacity = 14;
	const EncMagEmpty = 3;
	const EncMagLoaded = EncMagEmpty * 1;

	Default
	{
		HDMagAmmo.MaxPerUnit MagCapacity;
		HDMagAmmo.InsertTime 6;
		HDMagAmmo.ExtractTime 3;
		HDMagAmmo.RoundType "HD45ACPAmmo";
		HDMagAmmo.RoundBulk ENC_45ACPLOADED;
		HDMagAmmo.MagBulk EncMagEmpty;
		Tag "SoSA45A1 Magazine";
		Inventory.PickupMessage "Picked up a 14-round NORA .45 Magazine.";
		HDPickup.RefId "m45";
		Scale 0.12;
	}

	States
	{
		Spawn:
			45MG C -1;
			Stop;
		SpawnEmpty:
			45MG D -1
			{
				bROLLSPRITE = true;
				bROLLCENTER = true;
				roll = randompick(0, 0, 0, 0, 2, 2, 2, 2, 1, 3) * 90;
			}
			Stop;
	}
}

class SoSA45A1Random : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				let wpn = SoSA45A1(Spawn("SoSA45A1", pos, ALLOW_REPLACE));
				if (!wpn)
				{
					return;
				}
				
				for (int i = 0; i < 5; ++i)
				{
					wpn.Args[i] = Args[i];
				}
			}
			Stop;
	}
}