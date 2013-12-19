require 'chingu'

GROUND_Y = 400
OFF_SCREEN_TOP = -20
Y_SIZE = 480
X_SIZE = 640
MAX_WEIGHTS = 5
SPRITE_WIDTH  = 19
SPRITE_HEIGHT = 11
SPRITE_COUNT_ACROSS = 30
SPRITE_COUNT_DOWN   = 16

class Game < Chingu::Window
  def initialize
    super(X_SIZE, Y_SIZE)
    self.caption = "FoCoRuby example."
  end

  def setup
    self.input = {:esc => :exit, :r => :restart}

    @player = Player.create(:x => 200, :y => GROUND_Y)
    @player.input = {
      :holding_left  => :move_left,
      :holding_right => :move_right,
      :up            => :jump
    }

    @ground_spawner = GroundSpawner.new
    @ground_spawner.spawn

    @weight_spawner = WeightSpawner.new
    @fps = Chingu::FPSCounter.new
  end

  def restart
    Player.destroy_all
    Ground.destroy_all
    Weight.destroy_all
    setup
  end

  def update
    super

    @fps.register_tick
    log @fps.fps

    Timer("Spawning any new weights") { @weight_spawner.spawn }
    Timer("Destroying Weights off screen") do
      Weight.destroy_if {|w| w.off_screen? }
    end

    Timer("Check for collisions") do
      @player.each_bounding_box_collision(Weight) do |player, weight|
        @player.die!
      end
    end
  end
end

class GroundSpawner
  def spawn
    x = -20
    while (x = x + (SPRITE_WIDTH * 2)) < (X_SIZE + 20)
      Ground.create(:x => x,
                    :y => (GROUND_Y + (SPRITE_HEIGHT * 4)))
    end
  end
end

class WeightSpawner
  def spawn
    if Weight.size < MAX_WEIGHTS
      Timer("WeightSpawner.spawn") do
        Weight.create(:x => random_x, :y => OFF_SCREEN_TOP)
      end
    end
  end

  def random_x
    rand(X_SIZE)
  end
end

class Ground < Chingu::GameObject
  trait :retrofy
  def screen_x
    @x
  end

  def screen_y
    @y
  end

  def initialize(options={})
    options.merge!(:image => Tiles.ground)
    super(options)

    self.factor = 2
  end
end

class Weight < Chingu::GameObject
  trait :collision_detection
  trait :bounding_box, :scale => 1.00, :debug => true

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
  trait :collision_detection
  trait :bounding_box, :scale => 1.00, :debug => true

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
    return if dead?
    @x -= SPEED
  end

  def move_right
    return if dead?
    @x += SPEED
  end

  def jump
    return if dead?
    return if jumping?

    @vert = JUMP_HEIGHT
    @status = :jumping
  end

  def die!
    self.image = Tiles.dead_guy
    @status = :dead
  end

  def dead?
    return @status == :dead
  end

  def jumping?
    @status == :jumping
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
    @tiles ||= Gosu::Image.load_tiles($window, "assets/spritesheet_transparent.png", -SPRITE_COUNT_ACROSS, -SPRITE_COUNT_DOWN, false)
  end

  def self.guy
    self.tiles[19]
  end

  def self.dead_guy
    self.tiles[112]
  end

  def self.weight
    self.tiles[71]
  end

  def self.ground
    self.tiles[123]
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
