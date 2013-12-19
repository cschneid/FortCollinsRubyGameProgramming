require 'chingu'

class Tiles
  attr_reader :tiles
  def initialize
    @tiles = Gosu::Image.load_tiles($window, "assets/spritesheet_transparent.png", -30, -16, false)
  end
end

GROUND_Y = 400

class Game < Chingu::Window
  def initialize
    super(640,480)
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
  SPEED = 6
  JUMP_HEIGHT = 15
  GRAVITY = 1

  trait :retrofy
  def screen_x
    @x
  end

  def screen_y
    @y
  end

  def initialize(options={})
    super(options.merge(:image => Tiles.new.tiles[19]))
    self.factor = 2
  end

  def move_left
    @x -= SPEED
  end

  def move_right
    @x += SPEED
  end

  def jumping?
    @status == :jumping
  end

  def jump
    return if jumping?

    @vert = JUMP_HEIGHT
    @status = :jumping
  end

  def update
    if jumping?
      @y -= @vert
      @vert -= GRAVITY
      @status = :standing if @y >= GROUND_Y
    end
  end
end

Game.new.show
