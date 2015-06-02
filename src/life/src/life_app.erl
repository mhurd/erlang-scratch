%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jun 2015 12:17
%%% Usage:
%%%
%%%    application:start(life).
%%%    life:turn_on_cells([{41,51},{40,53},{41,53},{43,52},{44,53},{45,53},{46,53}]).
%%%    life:step().
%%%
%%%-------------------------------------------------------------------
-module(life_app).
-author("mhurd").

-behaviour(application).

%% API
-export([start/2, stop/1]).

start(_Type, _StartArgs) ->
  case life_sup:start_link() of
    {ok, Pid} -> {ok, Pid};
    Other -> {error, Other}
  end.

stop(_State) -> ok.
