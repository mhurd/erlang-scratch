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
-export([start/0, start/1]).

initState(OnCoords) ->
  LiveNeighbourCounts = maps:new(),
  OnCells = maps:new(),
  {LiveNeighbourCounts, putAll(OnCoords, OnCells)}.

putAll([], M) -> M;
putAll([H|T], M) ->
  putAll(T, maps:put(H, H, M)).


start(OnCoords) ->
  loop(initState(OnCoords)).

start() ->
  loop(initState([])).

loop(State) ->
  receive
    {From, step} ->
      NewState = step(State),
      From ! {self(), NewState},
      loop(NewState);
    _ -> {self(), not_know_at_this_address}
  end.

step(State) ->
  State.

% Pid = spawn(fun() -> life:start([{1,2}]) end).
% Pid ! {self(), step}.
% receive {From, State} -> io:format("Got: ~p~n", [State]) end.


