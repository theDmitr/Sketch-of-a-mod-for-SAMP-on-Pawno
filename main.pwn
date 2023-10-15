#include <a_samp>
#include <Pawn.CMD>
#include <sscanf2>
#include <foreach>
#include <rustext>
#include <streamer>
#include <pickfix>

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

#define MAX_PLAYERID_LENGTH 3
#define MAX_CHAT_MESSAGE 145
#define MAX_PLAYER_MEDCHESTS 3
#define MAX_PLAYER_CHIPS 4
#define MAX_PLAYER_PIZZAS 2
#define MAX_PLAYER_REPAIRKITS 3
#define MAX_PLAYER_AMMO 400

#define KEY_CLEAR_ANIMATION 32

#undef MAX_VEHICLES
#define MAX_VEHICLES 500

#define MAX_PLAYER_HEALTH Float:100.0

#define KEY_VEHICLE_ENGINE_SWITCH 1
#define KEY_VEHICLE_LIGHTS_SWITCH 4
#define KEY_VEHICLE_LEFTARROW_SWITCH 256
#define KEY_VEHICLE_RIGHTARROW_SWITCH 64

#define VEHICLE_CRITICAL_HEALTH 500
#define VEHICLE_MIN_HEALTH 251
#define VEHICLE_MAX_HEALTH 1000

#define DRIVER_SEAT 0

#define ARMY_STORAGE_CHECKPOINT_X 850.4578
#define ARMY_STORAGE_CHECKPOINT_Y 871.6127
#define ARMY_STORAGE_CHECKPOINT_Z 13.3516
#define ARMY_STORAGE_CHECKPOINT_RADIUS 3.0

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0))) 

#if !defined isnull
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

new const public_animations[][8] =
{
    {1260, 1, 1, 1, 1, 0, 0, 1},
    {37, 1, 0, 0, 0, 0, 0, 1},
    {740, 1, 0, 0, 0, 0, 0, 1},
    {741, 1, 0, 0, 0, 0, 0, 1},
    {3, 4, 1, 0, 0, 0, 0, 1}
};

new const name_gun[][] = 
{ 
    "Êàñòåò", "Ãîëüô êëþøêà", "Äóáèíêà", "Íîæ", "Áèòà", "Ëîïàòà", "Êèé", "Êàòàíà", "Áåíçîïèëà", "Äèëäî", "Äèëäî", "Âèáðàòîð", "Âèáðàòîð", "Öâåòû", 
    "Òðîñòü", "Âçðûâíàÿ ãðàíàòà", "Äûìîâàÿ ãðàíàòà", "Êîêòåëü ìîëîòîâà", "", "", "", "9mm", "9mm ñ ãëóøèòåëåì", "Äèãë", "Äðîáîâèê", "Îáðåç", 
    "Äðîáîâèê", "Ìèêðîóçè", "MP5", "AK-47", "M4", "Óçè", "Ðèôë", "Ñíàéïåðñêàÿ âèíòîâêà", "Ãðàíàòîì¸ò", "Ãðàíàòîì", "Îãíåì¸ò", "Âîñüìèñòâîëêà", 
    "Ëèïêàÿ áîìáà", "Äåòîíàòîð", "Ñïðåé", "Îãíåòóøèòåëü", "Ôîòîàïïàðàò", "Î÷êè òåïëîâîãî âèäåíüÿ", "Î÷êè íî÷íîãî âèäåíüÿ", "Ïàðàøþò" 
};

new const missing_guns[] = 
{ 
    19, 20, 21 
};

new stringFractions[][] =
{
    "Îòñóòñòâóåò",
    "Ñêèíõåäû",
    "Ãîïîòà",
    "Êàâêàç",
    "Áîëüíèöà",
    "ÌÂÄ",
    "Ïðàâèòåëüñòâî",
    "Âîéñêîâàÿ ÷àñòü"
};

new colorFractions[] =
{
    0xFFFFFFFF,
    0x4A0345FF,
    0x1B94D1FF,
    0x3A913FFF,
    0xE838B9FF,
    0x2329CFFF,
    0xD4C690FF,
    0x16611EFF
};

enum
{
    DLG_UNUSED,
    DLG_ANIMLIST,
    DLG_SHOP_ALLDAY
}

enum
{
    Text:text_stop_anim,
    Text:text_getting_vehicle,
    Text:text_engine_broken
}

enum
{
    fNone,
    fSkinheads,
    fGopota,
    fKavkaz,
    fHospital,
    fPolice,
    fGovernment,
    fArmy
}

new fractions_skins[][] =
{
    {},
    {100, 20},
    {18, 19},
    {},
    {285}
};

enum E_players
{
    pName[MAX_PLAYER_NAME],
    Float:pHealth,
    Float:pArmour,
    pMedchests,
    pChips,
    pPizzas,
    pRepairkits,
    pCarjacks,
    pMasks,
    pAmmo,
    pColor,
    pFraction,
    pSkin
}

new Text:text_draws[4];
new pickup_shop_1;

new Players[MAX_PLAYERS][E_players];
new army_storage_checkpoint_trigger[MAX_PLAYERS];
new army_storage_checkpoints_timers[MAX_PLAYERS];

main() {}

Float:GetDistanceBetweenPlayers(playerid1, playerid2)
{

    new Float:pos_x, Float:pos_y, Float:pos_z;
    GetPlayerPos(playerid2, pos_x, pos_y, pos_z);
    return GetPlayerDistanceFromPoint(playerid1, pos_x, pos_y, pos_z);
}

Float:get_min(Float:a, Float:b)
{
    return a < b ? a : b;
}

public OnGameModeInit()
{
    EnableStuntBonusForAll(0);
	ManualVehicleEngineAndLights();
    InitGlobalTextDraws();
    AddPlayerClass(0, 839.4578, 871.6127, 13.3516, 292.8988, 0, 0, 0, 0, 0, 0);
    PickupsInit();
	return 1;
}

public OnPlayerConnect(playerid)
{
    static const empty_player[E_players];
    Players[playerid] = empty_player;
    GetPlayerName(playerid, Players[playerid][pName], MAX_PLAYER_NAME);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    PreloadAllAnimLibs(playerid);
    if (GetPVarInt(playerid, "IsGod")) SetPlayerHealth(playerid, FLOAT_INFINITY);
    SetPlayerColor(playerid, colorFractions[Players[playerid][pFraction]]);
    army_storage_checkpoints_timers[playerid] = -1;
    army_storage_checkpoint_trigger[playerid] = 0;
    if (Players[playerid][pFraction] != 0) SetPlayerSkin(playerid, fractions_skins[Players[playerid][pFraction]][0]);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if (IsPlayerInRadius(playerid, ARMY_STORAGE_CHECKPOINT_X, ARMY_STORAGE_CHECKPOINT_Y, ARMY_STORAGE_CHECKPOINT_Z, ARMY_STORAGE_CHECKPOINT_RADIUS) && IsPlayerInOPG(playerid) && army_storage_checkpoints_timers[playerid] == -1)
    {
        army_storage_checkpoints_timers[playerid] = SetTimerEx("OnPlayerOnArmyStorageCheckpoint", 2000, 1, "d", playerid);
    }
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if (army_storage_checkpoints_timers[playerid] != -1)
    {
        KillTimer(army_storage_checkpoints_timers[playerid]);
        army_storage_checkpoints_timers[playerid] = -1;
    }
    return 1;
}

