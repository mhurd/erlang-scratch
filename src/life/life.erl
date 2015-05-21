%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. May 2015 20:15
%%%-------------------------------------------------------------------
-module(life).
-author("mhurd").

%% API
-export([start/1, step/0]).

initState(OnCoords) ->
  LiveNeighbourCounts = maps:new(),
  OnCells = maps:new(),
  {LiveNeighbourCounts, putAll(OnCoords, OnCells), 0}.

putAll([], M) -> M;
putAll([H|T], M) ->
  putAll(T, maps:put(H, H, M)).

start(OnCoords) ->
  register(life, spawn(fun() -> State = initState(OnCoords), loop(State) end)).

step() ->
  rpc(step).

rpc(Request) ->
  life ! {self(), Request},
  receive
    {_Pid, not_know_at_this_address} -> exit(rpc);
    {_Pid, NewState} -> NewState;
    _ -> exit(rpc)
  end.

loop(State) ->
  receive
    {From, step} ->
      NewState = iterate(State),
      From ! {self(), NewState},
      loop(NewState);
    {From, _} ->
      From ! {self(), not_know_at_this_address},
      loop(State)
  end.

iterate({LiveNeighbourCounts,OnCells,Count}) -> {LiveNeighbourCounts,OnCells,Count+1}.

