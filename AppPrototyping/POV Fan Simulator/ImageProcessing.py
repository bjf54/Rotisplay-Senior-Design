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

        self.testImg = None

        self.circArray = np.zeros(shape=(360,numberLEDs,3), dtype=np.uint8)

        test = None
        imgList = []

        if DEBUG == 1:
            test = self.imgData.copy()
            file = open("pittSeal.txt", 'w') 

        numPixels = 0

        for angle in range (360):
            for mag in range(numberLEDs):
                numPixels += 1
                # the angle needs changed to this for it to display correctly
                cartCoords = pol2cart(-mag, angle)

                self.circArray[angle, mag] = self.imgData[round(self.numLEDs+cartCoords.y), round(self.numLEDs+cartCoords.x)]
                if DEBUG == 1:

                    imgList.append(Image.fromarray(test.copy()))

                    r = f"{self.circArray[angle, mag][0]:x}".zfill(2)
                    g = f"{self.circArray[angle, mag][1]:x}".zfill(2)
                    b = f"{self.circArray[angle, mag][2]:x}".zfill(2)
                    
                    file.write(f"0x{r}{g}{b},\n")

                    # if (test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] == [255,255,255]).all():
                    #     test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] = (255,0,0)
                    # elif (test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] == [255,0,0]).all():
                    #     test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] = (0,255,0)
                    # elif (test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] == [0,255,0]).all():
                    #     test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] = (0,0,255)
                    # elif (test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] == [0,0,255]).all():
                    #     test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] = (255,0,255)
                    # elif (test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] == [255,0,255]).all():
                    #     test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] = (255,255,0)
                    # elif (test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] == [255,255,0]).all():
                    #     test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] = (0,255,255)
                    # else:
                    #     test[round(numberLEDs+cartCoords.y), round(numberLEDs+cartCoords.x)] = (255,255,255)

        print(numPixels)
        if DEBUG == 1:
            circImg = Image.fromarray(self.circArray)

            # imgList[0].save("test.gif", save_all=True, append_images=imgList[1::50], loop=0)
            # imgList[len(imgList)-1].save("lastImg.png")
            # test = 1
            # circImg.show()
            # Image.fromarray(test).save("smallTest.png")
            # img.show()

            circImg.save("circTest.png")
            img.save("smallImg.png")

            # print(f'Size of downsized original image in bytes: \t{os.path.getsize("smallTest.bmp")}')
            # print(f'Size of circular image in bytes: \t\t{os.path.getsize("circTest.bmp")}')


    def getImageData(self):
        return self.circArray.tolist()

def createTestImg(numberLEDs):
    testArr = np.zeros(shape=(numberLEDs * 2,numberLEDs * 2,3), dtype=np.uint8)

    for x in range(numberLEDs+1):
        for y in range(numberLEDs * 2):
            testArr[y, x] = (0,255,0)
    for x in range(numberLEDs, numberLEDs * 2):
        for y in range(numberLEDs * 2):
            testArr[y, x] = (255,0,0)
    # mag = 0
    # sign = 1
    # for angle in range(360):
    #     cartCords = pol2cart(mag, angle)
    #     testArr[round(numberLEDs + cartCords.x), round(numberLEDs + cartCords.y)] = (255,0,0)
    #     mag += sign
    #     if mag >= 64 or mag <= 0:
    #         sign *= -1


    testImg = Image.fromarray(testArr)
    testImg.save("testImg.png")

def main():
    numLEDs = 70
    # createTestImg(numLEDs)
    ImageProcessor(numLEDs, "pittSeal.png")

if __name__ == "__main__":
    main()