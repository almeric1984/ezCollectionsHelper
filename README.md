## EzCollectionsHelper
WIP allow azerothcore servers to use the EzCollections Addon by https://ezwow.org/user/273811-zeustiger/ 

## Info
* This is very much in alpha test on your server before production use. 
* Supported 2.4.4 addon version for this project.
* A modified version of EZCollections is required to allow custom races to work.
* I will not provided the addon or a modified version of it.

## Install
0) In order for apply to work correctly you need to use this modified version of mod_transmog https://github.com/almeric1984/mod-transmog
1) clone repo
2) Insert sql/auth.sql into auth database ```On Windows working directory might be bin so add ../ or use full path to modules config folder```
3) Config the above if need
``` Note step 4 isn't required if you already have this file from another  lua script```
4) copy dist/common/lualib_bundle.lua to lua_scripts/common/lualib_bundle.lua
5) copy dist/module/ezCollectionsHelper to lua_scripts/ezCollectionsHelper
6) Restart eluna engine

## Database Info
#### All tables are stored in auth to allow easier setup with multiple instances of the world server

### custom_ezCollectionsHelperConfig
> AllowedToHide isn't currently read but will be very soon

| RealmID | Prefix        | Version | CacheVersion | ModulesConfPath                    | AllowedToHide                                    |
| --------| --------------| ------- | ------------ | ---------------------------------- | ------------------------------------------------ |
| #       | EZCollections | 2.2.4   | any number   | realtive/full path to modules conf | : sperated list of slots user is allowed to hide |
### custom_ezCollectionsHelperCameras
> See https://www.azerothcore.org/wiki/item_template for class and subclass

> option is what model set the user has loaded currently this is never told to the server so use 1

| Id   | option     | race              | sex                           | x | y | z | f | anim | name   | class | subclass |
| ---- | -----------| ----------------- | ----------------------------- | - | - | - | - | -----| ------ | ----- | ---------|
| AUTO | 1 - 3      | 30 = All Races    | 1 = Male/2 = Female/ 3 = Both | # | # | # | # | #    | string | #     | #        |
