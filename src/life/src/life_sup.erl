%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jun 2015 12:19
%%%-------------------------------------------------------------------
-module(life_sup).
-author("mhurd").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  % Server = {ID, {Module, Function, Args}, permanent|temporary|transient, Shutdown, Type, Dependencies}
  Server = {life, {life, start_link, []}, permanent, 2000, worker, [life]},
  Children = [Server],
  % replace only the failing process (one_for_one)
  RestartStrategy = {one_for_one, 0, 1}, % 0 restarts in 1 second - effectively turning off restarts
  {ok, {RestartStrategy, Children}}.

