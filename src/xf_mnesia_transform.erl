%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Dec 2016 1:32 PM
%%%-------------------------------------------------------------------
-module(xf_mnesia_transform).
-author("simon").

%% API
-export([
  dump_to_file/2
  , load_from_file/1
]).

dump_to_file(FileName, TableList) when is_list(TableList), is_list(FileName) ->
  dump_to_file(list_to_binary(FileName), TableList);
dump_to_file(FileName, Table) when is_atom(Table), is_list(FileName) ->
  dump_to_file(list_to_binary(FileName), Table);
dump_to_file(FileName, TableList) when is_list(TableList), is_binary(FileName) ->
  %% dump all mnesia table to one file
  [dump_to_file(FileName, Table) || Table <- TableList];
dump_to_file(FileName, Table) when is_atom(Table), is_binary(FileName) ->
  lager:info("Dump ets table ~p started...", [FileName]),
  List = ets:tab2list(Table),

  F = fun(Term) ->
    io_lib:format("~tp.~n", [Term])
      end,

  Text = lists:map(F, List),
  file:write_file(FileName, Text, [append]),
  lager:info("Dump ets table ~p end...", [FileName]),
  ok.




load_from_file(FileName) ->
  lager:info("Start load terms from file: ~p", [FileName]),
  {ok, List} = file:consult(FileName),
  lager:info("Finish load terms from file: ~p", [FileName]),
  [mnesia:dirty_write(Term) || Term <- List],
  lager:info("End write to mnesia tables", []).

