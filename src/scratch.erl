%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Sep 2014 20:44
%%%-------------------------------------------------------------------
-module(scratch).
-author("mhurd").

%% API
-export([length/1]).

length(List) -> length(List, 0).
length([], Acc) -> Acc;
length([_|T], Acc) -> length(T, Acc+1).