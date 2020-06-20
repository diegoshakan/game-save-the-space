require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'




class SaveTheSpace < Gosu::Window
	ENEMY_FRENQUENCY = 0.02
	WIDTH = 640
	HEIGHT = 480

	def initialize
		super(WIDTH, HEIGHT)
		self.caption = 'Save The Space'
		@imagem_fundo = Gosu::Image.new("space.png")
		@player = Player.new(self)
		@enemies = []
		@bullets = []
		@explosions = []
		@fundoY = 0
		@font = Gosu::Font.new(20)
		@start_music = Gosu::Song.new('space walk.ogg')
		@start_music.play(true)
		@explosion_sound = Gosu::Sample.new('explosion.wav')
		@shooting_sound = Gosu::Sample.new('laser2.wav')
		
		
		

	end

	def draw
		@player.draw
		@font.draw("Placar: #{@player.placar}",10, 10, 3, 1.5, 1.5, 0xffffff00)
		@enemies.each do |enemy|
			enemy.draw
		end

		@bullets.each do |bullet|
			bullet.draw
		end

		@explosions.each do |explosion|
			explosion.draw
		end

		

		@imagem_fundo.draw(0,@fundoY,0)
		@imagem_fundo.draw(0,@fundoY-480,0)

		
	end

	def update
		@fundoY = (@fundoY + 4) % 480

			if (button_down?(Gosu::KbLeft)) then 
		 		@player.turn_left
		 	end
			if (button_down?(Gosu::KbRight)) then
				@player.turn_right 
			end


			if rand < ENEMY_FRENQUENCY
				@enemies.push Enemy.new(self)
			end
			@enemies.each do |enemy|
				enemy.move
			end


			@bullets.each do |bullet|
				bullet.move
			end

			@enemies.dup.each do |enemy|
				@bullets.dup.each do |bullet|
					distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
					if distance < enemy.radius + bullet.radius
						@enemies.delete enemy
						@bullets.delete bullet
						@explosions.push Explosion.new(self, enemy.x, enemy.y)
						@player.placar += 10
						@explosion_sound.play(0.2)


					end
				end
			end
			@explosions.dup.each do |explosion|
			@explosions.delete explosion if	explosion.finished
		end

			
			
			@enemies.dup.each do |enemy|
				if enemy.y > HEIGHT + enemy.radius
					@enemies.delete enemy
				end
			end

			@bullets.dup.each do |bullet|
				@bullets.delete bullet unless bullet.onscreen?

		end
	end


	def button_down(id)
		if id == Gosu::KbSpace
			@bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
			@shooting_sound.play(0.05)
			
		end
	end

end
		
	



	

window = SaveTheSpace.new
window.show