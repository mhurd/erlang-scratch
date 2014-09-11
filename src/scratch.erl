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
-export([length/1, map/2]).

length(List) -> length(List, 0).
length([], Acc) -> Acc;
length([_|T], Acc) -> length(T, Acc+1).

reverse(List) -> reverse(List, []).
reverse([], Acc) -> Acc;
reverse([H|T], Acc) -> reverse(T, [H|Acc]).

map(F, List) -> map(F, List, []).
map(_, [], Acc) -> reverse(Acc);
map(F, [H|T], Acc) -> map(F, T, [F(H)|Acc]).