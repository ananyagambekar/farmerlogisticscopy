import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { CropListing } from '../types';
import { Search, Plus, Filter, Edit3, Trash2, Sprout, AlertCircle, RefreshCw } from 'lucide-react';

export const CropsPage: React.FC = () => {
  const [crops, setCrops] = useState<CropListing[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');

  // Modal states
  const [showAddModal, setShowAddModal] = useState(false);
  const [editingCrop, setEditingCrop] = useState<CropListing | null>(null);
  const [deletingCropId, setDeletingCropId] = useState<string | null>(null);

  // Form fields
  const [formData, setFormData] = useState({
    cropType: '',
    quantityKg: '',
    unit: 'kg',
    askingPricePerKg: '',
    location: '',
    harvestDate: new Date().toISOString().split('T')[0],
    description: '',
  });
  const [formError, setFormError] = useState('');

  const loadCrops = async () => {
    setLoading(true);
    try {
      const res = await api.getCrops({ all: true });
      if (res.success) {
        setCrops(res.data);
      }
    } catch (err: any) {
      console.error('Failed to load crops:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCrops();
  }, []);

  const resetForm = () => {
    setFormData({
      cropType: '',
      quantityKg: '',
      unit: 'kg',
      askingPricePerKg: '',
      location: '',
      harvestDate: new Date().toISOString().split('T')[0],
      description: '',
    });
    setEditingCrop(null);
    setFormError('');
  };

  const handleOpenAdd = () => {
    resetForm();
    setShowAddModal(true);
  };

  const handleOpenEdit = (crop: CropListing) => {
    setEditingCrop(crop);
    setFormData({
      cropType: crop.cropType,
      quantityKg: crop.quantityKg.toString(),
      unit: crop.unit || 'kg',
      askingPricePerKg: crop.askingPricePerKg.toString(),
      location: crop.location,
      harvestDate: crop.harvestDate ? crop.harvestDate.split('T')[0] : new Date().toISOString().split('T')[0],
      description: crop.description || '',
    });
    setFormError('');
    setShowAddModal(true);
  };

  const handleSubmitForm = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');

    if (!formData.cropType.trim() || !formData.quantityKg || !formData.askingPricePerKg || !formData.location.trim()) {
      setFormError('Crop Type, Quantity, Price, and Location are required.');
      return;
    }

    const qVal = parseFloat(formData.quantityKg);
    const pVal = parseFloat(formData.askingPricePerKg);
    if (isNaN(qVal) || qVal <= 0 || isNaN(pVal) || pVal <= 0) {
      setFormError('Quantity and Price must be positive numbers.');
      return;
    }

    try {
      if (editingCrop) {
        await api.updateCrop(editingCrop.id, {
          cropType: formData.cropType.trim(),
          quantityKg: qVal,
          unit: formData.unit,
          askingPricePerKg: pVal,
          location: formData.location.trim(),
          harvestDate: new Date(formData.harvestDate).toISOString(),
          description: formData.description.trim(),
        });
      } else {
        await api.createCrop({
          cropType: formData.cropType.trim(),
          quantityKg: qVal,
          unit: formData.unit,
          askingPricePerKg: pVal,
          location: formData.location.trim(),
          harvestDate: new Date(formData.harvestDate).toISOString(),
          description: formData.description.trim(),
        });
      }
      setShowAddModal(false);
      resetForm();
      loadCrops();
    } catch (err: any) {
      setFormError(err.message || 'Failed to save crop listing.');
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await api.deleteCrop(id);
      setDeletingCropId(null);
      loadCrops();
    } catch (err: any) {
      alert(err.message || 'Failed to delete crop listing.');
    }
  };

  const handleStatusChange = async (id: string, newStatus: string) => {
    try {
      await api.updateCropStatus(id, newStatus);
      loadCrops();
    } catch (err: any) {
      console.error('Failed to update status:', err);
    }
  };

  const filteredCrops = crops.filter((c) => {
    const matchesSearch =
      c.cropType.toLowerCase().includes(search.toLowerCase()) ||
      (c.farmerName && c.farmerName.toLowerCase().includes(search.toLowerCase())) ||
      c.location.toLowerCase().includes(search.toLowerCase());
    const matchesStatus = statusFilter === 'ALL' || c.status.toUpperCase() === statusFilter.toUpperCase();
    return matchesSearch && matchesStatus;
  });

  const getStatusBadge = (status: string) => {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return <span className="bg-emerald-100 text-emerald-800 text-xs font-bold px-2.5 py-1 rounded-full">Available</span>;
      case 'RESERVED':
        return <span className="bg-amber-100 text-amber-800 text-xs font-bold px-2.5 py-1 rounded-full">Reserved</span>;
      case 'SOLD':
        return <span className="bg-blue-100 text-blue-800 text-xs font-bold px-2.5 py-1 rounded-full">Sold</span>;
      case 'CANCELLED':
        return <span className="bg-rose-100 text-rose-800 text-xs font-bold px-2.5 py-1 rounded-full">Cancelled</span>;
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
            <Sprout className="w-7 h-7 text-emerald-600" />
            Crop Listings Management
          </h1>
          <p className="text-sm text-slate-500">Monitor, create, and filter agricultural produce inventory.</p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={loadCrops}
            className="p-2 text-slate-600 hover:bg-slate-100 rounded-lg transition border border-slate-200"
            title="Refresh list"
          >
            <RefreshCw className="w-5 h-5" />
          </button>
          <button
            onClick={handleOpenAdd}
            className="flex items-center space-x-2 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold px-4 py-2.5 rounded-lg transition shadow-sm"
          >
            <Plus className="w-5 h-5" />
            <span>Add Crop Listing</span>
          </button>
        </div>
      </div>

      {/* Filter & Search Bar */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex flex-col md:flex-row gap-4 justify-between items-center">
        <div className="relative flex-1 w-full">
          <Search className="w-5 h-5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by crop name, farmer, or location..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-emerald-500"
          />
        </div>
        <div className="flex items-center space-x-2 w-full md:w-auto">
          <Filter className="w-4 h-4 text-slate-500" />
          <span className="text-xs font-semibold text-slate-500 uppercase">Status:</span>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="bg-slate-50 border border-slate-200 text-sm rounded-lg px-3 py-2 text-slate-700 font-medium focus:outline-none focus:ring-2 focus:ring-emerald-500"
          >
            <option value="ALL">All Statuses</option>
            <option value="AVAILABLE">Available</option>
            <option value="RESERVED">Reserved</option>
            <option value="SOLD">Sold</option>
            <option value="CANCELLED">Cancelled</option>
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-slate-500">Loading crop listings...</div>
        ) : filteredCrops.length === 0 ? (
          <div className="p-12 text-center text-slate-500 space-y-2">
            <Sprout className="w-10 h-10 text-slate-300 mx-auto" />
            <p className="font-semibold text-slate-700">No crop listings match your criteria.</p>
            <p className="text-xs text-slate-400">Try adjusting your search query or filter settings.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-slate-700 text-xs font-semibold uppercase border-b border-slate-200">
                <tr>
                  <th className="py-3.5 px-4">Crop Name</th>
                  <th className="py-3.5 px-4">Farmer</th>
                  <th className="py-3.5 px-4">Quantity</th>
                  <th className="py-3.5 px-4">Price / Unit</th>
                  <th className="py-3.5 px-4">Pickup Location</th>
                  <th className="py-3.5 px-4">Harvest Date</th>
                  <th className="py-3.5 px-4">Status</th>
                  <th className="py-3.5 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredCrops.map((c) => (
                  <tr key={c.id} className="hover:bg-slate-50 transition">
                    <td className="py-3.5 px-4">
                      <div className="font-semibold text-slate-900">{c.cropType}</div>
                      {c.description && <div className="text-xs text-slate-400 line-clamp-1">{c.description}</div>}
                    </td>
                    <td className="py-3.5 px-4 font-medium text-slate-700">{c.farmerName || c.farmerId}</td>
                    <td className="py-3.5 px-4 font-semibold text-slate-900">
                      {c.quantityKg} <span className="text-xs text-slate-500 font-normal">{c.unit || 'kg'}</span>
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-emerald-700">
                      KES {c.askingPricePerKg}
                    </td>
                    <td className="py-3.5 px-4 text-xs font-medium text-slate-700">{c.location}</td>
                    <td className="py-3.5 px-4 text-xs text-slate-500">
                      {c.harvestDate ? new Date(c.harvestDate).toLocaleDateString() : 'N/A'}
                    </td>
                    <td className="py-3.5 px-4">
                      <select
                        value={c.status}
                        onChange={(e) => handleStatusChange(c.id, e.target.value)}
                        className="bg-transparent text-xs font-semibold cursor-pointer border-none focus:outline-none"
                      >
                        <option value="AVAILABLE">AVAILABLE</option>
                        <option value="RESERVED">RESERVED</option>
                        <option value="SOLD">SOLD</option>
                        <option value="CANCELLED">CANCELLED</option>
                      </select>
                      <div className="mt-1">{getStatusBadge(c.status)}</div>
                    </td>
                    <td className="py-3.5 px-4 text-right space-x-2">
                      <button
                        onClick={() => handleOpenEdit(c)}
                        className="p-1.5 text-blue-600 hover:bg-blue-50 rounded-md transition"
                        title="Edit details"
                      >
                        <Edit3 className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => setDeletingCropId(c.id)}
                        className="p-1.5 text-rose-600 hover:bg-rose-50 rounded-md transition"
                        title="Delete listing"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal: Add/Edit Crop */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-6 space-y-4">
            <h2 className="text-xl font-bold text-slate-900">
              {editingCrop ? 'Edit Crop Listing' : 'Create New Crop Listing'}
            </h2>

            {formError && (
              <div className="p-3 bg-rose-50 text-rose-700 border border-rose-200 rounded-lg text-sm flex items-center gap-2">
                <AlertCircle className="w-4 h-4 shrink-0" />
                <span>{formError}</span>
              </div>
            )}

            <form onSubmit={handleSubmitForm} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Crop Name / Type *</label>
                <input
                  type="text"
                  placeholder="e.g. Yellow Maize (Grade A)"
                  value={formData.cropType}
                  onChange={(e) => setFormData({ ...formData, cropType: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-emerald-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Quantity *</label>
                  <input
                    type="number"
                    step="any"
                    placeholder="e.g. 5000"
                    value={formData.quantityKg}
                    onChange={(e) => setFormData({ ...formData, quantityKg: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Unit</label>
                  <select
                    value={formData.unit}
                    onChange={(e) => setFormData({ ...formData, unit: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-emerald-500 bg-white"
                  >
                    <option value="kg">kg</option>
                    <option value="Ton">Ton</option>
                    <option value="Bag">Bag</option>
                    <option value="Crate">Crate</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Expected Price / Unit (KES) *</label>
                <input
                  type="number"
                  step="any"
                  placeholder="e.g. 45"
                  value={formData.askingPricePerKg}
                  onChange={(e) => setFormData({ ...formData, askingPricePerKg: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-emerald-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Pickup Location *</label>
                <input
                  type="text"
                  placeholder="e.g. Nakuru North Farm, Gate 2"
                  value={formData.location}
                  onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-emerald-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Harvest Date</label>
                <input
                  type="date"
                  value={formData.harvestDate}
                  onChange={(e) => setFormData({ ...formData, harvestDate: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-emerald-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Description / Quality Notes</label>
                <textarea
                  rows={2}
                  placeholder="Optional details regarding crop quality, moisture content..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-emerald-500"
                />
              </div>

              <div className="flex justify-end space-x-3 pt-3">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 rounded-lg shadow-sm"
                >
                  {editingCrop ? 'Update Listing' : 'Save Listing'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deletingCropId && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl p-6 max-w-sm w-full space-y-4 text-center">
            <AlertCircle className="w-12 h-12 text-rose-600 mx-auto" />
            <h3 className="text-lg font-bold text-slate-900">Delete Crop Listing</h3>
            <p className="text-xs text-slate-500">Are you sure you want to delete this listing? It will be archived and removed from active marketplace.</p>
            <div className="flex justify-center space-x-3 pt-2">
              <button
                onClick={() => setDeletingCropId(null)}
                className="px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 rounded-lg"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDelete(deletingCropId)}
                className="px-4 py-2 text-sm font-semibold text-white bg-rose-600 hover:bg-rose-700 rounded-lg shadow-sm"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
