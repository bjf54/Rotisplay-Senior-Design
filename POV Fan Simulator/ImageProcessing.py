from PIL import Image
import numpy as np
import os

DEBUG = 0

def pol2cart(r, theta):
    theta = np.deg2rad(theta)
    return (r * np.cos(theta), r * np.sin(theta))

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

        # if DEBUG == 1:
        #     test = self.imgData.copy()

        for angle in range (360):
            for mag in range(numberLEDs):
                # the angle needs changed to this for it to display correctly
                x, y = pol2cart(mag, -1*(angle - 90))

                self.circArray[angle, mag] = self.imgData[round(self.numLEDs+x), round(self.numLEDs+y)]
                # if DEBUG == 1:
                #     test[round(numberLEDs+x), round(numberLEDs+y)] = (255,255,255)

        if DEBUG == 1:
            circImg = Image.fromarray(self.circArray)

            circImg.save("circTest.bmp")
            img.save("smallTest.bmp")

            print(f'Size of downsized original image in bytes: \t{os.path.getsize("smallTest.bmp")}')
            print(f'Size of circular image in bytes: \t\t{os.path.getsize("circTest.bmp")}')


    def getImageData(self):
        return self.circArray.tolist()

def main():
    ImageProcessor(64, "bigImage.jpg")

if __name__ == "__main__":
    main()