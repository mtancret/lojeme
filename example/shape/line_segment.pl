:- class(line_segment).
	:- ivar(integer, length).
	:- ivar(atom, color, green).

	:- new(Self, Length) --
		Self.set_length(Length).

	:- new(Self, Length, Color) --
		Self.new(Length),
		Self.set_color(Color).
:- end_class.
