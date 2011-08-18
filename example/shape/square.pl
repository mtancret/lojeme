:- class(square).
	:- ivar(line, side).
	:- ivar(atom, color).

	:- new(Self, Length) --
		line::new(Side, Length),
		Self::set_side(Side).

	:- new(Self, Length, Color) --
		Self::new(Length),

		Self::set_color(Color),

		Self::side(Side),
		Side::set_color(Color).

	:- area(Self, Area) --
		Self::side(Side),
		Side::length(Length),
		Area is Length * Length.
:- end_class.
