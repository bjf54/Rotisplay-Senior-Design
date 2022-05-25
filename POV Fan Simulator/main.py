import arcade
import math

# Size of the screen
SCREEN_SIZE = 600
SCREEN_TITLE = "Rotisplay simulation"

BACKGROUND_COLOR = arcade.color.BLACK

RGB = [arcade.color.RED, arcade.color.GREEN, arcade.color.BLUE]

class Pixel:
    """ This class represents our rectangle """

    def __init__(self, radius, globalRadius, color = arcade.color.WHITE):

        # Set up attribute variables

        # Where we are
        self.center_x = 0
        self.center_y = 0

        self.radius = radius

        self.globalRadius = globalRadius
        self.angle = 0

        self.color = color

    def update(self):
        self.angle = self.angle + 5
        self.angle = self.angle % 360

        self.center_x = self.globalRadius*math.cos(math.radians(-self.angle)) + SCREEN_SIZE/2
        self.center_y = self.globalRadius*math.sin(math.radians(-self.angle)) + SCREEN_SIZE/2

    def draw(self):
        arcade.draw_circle_filled(self.center_x,
                                    self.center_y,
                                    self.radius,
                                    self.color)


class Rotisplay(arcade.Window):
    """ Main application class. """

    def __init__(self, width, height, title):
        super().__init__(width, height, title)

        self.set_update_rate(1.0 / 60.0)

        self.numLEDs = 64

        self.pixels = []

        # This needs some cleaning
        for i in range(self.numLEDs):
            circWidth = (SCREEN_SIZE/2) / self.numLEDs
            pixel = Pixel(radius=circWidth/2, globalRadius=((i + 1) * circWidth - circWidth/2), color=RGB[i%3])            
            pixel.center_x = SCREEN_SIZE/2 + i * circWidth + (circWidth/2)
            pixel.center_y = SCREEN_SIZE/2 
            self.pixels.append(pixel)

        # Set background color
        self.background_color = BACKGROUND_COLOR

    def on_update(self, delta_time):
        # Move the pixels
        for pixel in self.pixels:
            pixel.update()

    def on_draw(self):
        """ Render the screen. """

        # Clear screen
        self.clear()
        # Draw the pixels
        arcade.draw_circle_outline(SCREEN_SIZE/2, SCREEN_SIZE/2, 3, arcade.color.WHITE)
        for pixel in self.pixels:
            pixel.draw()


def main():
    """ Main function """
    Rotisplay(SCREEN_SIZE, SCREEN_SIZE, SCREEN_TITLE)
    arcade.run()


if __name__ == "__main__":
    main()