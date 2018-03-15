
require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'


class SaveTheSpace < Gosu::Window
	WIDTH = 800
	HEIGHT = 600
	ENEMY_FREQUENCY = 0.02
	MAX_ENEMIES = 100

	def initialize
		super(WIDTH, HEIGHT)
		self.caption = "Save The Space"
		@background_image = Gosu::Image.new('start1.jpg')
		@scene = :start
		@start_music = Gosu::Song.new('startspace.ogg')
		@start_music.play(true)

	end

	def initialize_game
		@player = Player.new(self)
		@imagem_fundo = Gosu::Image.new("space.jpg")
		@enemies = []
		@bullets = []
		@explosions = []
		@fundoY = 0
		@font = Gosu::Font.new(20)
		@scene = :game
		@enemies_appeared = 0
		@enemies_destroyed = 0
		@music = Gosu::Song.new('space walk.ogg')
		@music.play(true)
		@explosion_sound = Gosu::Sample.new('explosion.wav')
		@shooting_sound = Gosu::Sample.new('laser2.wav')
	end

	def initialize_end(fate)
		case fate
		when :count_reached
			@message = "Você Salvou o Espaço! #{@enemies_destroyed} naves destruídas"
			@message2= "Parabéns!"
		when :hit_by_enemy
			@message = "Ouch! Você colidiu com a nave inimiga."
			@message2 = "Mais atenção na próxima. "
			@message2 += "Destruiu #{@enemies_destroyed} naves inimigas."
		when :off_top
			@message = "Você chegou perto!"
			@message2 = "Algumas naves passaram por você, "
			@message2 += "Você destruiu #{@enemies_destroyed} naves inimigas."
		end
			@bottom_message = "Seu Placar Total: #{@player.placar} "
			@bottom_message2 = "Aperte 'R' para Reiniciar ou 'S' para Sair."
			@message_font = Gosu::Font.new(28)
			@credits = []
		y = 480
		File.open('credits.txt').each do |line|
		@credits.push(Credit.new(self,line.chomp,30,y))
		y+=30
		end
		@scene = :end
		@end_music = Gosu::Song.new('bells2_1.ogg')
		@end_music.play(true)
		
	end
	
	def draw
		case @scene
			when :start
		draw_start
			when :game
		draw_game
			when :end
		draw_end
			end
	end

	def draw_start
		@background_image.draw(0,0,0)
	end

	def draw_game
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

	def draw_end
    clip_to(30,140,800,340) do
      @credits.each do |credit|
        credit.draw
      end
    end 
    draw_line(0,140,Gosu::Color::RED,WIDTH,140,Gosu::Color::RED)
    @message_font.draw(@message,10,40,1,1,1,Gosu::Color::FUCHSIA)
    @message_font.draw(@message2,10,75,1,1,1,Gosu::Color::FUCHSIA)
    draw_line(0,480,Gosu::Color::RED,WIDTH,480,Gosu::Color::RED)
    @message_font.draw(@bottom_message,270,540,1,1,1,Gosu::Color::AQUA)
    @message_font.draw(@bottom_message2,170,500,1,1,1,Gosu::Color::AQUA)
  end

	def button_down(id)
		case @scene
		when :start
			button_down_start(id)
		when :game
			button_down_game(id)
		when :end
			button_down_end(id)
		end
	end

	def button_down_start(id)
		if id == Gosu::KbReturn or button_down? Gosu::GpButton6 then
			initialize_game
	end
	end

	def update_game
		@fundoY = (@fundoY + 4) % 600

			if button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft
		 		@player.turn_left
		 	end
			if button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight
				@player.turn_right 
			end
			
			if rand < ENEMY_FREQUENCY
				@enemies.push Enemy.new(self)
				@enemies_appeared += 1
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
						@enemies_destroyed += 1
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

		initialize_end(:count_reached) if @enemies_appeared > MAX_ENEMIES
		@enemies.each do |enemy|
			distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
			initialize_end(:hit_by_enemy) if distance < @player.radius + enemy.radius
		end
		initialize_end(:off_top) if @player.y < -@player.radius
	end

	def update
		case @scene
			when :game
				update_game
			when :end
				update_end
		end
	end

	def update_end
		@credits.each do |credit|
		credit.move
		end
		if @credits.last.y < 110
			@credits.each do |credit|
		credit.reset
			end
		end
	end

	def button_down_game(id)
		if id == Gosu::KbSpace or button_down? Gosu::GpButton0
			@bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
			@shooting_sound.play(0.05)
			
		end
	end

	def button_down_end(id)
		if id == Gosu::KbR or button_down? Gosu::GpButton6
			initialize_game
		elsif id == Gosu::KbS or button_down? Gosu::GpButton4
			close
		end
	end
end

	

window = SaveTheSpace.new
window.show

