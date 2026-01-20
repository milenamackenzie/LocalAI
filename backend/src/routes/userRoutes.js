const express = require('express');
const userController = require('../controllers/userController');
const authenticate = require('../middleware/authMiddleware');
const validate = require('../middleware/validate');
const isAdmin = require('../middleware/adminMiddleware');
const upload = require('../middleware/uploadMiddleware');
const userValidator = require('../validators/userValidator');

const router = express.Router();

router.use(authenticate); // All user routes require authentication

// Profile
router.get('/profile', userController.getProfile);
router.put(
    '/profile', 
    upload.single('avatar'), 
    userValidator.updateProfileValidators, 
    validate, 
    userController.updateProfile
);

// Account
router.delete('/account', userController.deleteAccount);
router.post(
    '/change-password', 
    userValidator.changePasswordValidators, 
    validate, 
    userController.changePassword
);

// Preferences
router.get('/preferences', userController.getPreferences);
router.put(
    '/preferences', 
    userValidator.updatePreferencesValidators, 
    validate, 
    userController.updatePreferences
);

// Activity
router.get('/activity', userController.getActivity);

// Admin Search
router.get(
    '/search', 
    isAdmin, 
    userValidator.searchUserValidators, 
    validate, 
    userController.searchUsers
);

module.exports = router;
