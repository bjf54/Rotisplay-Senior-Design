import arcade
import math


# Size of the screen
SCREEN_WIDTH = 600
SCREEN_HEIGHT = SCREEN_WIDTH
SCREEN_TITLE = "Rotisplay simulation"

# Rectangle info
RECT_WIDTH = 25
RECT_HEIGHT = 25
RECT_COLOR = arcade.color.WHITE

BACKGROUND_COLOR = arcade.color.BLACK

class Pixel:
    """ This class represents our rectangle """

    def __init__(self, width, height, radius):

        # Set up attribute variables

        # Where we are
        self.center_x = 0
        self.center_y = 0

        self.width = width

        self.radius = radius
        self.angle = 0

    def update(self):
        self.angle = self.angle + 1
        self.angle = self.angle % 360

        self.center_x = self.radius*math.cos(math.radians(-self.angle)) + SCREEN_WIDTH/2
        self.center_y = self.radius*math.sin(math.radians(-self.angle)) + SCREEN_HEIGHT/2

    def draw(self):
        # Draw the rectangle
        # arcade.draw_rectangle_filled(self.center_x,
        #                              self.center_y,
        #                              self.width,
        #                              self.height,
        #                              RECT_COLOR)
        arcade.draw_circle_filled(self.center_x,
                                    self.center_y,
                                    self.width,
                                    RECT_COLOR)


class Rotisplay(arcade.Window):
    """ Main application class. """

    def __init__(self, width, height, title):
        super().__init__(width, height, title)

        self.numLEDs = 64

        self.pixels = []

        for i in range(self.numLEDs):
            squareSize = (SCREEN_HEIGHT/2) / self.numLEDs
            pixel = Pixel(squareSize, squareSize, (i+1) * squareSize)            
            pixel.center_x = SCREEN_WIDTH/2 + i * squareSize - squareSize
            pixel.center_y = SCREEN_HEIGHT/2 
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
        for pixel in self.pixels:
            pixel.draw()


def main():
    """ Main function """
    Rotisplay(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_TITLE)
    arcade.run()


if __name__ == "__main__":
    main()