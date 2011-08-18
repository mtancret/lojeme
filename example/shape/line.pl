:- class(line).
	:- ivar(integer, length).
	:- ivar(atom, color).

	:- new(Self, Length) --
		Self::set_length(Length).

	:- new(Self, Length, Color) --
		Self::new(Length),
		Self::set_color(Color).
:- end_class.
