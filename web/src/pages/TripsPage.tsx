import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { TripAssignment, DeliveryStatusLog } from '../types';
import { Navigation, MapPin, Truck, CheckCircle2, RefreshCw } from 'lucide-react';
import { Link } from 'react-router-dom';

export const TripsPage: React.FC = () => {
  const [trips, setTrips] = useState<TripAssignment[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedTripLogs, setSelectedTripLogs] = useState<{ tripId: string; logs: DeliveryStatusLog[] } | null>(null);

  async function loadTrips() {
    try {
      setLoading(true);
      const res = await api.getTrips();
      setTrips(res.data);
    } catch (err) {
      console.error('Failed to load trips:', err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadTrips();
  }, []);

  const handleViewLogs = async (tripId: string) => {
    try {
      const res = await api.getTripTrackingLogs(tripId);
      setSelectedTripLogs({ tripId, logs: res.data });
    } catch (err) {
      alert('Failed to fetch tracking logs');
    }
  };

  const getStatusStyle = (status: string) => {
    switch (status) {
      case 'DELIVERED':
      case 'COMPLETED':
        return 'bg-emerald-100 text-emerald-800 border-emerald-300';
      case 'IN_TRANSIT':
      case 'PICKED_UP':
        return 'bg-purple-100 text-purple-800 border-purple-300';
      case 'EN_ROUTE_PICKUP':
      case 'ASSIGNED':
        return 'bg-blue-100 text-blue-800 border-blue-300';
      default:
        return 'bg-slate-100 text-slate-800 border-slate-300';
    }
  };

  if (loading) {
    return (
      <div className="p-8 text-slate-500 flex items-center space-x-2">
        <RefreshCw className="w-5 h-5 animate-spin text-emerald-600" />
        <span>Loading trip assignments...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 flex items-center gap-2">
            <Navigation className="w-6 h-6 text-emerald-600" />
            Trip Assignments & Fleet Operations
          </h1>
          <p className="text-sm text-slate-500">Real-time driver dispatched trips and delivery progress monitoring.</p>
        </div>
        <Link
          to="/tracking"
          className="bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition flex items-center gap-2 shadow-sm"
        >
          <MapPin className="w-4 h-4" />
          <span>Open Live Tracking Board</span>
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {trips.map((t) => (
          <div key={t.id} className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm space-y-4 hover:border-slate-300 transition">
            <div className="flex justify-between items-center">
              <span className="font-mono text-xs font-semibold text-slate-500 bg-slate-100 px-2 py-0.5 rounded">
                #{t.id}
              </span>
              <span className={`text-xs font-bold px-2.5 py-0.5 rounded-full border ${getStatusStyle(t.status)}`}>
                {t.status}
              </span>
            </div>

            <div className="space-y-2 text-sm">
              <div className="flex items-center justify-between">
                <span className="font-bold text-slate-900 text-base">{t.cropName || 'Maize (Grade A)'}</span>
                <span className="text-xs text-slate-500">{(t.totalWeightKg || 5000).toLocaleString()} kg</span>
              </div>

              <div className="p-3 bg-slate-50 rounded-lg text-xs space-y-1 text-slate-600 border border-slate-100">
                <p className="flex items-center gap-1 font-medium text-slate-800">
                  <Truck className="w-3.5 h-3.5 text-slate-500" />
                  Driver: {t.driverName || 'David Ochieng'} ({t.vehiclePlate || 'KCF 789X'})
                </p>
                <p>Route: <span className="font-medium text-slate-700">{t.origin || 'Nakuru'}</span> ➔ <span className="font-medium text-slate-700">{t.destination || 'Nairobi Hub'}</span></p>
                <p className="text-emerald-700 font-bold">Agreed Compensation: KES {t.price.toLocaleString()}</p>
              </div>
            </div>

            <div className="flex items-center justify-between pt-2 border-t border-slate-100">
              <button
                onClick={() => handleViewLogs(t.id)}
                className="text-xs font-semibold text-indigo-600 hover:text-indigo-800 flex items-center gap-1"
              >
                <CheckCircle2 className="w-3.5 h-3.5" />
                <span>View Timeline History</span>
              </button>

              <Link
                to="/tracking"
                className="text-xs font-bold text-emerald-600 hover:text-emerald-800 flex items-center gap-1"
              >
                <span>Live GPS Board ➔</span>
              </Link>
            </div>
          </div>
        ))}
      </div>

      {/* Timeline Modal */}
      {selectedTripLogs && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl border border-slate-200 shadow-xl max-w-lg w-full p-6 space-y-4">
            <div className="flex justify-between items-center border-b border-slate-100 pb-3">
              <h3 className="font-bold text-slate-900 text-base">Tracking Timeline for #{selectedTripLogs.tripId}</h3>
              <button
                onClick={() => setSelectedTripLogs(null)}
                className="text-slate-400 hover:text-slate-600 font-bold text-lg"
              >
                ✕
              </button>
            </div>

            <div className="max-h-80 overflow-y-auto space-y-3 pr-2">
              {selectedTripLogs.logs.length === 0 ? (
                <p className="text-xs text-slate-400 italic">No tracking updates recorded for this trip.</p>
              ) : (
                selectedTripLogs.logs.map((log) => (
                  <div key={log.id} className="p-3 bg-slate-50 rounded-lg border border-slate-200 text-xs space-y-1">
                    <div className="flex justify-between font-bold text-slate-900">
                      <span>{log.status}</span>
                      <span className="text-slate-400 font-normal">{log.timestamp ? new Date(log.timestamp).toLocaleTimeString() : ''}</span>
                    </div>
                    <p className="text-slate-700">{log.location}</p>
                    {log.notes && <p className="text-slate-500 italic">{log.notes}</p>}
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
