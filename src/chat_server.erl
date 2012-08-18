-module(chat_server).
-export([start/0,stop/0]).
-export([init/0]).

start() ->
  Pid = spawn(chat_server, init, []),
  register(chat_server, Pid).

stop() ->
  exit(whereis(chat_server), normal),
  unregister(chat_server).

init() ->
  receive
    {open_room, Room} ->
      open_room(Room);
    {close_room, Room} ->
      close_room(Room);
    {'DOWN', Ref, process, Pid, Reason} ->
      demonitor(Ref),
      io:format("Process ~p has exited: ~p~n", [Pid,Reason]);
    _Else ->
      %save message to log file
      io:format("~p~n", [_Else])
  end,
  init().

open_room(Room) ->
  case whereis(Room) of
    undefined ->
      Pid = chat_room:start(Room),
      monitor(process, Pid),
      io:format("~s room was opened~n", [Room]),
      ok;
    _Pid ->
      io:format("~s room already exist~n", [Room]),
      error
    end.

close_room(Room) ->
  case whereis(Room) of
    undefined ->
      io:format("~s room doesn't exist~n", [Room]),
      error;
    Pid ->
      Pid ! close
    end.
