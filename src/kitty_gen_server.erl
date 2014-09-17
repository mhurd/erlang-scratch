%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Sep 2014 13:15
%%%-------------------------------------------------------------------
-module(kitty_gen_server).
-author("mhurd").
-behaviour(gen_server).

-compile(export_all).

-record(cat, {name, color=green, description}).

%% API
-export([]).

start_link() ->
  io:format("Normal exit...~n"),
  spawn(?MODULE, restarter, []).

restarter() ->
  process_flag(trap_exit, true),
  {ok, Pid} =  gen_server:start_link({local, shop}, ?MODULE, [], []),
  io:format("Registered ~p to 'shop'...~n", [Pid]),
  receive
    {'EXIT', Pid, normal} -> % not a crash
      io:format("Normal exit...~n"),
      ok;
    {'EXIT', Pid, shutdown} -> % manual termination, not a crash
      io:format("Shutdown exit...~n"),
      ok;
    {'EXIT', Pid, _} ->
      io:format("Restarting shop...~n"),
      restarter()
  end.

order_cat(Name, Color, Description) ->
  gen_server:call(whereis(shop), {order, Name, Color, Description}).

%% This call is asynchronous
return_cat(Cat = #cat{}) ->
  gen_server:cast(whereis(shop), {return, Cat}).

%% This call is synchronous
close_shop() ->
  gen_server:call(whereis(shop), terminate).

%% Server functions
init([]) -> {ok, []}. %% no treatment of info here!

handle_call({order, Name, Color, Description}, _From, Cats) ->
  if Cats =:= [] ->
      {reply, make_cat(Name, Color, Description), Cats};
    Cats =/= [] ->
       {reply, hd(Cats), tl(Cats)}
  end;
handle_call(terminate, _From, Cats) ->
  {stop, normal, ok, Cats}.

handle_cast({return, Cat = #cat{}}, Cats) ->
  {noreply, [Cat| Cats]}.

handle_info(Msg, Cats) ->
  io:format("Unexpected mesage: ~p~n", [Msg]),
  {noreply, Cats}.

terminate(normal, Cats) ->
  [io:format("~p was set free.~n", [C#cat.name]) || C <- Cats],
  ok.

code_change(_OldVsn, State, _Extra) ->
  %% No change planned. The function is here for the behaviour
  %% but will not be used.
  {ok, State}.

%% Private functions
make_cat(Name, Col, Desc) ->
  #cat{name=Name, color=Col, description=Desc}.