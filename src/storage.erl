%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Sep 2014 14:08
%%%-------------------------------------------------------------------
-module(storage).
-author("mhurd").

-compile([debug_info]).

%% API
-export([start/1, store/2, take/2, list/1, storage/1]).

store(Pid, Item) ->
  Pid ! {self(), {store, Item}},
  receive
    {Pid, Msg} -> Msg
  after 3000 ->
    timeout
  end.

list(Pid) ->
  Pid ! {self(), list},
  receive
    {Pid, Msg} -> Msg
  after 3000 ->
    timeout
  end.

take(Pid, Item) ->
  Pid ! {self(), {take, Item}},
  receive
    {Pid, Msg} -> Msg
  after 3000 ->
    timeout
  end.

start(Items) ->
  spawn(?MODULE, storage, [Items]).

storage(Items) ->
  receive
    {From, {store, Item}} ->
      From ! {self(), ok},
      storage([Item|Items]);
    {From, {take, Item}} ->
      case lists:member(Item, Items) of
        true ->
          From ! {self(), {ok, Item}},
          storage(lists:delete(Item, Items));
        false ->
          From ! {self(), not_found},
          storage(Items)
      end;
    {From, list} ->
      From ! {self(), Items},
      storage(Items);
    terminate ->
      ok
  end.