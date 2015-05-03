%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Mar 2015 20:39
%%%-------------------------------------------------------------------
-module(geometry).
-author("mhurd").

%% API
-export([area/1]).

area({rectangle, Width, Height}) -> Width * Height;

area({square, Side}) -> Side * Side;

area({circle, Radius}) -> 3.14159 * Radius * Radius.