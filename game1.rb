# A guy, who jumps.

require 'chingu'

class Tiles
  attr_reader :tiles
  def initialize
    @tiles = Gosu::Image.load_tiles($window, "assets/spritesheet.png", -30, -16, false)
  end
end

GROUND_Y = 320

class Game < Chingu::Window
  def initialize
    super(640,400)
    self.caption = "FoCoRuby example."
  end

  def setup
    @player = Player.create(:x => 200, :y => GROUND_Y)
    @player.input = {
      :holding_left  => :move_left,
      :holding_right => :move_right,
      :up            => :jump
    }
  end
end

class Player < Chingu::GameObject
  trait :retrofy
  def screen_x
    @x
  end

  def screen_y
    @y
  end

  def initialize(options={})
    super(options.merge(:image => Tiles.new.tiles[19]))
    self.factor = 5
  end

  def move_left
    @x -= 10
  end

  def move_right
    @x += 10
  end

  def jump
    @vert = 10
    @status = :jumping
  end

  def update
    if @status == :jumping
      @y -= @vert
      @vert -= 1
      @status = :standing if @y >= GROUND_Y
    end
  end
end

Game.new.show
