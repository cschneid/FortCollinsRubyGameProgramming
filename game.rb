require 'chingu'

class Tiles
  attr_reader :tiles
  def initialize
    @tiles = Gosu::Image.load_tiles($window, "assets/spritesheet.png", -30, -16, false)
  end
end

#
# We use Chingu::Window instead of Gosu::Window
#
class Game < Chingu::Window
  def setup
  end

  def update
    push_game_state(Play)
  end
end

class Play < Chingu::GameState
  def setup
    self.input = { :p => Pause,
                   :escape => :close,
                   :holding_left => :move_left,
                   :holding_right => :move_right,
                   :released_space => :fire }
  end

  def initialize
    @player = Player.create(:x => 200, :y => 400)
    @player.input = {
      :holding_left  => :move_left,
      :holding_right => :move_right,
      :up            => :jump
    }
  end


  def update
  end
end

class Pause < Chingu::GameState
  # pause logic here
end


#
# If we create classes from Chingu::GameObject we get stuff for free.
# The accessors image,x,y,zorder,angle,factor_x,factor_y,center_x,center_y,mode,alpha.
# We also get a default #draw which draws the image to screen with the parameters listed above.
# You might recognize those from #draw_rot - http://www.libgosu.org/rdoc/classes/Gosu/Image.html#M000023
# And in it's core, that's what Chingu::GameObject is, an encapsulation of draw_rot with some extras.
# For example, we get automatic calls to draw/update with Chingu::GameObject, which usually is what you want. 
# You could stop this by doing: @player = Player.new(:draw => false, :update => false)
#
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
      @status = :standing if @y >= 400
    end
  end
end

Game.new.show   # Start the Game update/draw loop!