forward OnPlayerOnArmyStorageCheckpoint(playerid);
public OnPlayerOnArmyStorageCheckpoint(playerid)
{
    if (!IsPlayerInRadius(playerid, ARMY_STORAGE_CHECKPOINT_X, ARMY_STORAGE_CHECKPOINT_Y, ARMY_STORAGE_CHECKPOINT_Z, ARMY_STORAGE_CHECKPOINT_RADIUS) || !IsPlayerInOPG(playerid))
    {
        KillTimer(army_storage_checkpoints_timers[playerid]);
        army_storage_checkpoints_timers[playerid] = -1;
        return 0;
    }
    if (Players[playerid][pAmmo] >= MAX_PLAYER_AMMO)
    {
        SendClientMessage(playerid, -1, "Ó âàñ ìàêñèìàëüíîå êîëè÷åñòâî ïàòðîíîâ!");
        KillTimer(army_storage_checkpoints_timers[playerid]);
        army_storage_checkpoints_timers[playerid] = -1;
        return 0;
    }
    new rand = 1 + random(4);
    Players[playerid][pAmmo] = min(MAX_PLAYER_AMMO, Players[playerid][pAmmo] + rand);
    new string[15];
    format(string, sizeof string, "+%dïò [%i/%i]", rand, Players[playerid][pAmmo], MAX_PLAYER_AMMO);
    SendClientMessage(playerid, -1, string);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DLG_ANIMLIST:
        {
            if (response)
            {
                return OnPlayerSetAnimation(playerid, public_animations[listitem][0], public_animations[listitem][1], public_animations[listitem][2], public_animations[listitem][3], public_animations[listitem][4], public_animations[listitem][5], public_animations[listitem][6], public_animations[listitem][7]);
            } 
        }
        case DLG_SHOP_ALLDAY:
        {
            if (response)
            {
                new shop_allday_costs[] = { 150, 400, 500, 200, 500, 400, 300, 2000, 1500 };
                if (GetPlayerMoney(playerid) >= shop_allday_costs[listitem])
                {
                    switch (listitem)
                    {
                        case 0:
                        {
                            if (Players[playerid][pChips] < MAX_PLAYER_CHIPS)
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]);
                                Players[playerid][pChips]++;
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè '×èïñû'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå ìàêñèìàëüíîå êîëè÷åñòâî ÷èïñîâ!");
                        }
                        case 1:
                        {
                            if (Players[playerid][pPizzas] < MAX_PLAYER_PIZZAS)
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]);
                                Players[playerid][pPizzas]++;
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè 'Ïèööà'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå ìàêñèìàëüíîå êîëè÷åñòâî ïèöö!");
                        }
                        case 2:
                        {
                            if (!HasPlayerWeapon(playerid, 14))
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]);
                                GivePlayerWeapon(playerid, 14, 1);
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè 'Áóêåò öâåòîâ'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå åñòü áóêåò öâåòîâ!");
                        }
                        case 3:
                        {
                            if (Players[playerid][pMedchests] < MAX_PLAYER_MEDCHESTS)
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]);
                                Players[playerid][pMedchests]++;
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè 'Ìåäèöèíñêàÿ àïòå÷êà'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå ìàêñèìàëüíîå êîëè÷åñòâî àïòå÷åê!");
                        }
                        case 4:
                        {
                            if (!HasPlayerWeapon(playerid, 43))
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]);
                                GivePlayerWeapon(playerid, 43, 100000000);
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè 'Ôîòîàïïàðàò'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå åñòü ôîòîàïïàðàò!");
                        }
                        case 5:
                        {
                            if (!HasPlayerWeapon(playerid, 41))
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]);
                                GivePlayerWeapon(playerid, 41, 400);
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè 'Áàëëîí÷èê ñ êðàñêîé'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå åñòü áàëëîí÷èê ñ êðàñêîé!");
                        }
                        case 6:
                        {
                            if (Players[playerid][pMasks] == 0)
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]);
                                Players[playerid][pMasks]++;
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè 'Ìàñêà'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå åñòü ìàñêà!");
                        }
                        case 7:
                        {
                            if (Players[playerid][pRepairkits] < MAX_PLAYER_REPAIRKITS)
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]); 
                                Players[playerid][pRepairkits]++;
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè 'Ðåìîíòíûé íàáîð'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå ìàêñèìàëüíîå êîëè÷åñòâî ðåìîíòíûõ íàáîðîâ!");
                        }
                        case 8:
                        {
                            if (Players[playerid][pCarjacks] == 0)
                            {
                                GivePlayerMoney(playerid, -shop_allday_costs[listitem]); 
                                Players[playerid][pCarjacks]++;
                                SendClientMessage(playerid, -1, "Âû ïðèîáðåëè 'Äîìêðàò'");
                            }
                            else SendClientMessage(playerid, -1, "Ó âàñ óæå åñòü äîìêðàò!");
                        }
                    }
                }
                else SendClientMessage(playerid, -1, "Ó âàñ íåäîñòàòî÷íî ñðåäñòâ äëÿ ïîêóïêè ýòîãî òîâàðà!");
                return ShowPlayerDialogShopAllDay(playerid);
            }
        }
    }
    return 0;
}

public OnPlayerUpdate(playerid)
{
    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        new Float:vehiclehealth;
        GetVehicleHealth(vehicleid, vehiclehealth);
        if (vehiclehealth < VEHICLE_MIN_HEALTH) SetVehicleHealth(vehicleid, VEHICLE_MIN_HEALTH);
    }
    if (IsPlayerInRadius(playerid, ARMY_STORAGE_CHECKPOINT_X, ARMY_STORAGE_CHECKPOINT_Y, ARMY_STORAGE_CHECKPOINT_Z, 15.0) && IsPlayerInOPG(playerid))
    {
        SetPlayerCheckpoint(playerid, ARMY_STORAGE_CHECKPOINT_X, ARMY_STORAGE_CHECKPOINT_Y, ARMY_STORAGE_CHECKPOINT_Z, ARMY_STORAGE_CHECKPOINT_RADIUS);
        army_storage_checkpoint_trigger[playerid] = 1;
    }
    else if (army_storage_checkpoint_trigger[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        army_storage_checkpoint_trigger[playerid] = 0;
    }
    return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{	
    new Float:vehicle_health;	
    GetVehicleHealth(vehicleid, vehicle_health);
    if (vehicle_health < VEHICLE_MIN_HEALTH) SetVehicleHealth(vehicleid, VEHICLE_MIN_HEALTH);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if (strlen(text) > (MAX_CHAT_MESSAGE - 1 - (16 + (-2 + MAX_PLAYER_NAME) + MAX_PLAYERID_LENGTH))) return 0;
    static const fmt_str[] = "- %s {%06x}(%s)[%d]";
    new string[MAX_CHAT_MESSAGE];
    format(string, sizeof string, fmt_str, text, GetPlayerColor(playerid) >>> 8, Players[playerid][pName], playerid);
    ProxDetectorWithColor(playerid, 20.0, 0xCCCCCCAA, string);
    SetPlayerChatBubble(playerid, text, 0xCCCCCCAA, 20.0, 4000);
    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) SetPlayerAnimation(playerid, 1184);
    return 0;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
    {
        if (IsVehicleBicycle(GetPlayerVehicleID(playerid)))
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
	        GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
            SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
        }
        else
        {
            TextDrawShowForPlayer(playerid, text_draws[text_getting_vehicle]);
            SetTimerEx("HideTextDraw", 3000, false, "dd", playerid, text_getting_vehicle);
        }
    }
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (PRESSED(KEY_FIRE | KEY_CROUCH) && GetPlayerWeapon(playerid) != 0)
    {
        TogglePlayerControllable(playerid, 0);
        SetTimerEx("SafeLoadAnti", 2000, 0, "d", playerid);
    }
    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER && !IsVehicleBicycle(GetPlayerVehicleID(playerid)))
    {
        if (newkeys & KEY_VEHICLE_ENGINE_SWITCH) return OnPlayerSwitchVehicleEngine(playerid, GetPlayerVehicleID(playerid));
        if (newkeys & KEY_VEHICLE_LIGHTS_SWITCH) return OnPlayerSwitchVehicleLights(playerid, GetPlayerVehicleID(playerid));
    }
    if (newkeys & KEY_CLEAR_ANIMATION) return OnPlayerClearAnimation(playerid);
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    if (pickupid == pickup_shop_1)
    {
        ShowPlayerDialogShopAllDay(playerid);
    }
    return 1;
}

