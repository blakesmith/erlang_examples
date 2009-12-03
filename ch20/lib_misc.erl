-module(lib_misc).
-export([map/2, pmap/2]).

map(_, []) -> [];
map(F, [H|T]) -> [F(H)|map(F, T)].

pmap(F, L) ->
	S = self(),
	Ref = erlang:make_ref(),
	Pids = map(fun(I) ->
				spawn(fun() -> do_f(S, Ref, F, I) end)
		end, L),
	gather(Pids, Ref).

do_f(Parent, Ref, F, I) ->
	Parent ! {self(), Ref, (catch F(I))}.

gather([Pid|T], Ref) ->
	receive
		{Pid, Ref, Ret} -> [Ret|gather(T, Ref)]
	end;

gather([], _) ->
	[].

