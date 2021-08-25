from PIL import Image, ImageDraw, ImageFont

class ImageEditor:
    """
    Image Editor Class
    """

    def __init__(self):
        """
        Constructor
        """
        pass

    @staticmethod
    def get_image_size(image_path):
        """
        Get image size
        :param image_path:
        :return:
        """
        image = Image.open(image_path)
        return image.size

    @staticmethod
    def resize_image(image_path, new_width=None, new_height=None):
        """
        Resize image
        :param image_path:
        :param new_width:
        :param new_height:
        :return:
        """
        image = Image.open(image_path)
        image_width, image_height = image.size

        if new_width is None and new_height is not None:
            image_width = (image_width * new_height) / image_height
            image_height = new_height
        elif new_width is not None and new_height is None:
            image_height = (image_height * new_width) / image_width
            image_width = new_width
        elif new_width is not None and new_height is not None:
            image_width = new_width
            image_height = new_height

        return image.resize((int(image_width), int(image_height)), Image.ANTIALIAS)

    @staticmethod
    def crop_image(image_path, left, top, right, bottom):
        """
        Crop image
        :param image_path:
        :param left:
        :param top:
        :param right:
        :param bottom:
        :return:
        """
        image = Image.open(image_path)
        image = image.crop((left, top, right, bottom))
        image.save(image_path)

    @staticmethod
    def rotate_image(image_path, angle):
        """
        Rotate image
        :param image_path:
        :param angle:
        :return:
        """
        image = Image.open(image_path)
        image = image.rotate(angle)
        image.save(image_path)
    
    @staticmethod
    def flip_image(image_path, flip_type):
        """
        Flip image
        :param image_path:
        :param flip_type:
        :return:
        """
        image = Image.open(image_path)
        if flip_type == 'FLIP_LEFT_RIGHT':
            image = image.transpose(Image.FLIP_LEFT_RIGHT)
        elif flip_type == 'FLIP_TOP_BOTTOM':
            image = image.transpose(Image.FLIP_TOP_BOTTOM)
        image.save(image_path)
    
    @staticmethod
    def get_image_pixel(image_path, x, y):
        """
        Get image pixel
        :param image_path:
        :param x:
        :param y:
        :return:
        """
        image = Image.open(image_path)
        return image.getpixel((x, y))
    
    @staticmethod
    def add_watermark(image_path, watermark_path, opacity):
        """
        Add watermark to image. The watermark image should be scaled accordingly yto the image size
        :param image_path:
        :param watermark_path:
        :param opacity:
        :return:
        """
        image = Image.open(image_path)
        watermark = Image.open(watermark_path)
        layer = Image.new('RGBA', image.size, (0, 0, 0, 0))
        layer.paste(image, (0, 0))
        layer.paste(watermark, (0, 0), watermark)
        # Apply opacity
        alpha = Image.new('L', layer.size, opacity)
        layer = Image.composite(layer, layer, alpha)
        layer.save(image_path)

    @staticmethod
    def watermark_image_with_text(filename, text, color, fontfamily):
        image = Image.open(filename)
        imageWatermark = Image.new('RGBA', image.size, (255, 255, 255))

        draw = ImageDraw.Draw(imageWatermark)
        
        width, height = image.size
        margin = 10
        font = ImageFont.truetype(fontfamily, int(height / 20))
        textWidth, textHeight = draw.textsize(text, font)
        x = width - textWidth - margin
        y = height - textHeight - margin

        draw.text((x, y), text, color, font)

        return Image.alpha_composite(image, imageWatermark)

    @staticmethod
    def duplicated_image_with_different_name(image, new_image_name):
        """
        Duplicated image with different name
        :return:
        """
        image = Image.open(image)
        image.save(new_image_name)

    @staticmethod
    def create_thumbnail(image_path, new_image_path, size):
        """
        Create thumbnail
        :param image_path:
        :param new_image_path:
        :param size:
        :return:
        """
        image = Image.open(image_path)
        image.thumbnail(size)
        image.save(new_image_path)
        
