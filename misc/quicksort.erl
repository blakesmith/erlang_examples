%% quicksort:quicksort(List)
%% Sort a list of items
-module(quicksort).     % This is the file 'quicksort.erl'
-export([quicksort/1]). % A function 'quicksort' with 1 parameter is exported (no type, no name)
 
quicksort([]) -> []; % If the list [] is empty, return an empty list (nothing to sort)
quicksort([Pivot|Rest]) -> % Compose recursively a list with 'Front' 
                           % from 'Pivot' and 'Back' from 'Rest'
    quicksort([Front || Front <- Rest, Front < Pivot]) 
    ++ [Pivot] ++ 
    quicksort([Back || Back <- Rest, Back >= Pivot]).

