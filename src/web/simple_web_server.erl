%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 14. May 2015 21:06
%%%-------------------------------------------------------------------
-module(simple_web_server).
-author("mhurd").

-compile(export_all).

start() ->
  start(8877).

start(Port) ->
  ok = application:start(crypto),
  ok = application:start(ranch),
  ok = application:start(cowlib),
  ok = application:start(cowboy),
  N_acceptors = 100,
  Dispatch = cowboy_router:compile(
    [
      %% {URIHost, list({URIPath, Handler, Opts})}
      {'_', [{'_', simple_web_server, []}]}
    ]),
  cowboy:start_http(simple_web_server,
    N_acceptors,
    [{port, Port}],
    [{env, [{dispatch, Dispatch}]}]
  ).

stop() ->
  ok = application:stop(cowboy),
  ok = application:stop(cowlib),
  ok = application:stop(ranch),
  ok = application:stop(crypto).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined}.

handle(Req, State) ->
  {Path, Req1} = cowboy_req:path(Req),
  io:format("Handling path: ~p~n", [Path]),
  handle1(Path, Req1, State).

handle1(<<"/">>, Req, State) ->
  Response = read_file(<<"/index.html">>),
  {ok, Req2} = cowboy_req:reply(200, [], Response, Req),
  {ok, Req2, State};
handle1(<<"/cgi">>, Req, State) ->
  {Args, Req1} = cowboy_req:qs_vals(Req),
  {ok, Bin, Req2} = cowboy_req:body(Req1),
  Val = mochijson2:decode(Bin),
  Response = call(Args, Val),
  Json = mochijson2:encode(Response),
  {ok, Req3} = cowboy_req:reply(200, [], Json, Req2),
  {ok, Req3, State};
handle1(Path, Req, State) ->
  Response = read_file(Path),
  {ok, Req1} = cowboy_req:reply(200, [], Response, Req),
  {ok, Req1, State}.

terminate(_Reason, _Req, _State) ->
  ok.

call([{<<"mod">>, MB}, {<<"func">>, FB}], X) ->
  Mod = list_to_atom(binary_to_list(MB)),
  Func = list_to_atom(binary_to_list(FB)),
  apply(Mod, Func, [X]).

read_file(Path) ->
  File = ["." | binary_to_list(Path)],
  io:format("Handling file: ~p~n", [File]),
  case file:read_file(File) of
    {ok, Bin} -> Bin;
    _ -> ["<pre>cannot read:", File, "</pre>"]
  end.

