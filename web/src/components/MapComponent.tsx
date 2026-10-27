import React, { useEffect, useRef } from 'react';
import L from 'leaflet';

interface MapComponentProps {
  pickupLat?: number;
  pickupLng?: number;
  pickupLabel?: string;
  destLat?: number;
  destLng?: number;
  destLabel?: string;
  driverLat?: number;
  driverLng?: number;
  driverLabel?: string;
}

export const MapComponent: React.FC<MapComponentProps> = ({
  pickupLat = -0.2833, // Nakuru
  pickupLng = 36.0667,
  pickupLabel = 'Nakuru North Farm Pickup',
  destLat = -1.286389, // Nairobi
  destLng = 36.817223,
  destLabel = 'Nairobi Fresh Produce Hub',
  driverLat = -0.7167, // Naivasha
  driverLng = 36.4333,
  driverLabel = 'Driver En Route (David Ochieng - KCF 789X)',
}) => {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<L.Map | null>(null);

  useEffect(() => {
    if (!mapContainerRef.current) return;

    if (mapInstanceRef.current) {
      mapInstanceRef.current.remove();
      mapInstanceRef.current = null;
    }

    const map = L.map(mapContainerRef.current).setView([driverLat, driverLng], 8);
    mapInstanceRef.current = map;

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

    // Custom Icon helper
    const createIcon = (color: string, iconText: string) => {
      return L.divIcon({
        className: 'custom-leaflet-marker',
        html: `<div style="background-color: ${color}; color: white; border-radius: 50%; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-weight: bold; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);">${iconText}</div>`,
        iconSize: [32, 32],
        iconAnchor: [16, 16],
      });
    };

    // Add Markers
    const pickupMarker = L.marker([pickupLat, pickupLng], {
      icon: createIcon('#10b981', 'P'),
    }).addTo(map);
    pickupMarker.bindPopup(`<b>Pickup Point</b><br/>${pickupLabel}`);

    const destMarker = L.marker([destLat, destLng], {
      icon: createIcon('#ef4444', 'D'),
    }).addTo(map);
    destMarker.bindPopup(`<b>Destination</b><br/>${destLabel}`);

    const driverMarker = L.marker([driverLat, driverLng], {
      icon: createIcon('#2563eb', '🚛'),
    }).addTo(map);
    driverMarker.bindPopup(`<b>Live Driver Location</b><br/>${driverLabel}`);

    // Draw Polyline Route
    const routeCoords: [number, number][] = [
      [pickupLat, pickupLng],
      [driverLat, driverLng],
      [destLat, destLng],
    ];
    L.polyline(routeCoords, { color: '#059669', weight: 4, opacity: 0.8, dashArray: '6, 8' }).addTo(map);

    // Fit map bounds to show all markers
    const bounds = L.latLngBounds([
      [pickupLat, pickupLng],
      [destLat, destLng],
      [driverLat, driverLng],
    ]);
    map.fitBounds(bounds, { padding: [40, 40] });

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }
    };
  }, [pickupLat, pickupLng, destLat, destLng, driverLat, driverLng]);

  return (
    <div className="w-full h-80 rounded-xl overflow-hidden border border-slate-200 shadow-sm relative">
      <div ref={mapContainerRef} className="w-full h-full min-h-[320px]" />
    </div>
  );
};
