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
-export([gen_problem/2, n_squared_solve/1, n_squared_solve2/1]).

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
  {Solutions, Acc} = lists:foldl(
    fun(I1, L1Acc) ->
      lists:foldl(
        fun(I2, {L2Results, L2Acc}) -> {maps:put(get_pair(Target, I1, I2), get_pair(Target, I1, I2), L2Results), L2Acc + 1} end, L1Acc, L2)
    end, {maps:new(), 0}, L1),
  print_solution(Problem, maps:keys(maps:remove({}, Solutions)), Acc).

% uses list comprehensions for brevity - can't thread through an accumilator for counting the iterations though.
n_squared_solve2({Target, L1, L2} = Problem) ->
  print_solution(Problem, lists:usort([{I1, I2} || I1 <- L1, I2 <- L2, I1 + I2 == Target]), length(L1)*length(L2)).