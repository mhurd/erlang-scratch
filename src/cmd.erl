%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Jun 2015 19:18
%%%-------------------------------------------------------------------
-module(cmd).
-author("mhurd").

-define(DEFAULT_TIMEOUT, 5000).

%% API
-export([run/1, run/2]).

run(Cmd) ->
  run(Cmd, ?DEFAULT_TIMEOUT).

run(Cmd, Timeout) ->
  Port = erlang:open_port({spawn, Cmd}, [exit_status]),
  loop(Port, [], Timeout).

loop(Port, Data, Timeout) ->
  receive
    {Port, {data, NewData}} -> loop(Port, [NewData | Data], Timeout);
    {Port, {exit_status, 0}} -> lists:reverse(Data);
    {Port, {exit_status, S}} -> throw({commandfailed, S})
  after Timeout ->
    throw(timeout)
  end.
