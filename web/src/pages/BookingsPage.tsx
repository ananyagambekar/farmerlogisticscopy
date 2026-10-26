import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { TransportBooking, User, DriverVehicle } from '../types';
import { Truck, Search, Filter, CheckCircle2, XCircle, Navigation, RefreshCw, AlertCircle } from 'lucide-react';

export const BookingsPage: React.FC = () => {
  const [bookings, setBookings] = useState<TransportBooking[]>([]);
  const [drivers, setDrivers] = useState<User[]>([]);
  const [vehicles, setVehicles] = useState<DriverVehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');

  // Dispatch modal
  const [dispatchBooking, setDispatchBooking] = useState<TransportBooking | null>(null);
  const [selectedDriverId, setSelectedDriverId] = useState('');
  const [selectedVehicleId, setSelectedVehicleId] = useState('');
  const [confirmedPrice, setConfirmedPrice] = useState('');
  const [actionError, setActionError] = useState('');

  const loadData = async () => {
    setLoading(true);
    try {
      const [bRes, uRes, vRes] = await Promise.all([
        api.getBookings({ all: true }),
        api.getUsers(),
        api.getVehicles(),
      ]);
      if (bRes.success) setBookings(bRes.data);
      if (uRes.success) setDrivers(uRes.data.filter((u) => u.role === 'DRIVER'));
      if (vRes.success) setVehicles(vRes.data);
    } catch (err) {
      console.error('Failed to load transport bookings data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleOpenDispatch = (b: TransportBooking) => {
    setDispatchBooking(b);
    setSelectedDriverId(drivers.length > 0 ? drivers[0].id : '');
    setSelectedVehicleId(vehicles.length > 0 ? vehicles[0].id : '');
    setConfirmedPrice(b.estimatedCost.toString());
    setActionError('');
  };

  const handleConfirmDispatch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!dispatchBooking) return;
    setActionError('');

    try {
      await api.assignBooking(dispatchBooking.id, {
        driverId: selectedDriverId,
        vehicleId: selectedVehicleId,
        price: parseFloat(confirmedPrice) || dispatchBooking.estimatedCost,
      });
      setDispatchBooking(null);
      loadData();
    } catch (err: any) {
      setActionError(err.message || 'Failed to assign driver and vehicle.');
    }
  };

  const handleStatusUpdate = async (id: string, newStatus: string) => {
    try {
      await api.updateBookingStatus(id, newStatus);
      loadData();
    } catch (err: any) {
      console.error('Failed to update status:', err);
    }
  };

  const filteredBookings = bookings.filter((b) => {
    const matchesSearch =
      b.origin.toLowerCase().includes(search.toLowerCase()) ||
      b.destination.toLowerCase().includes(search.toLowerCase()) ||
      (b.requesterName && b.requesterName.toLowerCase().includes(search.toLowerCase())) ||
      (b.driverName && b.driverName.toLowerCase().includes(search.toLowerCase()));
    const matchesStatus = statusFilter === 'ALL' || b.status.toUpperCase() === statusFilter.toUpperCase();
    return matchesSearch && matchesStatus;
  });

  const getStatusBadge = (status: string) => {
    switch (status.toUpperCase()) {
      case 'REQUESTED':
      case 'PENDING':
        return <span className="bg-amber-100 text-amber-800 text-xs font-bold px-2.5 py-1 rounded-full">Requested</span>;
      case 'ACCEPTED':
        return <span className="bg-blue-100 text-blue-800 text-xs font-bold px-2.5 py-1 rounded-full">Accepted</span>;
      case 'ASSIGNED':
      case 'MATCHED':
        return <span className="bg-purple-100 text-purple-800 text-xs font-bold px-2.5 py-1 rounded-full">Assigned</span>;
      case 'IN_TRANSIT':
        return <span className="bg-indigo-100 text-indigo-800 text-xs font-bold px-2.5 py-1 rounded-full">In Transit</span>;
      case 'DELIVERED':
        return <span className="bg-emerald-100 text-emerald-800 text-xs font-bold px-2.5 py-1 rounded-full">Delivered</span>;
      case 'REJECTED':
      case 'CANCELLED':
        return <span className="bg-rose-100 text-rose-800 text-xs font-bold px-2.5 py-1 rounded-full">{status}</span>;
      default:
        return <span className="bg-slate-100 text-slate-800 text-xs font-bold px-2.5 py-1 rounded-full">{status}</span>;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
            <Truck className="w-7 h-7 text-emerald-600" />
            Transport Bookings & Dispatch Hub
          </h1>
          <p className="text-sm text-slate-500">Manage produce freight requests, review tariffs, and dispatch driver fleet.</p>
        </div>
        <button
          onClick={loadData}
          className="p-2 text-slate-600 hover:bg-slate-100 rounded-lg transition border border-slate-200 self-start md:self-auto"
          title="Refresh"
        >
          <RefreshCw className="w-5 h-5" />
        </button>
      </div>

      {/* Filter & Search */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex flex-col md:flex-row gap-4 justify-between items-center">
        <div className="relative flex-1 w-full">
          <Search className="w-5 h-5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by requester, origin, destination, or assigned driver..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-emerald-500"
          />
        </div>
        <div className="flex items-center space-x-2 w-full md:w-auto">
          <Filter className="w-4 h-4 text-slate-500" />
          <span className="text-xs font-semibold text-slate-500 uppercase">Filter Status:</span>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="bg-slate-50 border border-slate-200 text-sm rounded-lg px-3 py-2 text-slate-700 font-medium focus:outline-none focus:ring-2 focus:ring-emerald-500"
          >
            <option value="ALL">All Statuses</option>
            <option value="REQUESTED">Requested / Pending</option>
            <option value="ACCEPTED">Accepted</option>
            <option value="ASSIGNED">Assigned / Matched</option>
            <option value="IN_TRANSIT">In Transit</option>
            <option value="DELIVERED">Delivered</option>
            <option value="REJECTED">Rejected / Cancelled</option>
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-slate-500">Loading transport bookings...</div>
        ) : filteredBookings.length === 0 ? (
          <div className="p-12 text-center text-slate-500 space-y-2">
            <Truck className="w-10 h-10 text-slate-300 mx-auto" />
            <p className="font-semibold text-slate-700">No transport bookings found.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-slate-700 text-xs font-semibold uppercase border-b border-slate-200">
                <tr>
                  <th className="py-3.5 px-4">Booking ID</th>
                  <th className="py-3.5 px-4">Requester</th>
                  <th className="py-3.5 px-4">Route</th>
                  <th className="py-3.5 px-4">Weight & Vehicle</th>
                  <th className="py-3.5 px-4">Est. Price</th>
                  <th className="py-3.5 px-4">Driver Assignment</th>
                  <th className="py-3.5 px-4">Status</th>
                  <th className="py-3.5 px-4 text-right">Dispatch Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredBookings.map((b) => (
                  <tr key={b.id} className="hover:bg-slate-50 transition">
                    <td className="py-3.5 px-4 font-mono text-xs text-slate-500">{b.id}</td>
                    <td className="py-3.5 px-4 font-semibold text-slate-900">
                      {b.requesterName || b.requesterId}
                    </td>
                    <td className="py-3.5 px-4 text-xs">
                      <div className="font-semibold text-slate-800">{b.origin}</div>
                      <div className="text-slate-400">➔ {b.destination}</div>
                    </td>
                    <td className="py-3.5 px-4">
                      <div className="font-semibold text-slate-900">{b.totalWeightKg} kg</div>
                      <div className="text-xs text-slate-500">{b.vehicleTypeRequired}</div>
                    </td>
                    <td className="py-3.5 px-4 font-bold text-emerald-700">
                      KES {b.estimatedCost}
                    </td>
                    <td className="py-3.5 px-4 text-xs">
                      {b.driverName ? (
                        <div>
                          <span className="font-semibold text-indigo-700">{b.driverName}</span>
                          <span className="block text-slate-400 font-mono">{b.vehiclePlate || 'Assigned'}</span>
                        </div>
                      ) : (
                        <span className="text-slate-400 italic">Unassigned</span>
                      )}
                    </td>
                    <td className="py-3.5 px-4">{getStatusBadge(b.status)}</td>
                    <td className="py-3.5 px-4 text-right space-x-1">
                      <button
                        onClick={() => handleOpenDispatch(b)}
                        className="inline-flex items-center space-x-1 bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-semibold px-3 py-1.5 rounded-lg transition shadow-sm"
                      >
                        <Navigation className="w-3.5 h-3.5" />
                        <span>Dispatch</span>
                      </button>

                      {b.status === 'REQUESTED' || b.status === 'PENDING' ? (
                        <>
                          <button
                            onClick={() => handleStatusUpdate(b.id, 'ACCEPTED')}
                            className="p-1 text-emerald-600 hover:bg-emerald-50 rounded"
                            title="Accept Request"
                          >
                            <CheckCircle2 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleStatusUpdate(b.id, 'REJECTED')}
                            className="p-1 text-rose-600 hover:bg-rose-50 rounded"
                            title="Reject Request"
                          >
                            <XCircle className="w-4 h-4" />
                          </button>
                        </>
                      ) : null}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Dispatch Modal */}
      {dispatchBooking && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl shadow-xl max-w-lg w-full p-6 space-y-4">
            <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
              <Navigation className="w-6 h-6 text-indigo-600" />
              Dispatch Driver & Fleet Vehicle
            </h2>
            <p className="text-xs text-slate-500">
              Booking <span className="font-mono text-slate-700">{dispatchBooking.id}</span> ({dispatchBooking.origin} ➔ {dispatchBooking.destination})
            </p>

            {actionError && (
              <div className="p-3 bg-rose-50 text-rose-700 border border-rose-200 rounded-lg text-sm flex items-center gap-2">
                <AlertCircle className="w-4 h-4 shrink-0" />
                <span>{actionError}</span>
              </div>
            )}

            <form onSubmit={handleConfirmDispatch} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Select Driver</label>
                <select
                  value={selectedDriverId}
                  onChange={(e) => setSelectedDriverId(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500"
                >
                  {drivers.length === 0 && <option value="">No registered drivers found</option>}
                  {drivers.map((d) => (
                    <option key={d.id} value={d.id}>
                      {d.fullName} ({d.phone})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Select Fleet Vehicle</label>
                <select
                  value={selectedVehicleId}
                  onChange={(e) => setSelectedVehicleId(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg text-sm bg-white focus:ring-2 focus:ring-indigo-500"
                >
                  {vehicles.length === 0 && <option value="">No fleet vehicles registered</option>}
                  {vehicles.map((v) => (
                    <option key={v.id} value={v.id}>
                      {v.licensePlate} — {v.vehicleType} ({v.capacityKg} kg capacity)
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Confirmed Fare Price (KES)</label>
                <input
                  type="number"
                  value={confirmedPrice}
                  onChange={(e) => setConfirmedPrice(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg text-sm font-bold text-emerald-800 focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div className="flex justify-end space-x-3 pt-3 border-t">
                <button
                  type="button"
                  onClick={() => setDispatchBooking(null)}
                  className="px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-sm"
                >
                  Assign & Dispatch
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
