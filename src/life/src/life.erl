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
%%% application:start(life).
%%% life:turn_on_cells([{41,51},{40,53},{41,53},{43,52},{44,53},{45,53},{46,53}]).
%%% eprof:start().
%%% eprof:start_profiling([pid(0,34,0)]).
%%% life:step(100).
%%% eprof:stop_profiling().
%%% eprof:analyze().
%%%
%%% Smaller grid:
%%% life:reset_to_bounds({10,10}).
%%% life:turn_on_cells([{3,4},{2,6},{3,6},{5,5},{6,6},{7,6},{8,6}]).
%%%
%%%
%%% ****** Process <0.60.0>    -- 100.00 % of profiled time ***
%%% FUNCTION                                      CALLS      %     TIME  [uS / CALLS]
%%% --------                                      -----    ---     ----  [----------]
%%% io:format/3                                       1   0.00        2  [      2.00]
%%% erlang:group_leader/0                             1   0.00        2  [      2.00]
%%% io:o_request/3                                    1   0.00        3  [      3.00]
%%% io:execute_request/2                              1   0.00        3  [      3.00]
%%% io:bc_req/3                                       1   0.00        3  [      3.00]
%%% io:io_request/2                                   1   0.00        3  [      3.00]
%%% gen_server:loop/6                                 1   0.00        3  [      3.00]
%%% gen_server:handle_msg/5                           1   0.00        3  [      3.00]
%%% net_kernel:dflag_unicode_io/1                     1   0.00        3  [      3.00]                                                                                       [28/350]
%%% io:format/2                                       1   0.00        4  [      4.00]
%%% io:request/2                                      1   0.00        5  [      5.00]
%%% io:default_output/0                               1   0.00        5  [      5.00]
%%% gen_server:decode_msg/8                           1   0.00        5  [      5.00]
%%% life:handle_call/3                                1   0.00        6  [      6.00]
%%% erlang:demonitor/2                                1   0.00        6  [      6.00]
%%% gen_server:reply/2                                1   0.00        7  [      7.00]
%%% io:wait_io_mon_reply/2                            1   0.00       10  [     10.00]
%%% erlang:monitor/2                                  1   0.00       55  [     55.00]
%%% sets:fold/3                                     100   0.00      206  [      2.06]
%%% life:step_forward/2                             101   0.00      240  [      2.38]
%%% sets:fold_set/3                                 100   0.00      262  [      2.62]
%%% sets:mk_seg/1                                   100   0.01      416  [      4.16]
%%% sets:to_list/1                                  100   0.01      434  [      4.34]
%%% life:evaluate_cells/3                           100   0.01      439  [      4.39]
%%% life:evaluate_cell_fun/2                        100   0.01      440  [      4.40]
%%% sets:new/0                                      100   0.01      462  [      4.62]
%%% maps:keys/1                                     201   0.01      577  [      2.87]
%%% life:get_live_cell_neighbours/2                 100   0.01      610  [      6.10]
%%% sets:expand_segs/2                              176   0.01      735  [      4.18]
%%% sets:fold_segs/4                                507   0.01     1071  [      2.11]
%%% life:death/2                                   2556   0.07     5531  [      2.16]
%%% life:remove_all/2                              2656   0.07     5648  [      2.13]
%%% maps:remove/2                                  2556   0.09     7125  [      2.79]
%%% sets:get_bucket_s/2                            3064   0.16    12660  [      4.13]
%%% sets:maybe_expand_segs/1                       3064   0.16    12969  [      4.23]
%%% life:put_all/2                                 6618   0.18    14212  [      2.15]
%%% life:life/2                                    6518   0.18    14286  [      2.19]
%%% sets:fold_seg/4                                6919   0.20    15878  [      2.29]
%%% maps:put/3                                     6518   0.26    20602  [      3.16]
%%% life:'-get_live_cell_neighbours/2-fun-0-'/3    6449   0.33    26291  [      4.08]
%%% sets:put_bucket_s/3                            6128   0.33    26390  [      4.31]
%%% life:conway_rule/4                            22719   0.62    48515  [      2.14]
%%% sets:fold_bucket/3                            29231   0.91    71680  [      2.45]
%%% sets:'-to_list/1-fun-0-'/2                    22719   1.14    89807  [      3.95]
%%% life:is_alive/2                               22719   1.18    93264  [      4.11]
%%% life:'-evaluate_cell_fun/2-fun-0-'/4          22719   1.19    93576  [      4.12]
%%% life:count_active_neighbours/3                22719   1.21    95069  [      4.18]
%%% sets:rehash/4                                 24944   1.28   101021  [      4.05]
%%% life:get_coord_neighbours/2                   29168   1.53   120270  [      4.12]
%%% sets:maybe_expand/2                           58041   1.58   124436  [      2.14]
%%% life:add_all_to_set/2                         64590   1.65   130212  [      2.02]
%%% erlang:phash/2                                79921   2.37   186584  [      2.33]
%%% sets:add_element/2                            58041   2.98   235030  [      4.05]
%%% sets:'-add_element/2-fun-0-'/2                58041   3.00   236120  [      4.07]
%%% sets:get_slot/2                               58041   3.05   240706  [      4.15]
%%% sets:on_bucket/3                              58041   3.09   243362  [      4.19]
%%% sets:add_bkt_el/3                            178417   4.63   365043  [      2.05]
%%% lists:foldl/3                                233839   6.76   533046  [      2.28]
%%% erlang:setelement/3                          250606   6.90   543958  [      2.17]
%%% maps:find/2                                  204471   7.36   579885  [      2.84]
%%% life:'-count_active_neighbours/3-fun-0-'/3   181752   9.32   734526  [      4.04]
%%% life:add_coords/3                            233344  12.11   954950  [      4.09]
%%% life:roll_around/2                           466688  24.03  1894359  [      4.06]
%%% -------------------------------------------------------------------
-module(life).
-author("mhurd").

