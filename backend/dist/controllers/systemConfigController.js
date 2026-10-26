"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSystemConfigs = getSystemConfigs;
exports.updateSystemConfig = updateSystemConfig;
const store_1 = require("../services/store");
async function getSystemConfigs(req, res) {
    await store_1.store.seedInitialData();
    const list = Array.from(store_1.store.configs.values());
    return res.status(200).json({ success: true, count: list.length, data: list });
}
async function updateSystemConfig(req, res) {
    await store_1.store.seedInitialData();
    const { key } = req.params;
    const { value, description } = req.body;
    let config;
    for (const c of store_1.store.configs.values()) {
        if (c.key === key) {
            config = c;
            break;
        }
    }
    if (!config) {
        config = {
            id: `cfg-${Date.now()}`,
            key,
            value: String(value),
            description: description || '',
            updatedAt: new Date().toISOString(),
        };
    }
    else {
        config.value = String(value);
        if (description !== undefined)
            config.description = description;
        config.updatedAt = new Date().toISOString();
    }
    store_1.store.configs.set(config.id, config);
    return res.status(200).json({ success: true, message: 'System configuration updated', data: config });
}
