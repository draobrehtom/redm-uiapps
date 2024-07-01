# redm-uiapps

```
abilities
character_creator
collectors
coupons
crafting
ending_credits
fast_travel_menu
help_menu
hub
hud_quick_select
landing_page
leaderboards
lobbies_menu
map
mp_mission_info
naturalist
opening_credits_sequence
pause_menu
player_menu
policies_menu
progress_menu
rewards
rockstar_editor
role_progression
satchel
saveload_menu
settings_menu
shop_browsing
shop_menu
social_club_feed
social_club_login
stats_menu
store
trader
translation_overlay
virtual_keyboard
weapon_locker
```

# Events
```c++
enum eUIScriptEventType : Hash
{
	UISCRIPTEVENTTYPE_INVALID = 0,
	UISCRIPTEVENTTYPE_ITEM_FOCUSED = 0x984750E7,
	UISCRIPTEVENTTYPE_ITEM_UNFOCUSED = 0xDA4D50F6,
	UISCRIPTEVENTTYPE_ITEM_SELECTED = 0xB841988C,
	UISCRIPTEVENTTYPE_NEW_ACTIVITY = 0x36FB9F7E,
	UISCRIPTEVENTTYPE_NEW_PAGE = 0x8445624D,
	UISCRIPTEVENTTYPE_TAB_PAGE_INCREMENT = 0x29EB385C,
	UISCRIPTEVENTTYPE_TAB_PAGE_DECREMENT = 0xD4E9057D,
	UISCRIPTEVENTTYPE_INDEX_CHANGED = 0x6EAEFEB9,
	UISCRIPTEVENTTYPE_INDEX_CHANGE_REQUESTED = 0x462BEB80,
	UISCRIPTEVENTTYPE_ITEM_SELECTED_ACTION_SUCCEEDED = 0xE29A8210,
	UISCRIPTEVENTTYPE_ITEM_HOLD_ACTION_STARTED = 0x37104AFD,
	UISCRIPTEVENTTYPE_ITEM_HOLD_ACTION_CANCELLED = 0x9BA74C01,
	UISCRIPTEVENTTYPE_DATA_ADJUSTABLE_CHANGED = 0xBB5C7348,
	UISCRIPTEVENTTYPE_DATA_ADJUSTABLE_CHANGED_ABSOLUTE = 0x60624708,
	UISCRIPTEVENTTYPE_FEED_MESSAGE_INTERACTED = 0xB018ED22,
	UISCRIPTEVENTTYPE_STICKY_FEED_CLEARED = 0xE5733EE0,
	UISCRIPTEVENTTYPE_PAGED_COLLECTION_INITIALIZED = 0xF8D8E7EA,
	UISCRIPTEVENTTYPE_PAGED_COLLECTION_REQUEST = 0x15F05555,
	UISCRIPTEVENTTYPE_PAGED_COLLECTION_RESET = 0xF9307213,
	UISCRIPTEVENTTYPE_ENTER_TRANSITION_COMPLETED = 0x5DF51FC0,
	UISCRIPTEVENTTYPE_EXIT_TRANSITION_COMPLETED = 0x7C0102D8,
	UISCRIPTEVENTTYPE_VIRTUAL_KEYBOARD_RESULT = 0x73446E9B,
	UISCRIPTEVENTTYPE_PINNED_ITEM_VALIDATION = 0x7D26E5FF
};
```
Example usage ([reference](https://github.com/aaron1a12/wild/blob/9235aaa39696691ff26977ff1d2c18fe67971ef5/wild-core/client/cl_weaponWheel.lua#L28)):
```lua
local msg = DataView.ArrayBuffer(8 * 4) -- https://github.com/meta-hub/redm-events/blob/main/dataview.lua
msg:SetInt32(0, 0)
msg:SetInt32(8, 0)
msg:SetInt32(16, 0)
msg:SetInt32(24, 0)

if EventsUiGetMessage(`hud_quick_select`, msg:Buffer()) ~= 0 then                    
    if msg:GetInt32(0) == `ITEM_FOCUSED` then

	if msg:GetInt32(8) == 1 and msg:GetInt32(16) == 813560150 then
	    currentWheel = 0 -- Weapon wheel
	end

	if msg:GetInt32(8) == 2 and msg:GetInt32(16) == -414255251 then
	    currentWheel = 1 -- Item wheel
	end

	if msg:GetInt32(8) == 3 and msg:GetInt32(16) == -1472057397 then
	    currentWheel = 2 -- Horse wheel
	end
    end
end 
```
