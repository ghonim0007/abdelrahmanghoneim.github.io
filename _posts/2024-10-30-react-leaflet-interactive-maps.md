---
title: "Building Interactive Maps with React and Leaflet"
date: 2024-10-30 15:00:00 +0200
categories: [Web Development, GIS]
tags: [react, leaflet, javascript, maps, frontend]
---

## Introduction

React and Leaflet make a powerful combination for creating interactive web maps. This guide shows you how to build modern, responsive mapping applications using these technologies.

## Why React + Leaflet?

### Advantages

- **Component-Based** - Reusable map components
- **Fast Rendering** - React's virtual DOM
- **Rich Ecosystem** - Thousands of React packages
- **Mobile-Friendly** - Touch-optimized interactions
- **Open Source** - No API keys or usage limits

## Setup

### Installation

```bash
# Create React app
npx create-react-app my-map-app
cd my-map-app

# Install dependencies
npm install react-leaflet leaflet
```

### Import Leaflet CSS

In `src/index.js` or `src/App.js`:

```javascript
import 'leaflet/dist/leaflet.css';
```

## Basic Map Component

### Simple Map

```jsx
import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';

function MapComponent() {
  const position = [30.0444, 31.2357]; // Cairo coordinates

  return (
    <MapContainer 
      center={position} 
      zoom={13} 
      style={{ height: '100vh', width: '100%' }}
    >
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <Marker position={position}>
        <Popup>
          Cairo, Egypt
        </Popup>
      </Marker>
    </MapContainer>
  );
}

export default MapComponent;
```

## Advanced Features

### Custom Markers

```jsx
import L from 'leaflet';
import { Marker } from 'react-leaflet';

const customIcon = new L.Icon({
  iconUrl: '/marker-icon.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
});

function CustomMarker({ position, title }) {
  return (
    <Marker position={position} icon={customIcon}>
      <Popup>{title}</Popup>
    </Marker>
  );
}
```

### Drawing Shapes

```jsx
import { Circle, Polygon, Polyline } from 'react-leaflet';

function Shapes() {
  const center = [30.0444, 31.2357];
  const polygon = [
    [30.05, 31.23],
    [30.04, 31.24],
    [30.03, 31.23],
  ];

  return (
    <>
      <Circle
        center={center}
        radius={1000}
        pathOptions={{ color: 'red', fillColor: 'red' }}
      />
      <Polygon
        positions={polygon}
        pathOptions={{ color: 'blue' }}
      />
    </>
  );
}
```

### GeoJSON Layer

```jsx
import { GeoJSON } from 'react-leaflet';
import { useState, useEffect } from 'react';

function GeoJSONLayer() {
  const [geoData, setGeoData] = useState(null);

  useEffect(() => {
    fetch('/data/countries.geojson')
      .then(response => response.json())
      .then(data => setGeoData(data));
  }, []);

  const onEachFeature = (feature, layer) => {
    if (feature.properties && feature.properties.name) {
      layer.bindPopup(feature.properties.name);
    }
  };

  return geoData ? (
    <GeoJSON 
      data={geoData} 
      onEachFeature={onEachFeature}
      style={{ color: '#3388ff' }}
    />
  ) : null;
}
```

## Interactive Features

### Click Events

```jsx
import { useMapEvents } from 'react-leaflet';

function MapClickHandler() {
  const [position, setPosition] = useState(null);

  useMapEvents({
    click(e) {
      setPosition(e.latlng);
      console.log('Clicked at:', e.latlng);
    },
  });

  return position ? (
    <Marker position={position}>
      <Popup>You clicked here!</Popup>
    </Marker>
  ) : null;
}
```

### Search Functionality

```jsx
import { useState } from 'react';
import { useMap } from 'react-leaflet';

function SearchControl() {
  const [query, setQuery] = useState('');
  const map = useMap();

  const handleSearch = async () => {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/search?format=json&q=${query}`
    );
    const data = await response.json();
    
    if (data.length > 0) {
      const { lat, lon } = data[0];
      map.flyTo([lat, lon], 13);
    }
  };

  return (
    <div className="search-control">
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search location..."
      />
      <button onClick={handleSearch}>Search</button>
    </div>
  );
}
```

### Clustering Markers

```bash
npm install react-leaflet-cluster
```

```jsx
import MarkerClusterGroup from 'react-leaflet-cluster';

function ClusteredMarkers({ markers }) {
  return (
    <MarkerClusterGroup>
      {markers.map((marker, idx) => (
        <Marker key={idx} position={marker.position}>
          <Popup>{marker.title}</Popup>
        </Marker>
      ))}
    </MarkerClusterGroup>
  );
}
```

## Complete Example: Location Finder

```jsx
import React, { useState } from 'react';
import { 
  MapContainer, 
  TileLayer, 
  Marker, 
  Popup, 
  useMapEvents 
} from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

function LocationMarker() {
  const [position, setPosition] = useState(null);

  useMapEvents({
    click(e) {
      setPosition(e.latlng);
    },
  });

  return position === null ? null : (
    <Marker position={position}>
      <Popup>
        Lat: {position.lat.toFixed(4)}<br />
        Lng: {position.lng.toFixed(4)}
      </Popup>
    </Marker>
  );
}

function App() {
  return (
    <div className="App">
      <h1>Click on the map to add a marker</h1>
      <MapContainer
        center={[30.0444, 31.2357]}
        zoom={10}
        style={{ height: '600px', width: '100%' }}
      >
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; OpenStreetMap contributors'
        />
        <LocationMarker />
      </MapContainer>
    </div>
  );
}

export default App;
```

## Styling

### Custom CSS

```css
.leaflet-container {
  height: 100vh;
  width: 100%;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.search-control {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 1000;
  background: white;
  padding: 10px;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.search-control input {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin-right: 5px;
}

.search-control button {
  padding: 8px 16px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
```

## Performance Optimization

### 1. Memoization

```jsx
import { useMemo } from 'react';

function OptimizedMap({ markers }) {
  const markerComponents = useMemo(
    () => markers.map((m, idx) => (
      <Marker key={idx} position={m.position}>
        <Popup>{m.title}</Popup>
      </Marker>
    )),
    [markers]
  );

  return <>{markerComponents}</>;
}
```

### 2. Lazy Loading

```jsx
import { lazy, Suspense } from 'react';

const MapComponent = lazy(() => import('./MapComponent'));

function App() {
  return (
    <Suspense fallback={<div>Loading map...</div>}>
      <MapComponent />
    </Suspense>
  );
}
```

## Best Practices

1. **Fix Marker Icons** - Leaflet icons may not work correctly in React
2. **Use Refs Carefully** - Access map instance when needed
3. **Cleanup Effects** - Remove event listeners
4. **Optimize Re-renders** - Use React.memo for markers
5. **Handle Errors** - Wrap API calls in try-catch

## Common Issues

### Marker Icons Not Showing

```javascript
import L from 'leaflet';
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

L.Marker.prototype.options.icon = DefaultIcon;
```

## Conclusion

React and Leaflet provide a powerful, flexible solution for building interactive web maps. The component-based architecture of React combined with Leaflet's mapping capabilities creates maintainable and scalable mapping applications.

## Resources

- [React Leaflet Documentation](https://react-leaflet.js.org/)
- [Leaflet Documentation](https://leafletjs.com/)
- [OpenStreetMap](https://www.openstreetmap.org/)
- [Nominatim API](https://nominatim.org/)
