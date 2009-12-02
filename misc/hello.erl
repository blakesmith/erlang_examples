-module(hello).
-export([start_list/1, start/1, stop/1, switch/2, speak/2]).

start(Name) ->
	register(Name, spawn(fun() -> loop(fun undef_callback/1) end)).

stop(Name) ->
	Name ! stop.

switch(Name, Fun) ->
	Name ! {switch, Fun}.

start_list([H|T]) ->
	start(H),
	start_list(T);

start_list([]) ->
	io:format("All processes successfully started!~n").

speak(Name, Person) -> Name ! {speak, Person}.

undef_callback(_) ->
	io:format("Please attach a callback using the function hello:switch/2~n").

loop(Fun) ->
	receive
		{speak, Person} ->
			catch(Fun(Person)),
			loop(Fun);
		{switch, Fun1} ->
			loop(Fun1);
		stop ->
			exit(self(), normal)
	end.
