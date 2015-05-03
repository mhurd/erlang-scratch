%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Mar 2015 20:44
%%%-------------------------------------------------------------------
-module(try_test).
-author("mhurd").

%% API
-export([generate_exception/1, demo1/0, demo2/0, demo3/0]).

generate_exception(1) -> a;
generate_exception(2) -> throw(a);
generate_exception(3) -> exit(a);
generate_exception(4) -> {'EXIT', a};
generate_exception(5) -> error(a).

demo1() -> [catcher(I) || I <- [1,2,3,4,5]].

catcher(N) ->
  try generate_exception(N) of
    Val -> {N, normal, Val}
  catch
    throw:X -> {N, caught, thrown, X};
    exit:X -> {N, caught, exited, X};
    error:X -> {N, caught, errored, X}
  end.

demo2() -> [{I, (catch generate_exception(I))} || I <- [1,2,3,4,5]].

demo3() ->
  try generate_exception(5)
  catch
    error:X ->
      {X, erlang:get_stacktrace()}
  end.
