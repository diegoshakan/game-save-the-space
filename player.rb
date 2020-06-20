class Player
attr_reader :x, :y, :angle, :radius
attr_accessor :placar

	def initialize(window)
		@x = 380
		@y = 510
		@angle = 0
		@radius = 20
		@image = Gosu::Image.new('media/nave1.png')
		@window = window
		@placar = 0
	end

	def draw
		@image.draw(@x, @y, 1)
	end

	def turn_right
		@x = @x + 6.5
			if (@x > 795 - (@image.width)) then
				@x = 795 - (@image.width)
			end

	end

	def turn_left
		@x = @x - 6.5
		if (@x < 3) then 
			@x = 3 end
		end
	

end
