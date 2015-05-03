%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Mar 2015 12:46
%%%-------------------------------------------------------------------
-module(lib_misc).
-author("mhurd").

%% API
-export([perms/1]).

perms([]) -> [[]];

perms(L) -> [[H|T] || H <- L, T <- perms(L--[H])].
