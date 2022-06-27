#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import cv2

filename= r'yuv444.yuv'
yuv_file = open(filename, 'rb')
frame_len = 640*480*3
shape = (480, 640, 3)
raw = yuv_file.read(int(frame_len))

yuv = np.frombuffer(raw, dtype=np.uint8)
yuv = yuv.reshape(shape)

# bgr = cv2.cvtColor(yuv,cv2.COLOR_YUV2BGR)
# bgr = cv2.cvtColor(yuv,cv2.COLOR_YCrCb2RGB)
bgr = cv2.cvtColor(yuv,cv2.COLOR_YCrCb2BGR)
cv2.imshow("YUV2BGR", bgr)
while True:
    if cv2.waitKey(0) == 27: # esc
        cv2.destroyWindow('YUV2BGR')
        break;



