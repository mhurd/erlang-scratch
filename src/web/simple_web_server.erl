%%%-------------------------------------------------------------------
%%% @author mhurd
%%% @copyright (C) 2015, <COMPANY>
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
  ok = application:start(crypto), %%<label id="web.app.start"/>
  ok = application:start(ranch),
  ok = application:start(cowlib),
  ok = application:start(cowboy), %%<label id="web.app.end"/>
  N_acceptors = 10, %%<label id="web.app.acc"/>
  Dispatch = cowboy_router:compile(
    [
      %% {URIHost, list({URIPath, Handler, Opts})}
      {'_', [{'_', simple_web_server, []}]}  %%<label id="web.app.disp"/>
    ]),
  cowboy:start_http(my_simple_web_server,
    N_acceptors,       %%<label id="web.app.accu"/>
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
  {Path, Req1} = cowboy_req:path(Req),                %%<label id="web.handle1"/>
  Response = read_file(Path),                             %%<label id="web.handle2"/>
  {ok, Req2} = cowboy_req:reply(200, [], Response, Req1), %%<label id="web.handle3"/>
  {ok, Req2, State}.  %%<label id="web.handle4"/>

terminate(_Reason, _Req, _State) ->
  ok.

read_file(Path) ->
  File = ["." | binary_to_list(Path)],
  case file:read_file(File) of
    {ok, Bin} -> Bin;
    _ -> ["<pre>cannot read:", File, "</pre>"]
  end.

