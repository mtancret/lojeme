% hashmap.pl
% Purpose: Encapsulates a hashmap data structure.
% Author(s): Matthew Tan Creti
%
% Copyright 2011 Matthew Tan Creti
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

:- dynamic(map/3).
:- class(hashmap).
	:- ivar(atom, mapid).
	:- ivar(array, array).
	:- ivar(integer, next_idx).

	:- new(Self) --
		gensym(o, Mapid),
		Self.set_mapid(Mapid),

		functor(Array, array, 128),
		Self.set_array(Array),

		Self.set_next_idx(1).

	:- add(Self, Key, Value) --
		Self.next_idx(Idx),
		
		Self.mapid(Mapid),
		asserta(hashmap:map(Mapid, Key, Idx)),

		(
			Self.array(Array),
			functor(Array, _, Size),
			Idx =< Size, !
		;
			Self.expand(Array)
		),
		nb_linkarg(Idx, Array, Value),

		NextIdx is Idx + 1,
		Self.set_next_idx(NextIdx).

	:- key_value(Self, Key, Value) --
		Self.mapid(Mapid),
		hashmap:map(Mapid, Key, Idx),

		Self.array(Array),
		arg(Idx, Array, Value).

	:- expand(Self, NewArray) --
		Self.array(Array),
		functor(Array, _, Size),
		NewSize is Size * 2,
		functor(NewArray, array, NewSize),
		forall(between(1, Size, I), (
			arg(I, Array, Arg),
			nb_linkarg(I, NewArray, Arg)
		)),
		Self.set_array(NewArray).
:- end_class.
