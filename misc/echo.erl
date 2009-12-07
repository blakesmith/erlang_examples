-module(echo).
-export([listen/1]).

-define(TCP_OPTIONS, [list, {packet, 0}, {active, false}, {reuseaddr, true}]).

-record(player, {name=none, socket, mode}).

listen(Port) ->
	register(client_manager, spawn(fun() -> maintain_clients([]) end)),
	{ok, LSocket} = gen_tcp:listen(Port, ?TCP_OPTIONS),
	do_accept(LSocket).

do_accept(LSocket) ->
	{ok, Socket} = gen_tcp:accept(LSocket),
	spawn(fun() -> handle_client(Socket) end),
	client_manager ! {connect, Socket},
	do_accept(LSocket).

handle_client(Socket) ->
	case gen_tcp:recv(Socket, 0) of
		{ok, Data} ->
			client_manager ! {data, Socket, Data},
			handle_client(Socket);
		{error, closed} ->
			client_manager ! {disconnect, Socket}
	end.

maintain_clients(Players) ->
	io:fwrite("Players:~n"),
	lists:foreach(fun(P) -> io:fwrite(">>> ~w~n", [P]) end, Players),
	receive
		{connect, Socket} ->
			Player = #player{socket=Socket, mode=connect},
			send_prompt(Player),
			io:fwrite("client connected: ~w~n", [Player]),
			NewPlayers = [Player|Players];
		{disconnect, Socket} ->
			Player = find_player(Socket, Players),
			io:fwrite("client disconnected: ~w~n", [Player]),
			NewPlayers = lists:delete(Player, Players);
		{data, Socket, Data} ->
			Player = find_player(Socket, Players),
			NewPlayers = parse_data(Player, Players, Data),
			NewPlayer = find_player(Socket, NewPlayers),
			send_prompt(NewPlayer)
	end,
	maintain_clients(NewPlayers).

find_player(Socket, Players) ->
	{value, Player} = lists:keysearch(Socket, #player.socket, Players),
	Player.

delete_player(Player, Players) ->
	lists:keydelete(Player#player.socket, #player.socket, Players).

send_prompt(Player) ->
	case Player#player.mode of
		connect ->
			gen_tcp:send(Player#player.socket, "Name: ");
		active ->
			ok
	end.

send_to_active(Prefix, Players, Data) ->
	ActivePlayers = lists:filter(fun(P) -> P#player.mode == active end, Players),
	lists:foreach(fun(P) -> gen_tcp:send(P#player.socket, Prefix ++ Data) end, ActivePlayers),
	ok.

parse_data(Player, Players, Data) ->
	case Player#player.mode of
		active ->
			send_to_active(Player#player.name ++ ": ",
				Players, Data),
			Players;
		connect ->
			UPlayer = Player#player{name=bogostrip(Data), mode=active},
			[UPlayer|delete_player(Player, Players)]
	end.

bogostrip(String) ->
	bogostrip(String, "\r\n\t ").

bogostrip(String, Chars) ->
	[Stripped|_Rest] = string:tokens(String, Chars),
	Stripped.
