%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. May 2015 20:15
%%% Good starting values: life:turn_on_cells([{41,51},{40,53},{41,53},{43,52},{44,53},{45,53},{46,53}]).
%%% http://lserinol.blogspot.co.uk/2009/01/profiling-performance-of-erlang.html
%%% ****** Process <0.60.0>    -- 100.00 % of profiled time ***
%%% FUNCTION                                      CALLS      %     TIME  [uS / CALLS]
%%% --------                                      -----    ---     ----  [----------]
%%% io:o_request/3                                    1   0.00        2  [      2.00]
%%% io:format/3                                       1   0.00        2  [      2.00]
%%% net_kernel:dflag_unicode_io/1                     1   0.00        2  [      2.00]
%%% erlang:group_leader/0                             1   0.00        2  [      2.00]
%%% io:format/2                                       1   0.00        3  [      3.00]
%%% io:execute_request/2                              1   0.00        3  [      3.00]
%%% io:bc_req/3                                       1   0.00        3  [      3.00]
%%% io:io_request/2                                   1   0.00        4  [      4.00]
%%% maps:keys/1                                       1   0.00        4  [      4.00]
%%% erlang:demonitor/2                                1   0.00        4  [      4.00]
%%% io:request/2                                      1   0.00        5  [      5.00]
%%% io:default_output/0                               1   0.00        5  [      5.00]
%%% life:handle_call/3                                1   0.00        5  [      5.00]
%%% gen_server:loop/6                                 1   0.00        5  [      5.00]
%%% gen_server:decode_msg/8                           1   0.00        5  [      5.00]
%%% io:wait_io_mon_reply/2                            1   0.00        6  [      6.00]
%%% erlang:monitor/2                                  1   0.00       10  [     10.00]
%%% gen_server:handle_msg/5                           1   0.00       15  [     15.00]
%%% life:step_forward/2                              11   0.00       36  [      3.27]
%%% gen_server:reply/2                                1   0.00      224  [    224.00]
%%% life:'-step_forward/2-lc$^0/1-0-'/2            1010   0.01     1972  [      1.95]
%%% life:put_all/2                                 1740   0.02     3294  [      1.89]
%%% lists:seq/2                                    1010   0.02     3795  [      3.76]
%%% maps:put/3                                     1730   0.04     5773  [      3.34]
%%% lists:seq_loop/3                              26260   0.34    53463  [      2.04]
%%% life:remove_all/2                             98280   1.16   180808  [      1.84]
%%% maps:remove/2                                 98270   2.02   315207  [      3.21]
%%% life:'-step_forward/2-lc$^1/1-1-'/4          101000   2.34   366125  [      3.63]
%%% life:is_alive/2                              100000   2.37   369676  [      3.70]
%%% life:'-step_forward/2-fun-0-'/4              100000   2.37   370179  [      3.70]
%%% life:count_active_neighbours/3               100000   2.40   374748  [      3.75]
%%% life:get_neighbours/2                        100000   2.43   379153  [      3.79]
%%% erlang:setelement/3                          400000   5.05   789262  [      1.97]
%%% lists:foldl/3                               1000010  13.09  2044002  [      2.04]
%%% life:'-count_active_neighbours/3-fun-0-'/3   800000  18.85  2943218  [      3.68]
%%% maps:find/2                                  900000  19.02  2969055  [      3.30]
%%% life:roll_around/2                          1206000  28.46  4443674  [      3.68]
%%%-------------------------------------------------------------------
-module(life).
-author("mhurd").

-include("life.hrl").
-include_lib("eunit/include/eunit.hrl").

-behaviour(gen_server).

-define(SERVER, ?MODULE).

%% gen_server callback API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% API
-export([start_link/2, start_link/1, start_link/0, turn_on_cells/1, step/0, step/1, reset/1]).

%% API implementation methods

start_link(Bounds, LiveCells) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [Bounds, LiveCells], []).

start_link(Bounds) ->
  start_link(Bounds, []).

start_link() ->
  start_link(#bounds{x=100,y=100}, []).

turn_on_cells(LiveCells) ->
  gen_server:call(?SERVER, {turn_on_cells, LiveCells}).

step() ->
  gen_server:call(?SERVER, step).
step(N) ->
  gen_server:call(?SERVER, {step, N}, infinity).

reset(Bounds) ->
  gen_server:call(?SERVER, {reset, Bounds}).

%% gen_server callback implementations

init([Bounds, LiveCells]) ->
  {ok, init_state(Bounds, LiveCells)}.

handle_call({turn_on_cells, NewLiveCells}, _From, #state{live_cells=LiveCellMap} = State) ->
  Reply = ok,
  {reply, Reply, State#state{live_cells=put_all(tuples_to_coords(NewLiveCells), LiveCellMap)}};
handle_call(step, _From, State) ->
  Reply = ok,
  {reply, Reply, step_forward(State, 1)};
handle_call({step, N}, _From, State) ->
  Reply = ok,
  {reply, Reply, step_forward(State, N)};
handle_call({reset, Bounds}, _From, _State) ->
  Reply = ok,
  {reply, Reply, init_state(Bounds, [])}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%% implementations

init_state(Bounds, InitialLiveCells) ->
  LiveCells = put_all(InitialLiveCells, maps:new()),
  #state{bounds=Bounds,live_cells=LiveCells}.

put_all([], M) -> M;
put_all([H|T], M) ->
  put_all(T, maps:put(H, 1, M)).

remove_all([], M) -> M;
remove_all([H|T], M) ->
  remove_all(T, maps:remove(H, M)).

tuples_to_coords(L) ->
  lists:map(fun({X, Y}) -> #coord{x=X,y=Y} end, L).

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

step_forward(#state{bounds=#bounds{x=XBounds, y=YBounds}, live_cells=LiveCells} = State, 0) ->
  io:format("~p/~p cells are alive~n", [length(maps:keys(LiveCells)), XBounds*YBounds]),
  State;
step_forward(#state{bounds=#bounds{x=XBounds, y=YBounds} = Bounds,live_cells=LiveCells,age=Age}, N) ->
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
  RemovedDead = remove_all(DCells, LiveCells),
  AddedLive = put_all(LCells, RemovedDead),
  step_forward(#state{bounds=Bounds,live_cells=AddedLive,age=Age+1}, N-1).

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
  [?assertEqual(#state{bounds=Bounds,live_cells=EmptyCells,age=1},
    step_forward(#state{bounds=Bounds, live_cells=LiveCells, age=0}, 1)),
    ?assertEqual(#state{bounds=Bounds,live_cells=LiveCellsB2,age=1},
      step_forward(#state{bounds=Bounds, live_cells=LiveCellsB1, age=0}, 1))].
-endif.