-include("life.hrl").
-include_lib("eunit/include/eunit.hrl").

-behaviour(gen_server).

-define(SERVER, ?MODULE).
% assuming 0,0 is top left of the coordinate system
-define(NORTH, #coord{x=0,y=-1}).
-define(NORTH_EAST, #coord{x=1,y=-1}).
-define(EAST, #coord{x=1,y=0}).
-define(SOUTH_EAST, #coord{x=1,y=1}).
-define(SOUTH, #coord{x=0,y=1}).
-define(SOUTH_WEST, #coord{x=-1,y=1}).
-define(WEST, #coord{x=-1,y=0}).
-define(NORTH_WEST, #coord{x=-1,y=-1}).

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

% assumes that we never get more than +/-1 from [1..Bound]
roll_around(Bound, 0) -> Bound;
roll_around(Bound, Bound) -> Bound;
roll_around(Bound, Val) -> Val rem Bound.

add_coords(#bounds{x=XB,y=YB}, #coord{x=X1, y=Y1}, #coord{x=X2, y=Y2}) ->
  #coord{x=roll_around(XB, X1+X2), y=roll_around(YB, Y1+Y2)}.

get_coord_neighbours(Bounds, Coord) ->
  [
    add_coords(Bounds, Coord, ?NORTH),
    add_coords(Bounds, Coord, ?NORTH_EAST),
    add_coords(Bounds, Coord, ?EAST),
    add_coords(Bounds, Coord, ?SOUTH_EAST),
    add_coords(Bounds, Coord, ?SOUTH),
    add_coords(Bounds, Coord, ?SOUTH_WEST),
    add_coords(Bounds, Coord, ?WEST),
    add_coords(Bounds, Coord, ?NORTH_WEST)
  ].

count_active_neighbours(Bounds, Coord, LiveCellMap) ->
  F = fun(C, Acc) -> case maps:find(C, LiveCellMap) of
                       {ok, Value} -> [Value | Acc];
                       error -> Acc
                     end end,
  length(lists:foldl(F, [], get_coord_neighbours(Bounds, Coord))).

is_alive(Coord, LiveCellMap) ->
  case maps:find(Coord, LiveCellMap) of
    {ok, _} -> true;
    error -> false
  end.

add_all_to_set([], S) -> S;
add_all_to_set([H|T], S) -> add_all_to_set(T, sets:add_element(H, S)).

death(Coord, #changed_cells{dead_cells=DeadCellList} = ChangedCells) ->
  ChangedCells#changed_cells{dead_cells = [Coord | DeadCellList]}.
life(Coord, #changed_cells{live_cells = LiveCellList} = ChangedCells) ->
  ChangedCells#changed_cells{live_cells = [Coord | LiveCellList]}.

conway_rule(alive, Coord, ChangedCells, _LiveNeighbours = 0) ->
  death(Coord, ChangedCells); % no neighbours - die!
conway_rule(alive, Coord, ChangedCells, _LiveNeighbours = 1) ->
  death(Coord, ChangedCells); % lonely - die!
conway_rule(alive, Coord, ChangedCells, _LiveNeighbours = 2) ->
  life(Coord, ChangedCells); % ok - stay alive
conway_rule(alive, Coord, ChangedCells, _LiveNeighbours = 3) ->
  life(Coord, ChangedCells); % ok - stay alive
conway_rule(alive, Coord, ChangedCells, _) ->
  death(Coord, ChangedCells); % over-crowded - die!
conway_rule(dead, Coord, ChangedCells, _LiveNeighbours = 3) ->
  life(Coord, ChangedCells); % birth!
conway_rule(dead, _Coord, ChangedCells, _) ->
  ChangedCells. % stay dead

evaluate_cell_fun(Bounds, LiveCells) -> fun(Coord, ChangedCells) ->
  ActiveNeighbourCount = count_active_neighbours(Bounds, Coord, LiveCells),
  %io:format("~p has ~p active neighbours~n", [Coord, ActiveNeighbourCount]),
  case is_alive(Coord, LiveCells) of
    true -> conway_rule(alive, Coord, ChangedCells, ActiveNeighbourCount);
    false -> conway_rule(dead, Coord, ChangedCells, ActiveNeighbourCount)
  end end.

evaluate_cells(Bounds, CurrentLiveCells, CoordsToEvaluate) ->
  lists:foldl(evaluate_cell_fun(Bounds, CurrentLiveCells), #changed_cells{}, CoordsToEvaluate).

get_live_cell_neighbours(Bounds, CurrentLiveCells) ->
  lists:foldl(fun(LC, Acc) -> add_all_to_set(get_coord_neighbours(Bounds, LC), Acc) end, sets:new(), maps:keys(CurrentLiveCells)).

step_forward(#state{bounds=#bounds{x=XBounds, y=YBounds}, live_cells=LiveCells} = State, 0) ->
  io:format("~p/~p cells are alive~n", [length(maps:keys(LiveCells)), XBounds*YBounds]),
  State;
step_forward(#state{bounds=Bounds,live_cells=CurrentLiveCells,age=Age}, N) ->
  NeighbouringCells = get_live_cell_neighbours(Bounds, CurrentLiveCells),
  LiveAndNeighbouringCells = add_all_to_set(maps:keys(CurrentLiveCells), NeighbouringCells),
  CellsToEvaluate = sets:to_list(LiveAndNeighbouringCells),
  %io:format("Age: ~p~n", [Age]),
  %io:format("Live Cells: ~p~n", [LiveCells]),
  %io:format("Neighbours: ~p~n", [GridCoords]),
  #changed_cells{dead_cells = DeadCellList, live_cells = LiveCellList} =
    evaluate_cells(Bounds, CurrentLiveCells, CellsToEvaluate),
  RemovedDead = remove_all(DeadCellList, CurrentLiveCells),
  AddedLive = put_all(LiveCellList, RemovedDead),
  step_forward(#state{bounds=Bounds,live_cells=AddedLive,age=Age+1}, N-1).

%%%-------------------------------------------------------------------
%%%  ******* **** ***** ******* *****
%%%     *    *    *        *    *
%%%     *    ***  *****    *    *****
%%%     *    *        *    *        *
%%%     *    **** *****    *    *****
%%%-------------------------------------------------------------------

-ifdef(EUNIT).
roll_around_test() ->
  [?assertEqual(1, roll_around(10, 11)),
    ?assertEqual(5, roll_around(10, 5)),
    ?assertEqual(10, roll_around(10, 0)),
    ?assertEqual(10, roll_around(10, 10)),
    ?assertEqual(1, roll_around(10, 1)),
    ?assertEqual(9, roll_around(10, 9))].
get_neighbours_test() ->
  [?assertEqual([#coord{x=10,y=9},#coord{x=1,y=9},#coord{x=1,y=10},#coord{x=1,y=1},#coord{x=10,y=1},#coord{x=9,y=1},#coord{x=9,y=10},#coord{x=9,y=9}],
    get_coord_neighbours(#bounds{x=10,y=10}, #coord{x=10,y=10})),
    ?assertEqual([#coord{x=5,y=4},#coord{x=6,y=4},#coord{x=6,y=5},#coord{x=6,y=6},#coord{x=5,y=6},#coord{x=4,y=6},#coord{x=4,y=5},#coord{x=4,y=4}],
      get_coord_neighbours(#bounds{x=10,y=10}, #coord{x=5,y=5})),
    ?assertEqual([#coord{x=1,y=10},#coord{x=2,y=10},#coord{x=2,y=1},#coord{x=2,y=2},#coord{x=1,y=2},#coord{x=10,y=2},#coord{x=10,y=1},#coord{x=10,y=10}],
      get_coord_neighbours(#bounds{x=10,y=10}, #coord{x=1,y=1}))].
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