CMD:s(playerid, params[])
{
    if (sscanf(params, "s[145]", params[0]) || strlen(params[0]) > (MAX_CHAT_MESSAGE - 1 - (12 + -2 + MAX_PLAYER_NAME + MAX_PLAYERID_LENGTH))) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /s <Ñîîáùåíèå>");
    new string[MAX_CHAT_MESSAGE], bubble_string[MAX_CHAT_MESSAGE - 1 - (14 + -2 + MAX_PLAYER_NAME + MAX_PLAYERID_LENGTH)];
    format(bubble_string, sizeof bubble_string, "Êðè÷èò: %s", params[0]);
    SetPlayerChatBubble(playerid, bubble_string, 0xFFFFFFAA, 40.0, 5000);
    format(string, sizeof string, "%s[%d] êðèêíóë: %s", Players[playerid][pName], playerid, params[0]);
    return ProxDetector(playerid, 40.0, -1, string);
}

CMD:w(playerid, params[])
{
    if (sscanf(params, "s[145]", params[0]) || strlen(params[0]) > (MAX_CHAT_MESSAGE - 1 - (14 + -2 + MAX_PLAYER_NAME + MAX_PLAYERID_LENGTH))) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /w <Ñîîáùåíèå>");
    new string[MAX_CHAT_MESSAGE], bubble_string[MAX_CHAT_MESSAGE - 1 - (14 + -2 + MAX_PLAYER_NAME + MAX_PLAYERID_LENGTH)];
    format(bubble_string, sizeof bubble_string, params[0]);
    SetPlayerChatBubble(playerid, bubble_string, 0xCCCCCCAA, 5.0, 5000);
    format(string, sizeof string, "%s[%d] ïðîøåïòàë: %s", Players[playerid][pName], playerid, params[0]);
    return ProxDetector(playerid, 5.0, 0xCCCCCCAA, string);
}

CMD:n(playerid, params[])
{
    callcmd::b(playerid, params);
}

CMD:b(playerid, params[])
{
    if (sscanf(params, "s[145]", params[0]) || strlen(params[0]) > (MAX_CHAT_MESSAGE - 1 - (10 + -2 + MAX_PLAYER_NAME + MAX_PLAYERID_LENGTH))) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /b <Ñîîáùåíèå> èëè /n <Ñîîáùåíèå>");
    new string[MAX_CHAT_MESSAGE];
    format(string, sizeof string, "(( %s[%d]: %s ))", Players[playerid][pName], playerid, params[0]);
    return ProxDetector(playerid, 20.0, 0xAAAAAAAA, string);
}

CMD:me(playerid, params[])
{
    if (sscanf(params, "s[145]", params[0]) || strlen(params[0]) > (MAX_CHAT_MESSAGE - 1 - (1 + -2 + MAX_PLAYER_NAME))) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /me <Ñîîáùåíèå>");
    new string[MAX_CHAT_MESSAGE];
    SetPlayerChatBubble(playerid, params[0], 0xFF99CCAA, 20.0, 5000);
    format(string, sizeof string, "%s %s", Players[playerid][pName], params[0]);
    return ProxDetector(playerid, 20.0, 0xFF99CCAA, string);
}

CMD:do(playerid, params[])
{
    if (sscanf(params, "s[145]", params[0]) || strlen(params[0]) > (MAX_CHAT_MESSAGE - 1 - (3 + -2 + MAX_PLAYER_NAME))) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /do <Ñîîáùåíèå>");
    new string[MAX_CHAT_MESSAGE];
    SetPlayerChatBubble(playerid, params[0], 0xFF99CCAA, 20.0, 5000);
    format(string, sizeof string, "%s (%s)", params[0], Players[playerid][pName]);
    return ProxDetector(playerid, 20.0, 0xFF99CCAA, string);
}

CMD:todo(playerid, params[])
{
    if (sscanf(params, "s[144]s[144]", params[0], params[1])) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /todo <Ñîîáùåíèå>*<Äåéñòâèå>");
    new string[MAX_CHAT_MESSAGE];
    format(string, sizeof string, "- %s {FF99CCAA} ñêàçàë %s, %s", params[0], Players[playerid][pName], params[1]);
    return ProxDetector(playerid, 20.0, 0xFFFFFFAA, string);
}

CMD:try(playerid, params[])
{
    if (sscanf(params, "s[145]", params[0]) || strlen(params[0]) > (MAX_CHAT_MESSAGE - 1 - (2 + 20 + -2 + MAX_PLAYER_NAME))) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /try <Ñîîáùåíèå>");
    new string[MAX_CHAT_MESSAGE], bubble_string[MAX_CHAT_MESSAGE - (2 + 20 + -2 + MAX_PLAYER_NAME)], result[20];
    if (random(2) == 1) result = "{FF0000} (Íåóäà÷íî)";
    else result = "{00FF00} (Óäà÷íî)";
    format(bubble_string, sizeof bubble_string, "%s %s", params[0], result);
    SetPlayerChatBubble(playerid, bubble_string, 0xFF99CCAA, 20.0, 5000);
    format(string, sizeof string, "%s %s %s", Players[playerid][pName], params[0], result);
    return ProxDetector(playerid, 20.0, 0xFF99CCAA, string);
}

CMD:healme(playerid, params[])
{
    if (Players[playerid][pMedchests] < 1) return SendClientMessage(playerid, -1, "Ó âàñ íåò àïòå÷åê!");
    new Float:player_health;
    GetPlayerHealth(playerid, player_health);
    if (player_health > MAX_PLAYER_HEALTH - 5) return SendClientMessage(playerid, -1, "Âû íå íóæäàåòåñü â ëå÷åíèè!");
    Players[playerid][pMedchests]--;
    //SetPlayerAnimation();
    return SetPlayerHealth(playerid, get_min(player_health + 30.0, MAX_PLAYER_HEALTH));
}

