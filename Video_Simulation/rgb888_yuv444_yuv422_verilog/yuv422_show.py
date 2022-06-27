import cv2
import numpy as np
# from alive_progress import alive_it
 
#读取YUV格式图像文件
def read_yuv422(image_path, rows, cols):
    """
    :param image_path: 待转换的.yuv图像文件路径
    :param rows: 图像行数
    :param cols: 图像列数
    :return: y,u,v分量
    """
 
    # 创建y分量
    img_y_1 = np.zeros((rows, int(cols/2)), np.uint8)
    img_y_2 = np.zeros((rows, int(cols / 2)), np.uint8)
    img_y = np.zeros((rows, cols), np.uint8)
 
    # 创建u分量
    img_u = np.zeros((rows, int(cols / 2)), np.uint8)
 
    # 创建v分量
    img_v = np.zeros((rows, int(cols / 2)), np.uint8)
 
    # 读取内存中数据
    with open(image_path, 'rb') as reader:
        # for i in alive_it(range(rows)):
        for i in range(rows):
            # for j in alive_it(range(int(cols/2))):
            for j in range(int(cols/2)):
                img_y_1[i, j] = ord(reader.read(1))
                img_u[i, j] = ord(reader.read(1))
                img_y_2[i, j] = ord(reader.read(1))
                img_v[i, j] = ord(reader.read(1))
 
    # for i in alive_it(range(rows)):
    for i in range(rows):
        # for j in alive_it(range(int(cols/2))):
        for j in range(int(cols/2)):
            img_y[i, 2*j] = img_y_1[i, j]
            img_y[i, 2*j+1] = img_y_2[i,j]
 
    return img_y, img_u, img_v
 
#把YUV格式数据转换为RGB格式
def yuv2rgb422(y, u, v):
    """
    :param y: y分量
    :param u: u分量
    :param v: v分量
    :return: rgb格式数据以及r,g,b分量
    """
 
    rows, cols = y.shape[:2]
    
    # 创建r,g,b分量
    r = np.zeros((rows, cols), np.uint8)
    g = np.zeros((rows, cols), np.uint8)
    b = np.zeros((rows, cols), np.uint8)
 
    # for i in alive_it(range(rows)):
    for i in range(rows):
        # for j in alive_it(range(int(cols/2))):
        for j in range(int(cols/2)):
            r[i, 2 * j] = max(0,min(255,y[i, 2 * j] + 1.402 * (v[i, j] - 128)))
            g[i, 2 * j] = max(0,min(255,y[i, 2 * j] - 0.34414 * (u[i, j] - 128) - 0.71414 * (v[i, j] - 128)))
            b[i, 2 * j] = max(0,min(255,y[i, 2 * j] + 1.772 * (u[i, j] - 128)))
 
            r[i, 2 * j+1] = max(0,min(255,y[i, 2 * j+1] + 1.402 * (v[i, j] - 128)))
            g[i, 2 * j+1] = max(0,min(255,y[i, 2 * j+1] - 0.34414 * (u[i, j] - 128) - 0.71414 * (v[i, j] - 128)))
            b[i, 2 * j+1] = max(0,min(255,y[i, 2 * j+1] + 1.772 * (u[i, j] - 128)))
 
    rgb = cv2.merge([r, g, b])
 
    return rgb, r, g, b
 
# img_yuv=read_yuv422("yuv422.yuv",480,640)
 
# cv2.imshow("YUV_Y",img_yuv[0])#显示从文件提取出的Y分量
 
# img_rgb=yuv2rgb422(img_yuv[0],img_yuv[1],img_yuv[2])
 
# cv2.imshow("RGB",img_rgb[0])
 
# cv2.waitKey(0)

filename= r'yuv422.yuv'
yuv_file = open(filename, 'rb')
frame_len = 640*480*3
shape = (480, 640, 2)
raw = yuv_file.read(int(frame_len))

yuv = np.frombuffer(raw, dtype=np.uint8)
yuv = yuv.reshape(shape)

# bgr = cv2.cvtColor(yuv,cv2.COLOR_YUV2RGB_YUYV)
bgr = cv2.cvtColor(yuv,cv2.COLOR_YUV2RGB_UYVY)
cv2.imshow("YUV2BGR", bgr)
while True:
    if cv2.waitKey(0) == 27: # esc
        cv2.destroyWindow('YUV2BGR')
        break;