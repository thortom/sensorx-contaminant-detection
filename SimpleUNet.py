## Lesson 3 CamVid Tiramisu
#%reload_ext autoreload
#%autoreload 2
#%matplotlib inline

from fastai import *
from fastai.vision import *
from fastai.callbacks.hooks import *
import matplotlib.pyplot as plt

path = Path('C:/School/Scripts/BonesPngImages_copy') # TODO: Test using wild card to catch only the images not the masks
                                                     #          or just move the masks to different folder

path.ls()

## Data
images = get_image_files(path)

img_f = images[0]
img = open_image(img_f)
img.show(figsize=(5,5))
plt.show()

def get_y_fn(x): return Path(str(x.parent)+'annot')/x.name

codes = array(['Sky', 'Building', 'Pole', 'Road', 'Sidewalk', 'Tree',
    'Sign', 'Fence', 'Car', 'Pedestrian', 'Cyclist', 'Void'])

mask = open_mask(get_y_fn(img_f))
mask.show(figsize=(5,5), alpha=1)
plt.show()

src_size = np.array(mask.shape[1:])
print(src_size, mask.data)

## Datasets
bs,size = 8,src_size//2

src = (SegmentationItemList.from_folder(path)
       .split_by_folder(valid='val')
       .label_from_func(get_y_fn, classes=codes))

data = (src.transform(get_transforms(), tfm_y=True)
        .databunch(bs=bs, num_workers=0)
        .normalize(imagenet_stats))

data.show_batch(2, figsize=(10,7))
plt.show()

## Model
name2id = {v:k for k,v in enumerate(codes)}
void_code = name2id['Void']

def acc_camvid(input, target):
    target = target.squeeze(1)
    mask = target != void_code
    return (input.argmax(dim=1)[mask]==target[mask]).float().mean()

metrics=acc_camvid
wd=1e-2

learn = unet_learner(data, models.resnet34, metrics=metrics, wd=wd, model_dir='/tmp/models')

lr_find(learn)
learn.recorder.plot()

lr=2e-3

learn.fit_one_cycle(10, slice(lr), pct_start=0.8)

learn.save('stage-1')

learn.load('stage-1')

learn.unfreeze()

lrs = slice(lr/100,lr)

learn.fit_one_cycle(12, lrs, pct_start=0.8)

learn.save('stage-2')

# gc.collect()