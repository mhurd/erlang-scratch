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
  N_acceptors = 10,
  Dispatch = cowboy_router:compile(
    [
      %% {URIHost, list({URIPath, Handler, Opts})}
      {'_', [{'_', simple_web_server, []}]}
    ]),
  cowboy:start_http(my_simple_web_server,
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
  Response = case  binary_to_list(Path) of
    "/" -> read_file(<<"/index.html">>);
    _ -> read_file(Path)
  end,
  {ok, Req2} = cowboy_req:reply(200, [], Response, Req1),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.

read_file(Path) ->
  File = ["." | binary_to_list(Path)],
  case file:read_file(File) of
    {ok, Bin} -> Bin;
    _ -> ["<pre>cannot read:", File, "</pre>"]
  end.

