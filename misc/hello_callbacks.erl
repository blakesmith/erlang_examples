-module(hello_callbacks).
-export([hello/1, bye/1]).

hello(Person) ->
	io:format("Hello there, ~s~n", [Person]).

bye(Person) ->
	io:format("Bye ~s!~n", [Person]).

