#include <iostream>

#include "bitmap_image.hpp"

int main() {
    bitmap_image img("smallTest.bmp");

    auto width = img.width();
    auto height = img.width();

    std::cout << width << height;

    rgb_t color;

    
    return 0;
}