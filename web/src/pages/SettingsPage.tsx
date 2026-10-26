import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { SystemConfig } from '../types';
import { Save } from 'lucide-react';

export const SettingsPage: React.FC = () => {
  const [configs, setConfigs] = useState<SystemConfig[]>([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    async function loadConfigs() {
      try {
        const res = await api.getSystemConfigs();
        setConfigs(res.data);
      } catch (err) {
        console.error('Failed to load configs:', err);
      } finally {
        setLoading(false);
      }
    }
    loadConfigs();
  }, []);

  const handleUpdate = async (key: string, value: string) => {
    try {
      await api.updateSystemConfig(key, value);
      setMessage(`Updated configuration '${key}' successfully`);
      setTimeout(() => setMessage(null), 3000);
    } catch (err: any) {
      alert(`Failed to update config: ${err.message}`);
    }
  };

  if (loading) return <div className="p-8 text-slate-500">Loading system configurations...</div>;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-800">System Configurations</h1>
        <p className="text-sm text-slate-500">Global operational parameters, pricing multipliers, and commission rates.</p>
      </div>

      {message && (
        <div className="bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-2.5 rounded-lg text-sm">
          {message}
        </div>
      )}

      <div className="bg-white rounded-xl shadow-sm border border-slate-200 divide-y divide-slate-100">
        {configs.map((c) => (
          <div key={c.id} className="p-5 flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div className="space-y-1">
              <p className="font-mono font-bold text-sm text-slate-900">{c.key}</p>
              <p className="text-xs text-slate-500">{c.description || 'No description provided'}</p>
            </div>
            <div className="flex items-center space-x-3">
              <input
                type="text"
                defaultValue={c.value}
                onBlur={(e) => handleUpdate(c.key, e.target.value)}
                className="px-3 py-1.5 bg-slate-50 border border-slate-300 rounded-md text-sm font-mono text-slate-800 w-48 outline-none focus:ring-2 focus:ring-emerald-500"
              />
              <button
                onClick={(e) => {
                  const input = e.currentTarget.previousElementSibling as HTMLInputElement;
                  if (input) handleUpdate(c.key, input.value);
                }}
                className="p-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-md transition"
              >
                <Save className="w-4 h-4" />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
