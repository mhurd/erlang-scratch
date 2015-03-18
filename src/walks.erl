%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Mar 2015 12:20
%%%-------------------------------------------------------------------
-module(walks).
-author("mhurd").

-export([plan_route/2]).

-spec plan_route(From::point(), To::point()) -> route().

-type direction() :: north | south | east | west.
-type point()     :: {integer(), integer()}.
-type route()     :: [{go,direction(),integer()}].
%% there is no code here
%% this is deliberate
plan_route({X1,Y1} = From, {X2, Y2} = To) ->
  [route, From, To].

-type angle()       :: {Degrees::0..360, Minutes::0..60, Seconds::0..60}.
-type position()    :: {latitude | longitude, angle()}.
-spec plan_route1(From::position(), To::position()) -> [].

plan_route1(From,To) ->
  a.

