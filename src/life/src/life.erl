%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. May 2015 20:15
%%% Good starting values: life:turn_on_cells([{41,51},{40,53},{41,53},{43,52},{44,53},{45,53},{46,53}]).
%%% http://lserinol.blogspot.co.uk/2009/01/profiling-performance-of-erlang.html
%%%
%%% eprof:start().
%%% eprof:start_profiling([pid(0,34,0)]).
%%% eprof:stop_profiling().
%%% eprof:analyse().
%%%
%%% ****** Process <0.60.0>    -- 100.00 % of profiled time ***
%%% FUNCTION                                      CALLS      %     TIME [uS / CALLS]
%%% --------                                      -----    ---     ---- [----------]
%%% io:o_request/3                                   1   0.00        2  [      2.00]
%%% io:format/3                                      1   0.00        2  [      2.00]
%%% gen_server:handle_msg/5                          1   0.00        2  [      2.00]
%%% net_kernel:dflag_unicode_io/1                    1   0.00        2  [      2.00]
%%% erlang:group_leader/0                            1   0.00        2  [      2.00]
%%% io:execute_request/2                             1   0.00        3  [      3.00]
%%% io:bc_req/3                                      1   0.00        3  [      3.00]
%%% gen_server:loop/6                                1   0.00        3  [      3.00]
%%% io:default_output/0                              1   0.00        4  [      4.00]
%%% io:io_request/2                                  1   0.00        4  [      4.00]
%%% io:format/2                                      1   0.00        5  [      5.00]
%%% io:request/2                                     1   0.00        5  [      5.00]
%%% life:handle_call/3                               1   0.00        6  [      6.00]
%%% gen_server:decode_msg/8                          1   0.00        6  [      6.00]
%%% gen_server:reply/2                               1   0.00        7  [      7.00]
%%% io:wait_io_mon_reply/2                           1   0.00        8  [      8.00]
%%% erlang:demonitor/2                               1   0.00       12  [     12.00]
%%% erlang:monitor/2                                 1   0.00       27  [     27.00]
%%% sets:fold/3                                    100   0.00      190  [      1.90]
%%% sets:fold_set/3                                100   0.00      222  [      2.22]
%%% life:step_forward/2                            101   0.00      241  [      2.39]
%%% sets:new/0                                     100   0.01      403  [      4.03]
%%% sets:mk_seg/1                                  100   0.01      406  [      4.06]
%%% sets:to_list/1                                 100   0.01      413  [      4.13]
%%% maps:keys/1                                    201   0.01      471  [      2.34]
%%% sets:expand_segs/2                             176   0.01      651  [      3.70]
%%% sets:fold_segs/4                               507   0.02      963  [      1.90]
%%% sets:get_bucket_s/2                           3064   0.19    11323  [      3.70]
%%% sets:maybe_expand_segs/1                      3064   0.19    11471  [      3.74]
%%% life:put_all/2                                6618   0.20    12380  [      1.87]
%%% sets:fold_seg/4                               6919   0.22    13568  [      1.96]
%%% maps:put/3                                    6518   0.29    17782  [      2.73]
%%% sets:put_bucket_s/3                           6128   0.40    24025  [      3.92]
%%% life:'-step_forward/2-fun-0-'/3               6449   0.40    24364  [      3.78]
%%% life:remove_all/2                            16301   0.51    30958  [      1.90]
%%% maps:remove/2                                16201   0.66    40108  [      2.48]
%%% sets:fold_bucket/3                           29231   1.08    65531  [      2.24]
%%% sets:'-to_list/1-fun-0-'/2                   22719   1.38    83326  [      3.67]
%%% life:'-step_forward/2-fun-1-'/4              22719   1.40    84652  [      3.73]
%%% life:is_alive/2                              22719   1.42    86033  [      3.79]
%%% life:count_active_neighbours/3               22719   1.42    86294  [      3.80]
%%% sets:rehash/4                                24944   1.51    91528  [      3.67]
%%% life:get_neighbours/2                        29168   1.83   111118  [      3.81]
%%% sets:maybe_expand/2                          58041   1.87   113255  [      1.95]
%%% life:add_all_to_set/2                        64590   2.01   121583  [      1.88]
%%% erlang:phash/2                               79921   2.65   160365  [      2.01]
%%% sets:add_element/2                           58041   3.54   214643  [      3.70]
%%% sets:'-add_element/2-fun-0-'/2               58041   3.55   214922  [      3.70]
%%% sets:get_slot/2                              58041   3.61   218427  [      3.76]
%%% sets:on_bucket/3                             58041   3.64   220748  [      3.80]
%%% sets:add_bkt_el/3                           178417   5.50   333051  [      1.87]
%%% lists:foldl/3                               233839   7.89   477803  [      2.04]
%%% maps:find/2                                 204471   8.36   506634  [      2.48]
%%% life:'-count_active_neighbours/3-fun-0-'/3  181752  11.05   669153  [      3.68]
%%% erlang:setelement/3                         358204  11.46   693951  [      1.94]
%%% life:roll_around/2                          350016  21.70  1314710  [      3.76]
%%% -------------------------------------------------------------------
-module(life).
-author("mhurd").

-include("life.hrl").
-include_lib("eunit/include/eunit.hrl").

-behaviour(gen_server).

-define(SERVER, ?MODULE).

%% gen_server callback API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% API
-export([start_link/2, start_link/1, start_link/0, turn_on_cells/1, step/0, step/1, reset_to_bounds/1, get_state/0]).

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

get_state() ->
  gen_server:call(?SERVER, get_state).

reset_to_bounds(Bounds) ->
  gen_server:call(?SERVER, {reset_to_bounds, Bounds}).

%% gen_server callback implementations

init([Bounds, LiveCells]) ->
  io:format("life PID: ~p~n", [self()]),
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
handle_call(get_state, _From, State) ->
  Reply = State,
  {reply, Reply, State};
handle_call({reset_to_bounds, Bounds}, _From, _State) ->
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

add_all_to_set([], S) -> S;
add_all_to_set([H|T], S) -> add_all_to_set(T, sets:add_element(H, S)).

step_forward(#state{bounds=#bounds{x=XBounds, y=YBounds}, live_cells=LiveCells} = State, 0) ->
  io:format("~p/~p cells are alive~n", [length(maps:keys(LiveCells)), XBounds*YBounds]),
  State;
step_forward(#state{bounds=Bounds,live_cells=LiveCells,age=Age}, N) ->
  NeighboursSet = lists:foldl(
    fun(LC, Acc) -> add_all_to_set(get_neighbours(Bounds, LC), Acc) end, sets:new(), maps:keys(LiveCells)),
  TotalCellsSet = add_all_to_set(maps:keys(LiveCells), NeighboursSet),
  GridCoords = sets:to_list(TotalCellsSet),
  %io:format("Age: ~p~n", [Age]),
  %io:format("Live Cells: ~p~n", [LiveCells]),
  %io:format("Neighbours: ~p~n", [GridCoords]),
  F = fun(Coord, {{dead, NewDeadCells}, {live, NewLiveCells}}) ->
    ActiveNeighbourCount = count_active_neighbours(Bounds, Coord, LiveCells),
    %io:format("~p has ~p active neighbours~n", [Coord, ActiveNeighbourCount]),
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