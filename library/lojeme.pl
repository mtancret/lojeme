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

:- dynamic(obj_pred_/4).
:- op(650, xfy, .).
Obj.Goal :-
	functor(Obj, Class, Arity),
	obj_pred_(Class, Arity, Goal, Obj).

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
		obj_pred_(Class, 0, New, _) :-
			(
				var(Self),
				obj_pred_(Class, 0, template_(Self), _), !
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
		Check = (functor(Var, Type, _))
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

:- dynamic(ivar_/4).
ivar(Type, Name, Default) :-
	get_next_arg_idx_(ArgIdx),
	assertz(ivar_(Type, Name, ArgIdx, Default)).
ivar(Type, Name) :-
	ivar(Type, Name, _).

make_iconstructor_(Class, [Self|Args], TotalArgs) :-
	Inew =.. [new|Args],
	Cnew =.. [new|[Self|Args]],
	assertz((
		obj_pred_(Class, TotalArgs, Inew, Self) :-
			obj_pred_(Class, 0, Cnew, Self), !
	)).

make_ivar_(Class, Type, Name, ArgIdx, TotalArgs) :-
	functor(Obj, Class, TotalArgs),
	arg(ArgIdx, Obj, GetValue),
	Getter =.. [Name, GetValue],
	asserta((
		obj_pred_(Class, TotalArgs, Getter, Obj) :- !
	)),

	atom_concat('set_', Name, SetterName),
	Setter =.. [SetterName, SetValue],
	var_check_(Type, SetValue, CheckType),
	asserta((
		obj_pred_(Class, TotalArgs, Setter, Self) :-
			CheckType,
			nb_linkarg(ArgIdx, Self, SetValue), !
			;
			class_cast_exception_(SetValue, Type)
	)).

make_clause_(Class, Name, [Self|Args], Body, TotalArgs) :-
	Head =.. [Name|Args],
	assertz((
		obj_pred_(Class, TotalArgs, Head, Self) :- Body
	)).

end_class :-
	class_(Class),
	next_arg_idx_(NextArgIdx),
	TotalNumArgs is NextArgIdx - 1,
	retract( next_arg_idx_(_) ),

	functor(Template, Class, TotalNumArgs),
	forall( ivar_(_, _, ArgIdx, Default), (
		(
			var(Default), !
		;
			nb_linkarg(ArgIdx, Template, Default)
		)
	)),
	asserta( obj_pred_(Class, 0, template_(Template), _) ),

	forall( ivar_(Type, Name, ArgIdx, _), (
		make_ivar_(Class, Type, Name, ArgIdx, TotalNumArgs)
	)),

	forall( clause_(Name, Args, Body), (
		make_clause_(Class, Name, Args, Body, TotalNumArgs)
	)),

	forall( iconstructor_(Args), (
		make_iconstructor_(Class, Args, TotalNumArgs)
	)),

	retractall( ivar_(_, _, _, _) ),
	retractall( clause_(_, _, _) ),
	retractall( iconstructor_(_) ).

compile_lojeme :-
	index( obj_pred_(0, 0, 1, 0) ),
	compile_predicates([obj_pred_/4]).
