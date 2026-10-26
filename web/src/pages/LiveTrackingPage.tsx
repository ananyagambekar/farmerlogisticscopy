import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { TripAssignment, DeliveryStatusLog, DeliveryConfirmation } from '../types';
import { Navigation, MapPin, Activity, CheckCircle, AlertTriangle, ShieldCheck, RefreshCw } from 'lucide-react';

export const LiveTrackingPage: React.FC = () => {
  const [trips, setTrips] = useState<TripAssignment[]>([]);
  const [selectedTrip, setSelectedTrip] = useState<TripAssignment | null>(null);
  const [trackingLogs, setTrackingLogs] = useState<DeliveryStatusLog[]>([]);
  const [deliveryHistory, setDeliveryHistory] = useState<DeliveryConfirmation[]>([]);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);

  async function loadData() {
    try {
      setLoading(true);
      const [tripsRes, historyRes] = await Promise.all([
        api.getTrips(),
        api.getDeliveryHistory(),
      ]);
      setTrips(tripsRes.data);
      setDeliveryHistory(historyRes.data);

      if (tripsRes.data.length > 0 && !selectedTrip) {
        setSelectedTrip(tripsRes.data[0]);
        loadLogs(tripsRes.data[0].id);
      } else if (selectedTrip) {
        loadLogs(selectedTrip.id);
      }
    } catch (err) {
      console.error('Error loading tracking data:', err);
    } finally {
      setLoading(false);
    }
  }

  async function loadLogs(tripId: string) {
    try {
      const res = await api.getTripTrackingLogs(tripId);
      setTrackingLogs(res.data);
    } catch (err) {
      console.error('Error loading logs:', err);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  const handleSelectTrip = (trip: TripAssignment) => {
    setSelectedTrip(trip);
    loadLogs(trip.id);
  };

  const handleStatusChange = async (newStatus: string) => {
    if (!selectedTrip) return;
    try {
      setUpdating(true);
      await api.updateTripStatus(selectedTrip.id, {
        status: newStatus,
        locationName: selectedTrip.origin || 'Operations Control Center',
        notes: `Status updated to ${newStatus} from Web Operations Dashboard`,
      });
      await loadData();
    } catch (err: any) {
      alert(`Failed to update status: ${err.message}`);
    } finally {
      setUpdating(false);
    }
  };

  const getStatusBadge = (status: string) => {
    const s = status.toUpperCase();
    if (s.includes('DELIVERED') || s.includes('COMPLETED')) {
      return 'bg-emerald-100 text-emerald-800 border-emerald-300';
    }
    if (s.includes('TRANSIT') || s.includes('PICKED')) {
      return 'bg-purple-100 text-purple-800 border-purple-300';
    }
    if (s.includes('EN_ROUTE') || s.includes('ASSIGNED')) {
      return 'bg-blue-100 text-blue-800 border-blue-300';
    }
    return 'bg-amber-100 text-amber-800 border-amber-300';
  };

  if (loading && trips.length === 0) {
    return (
      <div className="p-8 text-slate-500 flex items-center space-x-3">
        <RefreshCw className="w-5 h-5 animate-spin text-emerald-600" />
        <span>Loading live tracking & operations board...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 flex items-center gap-2">
            <Activity className="w-6 h-6 text-emerald-600" />
            Live Shipment Tracking & Operations Board
          </h1>
          <p className="text-sm text-slate-500">Real-time GPS status streams, trip timelines, and delivery discrepancy logs.</p>
        </div>
        <button
          onClick={loadData}
          className="flex items-center space-x-2 bg-slate-800 hover:bg-slate-700 text-white px-3 py-2 rounded-lg text-sm font-medium transition"
        >
          <RefreshCw className="w-4 h-4" />
          <span>Refresh Data</span>
        </button>
      </div>

      {/* Main Grid: Active Board & Timeline */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Col: Trips List */}
        <div className="space-y-4">
          <h2 className="text-lg font-semibold text-slate-800 flex items-center gap-2">
            <Navigation className="w-5 h-5 text-indigo-600" />
            Active Dispatch Trips ({trips.length})
          </h2>

          <div className="space-y-3">
            {trips.map((t) => {
              const isSelected = selectedTrip?.id === t.id;
              return (
                <div
                  key={t.id}
                  onClick={() => handleSelectTrip(t)}
                  className={`p-4 rounded-xl border transition cursor-pointer shadow-sm ${
                    isSelected ? 'bg-emerald-50 border-emerald-500 ring-2 ring-emerald-200' : 'bg-white border-slate-200 hover:border-slate-300'
                  }`}
                >
                  <div className="flex justify-between items-start">
                    <div>
                      <span className="font-mono text-xs text-slate-400">#{t.id}</span>
                      <h3 className="font-bold text-slate-900 text-sm mt-0.5">{t.cropName || 'Agricultural Cargo'}</h3>
                    </div>
                    <span className={`text-xs font-bold px-2.5 py-1 rounded-full border ${getStatusBadge(t.status)}`}>
                      {t.status}
                    </span>
                  </div>

                  <div className="mt-3 space-y-1 text-xs text-slate-600">
                    <p className="flex items-center gap-1 font-medium text-slate-800">
                      <span>Driver:</span> {t.driverName || 'David Ochieng'} ({t.vehiclePlate || 'KCF 789X'})
                    </p>
                    <p>Route: {t.origin || 'Nakuru'} ➔ {t.destination || 'Nairobi Hub'}</p>
                    <p className="text-emerald-700 font-semibold">Agreed Price: KES {t.price.toLocaleString()}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Middle & Right Col: Live Timeline & Details */}
        <div className="lg:col-span-2 space-y-6">
          {selectedTrip ? (
            <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6 space-y-6">
              <div className="flex justify-between items-start border-b border-slate-100 pb-4">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-mono px-2 py-0.5 bg-slate-100 text-slate-600 rounded">#{selectedTrip.id}</span>
                    <h2 className="text-xl font-bold text-slate-900">{selectedTrip.cropName || 'Agricultural Produce'}</h2>
                  </div>
                  <p className="text-xs text-slate-500 mt-1">
                    Origin: <span className="font-semibold text-slate-700">{selectedTrip.origin || 'Nakuru North Farm'}</span> ➔ Destination:{' '}
                    <span className="font-semibold text-slate-700">{selectedTrip.destination || 'Nairobi Central Produce Hub'}</span>
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <span className={`text-xs font-bold px-3 py-1 rounded-full border ${getStatusBadge(selectedTrip.status)}`}>
                    {selectedTrip.status}
                  </span>
                </div>
              </div>

              {/* Status Update Quick Bar */}
              <div className="bg-slate-50 p-4 rounded-lg border border-slate-200 flex flex-wrap items-center justify-between gap-3">
                <span className="text-xs font-semibold text-slate-700">Operations Status Progression:</span>
                <div className="flex flex-wrap gap-2">
                  {['ASSIGNED', 'EN_ROUTE_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED', 'DELIVERED'].map((st) => (
                    <button
                      key={st}
                      disabled={updating || selectedTrip.status === st}
                      onClick={() => handleStatusChange(st)}
                      className={`text-xs px-2.5 py-1 rounded font-medium transition ${
                        selectedTrip.status === st
                          ? 'bg-emerald-600 text-white font-bold'
                          : 'bg-white border border-slate-300 text-slate-700 hover:bg-slate-100'
                      }`}
                    >
                      {st}
                    </button>
                  ))}
                </div>
              </div>

              {/* GPS Stream Timeline */}
              <div>
                <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2 mb-4">
                  <MapPin className="w-4 h-4 text-emerald-600" />
                  GPS Tracking History Timeline Stream ({trackingLogs.length} Checkpoints)
                </h3>

                {trackingLogs.length === 0 ? (
                  <p className="text-xs text-slate-400 italic">No GPS tracking logs recorded for this trip yet.</p>
                ) : (
                  <div className="relative border-l-2 border-emerald-500 ml-3 space-y-4 pl-4">
                    {trackingLogs.map((log) => (
                      <div key={log.id} className="relative">
                        <div className="absolute -left-[23px] top-1 w-3.5 h-3.5 rounded-full bg-emerald-500 border-2 border-white ring-2 ring-emerald-200"></div>
                        <div className="bg-slate-50 p-3 rounded-lg border border-slate-200">
                          <div className="flex justify-between items-center text-xs">
                            <span className="font-bold text-slate-900">{log.status}</span>
                            <span className="text-slate-400 font-mono">{log.timestamp ? new Date(log.timestamp).toLocaleTimeString() : ''}</span>
                          </div>
                          <p className="text-xs text-slate-700 mt-1 font-medium">{log.location}</p>
                          {log.notes && <p className="text-xs text-slate-500 mt-0.5">{log.notes}</p>}
                          {log.speed !== undefined && <span className="inline-block mt-1 text-[10px] bg-slate-200 text-slate-700 px-1.5 py-0.5 rounded">Speed: {log.speed} km/h</span>}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          ) : (
            <div className="bg-white p-8 rounded-xl border border-slate-200 text-center text-slate-400">
              Select a trip assignment from the left board to view live operations timeline.
            </div>
          )}

          {/* Delivery Discrepancy & Verification Logs */}
          <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6 space-y-4">
            <h2 className="text-lg font-bold text-slate-800 flex items-center gap-2">
              <ShieldCheck className="w-5 h-5 text-teal-600" />
              Verified Delivery & Discrepancy Audit Log ({deliveryHistory.length})
            </h2>

            {deliveryHistory.length === 0 ? (
              <p className="text-xs text-slate-400 italic">No confirmed delivery receipts logged yet.</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-xs text-left text-slate-600">
                  <thead className="bg-slate-100 text-slate-700 uppercase font-semibold text-[11px]">
                    <tr>
                      <th className="px-3 py-2">Trip ID</th>
                      <th className="px-3 py-2">Crop</th>
                      <th className="px-3 py-2">Received Weight</th>
                      <th className="px-3 py-2">Condition</th>
                      <th className="px-3 py-2">Discrepancy Notes</th>
                      <th className="px-3 py-2">Confirmed At</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {deliveryHistory.map((d) => (
                      <tr key={d.id} className="hover:bg-slate-50">
                        <td className="px-3 py-2 font-mono font-semibold text-slate-900">{d.tripId}</td>
                        <td className="px-3 py-2">{d.cropName || 'Maize (Grade A)'}</td>
                        <td className="px-3 py-2 font-bold text-slate-900">{d.receivedQuantity} kg</td>
                        <td className="px-3 py-2">
                          <span
                            className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                              d.conditionRating === 'EXCELLENT'
                                ? 'bg-emerald-100 text-emerald-800'
                                : d.conditionRating === 'GOOD'
                                ? 'bg-teal-100 text-teal-800'
                                : d.conditionRating === 'ACCEPTABLE'
                                ? 'bg-amber-100 text-amber-800'
                                : 'bg-red-100 text-red-800'
                            }`}
                          >
                            {d.conditionRating}
                          </span>
                        </td>
                        <td className="px-3 py-2 text-slate-500 italic">{d.issueNotes || 'No issues reported'}</td>
                        <td className="px-3 py-2 text-slate-400">{d.confirmedAt ? new Date(d.confirmedAt).toLocaleDateString() : ''}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
