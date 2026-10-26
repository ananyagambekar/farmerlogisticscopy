import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Users, Sprout, Truck, Navigation, Activity, Settings } from 'lucide-react';

export const Sidebar: React.FC = () => {
  const links = [
    { to: '/', label: 'Dashboard', icon: LayoutDashboard },
    { to: '/users', label: 'Users & Roles', icon: Users },
    { to: '/crops', label: 'Crop Listings', icon: Sprout },
    { to: '/bookings', label: 'Transport Bookings', icon: Truck },
    { to: '/trips', label: 'Trip Assignments', icon: Navigation },
    { to: '/tracking', label: 'Live Tracking Board', icon: Activity },
    { to: '/settings', label: 'System Config', icon: Settings },
  ];

  return (
    <aside className="w-64 bg-slate-900 text-slate-300 min-h-screen p-4 flex flex-col space-y-2 border-r border-slate-800">
      <div className="px-3 py-2 text-xs font-semibold text-slate-500 uppercase tracking-wider">
        Operations Management
      </div>
      <nav className="flex-1 space-y-1">
        {links.map((link) => {
          const Icon = link.icon;
          return (
            <NavLink
              key={link.to}
              to={link.to}
              className={({ isActive }) =>
                `flex items-center space-x-3 px-3 py-2.5 rounded-lg text-sm font-medium transition ${
                  isActive
                    ? 'bg-emerald-600 text-white font-semibold shadow-sm'
                    : 'hover:bg-slate-800 hover:text-white text-slate-400'
                }`
              }
            >
              <Icon className="w-5 h-5" />
              <span>{link.label}</span>
            </NavLink>
          );
        })}
      </nav>
      <div className="p-3 bg-slate-800/60 rounded-lg text-xs text-slate-400 border border-slate-700/50">
        <p className="font-semibold text-slate-300">System Status: Active</p>
        <p className="mt-1">Dynamic Routing Engine v1.0</p>
      </div>
    </aside>
  );
};
