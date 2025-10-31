---
title: "Analyzing Lake Nasser Satellite Imagery with Google Earth Engine and MODIS Data"
date: 2024-11-02 10:00:00 +0200
categories: [GIS, Remote Sensing, Python]
tags: [gee, google-earth-engine, modis, satellite-imagery, geemap, lake-nasser, time-series, python]
image:
  path: /assets/images/MODIS_Project/MOD.gif
  alt: Lake Nasser Time Series Analysis
---

I wanted to understand how the surface of Lake Nasser has changed over time, so I decided to build a small Python workflow using Google Earth Engine (GEE) and the geemap library. The idea was to collect satellite imagery, process it, and turn it into a GIF showing the temporal changes across the years.

---

## Step 1: Setting up and authenticating GEE

The first thing I did was authenticate my Google Earth Engine account and initialize it using:

```python
ee.Authenticate()
ee.Initialize(project='###')
```

Once that was done, I defined the time window for my study — from January 1, 2000, to August 1, 2023. I used `pandas` for date handling and generated a yearly list of timestamps to iterate through.

```python
start_date = pd.to_datetime('2000-01-01')
end_date = pd.to_datetime('2023-08-01')
dates_list = pd.date_range(start='2000-08-01', freq='YS-AUG', periods=24)
```

If you want to go even further back, like to 1979, you can switch from MODIS to Landsat 8 — it has better spatial detail for older periods.

---

## Step 2: Preparing the geographic data

Next, I needed to define the area of interest. For Lake Nasser, I used coordinates roughly around latitude 22.833 and longitude 32.500.

```python
lat, lon = 22.833, 32.500
point = ee.Geometry.Point([lon, lat]).buffer(distance=5000)
```

Then, I selected the MODIS collection `MODIS/061/MOD09GA`, which contains surface reflectance data. I focused on three key bands — red (`b02`), green (`b04`), and blue (`b03`) — to visualize the images in natural color.

```python
bands = ['sur_refl_b02', 'sur_refl_b04', 'sur_refl_b03']
```

---

## Step 3: Collecting and processing the images

Here, I looped over my date list and for each timestamp grabbed the first available MODIS image over the region.

```python
image_collection = []
for date in dates_list:
    MOD = ee.ImageCollection('MODIS/061/MOD09GA')\
            .filterDate(start=date)\
            .filterBounds(point)
    image_collection.append(ee.Image(MOD.first()))
```

I also defined a small rectangular region of interest (ROI) around the lake and visualization parameters:

```python
roi = ee.Geometry.Rectangle([32.3, 22.7, 32.7, 22.9])
visual_params = {'min': -100.0, 'max': 8000.0}
```

With these, I could visualize any of the images on a map using `geemap.Map()` and quickly check if my area and colors looked correct.

---

## Step 4: Building a time series and visual outputs

After confirming the data, I turned the image collection into a time series using `geemap.create_timeseries()`. This made it easy to loop through all images with consistent temporal spacing.

```python
col = geemap.create_timeseries(
    ee.ImageCollection(image_collection),
    start_date='2000-01-01',
    end_date='2023-08-01',
    region=roi,
    bands=bands
)
```

I then visualized each image, applied my visualization parameters, and stored the frames for generating a GIF.

```python
col = col.select(bands).map(
    lambda img: img.visualize(**visual_params).set({
        'system:time_start': img.get('system:time_start'),
        'system:date': img.get('system:date'),
    })
)
```

To export frames and make a GIF:

```python
geemap.get_image_collection_thumbnails(
    col,
    './MOD',
    vis_params={'min': 0, 'max': 255, 'bands': ['sur_refl_b02', 'sur_refl_b04', 'sur_refl_b03']},
    dimensions=768
)

geemap.make_gif(
    ['./MOD/' + x for x in os.listdir('./MOD')],
    'MOD.gif',
    fps=2,
    mp4=False,
    clean_up=True
)
```

Finally, I added the dates directly on the GIF frames to make it more informative:

```python
geemap.add_text_to_gif(
    'MOD.gif',
    'MOD.gif',
    text_sequence=[x.strftime('%Y-%m-%d') for x in dates_list],
    font_size=24,
    font_color='white'
)
```

---

## Step 5: The result

At the end, I had a time-lapse GIF showing how Lake Nasser’s water surface changed over more than two decades — a simple but powerful way to visualize environmental change using open satellite data.

It’s fascinating to see how accessible Earth observation has become — with a few lines of Python and some smart tools, you can turn raw satellite data into meaningful visuals.


## Resources

If you want to explore the full code or reuse it, check out these resources:

- **GitHub Project**: [Lake Nasser GEE Analysis](https://github.com/ghonim0007)
- **Geemap Documentation**: [geemap.org](https://geemap.org)
- **Google Earth Engine Guide**: [developers.google.com/earth-engine](https://developers.google.com/earth-engine)
- **MODIS Data**: [MODIS/061/MOD09GA](https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD09GA)

## Next Steps

To extend this analysis:

1. **Calculate NDWI** for precise water detection
2. **Add climate data** (temperature, precipitation)
3. **Compare with dam operations** data
4. **Analyze seasonal patterns** in detail
5. **Create interactive dashboard** with Streamlit

---

**Have you used Google Earth Engine for environmental monitoring? Share your experience in the comments!** 💬
