%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. May 2015 12:17
%%%-------------------------------------------------------------------
-author("mhurd").

-record(coord, {x, y}).
-record(bounds, {x, y}).
-record(cycle, {bounds=#bounds{}, live_cells, age=0}).