"""
TODO:
    -Trailing LEDs with decreasing alpha to simulate motion blur
"""
import arcade
import math

from ImageProcessing import ImageProcessor

# Size of the screen
SCREEN_SIZE = 600
SCREEN_TITLE = "Rotisplay simulation"

BACKGROUND_COLOR = arcade.color.BLACK

RGB = [arcade.color.RED, arcade.color.GREEN, arcade.color.BLUE]

class Pixel:
    """ This class represents our rectangle """

    def __init__(self, radius, globalRadius, id=0):

        # Set up attribute variables

        # Where we are
        self.center_x = 0
        self.center_y = 0

        self.radius = radius

        self.globalRadius = globalRadius
        self.angle = 0

        self.id = id

        self.color = RGB[self.id%3]


    def update(self, xUnit, yUnit, color):
        # Change speed of rotation
        # May need to add 'trailing' LEDs to actually simulate the 'ghosting' from the spinning

        self.center_x = self.globalRadius * xUnit + SCREEN_SIZE/2
        self.center_y = self.globalRadius * yUnit + SCREEN_SIZE/2

        # self.color = arcade.color_from_hex_string(f"{hex(color[0])}{hex(color[1])}{hex(color[2])}")
        self.color = color

    def draw(self):
        arcade.draw_circle_filled(self.center_x,
                                    self.center_y,
                                    self.radius,
                                    self.color)

    def drawCommand(self):
        return arcade.create_ellipse_filled(self.center_x,
                                    self.center_y,
                                    self.radius*2,
                                    self.radius*2,
                                    self.color)

class Arm:
    def __init__(self, numLEDs) -> None:
        self.numLEDs = numLEDs
        self.pixels = []
        self.shape_list = arcade.ShapeElementList()

        self.syncAngle = 0

        for i in range(self.numLEDs):
            circWidth = (SCREEN_SIZE/2) / self.numLEDs
            pixel = Pixel(radius=circWidth/2, globalRadius=((i + 1) * circWidth - circWidth/2), id=i)            
            pixel.center_x = SCREEN_SIZE/2 + i * circWidth + (circWidth/2)
            pixel.center_y = SCREEN_SIZE/2 
            shape = pixel.drawCommand()
            self.shape_list.append(shape)
            self.pixels.append(pixel)

    def syncPixels(self, syncAngle):
        self.syncAngle = syncAngle
        for pixel in self.pixels:
            pixel.angle = syncAngle

    def draw(self):
        # self.shape_list.draw()
        for pixel in self.pixels:
            pixel : Pixel
            pixel.draw()

    def update(self, pixelCol):
        self.syncAngle = self.syncAngle + 5
        self.syncAngle = self.syncAngle % 360

        xUnit = math.cos(math.radians(-self.syncAngle))
        yUnit = math.sin(math.radians(-self.syncAngle))

        # self.shape_list = arcade.ShapeElementList()

        i = 0
        for pixel in self.pixels:
            pixel : Pixel
            pixel.update(xUnit, yUnit, pixelCol[i])
            # shape = pixel.drawCommand()
            # self.shape_list.append(shape)
            i+=1


class Rotisplay(arcade.Window):
    """ Main application class. """

    def __init__(self, width, height, title):
        super().__init__(width, height, title)
        self.set_update_rate(1.0 / 60.0)

        self.LEDperArm = 64

        self.arms = []

        self.numArms = 4

        self.addArms(self.numArms)

        # Set background color
        self.background_color = BACKGROUND_COLOR

        self.imgData = None

    def loadImageData(self, imageData):
        self.imgData = imageData

    def addArms(self, numArms):
        for _ in range(numArms):
            self.addArm()

    def addArm(self):
        self.arms.append(Arm(self.LEDperArm))
        for arm, angle in zip(self.arms, range(0, 360, 360//(len(self.arms)))):
            arm: Arm
            angle: int

            arm.syncPixels(angle)


    def on_update(self, delta_time):
        # Move the pixels
        for arm in self.arms:
            arm: Arm
            arm.update(self.imgData[arm.syncAngle])

    def on_draw(self):
        """ Render the screen. """

        # Clear screen
        self.clear()

        # Draw the pixels
        arcade.draw_circle_outline(SCREEN_SIZE/2, SCREEN_SIZE/2, 3, arcade.color.WHITE)
        for arm in self.arms:
            arm.draw()


def main():
    """ Main function """
    processor = ImageProcessor(64, "bigImage.jpg")
    dataList = processor.getImageData()
    rotisplay = Rotisplay(SCREEN_SIZE, SCREEN_SIZE, SCREEN_TITLE)
    rotisplay.loadImageData(dataList)
    arcade.run()


if __name__ == "__main__":
    main()