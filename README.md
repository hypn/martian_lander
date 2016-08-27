# Martian Lander

## Running:
To run the Ruby lander:

    ruby lander.rb

To run the Python lander (Python 2 or 3):

    python lander.py

To run in Docker:

    docker run -v `pwd`:/src ruby sh -c "cd /src && ruby lander.rb"
    # or
    docker run -v `pwd`:/src python sh -c "cd /src && python lander.py"

A "data.txt" file (included) provides the rules for the map size and robot
placement and instructions.

## Additional options:
Passing a "last_map" to either script results in it printing out an ascii map
showing each robot's starting location (represented by the letter of their
starting orientation), and the trail they took (represented with a fullstop).

A "scent" where a robot has fallen off the edge of the map is represented with
an exclamation mark ("!"). Starting locations and "scent" markers are not
overwriten with a trail marker.

Example run + expected output of "last_map":

    1 1 E
    3 3 N LOST
    2 3 S
    -------------------------------------
    |  W  |  .  |  .  |  !  |     |     |
    |     |     |     |     |     |     |
    |     |     |     |  N  |     |     |
    |     |     |     |     |     |     |
    |  .  |  E  |     |     |     |     |
    |     |     |     |     |     |     |
    |  .  |  .  |     |     |     |     |
    |     |     |     |     |     |     |
    -------------------------------------
