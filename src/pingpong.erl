-module(pingpong).
-export([run/0]).

run() -> 
    Pid = spawn(fun ping/0),
    Pid ! self(),
    receive
        {From, pong} -> io:format("Received pong from ~p~n", [From]), ok
    end.

ping() ->
    receive
        From -> io:format("Received ping from ~p~n", [From]), From ! {self(), pong}
    end.
