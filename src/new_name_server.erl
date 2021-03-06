%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. May 2015 11:24
%%%-------------------------------------------------------------------
-module(new_name_server).
-author("mhurd").
-export([init/0, add/2, all_names/0, delete/1, find/1, handle/2]).
-import(server3, [rpc/2]).

%% interface
all_names() -> rpc(name_server, allNames).
add(Name, Place) -> rpc(name_server, {add, Name, Place}).
delete(Name) -> rpc(name_server, {delete, Name}).
find(Name) -> rpc(name_server, {find, Name}).
%% callback routines
init() -> dict:new().

handle({add, Name, Place}, Dict) -> {ok, dict:store(Name, Place, Dict)};
handle(allNames, Dict) -> {dict:fetch_keys(Dict), Dict};
handle({delete, Name}, Dict) -> {ok, dict:erase(Name, Dict)};
handle({find, Name}, Dict) -> {dict:find(Name, Dict), Dict}.