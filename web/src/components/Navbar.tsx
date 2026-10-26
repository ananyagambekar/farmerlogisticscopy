import React from 'react';
import { User } from '../types';
import { clearToken } from '../services/api';
import { LogOut, Leaf, ShieldCheck } from 'lucide-react';

interface NavbarProps {
  user: User | null;
  onLogout: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ user, onLogout }) => {
  return (
    <header className="bg-emerald-800 text-white shadow-md sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="bg-emerald-600 p-2 rounded-lg">
            <Leaf className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-lg font-bold tracking-tight">Agri-Logistics Operations</h1>
            <p className="text-xs text-emerald-200">Adaptive Transport & Market Hub</p>
          </div>
        </div>

        {user && (
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2 bg-emerald-900/60 px-3 py-1.5 rounded-full border border-emerald-700">
              <ShieldCheck className="w-4 h-4 text-emerald-400" />
              <span className="text-sm font-medium">{user.fullName}</span>
              <span className="text-xs font-semibold px-2 py-0.5 rounded bg-emerald-600 uppercase text-emerald-100">
                {user.role}
              </span>
            </div>

            <button
              onClick={() => {
                clearToken();
                onLogout();
              }}
              className="flex items-center space-x-1 bg-red-600/80 hover:bg-red-600 text-white px-3 py-1.5 rounded-md text-sm font-medium transition"
            >
              <LogOut className="w-4 h-4" />
              <span>Logout</span>
            </button>
          </div>
        )}
      </div>
    </header>
  );
};
