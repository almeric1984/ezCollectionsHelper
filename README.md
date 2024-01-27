## EzCollectionsHelper
WIP allow azerothcore servers to use the EzCollections Addon by https://ezwow.org/user/273811-zeustiger/ 

This is very much in alpha and should not be used in production. 2.4.4 addon version for this project.

## Install
1) clone repo
2) Insert sql/auth.sql into auth database
3) Config the above if need
``` Note step 4 isn't required if you already have this file from another  lua script```
4) copy dist/common/lualib_bundle.lua to lua_scripts/common/lualib_bundle.lua
5) copy dist/module/ezCollectionsHelper to lua_scripts/ezCollectionsHelper
6) Restart eluna engine

> In order for apply to work correctly you need to use this modified version of mod_transmog https://github.com/almeric1984/mod-transmog