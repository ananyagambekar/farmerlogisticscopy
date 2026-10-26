import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { User } from '../types';
import { Shield, UserCheck, UserX } from 'lucide-react';

export const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchUsers = async () => {
    try {
      const res = await api.getUsers();
      setUsers(res.data);
    } catch (err) {
      console.error('Failed to fetch users:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const toggleStatus = async (user: User) => {
    try {
      await api.updateUserStatus(user.id, !user.isActive);
      fetchUsers();
    } catch (err) {
      console.error('Failed to update user status:', err);
    }
  };

  if (loading) return <div className="p-8 text-slate-500">Loading user accounts...</div>;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">User & Role Management</h1>
          <p className="text-sm text-slate-500">Manage registered Farmers, Agents, Drivers, Receivers and Admins.</p>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
        <table className="w-full text-left text-sm text-slate-600">
          <thead className="bg-slate-50 text-slate-700 text-xs font-semibold uppercase border-b">
            <tr>
              <th className="py-3.5 px-4">Full Name</th>
              <th className="py-3.5 px-4">Phone</th>
              <th className="py-3.5 px-4">Role</th>
              <th className="py-3.5 px-4">Status</th>
              <th className="py-3.5 px-4">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {users.map((u) => (
              <tr key={u.id} className="hover:bg-slate-50">
                <td className="py-3 px-4 font-semibold text-slate-900">{u.fullName}</td>
                <td className="py-3 px-4 font-mono text-xs">{u.phone}</td>
                <td className="py-3 px-4">
                  <span className={`px-2 py-1 text-xs font-bold rounded-full ${
                    u.role === 'ADMIN' ? 'bg-purple-100 text-purple-800' :
                    u.role === 'FARMER' ? 'bg-emerald-100 text-emerald-800' :
                    u.role === 'AGENT' ? 'bg-blue-100 text-blue-800' :
                    u.role === 'DRIVER' ? 'bg-amber-100 text-amber-800' :
                    'bg-slate-100 text-slate-800'
                  }`}>
                    {u.role}
                  </span>
                </td>
                <td className="py-3 px-4">
                  <span className={`px-2 py-0.5 text-xs font-medium rounded ${u.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                    {u.isActive ? 'Active' : 'Disabled'}
                  </span>
                </td>
                <td className="py-3 px-4">
                  {u.role !== 'ADMIN' && (
                    <button
                      onClick={() => toggleStatus(u)}
                      className={`text-xs px-2.5 py-1 rounded font-medium flex items-center space-x-1 ${
                        u.isActive ? 'bg-red-50 text-red-600 hover:bg-red-100' : 'bg-green-50 text-green-600 hover:bg-green-100'
                      }`}
                    >
                      {u.isActive ? <UserX className="w-3.5 h-3.5" /> : <UserCheck className="w-3.5 h-3.5" />}
                      <span>{u.isActive ? 'Deactivate' : 'Activate'}</span>
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
