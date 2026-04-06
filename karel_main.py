from karel.stanfordkarel import *

def main():
    go_to_package()
    pick_beeper()
    return_home()

def go_to_package():
    move()
    move()
    move()
    turn_left()
    move()
    move()
    turn_right()
    move()
    move()
    
def return_home():
    turn_around()
    move()
    move()
    turn_left()
    move()
    move()
    turn_left()
    move()
    move()
    move()

def turn_around():
    turn_left()
    turn_left()

def turn_right():
    turn_left()
    turn_left()
    turn_left()

if __name__ == '__main__':
    run_karel_program()
