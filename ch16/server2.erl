-module(server2).
-export([start/2, rpc/2]).

start(Name, Mod) ->
	register(Name, spawn(fun() -> loop(Name, Mod, Mod:init()) end)).

rpc(Name, Request) ->
	Name ! {self(), Request},
	receive
		{Name, crash} -> exit(rpc);
		{Name, ok, Response} -> Response
	end.

loop(Name, Mod, OldState) ->
	receive
		{From, Request} ->
			try Mod:handle(Request, OldState) of
				{Response, Newstate} ->
					From ! {Name, ok, Response},
					loop(Name, Mod, Newstate)
			catch 
				_:Why ->
					log_the_error(Name, Request, Why),
					%% send a message to cause the client to crash
					From ! {Name, crash},
					%% loop the original state
					loop(Name, Mod, OldState)
			end
	end.

log_the_error(Name, Request, Why) ->
	io:format("Server ~p request ~p ~n"
		"caused exception ~p~n",
		[Name, Request, Why]).
