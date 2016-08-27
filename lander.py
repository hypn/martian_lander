import sys

world = {
    'width': False,
    'height': False,
    'map': []
}


class Robot():
    """ keeping this class in-line for now """

    # using an array of possible orientations for rotation
    ORIENTATIONS = ['N', 'E', 'S', 'W']

    # custom error to throw when falling off the map
    class OffMapError(Exception):
        pass

    def __init__(self, x, y, orientation):
        # assign all the values to the new object
        self.x = int(x)
        self.y = int(y)
        self.orientation = orientation
        self.lost = ''

        # plot the starting location on the map, showing orientation
        world['map'][self.y][self.x] = self.orientation

    def process(self, instructions):
        for instruction in instructions:
            try:
                if instruction == 'F':
                    self.move_forward()
                elif instruction == 'L':
                    self.rotate(instruction)
                elif instruction == 'R':
                    self.rotate(instruction)

            except self.OffMapError as e:
                break

    def move_forward(self):
        # determine whether our axis (x/y) value is increasing or decreasing
        change = -1 if (self.orientation == 'W') else 1
        change = -1 if (self.orientation == 'S') else change

        # determine which axis to move on, based on our orientation
        #   it is a bit verbose setting the "new" variables here, but it keeps
        #   the "if" below easier to read
        if ((self.orientation == 'W') or (self.orientation == 'E')):
            axis = 'x'
            new_x = self.x + change
            new_y = self.y
        else:
            axis = 'y'
            new_x = self.x
            new_y = self.y + change

        # check if we're about to leave the map area...
        if ((new_x < 0) or (new_y < 0) or (new_x > world['width']) or (new_y > world['height'])):
            # check if there's a scent here to warn us
            if (world['map'][self.y][self.x] == '!'):
                # if so don't execute this suicidal instruction
                # print('DEBUG: Scent detected at x: ' + str(self.x) + ', y: ' + str(self.y) + ' - ignoring instruction!')
                return

            else:
                # add our scent to the map...
                world['map'][self.y][self.x] = '!'
                # set ourselves as lost
                self.lost = 'LOST'
                # and then fall off :(
                raise self.OffMapError("Fell off the map!")

        # update our co-ordinates (if we didn't get a scent or fall off)
        self.x = new_x
        self.y = new_y

        # add our path on the map
        if (world['map'][self.y][self.x] == ' '):
            world['map'][self.y][self.x] = '.'

    def rotate(self, direction):
        # find current orientation in the list, move to the next/previous one
        change = 1 if (direction == 'R') else -1
        i = self.ORIENTATIONS.index(self.orientation) + change
        i = 0 if (i == len(self.ORIENTATIONS)) else i

        # print('DEBUG: Rotating from ' + self.orientation + ' to ' + self.ORIENTATIONS[i])
        self.orientation = self.ORIENTATIONS[i]

    def print_location(self):
        print(str(self.x) + ' ' + str(self.y) + ' ' + self.orientation + ' ' + self.lost)


# Note: a bit hacky, but just for debug + fun ;)
def print_map():
    # work out how long our horizontal line should be
    # create a string with that many minus signs
    horizontal_line = ''
    for i in range((world['width'] * 6) + 7):
        horizontal_line = horizontal_line + '-'

    # work out what a separator line looks like
    spacing_line = ''
    for i in range((world['width'])):
        spacing_line = spacing_line + '   |  '
    spacing_line = '|  ' + spacing_line + '   |'

    print(horizontal_line)

    # print each row's data)
    for y in range(world['height'] + 1):
        # print highest to lowest rows as x=0 y=0 is the bottom row to be shown)
        row = world['height'] - y

        print('|  ' + '  |  '.join(world['map'][row]) + '  |')
        print(spacing_line)

    print(horizontal_line)
    print
    print

# some rules that control things
ROBOT_NUM_LINES = 3
MAX_WIDTH_HEIGHT = 50

# variables used for loop through the data file and knowing when
current_line_num = 1
robot_lines = []

# main loop and parsing of data file
f = open('data.txt', 'r')
for line in f:
    # collect the lines of data
    robot_lines.append(line.strip())

    # once we've collected 3 lines (per robot)
    if ((current_line_num % ROBOT_NUM_LINES) == 0):
        # create the world map (if not already done)
        if (not world['width'] and not world['height']):
            world_width, world_height = str.split(robot_lines[0], ' ')

            # limit the max width and height (decided to cap it at the limit
            # rather than throwing an error) ideally this should all be part
            # of a World object constructor
            if int(world_height) > MAX_WIDTH_HEIGHT:
                world['height'] = MAX_WIDTH_HEIGHT
            else:
                world['height'] = int(world_height)

            if int(world_width) > MAX_WIDTH_HEIGHT:
                world['width'] = MAX_WIDTH_HEIGHT
            else:
                world['width'] = int(world_width)

            # build a map for storing scent and debugging/printing
            for y in range(world['height']+1):
                row = []

                for x in range(world['width']+1):
                    row.append(' ')

                world['map'].append(row)

        # create a new robot from the input (2nd line of data)
        x, y, orientation = robot_lines[1].split(' ')
        robot = Robot(x, y, orientation)

        # process the instructions (3rd line of data)
        instructions = list(robot_lines[2].strip())
        robot.process(instructions)

        # print the robot's final location)
        robot.print_location()

        # if script is run with an additional "all_maps" value
        if ((len(sys.argv) > 1) and (sys.argv[1] == 'all_maps')):
            print_map()

        # reset the robot data for a possible next robot
        robot_lines = []

    current_line_num += 1

f.close

# if script is run with an additional "last_map" value,
if ((len(sys.argv) > 1) and (sys.argv[1] == 'last_map')):
    print_map()
