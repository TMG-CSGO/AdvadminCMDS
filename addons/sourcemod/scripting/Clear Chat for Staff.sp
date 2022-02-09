#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <autoexecconfig>
#include <adminmenu>

#pragma semicolon 1

#define DEBUG

#pragma newdecls required

char g_ChatPrefix[256];
ConVar gConVar_Chat_Prefix;

ConVar gConVar_JoinMsg;
ConVar gConVar_Clear_Message;

//ADMIN MENU

Handle hAdminMenu;

public Plugin myinfo = 
{
	name = "Clear Chat for Staff (!clear) by Lantejoula", 
	author = "Lantejoula", 
	description = "Clear Chat with command !clear for STAFF", 
	version = "1.6", 
	url = "https://steamcommunity.com/id/lantejoula"
};

public void OnPluginStart()
{
	LoadTranslations("clearchatforstaff.phrases");
	
	RegAdminCmd("sm_cc", ClearChat, ADMFLAG_CHAT);
	RegAdminCmd("sm_clearchat", ClearChat, ADMFLAG_CHAT);
	RegAdminCmd("sm_clear", ClearChat, ADMFLAG_CHAT);
	
	
	AutoExecConfig_SetFile("plugin.clearchatforstaff");
	
	gConVar_Chat_Prefix = AutoExecConfig_CreateConVar("sm_clearchat_chat_prefix", "[{green}TMG-CC{default}]", "Chat Prefix");
	
	gConVar_Clear_Message = AutoExecConfig_CreateConVar("sm_clearchat_clear_message", "1", "Enable/Disable the Message when STAFF Clear Chat (1 - Enable | 0 - Disable)", 0, true, 0.0, true, 1.0);
	
	gConVar_JoinMsg = AutoExecConfig_CreateConVar("sm_clearchat_join_message", "0", "Enable/Disable the Message when STAFF Join (1 - Enable | 0 - Disable)", 0, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	gConVar_Chat_Prefix.AddChangeHook(OnPrefixChange);
}

////////
//Prefix
////////

public void SavePrefix()
{
	GetConVarString(gConVar_Chat_Prefix, g_ChatPrefix, sizeof(g_ChatPrefix));
}

public void OnConfigsExecuted()
{
	SavePrefix();
}

public void OnPrefixChange(ConVar cvar, char[] oldvalue, char[] newvalue)
{
	SavePrefix();
}

////////
//Plugin
////////

public Action ClearChat(int client, int args)
{
	for (int i = 0; i < 300; i++)
	{
		PrintToChatAll(" ");
	}
	
	char Name[MAX_NAME_LENGTH];
	GetClientName(client, Name, sizeof(Name));
	
	if (gConVar_Clear_Message.BoolValue)
		CPrintToChatAll("%s %t", g_ChatPrefix, "Clear Chat", Name);
}

///////////////////
//AUTO JOIN MESSAGE
///////////////////

public void OnClientPutInServer(int client)
{
	CreateTimer(5.0, JoinMsg, client);
}

public Action JoinMsg(Handle timer, any client)
{
	if (CheckCommandAccess(client, "sm_override_staff", ADMFLAG_GENERIC))
	{
		if (gConVar_JoinMsg.BoolValue)
			CPrintToChat(client, "%s %t", g_ChatPrefix, "JoinMsg");
	}
}

////////////
//ADMIN MENU
////////////

public void OnAllPluginsLoaded()
{
	Handle topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(topmenu);
}

public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == hAdminMenu)
		return;
	
	hAdminMenu = topmenu;
	CreateTimer(1.0, Timer_AttachAdminMenu);
}

public Action Timer_AttachAdminMenu(Handle timer)
{
	TopMenuObject menu_category = AddToTopMenu(hAdminMenu, "clearchat", TopMenuObject_Category, Handle_Category, INVALID_TOPMENUOBJECT, "clearchat", ADMFLAG_GENERIC);
	if (menu_category == INVALID_TOPMENUOBJECT)
		return;
	
	AddToTopMenu(hAdminMenu, "sm_clearchat", TopMenuObject_Item, AdminMenu_ClearChatStaff, menu_category, "sm_clearchat", ADMFLAG_GENERIC);
}

public void Handle_Category(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayTitle)
		Format(buffer, maxlength, "%T", "Clear Chat Title in Admin", param);
	else if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "%T", "Clear Chat Title in Admin", param);
}

public void AdminMenu_ClearChatStaff(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "%T", "Clear Chat Buttom in Admin", param);
	else if (action == TopMenuAction_SelectOption)
		FakeClientCommand(param, "sm_clearchat");
} 