CMD:givechest(playerid, params[])
{
    if (sscanf(params, "i", params[0])) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /givechest <id ïîëó÷àòåëÿ>");
    if (!IsPlayerConnected(params[0])) return SendClientMessage(playerid, -1, "Äàííûé èãðîê îòñóòñòâóåò íà ñåðâåðå!");
    if (playerid == params[0]) return SendClientMessage(playerid, -1, "Âû íå ìîæåòå ïåðåäàòü àïòå÷êó ñàìîìó ñåáå!");
    if (GetDistanceBetweenPlayers(playerid, params[0]) > 5.0) return SendClientMessage(playerid, -1, "Èãðîê íàõîäèòñÿ ñëèøêîì äàëåêî!");
    if (Players[playerid][pMedchests] < 1) return SendClientMessage(playerid, -1, "Ó âàñ íåò àïòå÷åê!");
    if (Players[params[0]][pMedchests] == MAX_PLAYER_MEDCHESTS) return SendClientMessage(playerid, -1, "Ó èãðîêà ïîëíûé íàáîð àïòå÷åê!");
    Players[playerid][pMedchests]--;
    Players[params[0]][pMedchests]++;
    new string[29 + (-2 + MAX_PLAYER_NAME)];
    format(string, sizeof string, "ïåðåäàë %s ìåäèöèíñêóþ àïòå÷êó", Players[playerid][pName], Players[params[0]][pName]);
    return callcmd::me(playerid, string);
}

CMD:anim(playerid, params[])
{
    if (isnull(params)) return ShowPlayerDialogAnimationsList(playerid);
    if (sscanf(params, "i", params[0]) || params[0] > sizeof public_animations || params[0] < 1) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /anim <Íîìåð àíèìàöèè>");
    params[0]--;
    return OnPlayerSetAnimation(playerid, public_animations[params[0]][0], public_animations[params[0]][1], public_animations[params[0]][2], public_animations[params[0]][3], public_animations[params[0]][4], public_animations[params[0]][5], public_animations[params[0]][6], public_animations[params[0]][7]);
}

CMD:vehdamage(playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if (vehicleid == 0) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå â òðàíñïîðòíîì ñðåäñòâå!");
	if (sscanf(params, "i", params[0])) return SendClientMessage(playerid, -1, "Ââåäèòå: /vehdamage <ÇÄÎÐÎÂÜÅ>");
	return SetVehicleHealth(vehicleid, params[0]);
}

