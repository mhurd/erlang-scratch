%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. May 2015 20:15
%%% Good starting values: start({100,100},[{41,51},{40,53},{41,53},{43,52},{44,53},{45,53},{46,53}]).
%%%-------------------------------------------------------------------
-module(life).
-author("mhurd").

-include("life.hrl").
-include_lib("eunit/include/eunit.hrl").

%% API
-export([start/2, step/0, restart/2, get_neighbours/2]).

init_state(Bounds, InitialLiveCells) ->
  LiveCells = put_all(InitialLiveCells, maps:new()),
  #cycle{bounds=Bounds,live_cells=LiveCells}.

put_all([], M) -> M;
put_all([H|T], M) ->
  put_all(T, maps:put(H, 1, M)).

remove_all([], M) -> M;
remove_all([H|T], M) ->
  remove_all(T, maps:remove(H, M)).

tuples_to_coords(L) ->
  lists:map(fun({X, Y}) -> #coord{x=X,y=Y} end, L).

start({X,Y}, LiveCells) ->
  register(life, spawn(fun() -> State = init_state(#bounds{x=X, y=Y}, tuples_to_coords(LiveCells)), loop(State) end)).

step() ->
  rpc(step).

restart(Bounds, LiveCells) ->
  rpc({restart,Bounds,LiveCells}).

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
    {From, {restart, {X, Y}, LiveCells}} ->
      NewState = init_state(#bounds{x=X,y=Y}, LiveCells),
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

get_neighbours(#bounds{x=XB, y=YB}, #coord{x=X, y=Y} = Coord) ->
  [
    Coord#coord{y=roll_around(YB,Y-1)}, % north
    Coord#coord{x=roll_around(XB,X+1),y=roll_around(YB,Y-1)}, % north-east
    Coord#coord{x=roll_around(XB,X+1)}, % east
    Coord#coord{x=roll_around(XB,X+1),y=roll_around(YB,Y+1)}, % south-east
    Coord#coord{y=roll_around(YB,Y+1)}, % south
    Coord#coord{x=roll_around(XB,X-1),y=roll_around(YB,Y+1)}, % south-west
    Coord#coord{x=roll_around(XB,X-1)}, % west
    Coord#coord{x=roll_around(XB,X-1),y=roll_around(YB,Y-1)} % north-west
  ].

count_active_neighbours(Bounds, Coord, LiveCellMap) ->
  F = fun(C, Acc) -> case maps:find(C, LiveCellMap) of
                       {ok, Value} -> [Value | Acc];
                       error -> Acc
                     end end,
  length(lists:foldl(F, [], get_neighbours(Bounds, Coord))).

is_alive(Coord, LiveCellMap) ->
  case maps:find(Coord, LiveCellMap) of
    {ok, _} -> true;
    error -> false
  end.

iterate(#cycle{bounds=#bounds{x=XBounds, y=YBounds} = Bounds,live_cells=LiveCells,age=Age}) ->
  GridCoords = [#coord{x=X, y=Y} || X <- lists:seq(1, XBounds), Y <- lists:seq(1, YBounds)],
  F = fun(Coord, {{dead, NewDeadCells}, {live, NewLiveCells}}) ->
    ActiveNeighbourCount = count_active_neighbours(Bounds, Coord, LiveCells),
    case is_alive(Coord, LiveCells) of
      true -> case ActiveNeighbourCount of
                0 -> {{dead, [Coord | NewDeadCells]}, {live, NewLiveCells}};
                1 -> {{dead, [Coord | NewDeadCells]}, {live, NewLiveCells}};
                2 -> {{dead, NewDeadCells}, {live, [Coord | NewLiveCells]}};
                3 -> {{dead, NewDeadCells}, {live, [Coord | NewLiveCells]}};
                _ -> {{dead, [Coord | NewDeadCells]}, {live, NewLiveCells}}
              end;
      false -> case ActiveNeighbourCount of
                 3 -> {{dead, NewDeadCells}, {live, [Coord | NewLiveCells]}};
                 _ -> {{dead, [Coord | NewDeadCells]}, {live, NewLiveCells}}
               end
     end end,
  {{dead, DCells}, {live, LCells}} = lists:foldl(F, {{dead, []}, {live, []}}, GridCoords),
  io:format("~p cells are dead this cycle~n", [length(DCells)]),
  io:format("~p cells are alive this cycle~n", [length(LCells)]),
  RemovedDead = remove_all(DCells, LiveCells),
  AddedLive = put_all(LCells, RemovedDead),
  #cycle{bounds=Bounds,live_cells=AddedLive,age=Age+1}.

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
  [?assertEqual([#coord{x=10,y=9},#coord{x=1,y=9},#coord{x=1,y=10},#coord{x=1,y=1},#coord{x=10,y=1},#coord{x=9,y=1},#coord{x=9,y=10},#coord{x=9,y=9}],
    get_neighbours(#bounds{x=10,y=10}, #coord{x=10,y=10})),
    ?assertEqual([#coord{x=5,y=4},#coord{x=6,y=4},#coord{x=6,y=5},#coord{x=6,y=6},#coord{x=5,y=6},#coord{x=4,y=6},#coord{x=4,y=5},#coord{x=4,y=4}],
      get_neighbours(#bounds{x=10,y=10}, #coord{x=5,y=5})),
    ?assertEqual([#coord{x=1,y=10},#coord{x=2,y=10},#coord{x=2,y=1},#coord{x=2,y=2},#coord{x=1,y=2},#coord{x=10,y=2},#coord{x=10,y=1},#coord{x=10,y=10}],
      get_neighbours(#bounds{x=10,y=10}, #coord{x=1,y=1}))].
count_active_neighbours_test() ->
  Bounds = #bounds{x=10, y=10},
  TestMap = #{#coord{x=5,y=4} =>1,
    #coord{x=5,y=5} => 1,
    #coord{x=4,y=4} => 1,
    #coord{x=3,y=3} => 1,
    #coord{x=2,y=1} => 1},
  [?assertEqual(2, count_active_neighbours(Bounds, #coord{x=5,y=5}, TestMap)),
    ?assertEqual(2, count_active_neighbours(Bounds, #coord{x=5,y=4}, TestMap)),
    ?assertEqual(3, count_active_neighbours(Bounds, #coord{x=4,y=4}, TestMap)),
    ?assertEqual(2, count_active_neighbours(Bounds, #coord{x=3,y=2}, TestMap)),
    ?assertEqual(0, count_active_neighbours(Bounds, #coord{x=6,y=1}, TestMap)),
    ?assertEqual(1, count_active_neighbours(Bounds, #coord{x=2,y=10}, TestMap))].
iterate_test() ->
  Bounds = #bounds{x=4, y=4},
  EmptyCells = #{},
  LiveCells = #{#coord{x=2, y=2} => 1},
  LiveCellsB1 = #{#coord{x=2, y=2} => 1, #coord{x=2, y=3} => 1, #coord{x=3, y=3} => 1},
  LiveCellsB2 = #{#coord{x=2, y=2} => 1, #coord{x=2, y=3} => 1, #coord{x=3, y=3} => 1, #coord{x=3, y=2} => 1},
  [?assertEqual(#cycle{bounds=Bounds,live_cells=EmptyCells,age=1},
    iterate(#cycle{bounds=Bounds, live_cells=LiveCells, age=0})),
    ?assertEqual(#cycle{bounds=Bounds,live_cells=LiveCellsB2,age=1},
      iterate(#cycle{bounds=Bounds, live_cells=LiveCellsB1, age=0}))].
-endif.