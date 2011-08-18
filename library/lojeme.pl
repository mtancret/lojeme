% lojeme.pl
% Purpose: A framework for object oriented programming in Prolog.
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

:- dynamic(obj_pred_/3).
:- op(650, xfy, ::).
Obj::Goal :-
	obj_pred_(Obj, Goal, Obj).

:- dynamic(clause_/3).
:- op(1155, xfx, --).
Head--Body :-
	Head =.. [Name|Args],
	(
		Name = new,
		make_constructor_(Args, Body)
	;
		assertz(clause_(Name, Args, Body))
	).

:- dynamic(class_/1).
:- dynamic(next_arg_idx_/1).
:- dynamic(superclass/2).
class(Class) :-
	asserta(class_(Class)),
	asserta(next_arg_idx_(1)).
class(Class, extends(Superclass)) :-
	class(Class),
	asserta(superclass(Superclass, Class)).

:- dynamic(iconstructor_/1).
make_constructor_([Self|Args], Body) :-
	class_(Class),
	New =.. [new|[Self|Args]],
	asserta((
		obj_pred_(Class, New, _) :-
			(
				var(Self),
				obj_pred_(Class, arity(Arity), _),
				functor(Self, Class, Arity), !
			;
				true
			),
			Body
	)),
	asserta(iconstructor_([Self|Args])).
make_constructor_(Args) :-
	make_consturctor_(Args, true).

term_type_(Term, Type) :-
	(
		is_list(Term),
		Type = list
	;
		integer(Term),
		Type = integer
	;
		atom(Term),
		Type = atom
	;
		compound(Term),
		Type = compound
	), !.

var_check_(Type, Var, Check) :-
	(
		Type = list,
		Check = (is_list(Var))
	;
		Type = integer,
		Check = (integer(Var))
	;
		Type = atom,
		Check = (atom(Var))
	;
		Type = compound,
		Check = (compound(Var))
	; % check object class
		Check = (Var =.. [Type|_])
	), !.

class_cast_exception_(Obj, ExpectedType) :-
	term_type_(Obj, Type),
	write('Class cast exception for object '),
	write(Obj),
	write(' of type: '),
	write(Type),
	write(', expected: '),
	write(ExpectedType),
	nl,
	fail, !.

instanceof(Object, Class) :-
	Object =.. [BaseClass|_],
	(
		BaseClass = Class
	;
		superclass(Class, BaseClass)
	).

get_next_arg_idx_(Arg) :-
	retract(next_arg_idx_(Arg)),
	Argpp is Arg + 1,
	asserta(next_arg_idx_(Argpp)).

:- dynamic(ivar_/3).
ivar(Type, Name) :-
	get_next_arg_idx_(ArgIdx),
	assertz(ivar_(Type, Name, ArgIdx)).

make_iconstructor_(Class, [Self|Args], TotalArgs) :-
	functor(Obj, Class, TotalArgs),
	Inew =.. [new|Args],
	Cnew =.. [new|[Self|Args]],
	assertz((
		obj_pred_(Obj, Inew, Self) :-
			obj_pred_(Class, Cnew, Self)
	)).

make_ivar_(Class, Type, Name, ArgIdx, TotalArgs) :-
	functor(Obj, Class, TotalArgs),
	arg(ArgIdx, Obj, GetValue),
	Getter =.. [Name, GetValue],
	asserta((
		obj_pred_(Obj, Getter, _) :- !
	)),

	atom_concat('set_', Name, SetterName),
	Setter =.. [SetterName, SetValue],
	var_check_(Type, SetValue, CheckType),
	asserta((
		obj_pred_(Obj, Setter, Self) :-
			CheckType,
			nb_linkarg(ArgIdx, Self, SetValue), !
			;
			class_cast_exception_(SetValue, Type)
	)).

make_clause_(Class, Name, [Self|Args], Body, TotalArgs) :-
	functor(Obj, Class, TotalArgs),
	Head =.. [Name|Args],
	assertz((
		obj_pred_(Obj, Head, Self) :- Body
	)).

end_class :-
	class_(Class),
	next_arg_idx_(NextArgIdx),
	TotalNumArgs is NextArgIdx - 1,
	retract(next_arg_idx_(_)),

	forall(ivar_(Type, Name, ArgIdx),
		make_ivar_(Class, Type, Name, ArgIdx, TotalNumArgs)),
	retractall(ivar_(_, _, _)),

	forall(clause_(Name, Args, Body),
		make_clause_(Class, Name, Args, Body, TotalNumArgs)),
	retractall(clause_(_, _, _)),

	forall(iconstructor_(Args),
		make_iconstructor_(Class, Args, TotalNumArgs)),
	retractall(iconstructor_(_)),

	asserta( obj_pred_(Class, arity(TotalNumArgs), _) ).
