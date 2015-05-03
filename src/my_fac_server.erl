%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. May 2015 14:54
%%%-------------------------------------------------------------------
-module(my_fac_server).
-author("mhurd").
-export([loop/0]).

loop() ->
  receive
    {From, {fac, N}} ->
      From ! {self(), fac(N)},
      loop();
    {become, Something} ->
      Something()
  end.

fac(0) -> 1;
fac(N) -> N * fac(N - 1).
