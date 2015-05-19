%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. May 2015 08:11
%%%-------------------------------------------------------------------
-module(find_pairs).
-author("mhurd").

%% API
-export([gen_problem/2, n_squared_solve/1]).

init_random() ->
  {A1,A2,A3} = now(),
  random:seed(A1, A2, A3).

gen_problem(N, Max) ->
  init_random(),
  {random:uniform(Max), gen_list(N, Max), gen_list(N, Max)}.

gen_list(N, Max) -> gen_list(N, Max, []).
gen_list(0, _Max, Acc) -> Acc;
gen_list(N, Max, Acc) -> gen_list(N-1, Max, [random:uniform(Max) | Acc]).

get_pair(Target, I1, I2) ->
  case I1 + I2 of
    Target -> {I1, I2};
    _ -> {}
  end.

print_solution({Target, L1, L2}, Solutions, Acc) ->
  io:format("List 1 ~p~n", [L1]),
  io:format("List 2 ~p~n", [L2]),
  io:format("Iterations for ~p items = ~p~n", [length(L1), Acc]),
  io:format("Target total was ~p~n", [Target]),
  io:format("Solutions = "),
  Solutions.

n_squared_solve({Target, L1, L2} = Problem) ->
  {_, {Solutions, Acc}} = lists:mapfoldl(
    fun(I1, L1Acc) ->
      lists:mapfoldl(
        fun(I2, {L2Results, L2Acc}) -> {null, {maps:put(get_pair(Target, I1, I2), get_pair(Target, I1, I2), L2Results), L2Acc + 1}} end, L1Acc, L2)
      end, {maps:new(), 0}, L1),
  print_solution(Problem, maps:keys(maps:remove({}, Solutions)), Acc).