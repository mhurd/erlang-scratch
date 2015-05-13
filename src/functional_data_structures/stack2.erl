%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. May 2015 20:04
%%%-------------------------------------------------------------------
-module(stack2).
-author("mhurd").

%% API
-export([empty/0, is_empty/1, cons/2, head/1, tail/1, map/2]).

-spec empty() -> empty().
-spec is_empty(stack()) -> boolean().
-spec cons(term(), stack()) -> stack().
-spec head(stack()) -> term() | error_empty.
-spec tail(stack()) -> stack() | empty().
-spec map(fun((_) -> any()), stack()) -> stack().

-type empty() :: {}.
-type element() :: {term(), element() | empty()}.
-type stack() :: element() | empty().

empty() -> {}.

is_empty({}) -> true;
is_empty(_) -> false.

cons(E, S) -> {E, S}.

head({}) -> empty_error;
head({H,_}) -> H.

tail({}) -> {};
tail({_, T}) -> T.

map(_, {}) -> {};
map(F, {H, T}) -> cons(F(H), map(F, T)).






