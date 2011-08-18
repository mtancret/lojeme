:- class(cube).
	:- ivar(line_segment, side).
	:- ivar(atom, color, green).

	:- new(Self, Length) --
		line_segment.new(Side, Length),
		Self.set_side(Side).

	:- new(Self, Length, Color) --
		Self.new(Length),

		Self.set_color(Color),

		Self.side(Side),
		Side.set_color(Color).

	:- area(Self, Area) --
		Self.side(Side),
		Side.length(Length),
		Area is 6 * Length * Length.

	:- volume(Self, Volume) --
		Self.side(Side),
		Side.length(Length),
		Volume is Length * Length * Length.
:- end_class.
