"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCrops = getCrops;
exports.createCrop = createCrop;
exports.updateCrop = updateCrop;
exports.updateCropStatus = updateCropStatus;
exports.deleteCrop = deleteCrop;
const store_1 = require("../services/store");
async function getCrops(req, res) {
    await store_1.store.seedInitialData();
    let cropsList = Array.from(store_1.store.crops.values()).filter(c => !c.isDeleted);
    const user = req.user;
    const { status, search, keyword, farmerId, all } = req.query;
    // Role-based filtering: Farmer sees their own crops unless 'all' is explicitly requested or filtered
    if (user?.role === 'FARMER' && all !== 'true' && !farmerId) {
        cropsList = cropsList.filter(c => c.farmerId === user.userId);
    }
    else if (farmerId) {
        cropsList = cropsList.filter(c => c.farmerId === farmerId);
    }
    // Status filtering
    if (status && typeof status === 'string') {
        const targetStatus = status.toUpperCase();
        cropsList = cropsList.filter(c => c.status === targetStatus);
    }
    // Keyword / search filtering
    const q = (search || keyword);
    if (q && q.trim().length > 0) {
        const term = q.trim().toLowerCase();
        cropsList = cropsList.filter(c => c.cropType.toLowerCase().includes(term) ||
            (c.description && c.description.toLowerCase().includes(term)) ||
            c.location.toLowerCase().includes(term) ||
            (c.farmerName && c.farmerName.toLowerCase().includes(term)));
    }
    return res.status(200).json({ success: true, count: cropsList.length, data: cropsList });
}
async function createCrop(req, res) {
    await store_1.store.seedInitialData();
    const { name, cropType, quantity, quantityKg, unit, harvestDate, expectedPrice, askingPricePerKg, pickupLocation, location, pickupLat, pickupLng, notes, description, } = req.body;
    const finalCropType = cropType || name;
    const finalQty = Number(quantityKg ?? quantity);
    const finalPrice = Number(askingPricePerKg ?? expectedPrice);
    const finalLocation = location || pickupLocation;
    if (!finalCropType || isNaN(finalQty) || finalQty <= 0 || isNaN(finalPrice) || finalPrice <= 0 || !finalLocation) {
        return res.status(400).json({
            success: false,
            message: 'cropType/name, quantity/quantityKg (>0), expectedPrice/askingPricePerKg (>0), and pickupLocation/location are required',
        });
    }
    const farmerId = req.user?.userId || 'usr-farmer-001';
    const farmer = store_1.store.users.get(farmerId);
    const newCrop = {
        id: `crop-${Date.now()}`,
        farmerId,
        farmerName: farmer?.fullName || 'Farmer',
        cropType: finalCropType,
        quantityKg: finalQty,
        unit: unit || 'kg',
        askingPricePerKg: finalPrice,
        location: finalLocation,
        pickupLat: pickupLat ? Number(pickupLat) : undefined,
        pickupLng: pickupLng ? Number(pickupLng) : undefined,
        description: description || notes || '',
        status: 'AVAILABLE',
        harvestDate: harvestDate || new Date().toISOString(),
        isDeleted: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
    };
    store_1.store.crops.set(newCrop.id, newCrop);
    return res.status(201).json({ success: true, message: 'Crop listing created', data: newCrop });
}
async function updateCrop(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const crop = store_1.store.crops.get(id);
    if (!crop || crop.isDeleted) {
        return res.status(404).json({ success: false, message: 'Crop listing not found' });
    }
    const { name, cropType, quantity, quantityKg, unit, harvestDate, expectedPrice, askingPricePerKg, pickupLocation, location, pickupLat, pickupLng, notes, description, status, } = req.body;
    if (cropType || name)
        crop.cropType = cropType || name;
    if (quantityKg !== undefined || quantity !== undefined) {
        crop.quantityKg = Number(quantityKg ?? quantity);
    }
    if (unit)
        crop.unit = unit;
    if (askingPricePerKg !== undefined || expectedPrice !== undefined) {
        crop.askingPricePerKg = Number(askingPricePerKg ?? expectedPrice);
    }
    if (location || pickupLocation)
        crop.location = location || pickupLocation;
    if (pickupLat !== undefined)
        crop.pickupLat = Number(pickupLat);
    if (pickupLng !== undefined)
        crop.pickupLng = Number(pickupLng);
    if (description !== undefined || notes !== undefined)
        crop.description = description ?? notes;
    if (harvestDate)
        crop.harvestDate = harvestDate;
    if (status) {
        const validStatuses = ['AVAILABLE', 'RESERVED', 'SOLD', 'CANCELLED', 'EXPIRED'];
        if (validStatuses.includes(status.toUpperCase())) {
            crop.status = status.toUpperCase();
        }
    }
    crop.updatedAt = new Date().toISOString();
    store_1.store.crops.set(id, crop);
    return res.status(200).json({ success: true, message: 'Crop listing updated successfully', data: crop });
}
async function updateCropStatus(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const { status } = req.body;
    const crop = store_1.store.crops.get(id);
    if (!crop || crop.isDeleted) {
        return res.status(404).json({ success: false, message: 'Crop listing not found' });
    }
    if (status) {
        crop.status = status.toUpperCase();
        crop.updatedAt = new Date().toISOString();
        store_1.store.crops.set(id, crop);
    }
    return res.status(200).json({ success: true, message: 'Crop status updated', data: crop });
}
async function deleteCrop(req, res) {
    await store_1.store.seedInitialData();
    const { id } = req.params;
    const crop = store_1.store.crops.get(id);
    if (!crop || crop.isDeleted) {
        return res.status(404).json({ success: false, message: 'Crop listing not found' });
    }
    crop.isDeleted = true;
    crop.status = 'CANCELLED';
    crop.updatedAt = new Date().toISOString();
    store_1.store.crops.set(id, crop);
    return res.status(200).json({ success: true, message: 'Crop listing deleted/archived successfully' });
}
