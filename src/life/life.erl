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

-include_lib("eunit/include/eunit.hrl").

%% API
-export([start/2, step/0, get_neighbours/2]).

init_state(Bounds, OnCoords) ->
  LiveNeighbourCounts = maps:new(),
  LiveCells = maps:new(),
  LiveCellMap = put_all(OnCoords, LiveCells),
  {Bounds, LiveNeighbourCounts, LiveCellMap, 0}.

turn_on_cell(Bounds, LiveNeighbourCounts, LiveCellMap, Coord) ->
  NewLiveCellMap = maps:put(Coord, Coord, LiveCellMap),
  Neighbours = get_neighbours(Bounds, Coord),
  NewLiveNeighbourCounts = lists:foldl(fun increment_live_neightbour_count/2, LiveNeighbourCounts, Neighbours),
  {Bounds, NewLiveNeighbourCounts, NewLiveCellMap}.

turn_off_cell(Bounds, LiveNeighbourCounts, LiveCellMap, Coord) ->
  NewLiveCellMap = maps:put(Coord, Coord, LiveCellMap),
  Neighbours = get_neighbours(Bounds, Coord),
  NewLiveNeighbourCounts = lists:foldl(fun decrement_live_neightbour_count/2, LiveNeighbourCounts, Neighbours),
  {Bounds, NewLiveNeighbourCounts, NewLiveCellMap}.

modify_live_neightbour_count(F, Coord, LiveNeighbourCounts) ->
  case maps:find(Coord, LiveNeighbourCounts) of
    {ok, Value} -> maps:put(Coord, F(Value), LiveNeighbourCounts);
    error -> maps:put(Coord, 0, LiveNeighbourCounts)
  end.

increment_live_neightbour_count(Coord, LiveNeighbourCounts) ->
  modify_live_neightbour_count(fun(V) -> V+1 end, Coord, LiveNeighbourCounts).

decrement_live_neightbour_count(Coord, LiveNeighbourCounts) ->
  modify_live_neightbour_count(fun(V) -> case V of 0 -> 0; _ -> V-1 end end, Coord, LiveNeighbourCounts).

put_all([], M) -> M;
put_all([H|T], M) ->
  put_all(T, maps:put(H, H, M)).

start({bounds, _X, _Y} = Bounds, OnCoords) ->
  register(life, spawn(fun() -> State = init_state(Bounds, OnCoords), loop(State) end)).

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

roll_around(Bound, 0) -> Bound;
roll_around(Bound, Val) when Val < 0 -> roll_around(Bound, Bound+Val);
roll_around(Bound, Val) when Val > Bound -> roll_around(Bound, Val rem Bound);
roll_around(Bound, Val) when (Val > 0) and (Val =< Bound) -> Val.

get_neighbours({bounds, XB, YB}, {coord, X, Y}) ->
  [
    {coord,X,roll_around(YB,Y-1)}, % north
    {coord,roll_around(XB,X+1),roll_around(YB,Y-1)}, % north-east
    {coord,roll_around(XB,X+1),Y}, % east
    {coord,roll_around(XB,X+1),roll_around(YB,Y+1)}, % south-east
    {coord,X,roll_around(YB,Y+1)}, % south
    {coord,roll_around(XB,X-1),roll_around(YB,Y+1)}, % south-west
    {coord,roll_around(XB,X-1),Y}, % west
    {coord,roll_around(XB,X-1),roll_around(YB,Y-1)} % north-west
  ].

count_active_neighbours(Bounds, Coord, OnCoords) ->
  F = fun(E, Acc) -> case maps:find(E, OnCoords) of
                       {ok, Value} -> [Value | Acc];
                       error -> Acc
                     end end,
  length(lists:foldl(F, [], get_neighbours(Bounds, Coord))).

iterate({Bounds,LiveNeighbourCounts,OnCells,Count}) ->
  {Bounds,LiveNeighbourCounts,OnCells,Count+1}.

%%% Tests

-ifdef(EUNIT).
roll_around_test() ->
  [?assertEqual(1, roll_around(10, 11)),
    ?assertEqual(4, roll_around(10, 14)),
    ?assertEqual(10, roll_around(10, 0)),
    ?assertEqual(7, roll_around(10, -3)),
    ?assertEqual(4, roll_around(10, 34)),
    ?assertEqual(7, roll_around(10, -303))].
get_neighbours_test() ->
  %?debugFmt("get_neighbours_test..."),
  [?assertEqual([{coord,10,9},{coord,1,9},{coord,1,10},{coord,1,1},{coord,10,1},{coord,9,1},{coord,9,10},{coord,9,9}],
    get_neighbours({bounds,10,10}, {coord,10,10})),
    ?assertEqual([{coord,5,4},{coord,6,4},{coord,6,5},{coord,6,6},{coord,5,6},{coord,4,6},{coord,4,5},{coord,4,4}],
      get_neighbours({bounds,10,10}, {coord,5,5})),
    ?assertEqual([{coord,1,10},{coord,2,10},{coord,2,1},{coord,2,2},{coord,1,2},{coord,10,2},{coord,10,1},{coord,10,10}],
      get_neighbours({bounds,10,10}, {coord,1,1}))].
count_active_neighbours_test() ->
  Bounds = {bounds, 10, 10},
  TestMap = #{{coord, 5, 4} => {coord, 5, 4},
    {coord, 5, 5} => {coord, 5, 5},
    {coord, 4, 4} => {coord, 4, 4},
    {coord, 3, 3} => {coord, 3, 3},
    {coord, 2, 1} => {coord, 2, 1}},
  [?assertEqual(2, count_active_neighbours(Bounds, {coord, 5, 5}, TestMap)),
    ?assertEqual(2, count_active_neighbours(Bounds, {coord, 5, 4}, TestMap)),
    ?assertEqual(3, count_active_neighbours(Bounds, {coord, 4, 4}, TestMap)),
    ?assertEqual(2, count_active_neighbours(Bounds, {coord, 3, 2}, TestMap)),
    ?assertEqual(0, count_active_neighbours(Bounds, {coord, 6, 1}, TestMap)),
    ?assertEqual(1, count_active_neighbours(Bounds, {coord, 2, 10}, TestMap))].
turn_on_cell_test() ->
  Bounds = {bounds, 10, 10},
  Result1 = {Bounds, #{{coord, 5, 5} => 0}, #{{coord, 5, 5} => {coord, 5, 5}}},
  [?assertEqual(Result1, turn_on_cell(Bounds, #{}, #{}, {coord, 5, 5}))].
-endif.