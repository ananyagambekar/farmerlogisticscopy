import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { Users, Sprout, Truck, Navigation, CheckCircle, TrendingUp } from 'lucide-react';

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState({
    usersCount: 0,
    cropsCount: 0,
    bookingsCount: 0,
    tripsCount: 0,
    vehiclesCount: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        const [u, c, b, t, v] = await Promise.all([
          api.getUsers(),
          api.getCrops(),
          api.getBookings(),
          api.getTrips(),
          api.getVehicles(),
        ]);
        setStats({
          usersCount: u.count || 0,
          cropsCount: c.count || 0,
          bookingsCount: b.count || 0,
          tripsCount: t.count || 0,
          vehiclesCount: v.count || 0,
        });
      } catch (err) {
        console.error('Error loading dashboard stats:', err);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);

  const cards = [
    { title: 'Registered Users', count: stats.usersCount, icon: Users, color: 'bg-blue-500' },
    { title: 'Active Crop Listings', count: stats.cropsCount, icon: Sprout, color: 'bg-emerald-500' },
    { title: 'Transport Bookings', count: stats.bookingsCount, icon: Truck, color: 'bg-amber-500' },
    { title: 'Active Trips', count: stats.tripsCount, icon: Navigation, color: 'bg-purple-500' },
    { title: 'Registered Vehicles', count: stats.vehiclesCount, icon: TrendingUp, color: 'bg-indigo-500' },
  ];

  if (loading) {
    return <div className="p-8 text-slate-500">Loading system overview...</div>;
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-800">System Overview</h1>
        <p className="text-sm text-slate-500">Real-time dynamic agricultural logistics and fleet statistics.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4">
        {cards.map((c, i) => {
          const Icon = c.icon;
          return (
            <div key={i} className="bg-white p-5 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
              <div>
                <p className="text-xs font-semibold text-slate-500 uppercase">{c.title}</p>
                <p className="text-3xl font-extrabold text-slate-800 mt-1">{c.count}</p>
              </div>
              <div className={`${c.color} p-3 rounded-lg text-white shadow-sm`}>
                <Icon className="w-6 h-6" />
              </div>
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
          <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center space-x-2">
            <CheckCircle className="w-5 h-5 text-emerald-600" />
            <span>Role Distribution & Activity</span>
          </h2>
          <div className="space-y-3">
            <div className="flex justify-between items-center text-sm border-b pb-2">
              <span className="font-medium text-slate-600">Farmers</span>
              <span className="font-bold text-emerald-700">Active</span>
            </div>
            <div className="flex justify-between items-center text-sm border-b pb-2">
              <span className="font-medium text-slate-600">Agents & Aggregators</span>
              <span className="font-bold text-emerald-700">Active</span>
            </div>
            <div className="flex justify-between items-center text-sm border-b pb-2">
              <span className="font-medium text-slate-600">Drivers & Transporters</span>
              <span className="font-bold text-emerald-700">Active</span>
            </div>
            <div className="flex justify-between items-center text-sm">
              <span className="font-medium text-slate-600">Produce Receivers / Hubs</span>
              <span className="font-bold text-emerald-700">Active</span>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
          <h2 className="text-lg font-bold text-slate-800 mb-4">Quick Operational Metrics</h2>
          <div className="space-y-4 text-sm">
            <div className="p-3 bg-slate-50 rounded-lg">
              <p className="font-semibold text-slate-700">Dynamic Pricing Engine</p>
              <p className="text-xs text-slate-500 mt-0.5">Base Rate: KES 15.5/km • Market Demand Multiplier: 1.2x</p>
            </div>
            <div className="p-3 bg-slate-50 rounded-lg">
              <p className="font-semibold text-slate-700">Capacity Utilization</p>
              <p className="text-xs text-slate-500 mt-0.5">Average Truck Load: 82% • Backhaul match efficiency: 68%</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
