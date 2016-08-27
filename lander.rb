# I've come VERY close to turning this in to a proper object, with some additional methods... but leaving it for now
#   it's also a global variable, which is horrible, but Ruby doesn't pass objects by reference making it difficult
#   to maintain state (such as "scents") another way (though I'd probably go with a Singleton and helper methods etc)
$world = {
    width: false,
    height: false,
    map: Array.new
}

# keeping this class in-line for now, would normally put classes in their own files
class Robot
    # using an array of possible orientations (which can be expanded on) for rotation
    ORIENTATIONS = ['N', 'E', 'S', 'W']

    attr_accessor :x
    attr_accessor :y
    attr_accessor :orientation
    attr_accessor :lost

    # custom error to throw when falling off the map
    class OffMapError < StandardError
      attr_reader :object

      def initialize(object)
        @object = object
      end
    end

    def initialize(x, y, orientation)
        # assign all the values to the new object
        self.x, self.y, self.orientation = x.to_i, y.to_i, orientation

        # plot the starting location on the map, showing orientation
        $world[:map][self.y][self.x] = self.orientation
    end

    def process(instructions)
        instructions.each do |instruction|
            begin

                case instruction
                when 'F'
                    move_forward()
                when 'L'
                    rotate(instruction)
                when 'R'
                    rotate(instruction)
                end

            rescue OffMapError
                # stop processing instructions if robot falls off the map
                break
            end
        end
    end

    def move_forward()
        # determine whether our axis (x/y) value is increasing or decreasing
        change = ((self.orientation === 'W') || (self.orientation === 'S')) ? -1 : 1

        # determine which axis to move on, based on our orientation
        #   it is a bit verbose setting the "new" variables here, but it keeps the "if" below easier to read and
        #   avoids having to use ".send(axis)" etc to dynamically modify an instance's properties (thanks ruby :/)
        if ((self.orientation === 'W') || (self.orientation === 'E'))
            axis = 'x'
            new_x = self.x + change
            new_y = self.y
        else
            axis = 'y'
            new_x = self.x
            new_y = self.y + change
        end

        # check if we're about to leave the map area...
        if ((new_x < 0) || (new_y < 0) || (new_x > $world[:width]) || (new_y > $world[:height]))
            # check if there's a scent here to warn us, and if so don't execute this suicidal instruction
            if ($world[:map][self.y][self.x] === '!')
                # puts "DEBUG: Scent detected at x: #{self.x}, new y: #{self.y} - ignoring instruction!"
                return

            else
                 # add our scent to the map...
                $world[:map][self.y][self.x] = '!'
                # set ourselves as lost
                self.lost = 'LOST'
                # and then fall off :(
                raise OffMapError.new("Fell off the map!")
            end
        end

        # update our co-ordinates (if we didn't get a scent or fall off the map already)
        self.x = new_x
        self.y = new_y

        # add our path on the map
        if ($world[:map][self.y][self.x] === ' ')
            $world[:map][self.y][self.x] = '.'
        end
    end

    def rotate(direction)
        # find our current orientation in the list, move to the next/previous one, ensuring we wrap around
        change = (direction === 'R') ? 1 : -1
        i = Robot::ORIENTATIONS.index(self.orientation) + change
        i = (i === Robot::ORIENTATIONS.length) ? 0 : i

        # puts "DEBUG: Rotating from #{self.orientation} to #{ORIENTATIONS[i]}"
        self.orientation = Robot::ORIENTATIONS[i]
    end

    def print_location
        puts "#{self.x} #{self.y} #{self.orientation} #{self.lost}"
    end
end

# Note: a bit hacky, but just for debug + fun ;)
def print_map
    # work out how long our horizontal line should be, create a string with that many minus signs
    horizontal_line = '-' * (($world[:width] * 6) + 7)
    # work out what a separator line looks like (based on how many columns the map has)
    spacing_line = '|  ' + ('   |  ' * $world[:width]) + '   |'

    puts horizontal_line

    # print each row's data
    for y in 0..$world[:height] do
        row = $world[:height] - y # print highest to lowest rows, as x=0 y=0 is the bottom row to be shown
        puts '|  ' + $world[:map][row].join('  |  ') + '  |'
        puts spacing_line
    end

    puts horizontal_line
    puts
    puts
end

# some rules that control things
ROBOT_NUM_LINES = 3
MAX_WIDTH_HEIGHT = 50

# variables used for loop through the data file and knowing when
current_line_num = 1
robot_lines = []

# main loop and parsing of data file
f = File.open("data.txt", "r")
f.each_line do |line|
    # collect the lines of data
    robot_lines << line

    # once we've collected 3 lines (per robot)
    if ((current_line_num % ROBOT_NUM_LINES) == 0)

        # create the world map (if not already done - first line of data, otherwise blank)
        unless $world[:width] and $world[:height]
            world_width, world_height = robot_lines[0].split(' ')

            # limit the max width and height (decided to cap it at the limit rather than throwing an error)
            # ideally this should all be part of a World object constructor
            $world[:width]  = (world_width.to_i > MAX_WIDTH_HEIGHT)  ? MAX_WIDTH_HEIGHT : world_width.to_i
            $world[:height] = (world_height.to_i > MAX_WIDTH_HEIGHT) ? MAX_WIDTH_HEIGHT : world_height.to_i

            # build a map for storing scent and debugging/printing
            for y in 0..$world[:height] do
                row = []

                for x in 0..$world[:width] do
                    row.push(' ')
                end

                $world[:map].push(row);
            end
        end

        # create a new robot from the input (2nd line of data)
        x, y, orientation = robot_lines[1].split(' ')
        robot = Robot.new(x, y, orientation)

        # process the instructions (3rd line of data)
        robot.process(robot_lines[2].strip.split(''))

        # print the robot's final location
        robot.print_location

        # if the script is run with an additional "all_maps" value, print the map after each robot
        if (ARGV[0] && (ARGV[0] == 'all_maps'))
            print_map
        end

        # reset the robot data for a possible next robot
        robot_lines = []
    end

    current_line_num += 1
end
f.close

# if the script is run with an additional "last_map" value, print the map at the end
if (ARGV[0] && (ARGV[0] == 'last_map'))
    print_map
end
