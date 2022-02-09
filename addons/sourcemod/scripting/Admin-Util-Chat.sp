#define PLUGIN_PREFIX "\x01[\x06A. TMG-Chat.\x01]"
#define PLUGIN_VERSION "1.14"

#include <sourcemod>

ConVar g_cvDeadTalk;

public Plugin myinfo = {
	name = "Admin Util - (Chat)",
	author = "Oscar Wos (OSWO)",
	description = "Admin Util",
	version = PLUGIN_VERSION,
	url = "https://github.com/OSCAR-WOS / https://steamcommunity.com/id/OSWO",
}

public void OnPluginStart() {
	AddCommandListener(lSay, "say");
	AddCommandListener(lSayTeam, "say_team");

	g_cvDeadTalk = FindConVar("sv_deadtalk");

	LoadTranslations("admin-util-chat.phrases");
}

public Action lSay(int iClient, const char[] cCommand, int iArgc) {
	if (!IsValidClient(iClient)) return;

	ArrayList aAdmins = new ArrayList();
	FindSuitableAdmins(aAdmins, ADMFLAG_CUSTOM6);

	char cMessage[512];
	int iClientAlive = IsPlayerAlive(iClient);

	GetCmdArgString(cMessage, sizeof(cMessage));
	if (strlen(cMessage) <= 2) return;

	cMessage[strlen(cMessage) - 1] = '\0';

	if (g_cvDeadTalk.BoolValue) return;

	for (int i = 0; i < aAdmins.Length; i++) {
		bool bCheckAlive = !iClientAlive && IsPlayerAlive(aAdmins.Get(i));

		if (bCheckAlive) SendCustomMessage(aAdmins.Get(i), iClient, bCheckAlive, false, cMessage[1]);
	}

	delete aAdmins;
}

public Action lSayTeam(int iClient, const char[] cCommand, int iArgc) {
	if (!IsValidClient(iClient)) return;

	ArrayList aAdmins = new ArrayList();
	FindSuitableAdmins(aAdmins, ADMFLAG_CHAT);

	char cMessage[512];
	int iClientAlive = IsPlayerAlive(iClient);
	int iClientTeam = GetClientTeam(iClient);

	GetCmdArgString(cMessage, sizeof(cMessage));
	if (strlen(cMessage) <= 2) return;

	cMessage[strlen(cMessage) - 1] = '\0';

	for (int i = 0; i < aAdmins.Length; i++) {
		bool bCheckAlive = !iClientAlive && IsPlayerAlive(aAdmins.Get(i));
		bool bCheckTeam = iClientTeam != GetClientTeam(aAdmins.Get(i));

		if (bCheckAlive || bCheckTeam) SendCustomMessage(aAdmins.Get(i), iClient, bCheckAlive, bCheckTeam, cMessage[1]);
	}

	delete aAdmins;
}

void FindSuitableAdmins(ArrayList aAdmins, int iFlag) {
	for (int i = 0; i <= MaxClients; i++) {
		if (IsValidClient(i)) {
			if (CheckCommandAccess(i, "", iFlag, true)) {
				aAdmins.Push(i);
			}
		}
	}
}

void SendCustomMessage(int iClient, int iTarget, bool bDeadChat, bool bDiffChat, char[] cMessage) {
	char cBuffer[512];
	char cTargetName[64];

	GetClientName(iTarget, cTargetName, sizeof(cTargetName));
	Format(cBuffer, sizeof(cBuffer), "%s", PLUGIN_PREFIX);

	if (bDeadChat) { Format(cBuffer, sizeof(cBuffer), "%s (\x0F%T\x01)", cBuffer, "Dead", iClient); }

	if (bDiffChat) {
		switch (GetClientTeam(iTarget)) {
			case 1: {
				Format(cBuffer, sizeof(cBuffer), "%s (\x10%T \x0DS.\x01)", cBuffer, "Team", iClient);
			}
			case 2: {
				Format(cBuffer, sizeof(cBuffer), "%s (\x10%T \x07T\x01)", cBuffer, "Team", iClient);
			}
			case 3: {
				Format(cBuffer, sizeof(cBuffer), "%s (\x10%T \x0BCT\x01)", cBuffer, "Team", iClient);
			}
		}
	}

	Format(cBuffer, sizeof(cBuffer), "%s \x09%s\x01: %s", cBuffer, cTargetName, cMessage);
	PrintToChat(iClient, cBuffer);
}

bool IsValidClient(int iClient) {
	if (iClient > 0 && iClient <= MaxClients && IsValidEntity(iClient) && IsClientConnected(iClient) && IsClientInGame(iClient) && !IsFakeClient(iClient)) {
		return true;
	}

	return false;
}