CMD:givegun(playerid, params[])
{
    new receiverid, weaponid, ammo;
    if (sscanf(params, "iii", receiverid, weaponid, ammo)) 
    {
        if (!sscanf(params, "ii", weaponid, ammo)) receiverid = playerid;
        else return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /givegun <id ïîëó÷àòåëÿ> <id îðóæèÿ> <Êîë-âî ïàòðîí>");
    }
    else if (!IsPlayerConnected(receiverid) && receiverid != -1) return SendClientMessage(playerid, -1, "Äàííûé èãðîê îòñóòñòâóåò íà ñåðâåðå!");
    if (weaponid < 1 || weaponid > 46) return SendClientMessage(playerid, -1, "Íîìåð îðóæèÿ äîëæåí áûòü â ïðîìåæóòêå îò 1 äî 46!");
    if (!IsValidWeaponID(weaponid)) return SendClientMessage(playerid, -1, "Íåêîððåêòíûé íîìåð îðóæèÿ!");
    new string[64];
    if (receiverid == -1)
    {
        for (new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
        {
            if (!IsPlayerConnected(i)) continue;
            GivePlayerWeapon(i, weaponid, ammo);
            format(string, sizeof string, "Èãðîâîé ìàñòåð âûäàë âàì %s.", name_gun[weaponid - 1], ammo);
            SendClientMessage(i, -1, string);
        }
        return 1;
    }
    format(string, sizeof string, "Èãðîâîé ìàñòåð âûäàë âàì %s.", name_gun[weaponid - 1], ammo);
    SendClientMessage(receiverid, -1, string);
    return GivePlayerWeapon(receiverid, weaponid, ammo);
}

CMD:sethealth(playerid, params[])
{
    new receiverid, player_health;
    if (sscanf(params, "ii", receiverid, player_health))
    {
        if (!sscanf(params, "i", player_health)) receiverid = playerid;
        else return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /sethealth <id èãðîêà> <çäîðîâüå>");
    }
    else if (!IsPlayerConnected(receiverid) && receiverid != -1) return SendClientMessage(playerid, -1, "Èãðîêà ñ òàêèì ID íåò íà ñåðâåðå!");
    if (player_health > 100 || player_health < 0) return SendClientMessage(playerid, -1, "Çäîðîâüå íàõîäèòñÿ â ïðîìåæóòêå [0, 100]");
    if (receiverid == -1)
    {
        for (new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
        {
            if (!IsPlayerConnected(i)) continue;
            SetPlayerHealth(i, player_health);
            SendClientMessage(i, -1, "Èãðîâîé ìàñòåð èçìåíèë âàø óðîâåíü çäîðîâüÿ!");
        }
        return 1;
    }
    SendClientMessage(receiverid, -1, "Èãðîâîé ìàñòåð èçìåíèë âàø óðîâåíü çäîðîâüÿ!");
    return SetPlayerHealth(receiverid, player_health);
}

CMD:setarmour(playerid, params[])
{
    new receiverid, player_armour;
    if (sscanf(params, "ii", receiverid, player_armour))
    {
        if (!sscanf(params, "i", player_armour)) receiverid = playerid;
        else return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /sethealth <id èãðîêà> <áðîíÿ>");
    }
    else if (!IsPlayerConnected(receiverid) && receiverid != -1) return SendClientMessage(playerid, -1, "Èãðîêà ñ òàêèì ID íåò íà ñåðâåðå!");
    if (player_armour > 100 || player_armour < 0) return SendClientMessage(playerid, -1, "Óðîâåíü áðîíè íàõîäèòñÿ â ïðîìåæóòêå [0, 100]");
    if (receiverid == -1)
    {
        for (new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
        {
            if (!IsPlayerConnected(i)) continue;
            SetPlayerArmour(i, player_armour);
            SendClientMessage(i, -1, "Èãðîâîé ìàñòåð èçìåíèë âàø óðîâåíü áðîíè!");
        }
        return 1;
    }
    SendClientMessage(receiverid, -1, "Èãðîâîé ìàñòåð èçìåíèë âàø óðîâåíü áðîíè!");
    return SetPlayerArmour(receiverid, player_armour);
}

CMD:setskin(playerid, params[])
{
    new receiverid, skinid;
    if (sscanf(params, "ii", receiverid, skinid))
    {
        if (!sscanf(params, "i", skinid)) receiverid = playerid;
        else return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /setskin <id èãðîêà> <id ñêèíà>");
    }
    else if (!IsPlayerConnected(receiverid)  && receiverid != -1) return SendClientMessage(playerid, -1, "Èãðîêà ñ òàêèì ID íåò íà ñåðâåðå!");
    if (skinid < 0 || skinid > 311) return SendClientMessage(playerid, -1, "Íîìåðà ñêèíîâ íàõîäÿòñÿ â ïðîìåæóòêå [0, 311]");
    if (receiverid == -1)
    {
        for (new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
        {
            if (!IsPlayerConnected(i)) continue;
            SetPlayerSkin(i, skinid);
            SendClientMessage(i, -1, "Èãðîâîé ìàñòåð èçìåíèë âàø íàáîð îäåæäû!");
        }
        return 1;
    }
    SendClientMessage(receiverid, -1, "Èãðîâîé ìàñòåð èçìåíèë âàø íàáîð îäåæäû!");
    return SetPlayerSkin(receiverid, skinid);
}

CMD:spawnveh(playerid, params[])
{
    new vehicleid, color1, color2, siren;
    if (sscanf(params, "iiii", vehicleid, color1, color2, siren)) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /spawnveh <id òðàíñïîðòà> <Öâåò 1> <Öâåò 2> <Ñèðåíà>");
    if (vehicleid < 400 || vehicleid > 610) return SendClientMessage(playerid, -1, "Íîìåðà òðàíñïîðòà íàõîäÿòñÿ â ïðîìåæóòêå [400, 610]");
    if (color1 < 0 || color1 > 128 || color2 < 0 || color2 > 128) return SendClientMessage(playerid, -1, "Íîìåðà öâåòà íàõîäÿòñÿ â ïðîìåæóòêå [0, 128]");
    if (siren != 0 && siren != 1) return SendClientMessage(playerid, -1, "Çíà÷åíèå ïîëÿ 'Ñèðåíà' ìîæåò áûòü 1 èëè 0");
    new player_vehid = GetPlayerVehicleID(playerid);
    if (player_vehid != 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) DestroyVehicle(player_vehid);
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    return PutPlayerInVehicle(playerid, CreateVehicle(vehicleid, x, y, z, a, color1, color2, 0, siren), DRIVER_SEAT);
}

CMD:ungun(playerid, params[])
{
    if (isnull(params))
    {
        SendClientMessage(playerid, -1, "Âû î÷èñòèëè âñ¸ âàøå îðóæèå!");
        return ResetPlayerWeapons(playerid);
    }
    if (sscanf(params, "i", params[0])) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /ungun <id èãðîêà>");
    if (!IsPlayerConnected(params[0])) return SendClientMessage(playerid, -1, "Èãðîêà ñ òàêèì ID íåò íà ñåðâåðå!");
    SendClientMessage(params[0], -1, "Èãðîâîé ìàñòåð çàáðàë âñ¸ âàøå îðóæèå!");
    return ResetPlayerWeapons(params[0]);
}

CMD:getanim(playerid, params[])
{
    new animid = GetPlayerAnimationIndex(playerid);
    new string[29];
    format(string, sizeof string, "Íîìåð òåêóùåé àíèìàöèè: %d", animid);
    return SendClientMessage(playerid, -1, string);
}

CMD:god(playerid, params[])
{
    new Float:player_health;
    if (GetPVarInt(playerid, "IsGod"))
    {
        SendClientMessage(playerid, -1, "Âû äåàêòèâèðîâàëè ðåæèì Áîãà!");
        player_health = MAX_PLAYER_HEALTH;
        SetPVarInt(playerid, "IsGod", 0);
    }
    else
    {
        SendClientMessage(playerid, -1, "Âû àêòèâèðîâàëè ðåæèì Áîãà!");
        player_health = FLOAT_INFINITY;
        SetPVarInt(playerid, "IsGod", 1);
    }
    return SetPlayerHealth(playerid, player_health);
}

CMD:kill(playerid, params[])
{
    if (isnull(params)) return SetPlayerHealth(playerid, 0);
    new receiverid;
    if (sscanf(params, "i", receiverid)) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /kill <id èãðîêà>");
    if (!IsPlayerConnected(receiverid)) return SendClientMessage(playerid, -1, "Èãðîêà ñ òàêèì ID íåò íà ñåðâåðå!");
    if (GetPVarInt(receiverid, "IsGod")) return SendClientMessage(playerid, -1, "Èãðîê íàõîäèòñÿ â ðåæèìå Áîãà!");
    return SetPlayerHealth(receiverid, 0);
}

CMD:setfraction(playerid, params[])
{
    if (sscanf(params, "i", params[0])) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /setorg <id îðãàíèçàöèè>");
    if (params[0] < 0 || params[0] > 7) return SendClientMessage(playerid, -1, "ID îðãàíèçàöèé íàõîäÿòñÿ â ïðîìåæóòêå [0, 7]!");
    new string[46];
    format(string, sizeof string, "Âàøà îðãàíèçàöèÿ èçìåíåíà íà: %s", stringFractions[params[0]]);
    SendClientMessage(playerid, -1, string);
    return SetPlayerFraction(playerid, params[0]);
}

stock SetPlayerFraction(playerid, fraction)
{
    if (Players[playerid][pFraction] == fraction) return 0;
    Players[playerid][pFraction] = fraction;
    if (fraction != 0) SetPlayerSkin(playerid, fractions_skins[fraction][0]);
    else SetPlayerSkin(playerid, Players[playerid][pSkin]);
    return SetPlayerColor(playerid, colorFractions[fraction]);
}

CMD:givemoney(playerid, params[])
{
    if (sscanf(params, "d", params[0])) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /givemoney <Ñóììà>");
    return GivePlayerMoney(playerid, params[0]);
}

CMD:pay(playerid, params[])
{
    new receiverid, amount;
    if (sscanf(params, "ii", receiverid, amount)) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /pay <id èãðîêà> <Ñóììà>");
    if (playerid == receiverid) return SendClientMessage(playerid, -1, "Âû íå ìîæåòå ïåðåäàòü äåíüãè ñàìîìó ñåáå!");
    if (!IsPlayerConnected(receiverid)) return SendClientMessage(playerid, -1, "Èãðîêà ñ òàêèì ID íåò íà ñåðâåðå!");
    if (GetDistanceBetweenPlayers(playerid, receiverid) > 5.0) return SendClientMessage(playerid, -1, "Èãðîê íàõîäèòñÿ ñëèøêîì äàëåêî!");
    if (GetPlayerMoney(playerid) < amount) return SendClientMessage(playerid, -1, "Ó âàñ íåäîñòàòî÷íî ñðåäñòâ!");
    if (amount < 1) return SendClientMessage(playerid, -1, "Âû íå ìîæåòå ïåðåäàòü ìåíüøå îäíîãî ðóáëÿ!");
    if (amount > 3000) return SendClientMessage(playerid, -1, "Âû íå ìîæåòå ïåðåäàòü áîëüøå òð¸õ òûñÿ÷ ðóáëåé!");
    GivePlayerMoney(playerid, -amount);
    GivePlayerMoney(receiverid, amount);
    new string[144];
    format(string, sizeof string, "%s ïåðåäàë %s %d ðóáëåé", Players[playerid][pName], Players[receiverid][pName], amount);
    return ProxDetector(playerid, 20.0, 0xFF99CCAA, string);
}

CMD:eject(playerid, params[])
{
    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "Âû íå íàõîäèòåñü çà ðóë¸ì òðàíñïîðòà!");
    if (sscanf(params, "i", params[0])) return SendClientMessage(playerid, -1, "Èñïîëüçóéòå: /eject <id èãðîêà>");
    if (playerid == params[0]) return SendClientMessage(playerid, -1, "Âû íå ìîæåòå âûãíàòü ñàìîãî ñåáÿ!");
    if (GetPlayerVehicleID(params[0]) != GetPlayerVehicleID(playerid)) return SendClientMessage(playerid, -1, "Èãðîêà ñ òàêèì ID íåò â ìàøèíå!");
    new string[23 + (-2 + MAX_PLAYER_NAME)];
    format(string, sizeof string, "âûêèíóë èç òðàíñïîðòà %s", Players[params[0]][pName]);
    callcmd::me(playerid, string);
    return RemovePlayerFromVehicle(params[0]);
}

CMD:fix(playerid, params[])
{
    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "Ýòó êîìàíäó íåëüçÿ èñïîëüçîâàòü â òðàíñïîðòå!");
    if (Players[playerid][pRepairkits] <= 0) return SendClientMessage(playerid, -1, "Ó âàñ íåò ðåìîíòíîãî íàáîðà!");
    new vehicleid = GetNearestVehicle(playerid, 3);
    if (vehicleid == 0) return SendClientMessage(playerid, -1, "Ðÿäîì ñ âàìè íåò òðàíñïîðòíîãî ñðåäñòâà!");
    printf("%d", vehicleid);
    new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    if (engine == VEHICLE_PARAMS_ON) return SendClientMessage(playerid, -1, "Äâèãàòåëü äîëæåí áûòü çàãëóøåí!");
    new Float: vehiclehealth;
    GetVehicleHealth(vehicleid, vehiclehealth);
    if (vehiclehealth >= 900) return SendClientMessage(playerid, -1, "Òðàíñïîðò íå íóæäàåòñÿ â ïî÷èíêå!");
    Players[playerid][pRepairkits]--;
    new string[] = "ïî÷èíèë òðàíñïîðòíîå ñðåäñòâî";
    callcmd::me(playerid, string);
    return SetVehicleHealth(vehicleid, VEHICLE_MAX_HEALTH);
}

forward HideTextDraw(playerid, text_draw);
public HideTextDraw(playerid, text_draw)
{
    TextDrawHideForPlayer(playerid, text_draws[text_draw]);
    return 1;
}

forward SafeLoadAnti(playerid);
public SafeLoadAnti(playerid)
{
    TogglePlayerControllable(playerid, 1);
    return 1;
}

stock IsPlayerInOPG(playerid)
{
    return Players[playerid][pFraction] == fGopota || Players[playerid][pFraction] == fSkinheads || Players[playerid][pFraction] == fKavkaz;
}

stock IsPlayerInRadius(playerid, Float: SPX, Float: SPY, Float: SPZ, Float: radius)
{
    new Float:FPX, Float:FPY, Float:FPZ, Float:RPX, Float:RPY, Float:RPZ;
    GetPlayerPos(playerid, FPX, FPY, FPZ);
    RPX = (SPX - FPX);
    RPY = (SPY - FPY);
    RPZ = (SPZ - FPZ);
    if(((RPX < radius) && (RPX > -radius)) && ((RPY < radius) && (RPY > -radius)) && ((RPZ < radius) && (RPZ > -radius))) return 1;
    return 0;
}

stock GetNearestVehicle(playerid, Float:range)
{
    new Pretendent = 0, Float:p_X, Float:p_Y, Float:p_Z, Float:Distance, Float:PretendentDistance = range + 1;
    GetPlayerPos(playerid, p_X, p_Y, p_Z);
    for(new vehicleid = 1; vehicleid < MAX_VEHICLES; vehicleid++)
    {
        if (!IsValidVehicle(vehicleid)) continue;
        Distance = GetVehicleDistanceFromPoint(vehicleid, p_X, p_Y, p_Z);
        if(Distance <= range && Distance <= PretendentDistance)
        {
            Pretendent = vehicleid;
            PretendentDistance = Distance;
        }
    }
    return Pretendent;
}

stock ProxDetectorWithColor(playerid, Float: max_range, color, const string[], Float: max_ratio = 1.6)
{
	new Float: pos_x, Float: pos_y, Float: pos_z,
	Float: range, Float: range_ratio, Float: range_with_ratio,
	clr_r, clr_g, clr_b,
	Float: color_r, Float: color_g, Float: color_b;

	if (!GetPlayerPos(playerid, pos_x, pos_y, pos_z)) return 0;

	color_r = float(color >> 24 & 0xFF);
	color_g = float(color >> 16 & 0xFF);
	color_b = float(color >> 8 & 0xFF);
	range_with_ratio = max_range * max_ratio;

	foreach (new plr : Player)
	{
		if (!IsPlayerStreamedIn(playerid, plr)) continue;

		range = GetPlayerDistanceFromPoint(plr, pos_x, pos_y, pos_z);
		if (range > max_range) continue;

		range_ratio = (range_with_ratio - range) / range_with_ratio;

		clr_r = floatround(range_ratio * color_r);
		clr_g = floatround(range_ratio * color_g);
		clr_b = floatround(range_ratio * color_b);

		SendClientMessage(plr, (color & 0xFF) | (clr_b << 8) | (clr_g << 16) | (clr_r << 24), string);
	}
    SendClientMessage(playerid, color, string);
	return 1;
}


stock ProxDetector(playerid, Float: max_range, color, const string[])
{
	new Float: pos_x, Float: pos_y, Float: pos_z, Float: range;

	if (!GetPlayerPos(playerid, pos_x, pos_y, pos_z)) return 0;

	foreach (new plr : Player)
	{
		if (!IsPlayerStreamedIn(playerid, plr)) continue;

		range = GetPlayerDistanceFromPoint(plr, pos_x, pos_y, pos_z);
		if (range > max_range) continue;

		SendClientMessage(plr, color, string);
	}
    SendClientMessage(playerid, color, string);
	return 1;
}

stock PickupsInit()
{
    pickup_shop_1 = CreatePickup(19134, 23, 845.4578, 871.6127, 13.3516);
    return 1;
}

stock ShowPlayerDialogAnimationsList(playerid)
{
    return ShowPlayerDialog(playerid, DLG_ANIMLIST, DIALOG_STYLE_LIST, "Ñïèñîê àíèìàöèé", "1. Ïüÿíàÿ ïîõîäêà\n2. Ïîöåëóé 1\n3. Ïîöåëóé 2\n4. Ïîöåëóé 3\n5. Ñåñòü, îïåðåâøèñü íà ðóêó", "Ïðèìåíèòü", "Îòìåíà");
}

stock ShowPlayerDialogShopAllDay(playerid)
{
    return ShowPlayerDialog(playerid, DLG_SHOP_ALLDAY, DIALOG_STYLE_LIST, "Ìàãàçèí 24/7", "1. ×èïñû (ñ ñîáîé)\n2. Ïèööà (ñ ñîáîé)\n3. Áóêåò öâåòîâ 'Ìèëëèîí àëûõ ðîç'\n4. Ìåäèöèíñêàÿ àïòå÷êà\n5. Ôîòîàïïàðàò\n6. Áàëëîí÷èê ñ êðàñêîé\n7. Ìàñêà\n8. Ðåìîíòíûé íàáîð\n9. Äîìêðàò", "Êóïèòü", "Âûõîä");
}

stock HasPlayerWeapon(playerid, weaponid)
{
    if (!IsPlayerConnected(playerid)) return 0;
    new tmp_weaponid, tmp_weaponammo;
    for (new i = 0; i <= 12; i++)
    {
        GetPlayerWeaponData(playerid, i, tmp_weaponid, tmp_weaponammo);
        if (tmp_weaponid == weaponid && tmp_weaponammo > 0) return 1;
    }
    return 0;
}

stock OnPlayerClearAnimation(playerid)
{
    if (GetPVarInt(playerid, "CanClearAnim"))
    {
        switch (GetPlayerAnimationIndex(playerid))
        {
            case 3: SetPlayerAnimation(playerid, 4, 1, 0, 0, 0, 0, 0, 1);
            default: ClearAnimations(playerid);
        }
        SetPVarInt(playerid, "CanClearAnim", 0);
        TextDrawHideForPlayer(playerid, text_draws[text_stop_anim]);
    }
    return 1;
}

stock OnPlayerSetAnimation(playerid, index, Float:fDelta = 4.1, loop = 0, lockx = 0, locky = 0, freeze = 0, time = 0, forcesync = 1)
{
    if (GetPlayerVehicleID(playerid) != 0) return SendClientMessage(playerid, -1, "Àíèìàöèè íåëüçÿ èñïîëüçîâàòü â òðàíñïîðòå!");
    new current_anim = GetPlayerAnimationIndex(playerid);
    if (current_anim != 1189 && current_anim != 1133 && current_anim != 1132 
    && current_anim != 0 && current_anim != 1275 && current_anim != 1181 
    && current_anim != 1182 && current_anim != 1188 && current_anim != 1183 
    && current_anim != 1186 && current_anim != 1188) return SendClientMessage(playerid, -1, "Âû íå ìîæåòå èñïîëüçîâàòü àíèìàöèè â òåêóùèé ìîìåíò âðåìåíè!");
    if (loop | freeze)
    {
        SetPVarInt(playerid, "CanClearAnim", 1);
        TextDrawShowForPlayer(playerid, text_draws[text_stop_anim]);
    }
    return SetPlayerAnimation(playerid, index, fDelta, loop, lockx, locky, freeze, time, forcesync);
}

stock SetPlayerAnimation(playerid, index, Float:fDelta = 4.1, loop = 0, lockx = 0, locky = 0, freeze = 0, time = 0, forcesync = 1)
{
    if(IsPlayerConnected(playerid) && index > 0 && index < 1813) {
        new animlib[33], animname[33];
        GetAnimationName(index, animlib, sizeof animlib, animname, sizeof animname);
        ApplyAnimation(playerid, animlib, animname, fDelta, loop, lockx, locky, freeze, time, forcesync);
        return 1;
    }
    return 0;
}

stock PreloadAllAnimLibs(playerid)
{
    PreloadAnimLib(playerid,"AIRPORT");             
    PreloadAnimLib(playerid,"Attractors");          
    PreloadAnimLib(playerid,"BAR");         
    PreloadAnimLib(playerid,"BASEBALL");            
    PreloadAnimLib(playerid,"BD_FIRE");             
    PreloadAnimLib(playerid,"BEACH");               
    PreloadAnimLib(playerid,"benchpress");          
    PreloadAnimLib(playerid,"BF_injection");                
    PreloadAnimLib(playerid,"BIKED");               
    PreloadAnimLib(playerid,"BIKEH");                 
    PreloadAnimLib(playerid,"BIKELEAP");              
    PreloadAnimLib(playerid,"BIKES");                 
    PreloadAnimLib(playerid,"BIKEV");                 
    PreloadAnimLib(playerid,"BIKE_DBZ");              
    PreloadAnimLib(playerid,"BLOWJOBZ");              
    PreloadAnimLib(playerid,"BMX");           
    PreloadAnimLib(playerid,"BOMBER");                
    PreloadAnimLib(playerid,"BOX");           
    PreloadAnimLib(playerid,"BSKTBALL");              
    PreloadAnimLib(playerid,"BUDDY");                 
    PreloadAnimLib(playerid,"BUS");           
    PreloadAnimLib(playerid,"CAMERA");                
    PreloadAnimLib(playerid,"CAR");           
    PreloadAnimLib(playerid,"CARRY");                 
    PreloadAnimLib(playerid,"CAR_CHAT");              
    PreloadAnimLib(playerid,"CASINO");                
    PreloadAnimLib(playerid,"CHAINSAW");              
    PreloadAnimLib(playerid,"CHOPPA");                
    PreloadAnimLib(playerid,"CLOTHES");               
    PreloadAnimLib(playerid,"COACH");                 
    PreloadAnimLib(playerid,"COLT45");                
    PreloadAnimLib(playerid,"COP_AMBIENT");           
    PreloadAnimLib(playerid,"COP_DVBYZ");             
    PreloadAnimLib(playerid,"CRACK");                 
    PreloadAnimLib(playerid,"CRIB");                  
    PreloadAnimLib(playerid,"DAM_JUMP");              
    PreloadAnimLib(playerid,"DANCING");               
    PreloadAnimLib(playerid,"DEALER");                
    PreloadAnimLib(playerid,"DILDO");                 
    PreloadAnimLib(playerid,"DODGE");                 
    PreloadAnimLib(playerid,"DOZER");                 
    PreloadAnimLib(playerid,"DRIVEBYS");              
    PreloadAnimLib(playerid,"FAT");           
    PreloadAnimLib(playerid,"FIGHT_B");               
    PreloadAnimLib(playerid,"FIGHT_C");               
    PreloadAnimLib(playerid,"FIGHT_D");               
    PreloadAnimLib(playerid,"FIGHT_E");               
    PreloadAnimLib(playerid,"FINALE");                
    PreloadAnimLib(playerid,"FINALE2");               
    PreloadAnimLib(playerid,"FLAME");                 
    PreloadAnimLib(playerid,"Flowers");               
    PreloadAnimLib(playerid,"FOOD");                  
    PreloadAnimLib(playerid,"Freeweights");           
    PreloadAnimLib(playerid,"GANGS");                 
    PreloadAnimLib(playerid,"GHANDS");                
    PreloadAnimLib(playerid,"GHETTO_DB");             
    PreloadAnimLib(playerid,"goggles");               
    PreloadAnimLib(playerid,"GRAFFITI");              
    PreloadAnimLib(playerid,"GRAVEYARD");             
    PreloadAnimLib(playerid,"GRENADE");               
    PreloadAnimLib(playerid,"GYMNASIUM");             
    PreloadAnimLib(playerid,"HAIRCUTS");              
    PreloadAnimLib(playerid,"HEIST9");                
    PreloadAnimLib(playerid,"INT_HOUSE");             
    PreloadAnimLib(playerid,"INT_OFFICE");            
    PreloadAnimLib(playerid,"INT_SHOP");              
    PreloadAnimLib(playerid,"JST_BUISNESS");                  
    PreloadAnimLib(playerid,"KART");                  
    PreloadAnimLib(playerid,"KISSING");               
    PreloadAnimLib(playerid,"KNIFE");                 
    PreloadAnimLib(playerid,"LAPDAN1");               
    PreloadAnimLib(playerid,"LAPDAN2");               
    PreloadAnimLib(playerid,"LAPDAN3");               
    PreloadAnimLib(playerid,"LOWRIDER");              
    PreloadAnimLib(playerid,"MD_CHASE");              
    PreloadAnimLib(playerid,"MD_END");                
    PreloadAnimLib(playerid,"MEDIC");                 
    PreloadAnimLib(playerid,"MISC");                  
    PreloadAnimLib(playerid,"MTB");           
    PreloadAnimLib(playerid,"MUSCULAR");              
    PreloadAnimLib(playerid,"NEVADA");                
    PreloadAnimLib(playerid,"ON_LOOKERS");            
    PreloadAnimLib(playerid,"OTB");           
    PreloadAnimLib(playerid,"PARACHUTE");             
    PreloadAnimLib(playerid,"PARK");                  
    PreloadAnimLib(playerid,"PAULNMAC");              
    PreloadAnimLib(playerid,"ped");           
    PreloadAnimLib(playerid,"PLAYER_DVBYS");                  
    PreloadAnimLib(playerid,"PLAYIDLES");             
    PreloadAnimLib(playerid,"POLICE");                
    PreloadAnimLib(playerid,"POOL");                  
    PreloadAnimLib(playerid,"POOR");                  
    PreloadAnimLib(playerid,"PYTHON");                
    PreloadAnimLib(playerid,"QUAD");                  
    PreloadAnimLib(playerid,"QUAD_DBZ");              
    PreloadAnimLib(playerid,"RAPPING");               
    PreloadAnimLib(playerid,"RIFLE");                 
    PreloadAnimLib(playerid,"RIOT");                  
    PreloadAnimLib(playerid,"ROB_BANK");              
    PreloadAnimLib(playerid,"ROCKET");                
    PreloadAnimLib(playerid,"RUSTLER");               
    PreloadAnimLib(playerid,"RYDER");                 
    PreloadAnimLib(playerid,"SCRATCHING");            
    PreloadAnimLib(playerid,"SHAMAL");                
    PreloadAnimLib(playerid,"SHOP");                  
    PreloadAnimLib(playerid,"SHOTGUN");               
    PreloadAnimLib(playerid,"SILENCED");              
    PreloadAnimLib(playerid,"SKATE");                 
    PreloadAnimLib(playerid,"SMOKING");               
    PreloadAnimLib(playerid,"SNIPER");                
    PreloadAnimLib(playerid,"SPRAYCAN");              
    PreloadAnimLib(playerid,"STRIP");                 
    PreloadAnimLib(playerid,"SUNBATHE");              
    PreloadAnimLib(playerid,"SWAT");                  
    PreloadAnimLib(playerid,"SWEET");                 
    PreloadAnimLib(playerid,"SWIM");                  
    PreloadAnimLib(playerid,"SWORD");                 
    PreloadAnimLib(playerid,"TANK");                  
    PreloadAnimLib(playerid,"TATTOOS");               
    PreloadAnimLib(playerid,"TEC");           
    PreloadAnimLib(playerid,"TRAIN");                 
    PreloadAnimLib(playerid,"TRUCK");                 
    PreloadAnimLib(playerid,"UZI");           
    PreloadAnimLib(playerid,"VAN");           
    PreloadAnimLib(playerid,"VENDING");               
    PreloadAnimLib(playerid,"VORTEX");                
    PreloadAnimLib(playerid,"WAYFARER");
    PreloadAnimLib(playerid,"WEAPONS");
    PreloadAnimLib(playerid,"WUZI");
    return 1;
}

stock PreloadAnimLib(playerid, const animlib[])
{
   ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
   return 1;
}

stock OnPlayerSwitchVehicleEngine(playerid, vehicleid)
{
    new engine, lights, alarm, doors, bonnet, boot, objective, Float:vehiclehealth;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    GetVehicleHealth(vehicleid, vehiclehealth);
    if ((engine == VEHICLE_PARAMS_OFF || engine == VEHICLE_PARAMS_UNSET) && vehiclehealth <= VEHICLE_CRITICAL_HEALTH && random(VEHICLE_CRITICAL_HEALTH - VEHICLE_MIN_HEALTH) >= vehiclehealth - VEHICLE_MIN_HEALTH)
    {
        TextDrawShowForPlayer(playerid, text_draws[text_engine_broken]);
    }
    else if (engine == VEHICLE_PARAMS_ON) engine = VEHICLE_PARAMS_OFF;
    else
    {
        engine = VEHICLE_PARAMS_ON;
        TextDrawHideForPlayer(playerid, text_draws[text_engine_broken]);
    }
    return SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
}

stock OnPlayerSwitchVehicleLights(playerid, vehicleid)
{
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    if (lights == VEHICLE_PARAMS_OFF || lights == VEHICLE_PARAMS_UNSET) lights = VEHICLE_PARAMS_ON;
    else lights = VEHICLE_PARAMS_OFF;
    return SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
}

stock IsVehicleBicycle(vehicleid)
{
    new model = GetVehicleModel(vehicleid);
    return model == 481 || model == 509 || model == 510 ? 1 : 0;
}

stock InitGlobalTextDraws()
{
    text_draws[text_stop_anim] = TextDrawCreate(250.000000, 375.000000, "LShift - îòìåíèòü àíèìàöèþ.");
    TextDrawFont(text_draws[text_stop_anim], 1);
    TextDrawLetterSize(text_draws[text_stop_anim], 0.320833, 2.000000);
    TextDrawTextSize(text_draws[text_stop_anim], 458.000000, 0.000000);
    TextDrawSetOutline(text_draws[text_stop_anim], 0);
    TextDrawSetShadow(text_draws[text_stop_anim], 0);
    TextDrawAlignment(text_draws[text_stop_anim], 1);
    TextDrawColor(text_draws[text_stop_anim], -168436481);
    TextDrawBackgroundColor(text_draws[text_stop_anim], 255);
    TextDrawBoxColor(text_draws[text_stop_anim], 50);
    TextDrawUseBox(text_draws[text_stop_anim], 0);
    TextDrawSetProportional(text_draws[text_stop_anim], 1);
    TextDrawSetSelectable(text_draws[text_stop_anim], 0);

    text_draws[text_getting_vehicle] = TextDrawCreate(250.000000, 375.000000, "Ctrl - çàâåñòè òðàíñïîðò.");
    TextDrawFont(text_draws[text_getting_vehicle], 1);
    TextDrawLetterSize(text_draws[text_getting_vehicle], 0.320833, 2.000000);
    TextDrawTextSize(text_draws[text_getting_vehicle], 458.000000, 0.000000);
    TextDrawSetOutline(text_draws[text_getting_vehicle], 0);
    TextDrawSetShadow(text_draws[text_getting_vehicle], 0);
    TextDrawAlignment(text_draws[text_getting_vehicle], 1);
    TextDrawColor(text_draws[text_getting_vehicle], -168436481);
    TextDrawBackgroundColor(text_draws[text_getting_vehicle], 255);
    TextDrawBoxColor(text_draws[text_getting_vehicle], 50);
    TextDrawUseBox(text_draws[text_getting_vehicle], 0);
    TextDrawSetProportional(text_draws[text_getting_vehicle], 1);
    TextDrawSetSelectable(text_draws[text_getting_vehicle], 0);

    text_draws[text_engine_broken] = TextDrawCreate(203.000000, 272.000000, "Äâèãàòåëü ñëîìàí! Ïîïðîáóé åù¸ ðàç!");
    TextDrawFont(text_draws[text_engine_broken], 1);
    TextDrawLetterSize(text_draws[text_engine_broken], 0.600000, 2.000000);
    TextDrawTextSize(text_draws[text_engine_broken], 465.000000, 17.000000);
    TextDrawSetOutline(text_draws[text_engine_broken], 0);
    TextDrawSetShadow(text_draws[text_engine_broken], 0);
    TextDrawAlignment(text_draws[text_engine_broken], 1);
    TextDrawColor(text_draws[text_engine_broken], -1962934017);
    TextDrawBackgroundColor(text_draws[text_engine_broken], 255);
    TextDrawBoxColor(text_draws[text_engine_broken], 50);
    TextDrawUseBox(text_draws[text_engine_broken], 0);
    TextDrawSetProportional(text_draws[text_engine_broken], 1);
    TextDrawSetSelectable(text_draws[text_engine_broken], 0);

    return 1;
}

stock IsValidWeaponID(weaponid)
{
    for (new i = 0; i < sizeof missing_guns; i++) if (weaponid == missing_guns[i]) return 0;
    return 1;
}
