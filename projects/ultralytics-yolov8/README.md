### Build Apptainer
```apptainer build ultralytics.sif ultralytics.def```

### Build Docker
```docker build -t izone/hpc:ultralytics -f Dockerfile.ultralytics .```

### Push
```docker push izone/hpc:ultralytics```

### build from docker image
```apptainer pull ultralytics.sif docker://izone/hpc:ultralytics```

### Run
```apptainer run --nv ultralytics.sif python -c "import torch;print(torch.cuda.is_available())"```

```apptainer run --nv ultralytics.sif python -c "import ultralytics;ultralytics.checks()"```

-----

* Ultralytics YOLOv8 models:
* YOLOv8n (Nano)
* YOLOv8s (Small)
* YOLOv8m (Medium)
* YOLOv8l (Large)
* YOLOv8x (Extra Large)

#Shared Files on [Google Drive](https://drive.google.com/drive/folders/1pI0ImWiFNpSqaKXAqbDXXV30EueF3LGP)
#Sample code on [Google Colab](https://colab.research.google.com/drive/1QMHip0FLNbRvbP6PXyslwBsfhyDlixZ0?usp=sharing)
-----

## YOLO on CLI
```yolo task=detect mode=predict model=yolov8n.pt conf=0.25 source='image.png' save=True```
```yolo task=segment mode=predict model=yolov8n-seg.pt conf=0.25 source='image.png' save=True```
```yolo task=detect mode=train data={path_file.yaml} epochs=10```

## YOLO on Python
```
from ultralytics import YOLO
model = YOLO('yolov8n.pt')
img = cv2.imread('image.png')
#img = cv2.imread(os.environ['HOME']+'/Music/YOLOv8/cachorros.jpg')
results = model.predict(source=img, conf=0.6)
[ r.boxes.boxes for r in results ] #for r in results: print(r.boxes.boxes)
[ r.boxes.conf for r in results ] #for r in results: print(r.boxes.conf)
result = funcoes_desenho.desenha_caixas(img, results[0].boxes.boxes)
```
### Save Image from array
```
from PIL import Image
im = Image.fromarray(result)
im.save('dogs.png')
```
### Train
```
tee model.yaml <<EoF
path: '/content/dataset/'
train: 'train/'
valid: 'valid/'
test: #optional

nc: 3
names: ["Apple", "Coffe Cup", "Horse"]
EoF
```
```
import os
root_path='/content/'
config_file = os.path.join(root_path, 'model.yaml')

model = YOLO('yolov8n.yaml')
results = model.train(data=config_file, epochs=10, imgsz=640, name='yoloc8n_model', device='0,1')
```
