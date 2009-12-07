-module(echo).
-export([listen/1]).

-define(TCP_OPTIONS, [list, {packet, 0}, {active, false}, {reuseaddr, true}]).

listen(Port) ->
	{ok, LSocket} = gen_tcp:listen(Port, ?TCP_OPTIONS),
	{ok, Socket} = gen_tcp:accept(LSocket),
	do_echo(Socket).

do_echo(Socket) ->
	case gen_tcp:recv(Socket, 0) of
		{ok, Data} ->
			gen_tcp:send(Socket, Data),
			do_echo(Socket);
		{error, closed} ->
			ok
	end.
