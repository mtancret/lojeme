list_to_atom(List, Atom) :-
	object_to_atom_list(List, AtomList),
	atomic_list_concat(AtomList, Atom).
object_to_atom_list([], []).
object_to_atom_list([Object|ObjectRest], [Atom|AtomRest]) :-
	is_list(Object), !,
	list_to_atom(Object, Atom),
	object_to_atom_list(ObjectRest, AtomRest).
object_to_atom_list([Object|ObjectRest], [Object|AtomRest]) :-
	atomic(Object), !,
	object_to_atom_list(ObjectRest, AtomRest).
object_to_atom_list([Object|ObjectRest], [Atom|AtomRest]) :-
	(
		Object.to_atom(Atom), !
	;
		write(Object),nl,
		throw('to_atom failed for object')
	),
	object_to_atom_list(ObjectRest, AtomRest).

breakpoint.
%:- spy(breakpoint).
