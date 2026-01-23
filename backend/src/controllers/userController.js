const userRepository = require('../repositories/userRepository');
const preferenceRepository = require('../repositories/preferenceRepository');
const interactionRepository = require('../repositories/interactionRepository');
const logger = require('../utils/logger');
const bcrypt = require('bcrypt');

const SALT_ROUNDS = 12;

exports.getProfile = async (req, res, next) => {
    try {
        const user = await userRepository.findById(req.user.id);
        if (!user || user.deleted_at) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        res.status(200).json({ success: true, data: user.toJSON() });
    } catch (err) {
        next(err);
    }
};

exports.updateProfile = async (req, res, next) => {
    try {
        const { username, email } = req.body;
        const updates = {};
        if (username) updates.username = username;
        if (email) updates.email = email;

        // Handle Avatar Upload
        if (req.file) {
            updates.avatar_url = `/uploads/avatars/${req.file.filename}`;
        }

        if (Object.keys(updates).length === 0) {
            return res.status(400).json({ success: false, message: 'No updates provided' });
        }

        await userRepository.update(req.user.id, updates);
        
        const updatedUser = await userRepository.findById(req.user.id);
        res.status(200).json({ 
            success: true, 
            message: 'Profile updated', 
            data: updatedUser.toJSON() 
        });
    } catch (err) {
        next(err);
    }
};

exports.deleteAccount = async (req, res, next) => {
    try {
        // Soft Delete
        await userRepository.softDelete(req.user.id);
        logger.info(`User ${req.user.id} account deactivated`);
        res.status(200).json({ success: true, message: 'Account deactivated successfully' });
    } catch (err) {
        next(err);
    }
};

exports.changePassword = async (req, res, next) => {
    try {
        const { currentPassword, newPassword } = req.body;
        const user = await userRepository.findById(req.user.id);

        const isMatch = await user.verifyPassword(currentPassword);
        if (!isMatch) {
            return res.status(401).json({ success: false, message: 'Incorrect current password' });
        }

        const passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
        await userRepository.updatePassword(user.id, passwordHash);

        logger.info(`User ${user.id} changed password`);
        res.status(200).json({ success: true, message: 'Password changed successfully' });
    } catch (err) {
        next(err);
    }
};

exports.getPreferences = async (req, res, next) => {
    try {
        const prefs = await preferenceRepository.findByUserId(req.user.id);
        // Transform to cleaner object
        const preferences = prefs.reduce((acc, curr) => {
            try {
                acc[curr.category] = JSON.parse(curr.preference_value);
            } catch {
                acc[curr.category] = curr.preference_value;
            }
            return acc;
        }, {});

        res.status(200).json({ success: true, data: preferences });
    } catch (err) {
        next(err);
    }
};

exports.updatePreferences = async (req, res, next) => {
    try {
        const { preferences } = req.body; // Expect array: [{ category: 'theme', value: 'dark' }]
        
        for (const pref of preferences) {
            await preferenceRepository.upsert(req.user.id, pref.category, pref.value);
        }

        res.status(200).json({ success: true, message: 'Preferences updated' });
    } catch (err) {
        next(err);
    }
};

exports.getActivity = async (req, res, next) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        const activity = await interactionRepository.getUserHistory(req.user.id, limit, offset);
        
        res.status(200).json({ 
            success: true, 
            data: activity,
            meta: { page, limit } 
        });
    } catch (err) {
        next(err);
    }
};

exports.searchUsers = async (req, res, next) => {
    try {
        const { q, role, limit = 20, page = 1 } = req.query;
        const offset = (page - 1) * limit;
        
        const users = await userRepository.search({ query: q, role, limit, offset });
        
        res.status(200).json({ 
            success: true, 
            data: users.map(u => new (require('../models/User'))(u).toJSON()),
            meta: { page, limit }
        });
    } catch (err) {
        next(err);
    }
};
