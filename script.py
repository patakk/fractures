import numpy as np
import random
import tqdm
import cv2

def img_fill(im_in_col, point):  # n = binary image threshold
    im_in_col = im_in_col.copy().astype(np.uint8)
    im_in = im_in_col[:,:,0]
    # Copy the thresholded image.
    im_floodfill = im_in.copy()

    # Mask used to flood filling.
    # Notice the size needs to be 2 pixels than the image.
    h, w = im_in.shape[:2]
    mask = np.zeros((h + 2, w + 2), np.uint8)

    # Floodfill from point (0, 0)
    cv2.floodFill(im_floodfill, mask, point, 0);

    diff = im_in - im_floodfill

    color_fill = np.zeros((h, w, 3))
    sm = np.ones((1,1))
    color_fill[:,:,0] = im_in_col[:,:,0] - diff + (diff/255.*random.random()*255).astype(np.uint8)
    color_fill[:,:,1] = im_in_col[:,:,1] - diff + (diff/255.*random.random()*255).astype(np.uint8)
    color_fill[:,:,2] = im_in_col[:,:,2] - diff + (diff/255.*random.random()*255).astype(np.uint8)

    return color_fill

def main():
    image = cv2.imread('image.png', 0)

    h, w = image.shape

    step = 10

    fi = np.zeros((h, w, 3))
    fi[:,:,0] = image.copy()
    fi[:,:,1] = image.copy()
    fi[:,:,2] = image.copy()
    for y in tqdm.tqdm(range(300, 700, step)):
        for x in tqdm.tqdm(range(300, 700, step)):
            #point = (np.random.randint(300, 700), np.random.randint(300, 700))
            point = (y, x)
            if fi[y, x, 0] == 255:
                fi = img_fill(fi, point)

    while(1):
        cv2.imshow('fi', cv2.resize(fi/255, (500,500)))
        k = cv2.waitKey(33)
        if k==27:    # Esc key to stop
            break

if __name__ == '__main__':
    main()