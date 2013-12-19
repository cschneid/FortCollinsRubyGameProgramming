require 'chingu'

GROUND_Y = 400
OFF_SCREEN_TOP = -20
Y_SIZE = 480
X_SIZE = 640
MAX_WEIGHTS = 1

class Game < Chingu::Window
  def initialize
    super(X_SIZE, Y_SIZE)
    self.caption = "FoCoRuby example."
  end

  def setup
    self.input = {:esc => :exit}

    @player = Player.create(:x => 200, :y => GROUND_Y)
    @player.input = {
      :holding_left  => :move_left,
      :holding_right => :move_right,
      :up            => :jump
    }
  end

  def update
    super

    if Weight.size < MAX_WEIGHTS
      Timer("WeightSpawner.spawn") do
        Weight.create(:x => random_x, :y => OFF_SCREEN_TOP)
      end
    end

    Timer("Destroying Weights") do
      Weight.destroy_if {|w| w.off_screen? }
    end
  end

  def random_x
    rand(640)
  end
end

class Weight < Chingu::GameObject
  FALL_ACCEL = 0.1

  def initialize(options={})
    Timer("Merging option") do
      options.merge!(:image => Tiles.weight)
    end

    Timer("Init Weight") do
      # require 'byebug'; byebug
      super(options)
    end

    Timer("Set fall speed") do
      @fall_speed = FALL_ACCEL
    end
  end

  def off_screen?
    @y > Y_SIZE + 20
  end

  def update
    Timer("Weight Update") do
      @y += @fall_speed
      @fall_speed += FALL_ACCEL
    end
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
    super(options.merge(:image => Tiles.guy))
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
    Timer("Player Update") do
      if jumping?
        @y -= @vert
        @vert -= GRAVITY
        @status = :standing if @y >= GROUND_Y
      end
    end
  end
end

class Tiles
  def self.tiles
    @tiles ||= Gosu::Image.load_tiles($window, "assets/spritesheet_transparent.png", -30, -16, false)
  end

  def self.guy
    self.tiles[19]
  end

  def self.weight
    self.tiles[71]
  end
end

TIME_CUTOFF = 0.5 # half second
def Timer(name, &block)
  start = Time.now
  result = block.call
  stop = Time.now
  if (duration = stop.to_f - start.to_f) > TIME_CUTOFF
    log "Duration of #{name}: #{duration}"
  end

  return result
end

def log(*args)
  puts *args
end

Game.new.show
