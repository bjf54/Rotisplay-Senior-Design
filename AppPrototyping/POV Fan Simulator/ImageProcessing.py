from PIL import Image
import numpy as np
from math import cos, sin, pi
import os

DEBUG = 1

def pol2cart(r, theta):
    theta = theta * (pi / 180)
    return CartesianCords(r * cos(theta), r * sin(theta))

class CartesianCords:
    def __init__(self, x, y) -> None:
        self.x = x
        self.y = y

class ImageProcessor:
    """ 
        numberLEDs: the number of LEDs on a radius of the Rotisplay 
        fpath: the filepath to the full size image to be processed
    """
    def __init__(self, numberLEDs : int, fpath : str) -> None:

        self.numLEDs = numberLEDs

        img = Image.open(fpath).convert("RGB").resize((self.numLEDs*2, self.numLEDs*2))
        self.imgData = np.asarray(img)

        self.circArray = np.zeros(shape=(360,numberLEDs,3), dtype=np.uint8)

        test = None

        if DEBUG == 1:
            test = self.imgData.copy()
            # file = open("text.txt", 'w') 

        for angle in range (360):
            for mag in range(numberLEDs):
                # the angle needs changed to this for it to display correctly
                cartCoords = pol2cart(mag, angle)

                self.circArray[angle, mag] = self.imgData[round(self.numLEDs+cartCoords.y), round(self.numLEDs+cartCoords.x)]
                if DEBUG == 1:
                    
                    # file.write(f"0x{self.circArray[angle, mag][0]:x}{self.circArray[angle, mag][1]:x}{self.circArray[angle, mag][2]:x}\n")
                    test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] = (255,255,255)

        if DEBUG == 1:
            circImg = Image.fromarray(self.circArray)


            # test = 1
            # circImg.show()
            Image.fromarray(test).save("smallTest.png")
            # img.show()

            circImg.save("circTest.png")
            img.save("smallImg.png")

            # print(f'Size of downsized original image in bytes: \t{os.path.getsize("smallTest.bmp")}')
            # print(f'Size of circular image in bytes: \t\t{os.path.getsize("circTest.bmp")}')


    def getImageData(self):
        return self.circArray.tolist()

def main():
    ImageProcessor(64, "Lenna.png")

if __name__ == "__main__":
    main()