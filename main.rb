require 'gosu'
require 'json'
$stage = 0
$folder

class GameWindow < Gosu::Window
	def initialize
		super(576, 1024, fullscreen: false)
        @start_position = 50
		@old = Gosu::TextInput.new
        self.text_input = @old
		@new = Gosu::TextInput.new
        #self.text_input = @new
        @font = Gosu::Font.new(48)
        @update_array = []
        @dice_frame = 0
        @dice_roll
        @dc
        @target
        @roll
        @xp_text = ""
        @cache = {}
        @write_save_data = {}
        @folder_stat = 0
        if File.exist?('data.json')
            file = File.read('data.json')
            data = JSON.parse(file)
            if data.key?("level")
                @folder_stat = data['level']
            end
        end
        @volume = 0.5
        @dice_sound = Gosu::Sample.new("dice.mp3")
        

        @dice_image = Gosu::Image.new("dice.jpg")
        @death_screen = Gosu::Image.new("you_are_died.png")
	end

    def calculate_dc()
        @dc = @old.text.length
    end

    def swap_textbox(to)
        self.text_input = to
    end

    def check_folder(input)
        if Dir.exists?(input)
            $stage = 1
            @update_array.append(:dice_roll)
        else
            puts "Folder not found"
        end
    end

    def dice_roll
        if @dice_frame == 0
            @dice_sound.play(@volume)
        end
        @dice_frame += 1
        if @dice_frame >= 60
            @update_array.delete(:dice_roll)
            @dice_roll = rand(1..20)
            @cache[:fsst2] = @folder_stat
            $stage = 2
        end
    end

	def update
        @update_array.each do |function|
		    send(function)
        end
	end

	def draw
		@font.draw_text("Folder name: #{@old.text}", 20, @start_position, 2)
        #@font.draw_text("Change to: #{@new.text}", 20, 40, 0)
        if $stage >= 1
            @font.draw_text("Rolling dice... DC(#{@dc})", 20, @start_position * 2, 2)
            @dice_image.draw(20, @start_position * 3, 2)
        end
        if $stage >= 2
            @font.draw_text("#{@dice_roll}!!!! + #{@cache[:fsst2]} (Int)", 20, @start_position * 4 + 100, 2)
            if !(@update_array.include?(:win_fail)) and $stage == 2
                @update_array.append(:win_fail)
            end
        end
        if $stage >= 3
            @font.draw_text(@xp_text, 20, @start_position * 5 + 100, 0)
            @font.draw_text("Change to: #{@new.text}", 20, @start_position * 9 + 100, 0)
        end
        if $stage >= 4
           @font.draw_text("Successfully renamed folder", 20, @start_position * 10 + 100, 0)
        end
        if $stage == 50
            @death_screen.draw(0, 0, 1)
        end
        @font.draw_text("Press Esc to Save and Quit", 20, 850, 5)
	end

    def win_fail()
        if @dice_roll >= @dc
            if rand(1..10) > 5
                @folder_stat += 1
                @xp_text = "You gained some xp...\nand LEVELLED UP!\nInt #{@folder_stat-1} -> #{@folder_stat}"
            else
                @xp_text = "You gained some xp..."
            end
            self.text_input = @new
            $stage = 3
        else
            $stage = 50
        end
        @update_array.delete(:win_fail)
    end

	def button_down(id)
		if id == Gosu::KB_RETURN
            case $stage
            when 0
                calculate_dc
                check_folder(@old.text)
            when 3
                File.rename(@old.text, @new.text)
                $stage = 4
            else
                puts "wtf"
            end
        end
        if id == Gosu::KbEscape
            @write_save_data["level"] = @folder_stat
            File.write("data.json", JSON.generate(@write_save_data))
            close
        end
		#close if id == Gosu::KbEscape
	end
end

window = GameWindow.new
window.show