-module(area_server0).
-export([start/0, area/2]).

start() ->
	spawn(fun loop/0).

area(Pid, What) ->
	rpc(Pid, What).

rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive
		{Pid, Response} ->
			Response
	end.

loop() ->
	receive
		{From, {rectangle, Width, Ht}} ->
			From ! {self(), Width * Ht},
			loop();
		{From, {circle, R}} ->
			From ! {self(), 3.141592 * R * R},
			loop();
		{From, Other} ->
			From ! {self(), {error, Other}},
			loop()
	end.
