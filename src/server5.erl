%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. May 2015 11:26
%%%-------------------------------------------------------------------
-module(server5).
-author("mhurd").
-export([start/0, rpc/2]).
start() -> spawn(fun() -> wait() end).
wait() ->
  receive
    {become, F} -> F()
  end.
rpc(Pid, Q) ->
  Pid ! {self(), Q},
  receive
    {Pid, Reply} -> Reply
  end.