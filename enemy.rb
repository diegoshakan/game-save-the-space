class Enemy
	SPEED = 5
	attr_reader :x, :y, :angle, :radius

	def initialize(window)
		@width = 0
		@height = 0
		@window = window
		@radius = 30
		@x = rand(window.width - 5 * @radius) + @radius
		@y = 0
		@image = Gosu::Image.new('media/enemy1.png')
	end

	def draw
		@image.draw(@x + 42 - @radius, @y - @radius, 1)
	end

	def move
		@y += SPEED
	end


end